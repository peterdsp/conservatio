package com.conservatio.server.routes

import at.favre.lib.crypto.bcrypt.BCrypt
import com.conservatio.server.config.ErrorResponse
import com.conservatio.server.config.generateToken
import com.conservatio.server.db.ClientsTable
import com.conservatio.server.db.ConditionReportsTable
import com.conservatio.server.db.ConservationObjectsTable
import com.conservatio.server.db.ProjectsTable
import com.conservatio.server.db.TreatmentProposalsTable
import com.conservatio.server.db.UsersTable
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.auth.*
import io.ktor.server.auth.jwt.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import kotlinx.datetime.Clock
import kotlinx.serialization.Serializable
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.deleteWhere
import org.jetbrains.exposed.sql.insert
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.transactions.transaction
import org.jetbrains.exposed.sql.update
import java.io.File
import java.util.*

@Serializable
data class RegisterRequest(val email: String, val password: String, val displayName: String)

@Serializable
data class LoginRequest(val email: String, val password: String)

@Serializable
data class UpdateProfileRequest(val displayName: String)

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
            if (passwordHash == null) {
                // OAuth-only account  --  no local password to verify against.
                call.respond(
                    HttpStatusCode.Unauthorized,
                    ErrorResponse(
                        "Use the social sign-in for this account",
                        401,
                    ),
                )
                return@post
            }
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

        authenticate("auth-jwt") {
            put("/profile") {
                val principal = call.principal<JWTPrincipal>()!!
                val userId = UUID.fromString(principal.payload.getClaim("userId").asString())
                val request = call.receive<UpdateProfileRequest>()
                val now = Clock.System.now()
                val updated = transaction {
                    UsersTable.update({ UsersTable.id eq userId }) {
                        it[displayName] = request.displayName
                        it[updatedAt] = now
                    }
                }
                if (updated == 0) {
                    call.respond(HttpStatusCode.NotFound, ErrorResponse("User not found", 404))
                    return@put
                }
                call.respond(mapOf("displayName" to request.displayName))
            }

            // Permanently removes the account: uploaded images on disk, every
            // record the user owns, then the user row. There is no undo.
            delete("/account") {
                val principal = call.principal<JWTPrincipal>()!!
                val userId = UUID.fromString(principal.payload.getClaim("userId").asString())
                val storagePath = call.application.environment.config.property("storage.path").getString()

                val exists = transaction {
                    UsersTable.selectAll().where { UsersTable.id eq userId }.firstOrNull() != null
                }
                if (!exists) {
                    call.respond(HttpStatusCode.NotFound, ErrorResponse("User not found", 404))
                    return@delete
                }

                // Image ids referenced by the user's records. Uploads live in the
                // per-user directory; pre-quota uploads sit in the storage root.
                val imageIds = transaction {
                    val fromObjects = ConservationObjectsTable.select(ConservationObjectsTable.imageIds)
                        .where { ConservationObjectsTable.userId eq userId }
                        .map { it[ConservationObjectsTable.imageIds] }
                    val fromReports = ConditionReportsTable.select(ConditionReportsTable.imageIds)
                        .where { ConditionReportsTable.userId eq userId }
                        .map { it[ConditionReportsTable.imageIds] }
                    (fromObjects + fromReports).flatMap { it.split(",") }.filter { it.isNotBlank() }.toSet()
                }
                File(storagePath, userId.toString()).deleteRecursively()
                for (imageId in imageIds) {
                    val legacy = File(storagePath, imageId)
                    // Only plain file names: never follow a path outside the root.
                    if (legacy.parentFile == File(storagePath) && legacy.isFile) legacy.delete()
                }

                transaction {
                    // Children before parents so the foreign keys stay satisfied.
                    TreatmentProposalsTable.deleteWhere { TreatmentProposalsTable.userId eq userId }
                    ConditionReportsTable.deleteWhere { ConditionReportsTable.userId eq userId }
                    ProjectsTable.deleteWhere { ProjectsTable.userId eq userId }
                    ConservationObjectsTable.deleteWhere { ConservationObjectsTable.userId eq userId }
                    ClientsTable.deleteWhere { ClientsTable.userId eq userId }
                    UsersTable.deleteWhere { UsersTable.id eq userId }
                }
                call.respond(HttpStatusCode.NoContent)
            }
        }
    }
}
