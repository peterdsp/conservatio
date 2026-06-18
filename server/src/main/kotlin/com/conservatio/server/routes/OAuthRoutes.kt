package com.conservatio.server.routes

import com.auth0.jwt.JWT
import com.auth0.jwt.algorithms.Algorithm
import com.auth0.jwt.exceptions.JWTDecodeException
import com.conservatio.server.config.ErrorResponse
import com.conservatio.server.config.generateToken
import com.conservatio.server.db.UsersTable
import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.engine.cio.*
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.request.*
import io.ktor.client.request.forms.*
import io.ktor.client.statement.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import kotlinx.datetime.Clock
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.transactions.transaction
import java.security.KeyFactory
import java.security.interfaces.ECPrivateKey
import java.security.spec.PKCS8EncodedKeySpec
import java.time.Instant
import java.util.Base64
import java.util.UUID

@Serializable
data class OAuthExchangeRequest(
    val code: String,
    val redirectUri: String,
    // PKCE verifier for Google/LinkedIn (optional but recommended in SPAs).
    val codeVerifier: String? = null,
)

@Serializable
private data class GoogleTokenResponse(
    @SerialName("access_token") val accessToken: String? = null,
    @SerialName("id_token") val idToken: String? = null,
    val error: String? = null,
    @SerialName("error_description") val errorDescription: String? = null,
)

@Serializable
private data class LinkedInTokenResponse(
    @SerialName("access_token") val accessToken: String? = null,
    val error: String? = null,
    @SerialName("error_description") val errorDescription: String? = null,
)

@Serializable
private data class LinkedInUserInfo(
    val sub: String,
    val email: String? = null,
    val name: String? = null,
    @SerialName("given_name") val givenName: String? = null,
)

@Serializable
private data class AppleTokenResponse(
    @SerialName("id_token") val idToken: String? = null,
    val error: String? = null,
    @SerialName("error_description") val errorDescription: String? = null,
)

private val httpClient by lazy {
    HttpClient(CIO) {
        install(ContentNegotiation) {
            json(Json { ignoreUnknownKeys = true; isLenient = true })
        }
    }
}

fun Route.oauthRoutes() {
    route("/api/auth/oauth") {
        post("/google") { handleGoogle(call) }
        post("/linkedin") { handleLinkedIn(call) }
        post("/apple") { handleApple(call) }
    }
}

private suspend fun handleGoogle(call: ApplicationCall) {
    val request = call.receive<OAuthExchangeRequest>()
    val config = call.application.environment.config
    val clientId = config.propertyOrNull("oauth.google.clientId")?.getString()
    val clientSecret = config.propertyOrNull("oauth.google.clientSecret")?.getString()
    if (clientId.isNullOrBlank() || clientSecret.isNullOrBlank()) {
        call.respond(
            HttpStatusCode.ServiceUnavailable,
            ErrorResponse("Google sign-in is not configured on the server", 503),
        )
        return
    }

    val params = Parameters.build {
        append("code", request.code)
        append("client_id", clientId)
        append("client_secret", clientSecret)
        append("redirect_uri", request.redirectUri)
        append("grant_type", "authorization_code")
        if (!request.codeVerifier.isNullOrBlank()) append("code_verifier", request.codeVerifier)
    }
    val tokenResponse: GoogleTokenResponse = try {
        httpClient.submitForm("https://oauth2.googleapis.com/token", formParameters = params).body()
    } catch (cause: Throwable) {
        call.respond(HttpStatusCode.BadGateway, ErrorResponse("Token exchange failed: ${cause.message}", 502))
        return
    }
    val idToken = tokenResponse.idToken
    if (idToken.isNullOrBlank()) {
        call.respond(
            HttpStatusCode.Unauthorized,
            ErrorResponse(tokenResponse.errorDescription ?: tokenResponse.error ?: "Google rejected the code", 401),
        )
        return
    }

    val claims = decodeIdToken(idToken)
        ?: return call.respond(HttpStatusCode.Unauthorized, ErrorResponse("Invalid Google ID token", 401))
    val email = claims["email"] as? String
    val sub = claims["sub"] as? String
    if (email.isNullOrBlank() || sub.isNullOrBlank()) {
        call.respond(HttpStatusCode.Unauthorized, ErrorResponse("Google did not return an email", 401))
        return
    }
    val name = (claims["name"] as? String)
        ?: (claims["given_name"] as? String)
        ?: email.substringBefore('@')

    respondWithJwt(call, provider = "google", subject = sub, email = email, displayName = name)
}

