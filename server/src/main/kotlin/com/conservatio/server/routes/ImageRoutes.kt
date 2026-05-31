package com.conservatio.server.routes

import io.ktor.http.*
import io.ktor.http.content.*
import io.ktor.server.auth.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import java.io.File
import java.util.*

fun Route.imageRoutes() {
    authenticate("auth-jwt") {
        route("/api/images") {
            post {
                val storagePath = call.application.environment.config.property("storage.path").getString()
                val dir = File(storagePath)
                if (!dir.exists()) dir.mkdirs()

                val multipart = call.receiveMultipart()
                var imageId: String? = null

                multipart.forEachPart { part ->
                    if (part is PartData.FileItem) {
                        val id = UUID.randomUUID().toString()
                        val ext = part.originalFileName?.substringAfterLast('.', "jpg") ?: "jpg"
                        val file = File(dir, "$id.$ext")
                        part.streamProvider().use { input ->
                            file.outputStream().use { output ->
                                input.copyTo(output)
                            }
                        }
                        imageId = "$id.$ext"
                    }
                    part.dispose()
                }

                if (imageId != null) {
                    call.respond(HttpStatusCode.Created, mapOf("imageId" to imageId))
                } else {
                    call.respond(HttpStatusCode.BadRequest, mapOf("error" to "No file uploaded"))
                }
            }

            get("/{imageId}") {
                val storagePath = call.application.environment.config.property("storage.path").getString()
                val imageId = call.parameters["imageId"] ?: throw IllegalArgumentException("Missing imageId")
                val file = File(storagePath, imageId)
                if (!file.exists()) throw NoSuchElementException("Image not found")
                call.respondFile(file)
            }
        }
    }
}
