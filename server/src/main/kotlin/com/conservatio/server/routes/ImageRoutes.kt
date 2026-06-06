package com.conservatio.server.routes

import com.conservatio.server.db.UsersTable
import io.ktor.http.*
import io.ktor.http.content.*
import io.ktor.server.auth.*
import io.ktor.server.auth.jwt.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import kotlinx.datetime.Clock
import kotlinx.serialization.Serializable
import org.jetbrains.exposed.sql.SqlExpressionBuilder.plus
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.transactions.transaction
import org.jetbrains.exposed.sql.update
import java.io.File
import java.util.*

@Serializable
data class StorageUsageResponse(
    val usedBytes: Long,
    val limitBytes: Long,
    val usedFormatted: String,
    val limitFormatted: String,
    val percentUsed: Double,
)

private fun formatBytes(bytes: Long): String {
    if (bytes < 1024) return "$bytes B"
    val kb = bytes / 1024.0
    if (kb < 1024) return "%.1f KB".format(kb)
    val mb = kb / 1024.0
    if (mb < 1024) return "%.1f MB".format(mb)
    val gb = mb / 1024.0
    return "%.2f GB".format(gb)
}

fun Route.imageRoutes() {
    authenticate("auth-jwt") {
        route("/api/images") {
            post {
                val principal = call.principal<JWTPrincipal>()!!
                val userId = UUID.fromString(principal.payload.getClaim("userId").asString())
                val storagePath = call.application.environment.config.property("storage.path").getString()
                val maxFileSize = call.application.environment.config
                    .property("storage.maxFileSize").getString().toLong()

                // Look up current usage and limit
                val (usedBytes, limitBytes) = transaction {
                    UsersTable.selectAll().where { UsersTable.id eq userId }.first().let {
                        it[UsersTable.storageUsedBytes] to it[UsersTable.storageLimitBytes]
                    }
                }

                // Per-user directory
                val userDir = File(storagePath, userId.toString())
                if (!userDir.exists()) userDir.mkdirs()

                val multipart = call.receiveMultipart()
                var imageId: String? = null
                var fileSize: Long = 0
                var quotaError: String? = null

                multipart.forEachPart { part ->
                    if (part is PartData.FileItem && quotaError == null) {
                        val id = UUID.randomUUID().toString()
                        val ext = part.originalFileName?.substringAfterLast('.', "jpg") ?: "jpg"
                        val tempFile = File(userDir, "$id.$ext.tmp")

                        // Write to temp file first to measure size
                        part.streamProvider().use { input ->
                            tempFile.outputStream().use { output ->
                                input.copyTo(output)
                            }
                        }

                        fileSize = tempFile.length()

                        // Enforce per-file max size
                        if (fileSize > maxFileSize) {
                            tempFile.delete()
                            quotaError = "File too large. Maximum size is ${formatBytes(maxFileSize)}."
                        }
                        // Enforce storage quota
                        else if (usedBytes + fileSize > limitBytes) {
                            tempFile.delete()
                            quotaError = "Storage quota exceeded. You have ${formatBytes(limitBytes - usedBytes)} remaining of ${formatBytes(limitBytes)}."
                        } else {
                            // Commit the file
                            val finalFile = File(userDir, "$id.$ext")
                            tempFile.renameTo(finalFile)
                            imageId = "$id.$ext"
                        }
                    }
                    part.dispose()
                }

                if (quotaError != null) {
                    call.respond(HttpStatusCode.PayloadTooLarge, mapOf("error" to quotaError))
                } else if (imageId != null && fileSize > 0) {
                    // Update user's storage usage
                    transaction {
                        UsersTable.update({ UsersTable.id eq userId }) {
                            it[storageUsedBytes] = storageUsedBytes + fileSize
                            it[updatedAt] = Clock.System.now()
                        }
                    }
                    call.respond(HttpStatusCode.Created, mapOf("imageId" to imageId))
                } else {
                    call.respond(HttpStatusCode.BadRequest, mapOf("error" to "No file uploaded"))
                }
            }

            get("/{imageId}") {
                val principal = call.principal<JWTPrincipal>()!!
                val userId = principal.payload.getClaim("userId").asString()
                val storagePath = call.application.environment.config.property("storage.path").getString()
                val imageId = call.parameters["imageId"]
                    ?: throw IllegalArgumentException("Missing imageId")

                // Look in the user's own directory first, then fall back to shared root
                // (for backwards compatibility with pre-quota images)
                val userFile = File(File(storagePath, userId), imageId)
                val legacyFile = File(storagePath, imageId)
                val file = when {
                    userFile.exists() -> userFile
                    legacyFile.exists() -> legacyFile
                    else -> throw NoSuchElementException("Image not found")
                }

                call.respondFile(file)
            }

            delete("/{imageId}") {
                val principal = call.principal<JWTPrincipal>()!!
                val userId = UUID.fromString(principal.payload.getClaim("userId").asString())
                val storagePath = call.application.environment.config.property("storage.path").getString()
                val imageId = call.parameters["imageId"]
                    ?: throw IllegalArgumentException("Missing imageId")

                val userFile = File(File(storagePath, userId.toString()), imageId)
                val legacyFile = File(storagePath, imageId)
                val file = when {
                    userFile.exists() -> userFile
                    legacyFile.exists() -> legacyFile
                    else -> {
                        call.respond(HttpStatusCode.NotFound, mapOf("error" to "Image not found"))
                        return@delete
                    }
                }

                val fileSize = file.length()
                file.delete()

                // Decrease storage usage
                transaction {
                    val current = UsersTable.selectAll().where { UsersTable.id eq userId }.first()
                    val newUsed = (current[UsersTable.storageUsedBytes] - fileSize).coerceAtLeast(0)
                    UsersTable.update({ UsersTable.id eq userId }) {
                        it[storageUsedBytes] = newUsed
                        it[updatedAt] = Clock.System.now()
                    }
                }

                call.respond(HttpStatusCode.NoContent)
            }
        }

        route("/api/storage") {
            get("/usage") {
                val principal = call.principal<JWTPrincipal>()!!
                val userId = UUID.fromString(principal.payload.getClaim("userId").asString())

                val (usedBytes, limitBytes) = transaction {
                    UsersTable.selectAll().where { UsersTable.id eq userId }.first().let {
                        it[UsersTable.storageUsedBytes] to it[UsersTable.storageLimitBytes]
                    }
                }

                val percent = if (limitBytes > 0) (usedBytes.toDouble() / limitBytes * 100) else 0.0

                call.respond(
                    StorageUsageResponse(
                        usedBytes = usedBytes,
                        limitBytes = limitBytes,
                        usedFormatted = formatBytes(usedBytes),
                        limitFormatted = formatBytes(limitBytes),
                        percentUsed = "%.1f".format(percent).toDouble(),
                    )
                )
            }
        }
    }
}