private suspend fun handleLinkedIn(call: ApplicationCall) {
    val request = call.receive<OAuthExchangeRequest>()
    val config = call.application.environment.config
    val clientId = config.propertyOrNull("oauth.linkedin.clientId")?.getString()
    val clientSecret = config.propertyOrNull("oauth.linkedin.clientSecret")?.getString()
    if (clientId.isNullOrBlank() || clientSecret.isNullOrBlank()) {
        call.respond(
            HttpStatusCode.ServiceUnavailable,
            ErrorResponse("LinkedIn sign-in is not configured on the server", 503),
        )
        return
    }

    val params = Parameters.build {
        append("grant_type", "authorization_code")
        append("code", request.code)
        append("redirect_uri", request.redirectUri)
        append("client_id", clientId)
        append("client_secret", clientSecret)
    }
    val tokenResponse: LinkedInTokenResponse = try {
        httpClient.submitForm("https://www.linkedin.com/oauth/v2/accessToken", formParameters = params).body()
    } catch (cause: Throwable) {
        call.respond(HttpStatusCode.BadGateway, ErrorResponse("Token exchange failed: ${cause.message}", 502))
        return
    }
    val accessToken = tokenResponse.accessToken
    if (accessToken.isNullOrBlank()) {
        call.respond(
            HttpStatusCode.Unauthorized,
            ErrorResponse(tokenResponse.errorDescription ?: tokenResponse.error ?: "LinkedIn rejected the code", 401),
        )
        return
    }

    val info: LinkedInUserInfo = try {
        httpClient.get("https://api.linkedin.com/v2/userinfo") {
            header(HttpHeaders.Authorization, "Bearer $accessToken")
        }.body()
    } catch (cause: Throwable) {
        call.respond(HttpStatusCode.BadGateway, ErrorResponse("LinkedIn userinfo failed: ${cause.message}", 502))
        return
    }
    val email = info.email
    if (email.isNullOrBlank()) {
        call.respond(HttpStatusCode.Unauthorized, ErrorResponse("LinkedIn did not return an email", 401))
        return
    }
    val name = info.name ?: info.givenName ?: email.substringBefore('@')

    respondWithJwt(call, provider = "linkedin", subject = info.sub, email = email, displayName = name)
}

private suspend fun handleApple(call: ApplicationCall) {
    val request = call.receive<OAuthExchangeRequest>()
    val config = call.application.environment.config
    val servicesId = config.propertyOrNull("oauth.apple.clientId")?.getString()
    val teamId = config.propertyOrNull("oauth.apple.teamId")?.getString()
    val keyId = config.propertyOrNull("oauth.apple.keyId")?.getString()
    val privateKeyPem = config.propertyOrNull("oauth.apple.privateKey")?.getString()
    if (servicesId.isNullOrBlank() || teamId.isNullOrBlank() || keyId.isNullOrBlank() || privateKeyPem.isNullOrBlank()) {
        call.respond(
            HttpStatusCode.ServiceUnavailable,
            ErrorResponse("Apple sign-in is not configured on the server", 503),
        )
        return
    }

    val clientSecret = try {
        buildAppleClientSecret(teamId, keyId, servicesId, privateKeyPem)
    } catch (cause: Throwable) {
        call.respond(
            HttpStatusCode.InternalServerError,
            ErrorResponse("Could not build Apple client secret: ${cause.message}", 500),
        )
        return
    }

    val params = Parameters.build {
        append("grant_type", "authorization_code")
        append("code", request.code)
        append("redirect_uri", request.redirectUri)
        append("client_id", servicesId)
        append("client_secret", clientSecret)
    }
    val tokenResponse: AppleTokenResponse = try {
        httpClient.submitForm("https://appleid.apple.com/auth/token", formParameters = params).body()
    } catch (cause: Throwable) {
        call.respond(HttpStatusCode.BadGateway, ErrorResponse("Token exchange failed: ${cause.message}", 502))
        return
    }
    val idToken = tokenResponse.idToken
    if (idToken.isNullOrBlank()) {
        call.respond(
            HttpStatusCode.Unauthorized,
            ErrorResponse(tokenResponse.errorDescription ?: tokenResponse.error ?: "Apple rejected the code", 401),
        )
        return
    }
    val claims = decodeIdToken(idToken)
        ?: return call.respond(HttpStatusCode.Unauthorized, ErrorResponse("Invalid Apple ID token", 401))
    val sub = claims["sub"] as? String
    val email = claims["email"] as? String
    if (sub.isNullOrBlank() || email.isNullOrBlank()) {
        call.respond(HttpStatusCode.Unauthorized, ErrorResponse("Apple did not return an email", 401))
        return
    }
    val name = email.substringBefore('@')

    respondWithJwt(call, provider = "apple", subject = sub, email = email, displayName = name)
}

