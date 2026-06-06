package com.conservatio.server.routes

import at.favre.lib.crypto.bcrypt.BCrypt
import com.conservatio.server.config.ErrorResponse
import com.conservatio.server.config.generateToken
import com.conservatio.server.db.UsersTable
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import kotlinx.datetime.Clock
import kotlinx.serialization.Serializable
import org.jetbrains.exposed.sql.insert
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.transactions.transaction
import java.util.*

@Serializable
data class RegisterRequest(val email: String, val password: String, val displayName: String)

@Serializable
data class LoginRequest(val email: String, val password: String)

@Serializable
data class AuthResponse(
    val token: String,
    val userId: String,
    val email: String,
    val displayName: String,
    val storageUsedBytes: Long = 0,
    val storageLimitBytes: Long = 2_147_483_648,
)

fun Route.authRoutes() {
    route("/api/auth") {
        post("/register") {
            val request = call.receive<RegisterRequest>()
            val existing = transaction {
                UsersTable.selectAll().where { UsersTable.email eq request.email }.firstOrNull()
            }
            if (existing != null) {
                call.respond(HttpStatusCode.Conflict, ErrorResponse("Email already registered", 409))
                return@post
            }

            val passwordHash = BCrypt.withDefaults().hashToString(12, request.password.toCharArray())
            val userId = UUID.randomUUID()
            val now = Clock.System.now()

            transaction {
                UsersTable.insert {
                    it[id] = userId
                    it[email] = request.email
                    it[UsersTable.passwordHash] = passwordHash
                    it[displayName] = request.displayName
                    it[createdAt] = now
                    it[updatedAt] = now
                }
            }

            val config = call.application.environment.config
            val token = generateToken(
                userId = userId.toString(),
                email = request.email,
                secret = config.property("jwt.secret").getString(),
                issuer = config.property("jwt.issuer").getString(),
                audience = config.property("jwt.audience").getString(),
                expirationMs = config.property("jwt.expiration").getString().toLong()
            )

            val defaultQuota = call.application.environment.config
                .property("storage.defaultQuotaBytes").getString().toLong()
            call.respond(
                HttpStatusCode.Created,
                AuthResponse(
                    token = token,
                    userId = userId.toString(),
                    email = request.email,
                    displayName = request.displayName,
                    storageUsedBytes = 0,
                    storageLimitBytes = defaultQuota,
                )
            )
        }

        post("/login") {
            val request = call.receive<LoginRequest>()
            val user = transaction {
                UsersTable.selectAll().where { UsersTable.email eq request.email }.firstOrNull()
            } ?: run {
                call.respond(HttpStatusCode.Unauthorized, ErrorResponse("Invalid credentials", 401))
                return@post
            }

            val passwordHash = user[UsersTable.passwordHash]
            val verified = BCrypt.verifyer().verify(request.password.toCharArray(), passwordHash).verified
            if (!verified) {
                call.respond(HttpStatusCode.Unauthorized, ErrorResponse("Invalid credentials", 401))
                return@post
            }

            val config = call.application.environment.config
            val token = generateToken(
                userId = user[UsersTable.id].toString(),
                email = user[UsersTable.email],
                secret = config.property("jwt.secret").getString(),
                issuer = config.property("jwt.issuer").getString(),
                audience = config.property("jwt.audience").getString(),
                expirationMs = config.property("jwt.expiration").getString().toLong()
            )

            call.respond(
                AuthResponse(
                    token = token,
                    userId = user[UsersTable.id].toString(),
                    email = user[UsersTable.email],
                    displayName = user[UsersTable.displayName],
                    storageUsedBytes = user[UsersTable.storageUsedBytes],
                    storageLimitBytes = user[UsersTable.storageLimitBytes],
                )
            )
        }
    }
}