private fun decodeIdToken(idToken: String): Map<String, Any?>? = try {
    val decoded = JWT.decode(idToken)
    val payload = String(Base64.getUrlDecoder().decode(decoded.payload))
    @Suppress("UNCHECKED_CAST")
    Json.parseToJsonElement(payload).let { element ->
        element.toString().let { json ->
            // Re-parse into a raw map. We avoid a custom serializer to keep
            // this thin: just read string fields we care about.
            val raw = Json.decodeFromString<Map<String, kotlinx.serialization.json.JsonElement>>(json)
            raw.mapValues { (_, value) ->
                value.toString().trim('"').takeUnless { it == "null" }
            }
        }
    }
} catch (_: JWTDecodeException) {
    null
} catch (_: Throwable) {
    null
}

private fun buildAppleClientSecret(
    teamId: String,
    keyId: String,
    servicesId: String,
    privateKeyPem: String,
): String {
    val pkcs8 = privateKeyPem
        .replace("-----BEGIN PRIVATE KEY-----", "")
        .replace("-----END PRIVATE KEY-----", "")
        .replace("\\s".toRegex(), "")
    val keyBytes = Base64.getDecoder().decode(pkcs8)
    val key = KeyFactory.getInstance("EC").generatePrivate(PKCS8EncodedKeySpec(keyBytes)) as ECPrivateKey
    val algorithm = Algorithm.ECDSA256(null, key)
    val now = Instant.now()
    return JWT.create()
        .withKeyId(keyId)
        .withIssuer(teamId)
        .withAudience("https://appleid.apple.com")
        .withSubject(servicesId)
        .withIssuedAt(java.util.Date.from(now))
        .withExpiresAt(java.util.Date.from(now.plusSeconds(60 * 60 * 24 * 180))) // 180 days
        .sign(algorithm)
}

private data class Account(
    val userId: UUID,
    val displayName: String,
    val storageUsedBytes: Long,
    val storageLimitBytes: Long,
)

private suspend fun respondWithJwt(
    call: ApplicationCall,
    provider: String,
    subject: String,
    email: String,
    displayName: String,
) {
    val now = Clock.System.now()
    val defaultQuota = call.application.environment.config
        .property("storage.defaultQuotaBytes").getString().toLong()

    val account = transaction {
        val byOauth = UsersTable.selectAll().where {
            (UsersTable.oauthProvider eq provider) and
                (UsersTable.oauthSubject eq subject)
        }.firstOrNull()
        val existing = byOauth
            ?: UsersTable.selectAll().where { UsersTable.email eq email }.firstOrNull()

        if (existing != null) {
            val existingId = existing[UsersTable.id]
            UsersTable.update({ UsersTable.id eq existingId }) {
                it[oauthProvider] = provider
                it[oauthSubject] = subject
                if (existing[UsersTable.displayName].isBlank()) {
                    it[UsersTable.displayName] = displayName
                }
                it[updatedAt] = now
            }
            val refreshed = UsersTable.selectAll()
                .where { UsersTable.id eq existingId }
                .first()
            Account(
                userId = refreshed[UsersTable.id].value,
                displayName = refreshed[UsersTable.displayName],
                storageUsedBytes = refreshed[UsersTable.storageUsedBytes],
                storageLimitBytes = refreshed[UsersTable.storageLimitBytes],
            )
        } else {
            val newId = UUID.randomUUID()
            UsersTable.insert {
                it[id] = newId
                it[UsersTable.email] = email
                it[passwordHash] = null
                it[UsersTable.displayName] = displayName
                it[oauthProvider] = provider
                it[oauthSubject] = subject
                it[storageUsedBytes] = 0
                it[storageLimitBytes] = defaultQuota
                it[createdAt] = now
                it[updatedAt] = now
            }
            Account(
                userId = newId,
                displayName = displayName,
                storageUsedBytes = 0L,
                storageLimitBytes = defaultQuota,
            )
        }
    }

    val config = call.application.environment.config
    val token = generateToken(
        userId = account.userId.toString(),
        email = email,
        secret = config.property("jwt.secret").getString(),
        issuer = config.property("jwt.issuer").getString(),
        audience = config.property("jwt.audience").getString(),
        expirationMs = config.property("jwt.expiration").getString().toLong(),
    )
    call.respond(
        AuthResponse(
            token = token,
            userId = account.userId.toString(),
            email = email,
            displayName = account.displayName,
            storageUsedBytes = account.storageUsedBytes,
            storageLimitBytes = account.storageLimitBytes,
        )
    )
}
