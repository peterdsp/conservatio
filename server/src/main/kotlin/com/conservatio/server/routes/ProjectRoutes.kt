package com.conservatio.server.routes

import io.ktor.server.auth.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun Route.projectRoutes() {
    authenticate("auth-jwt") {
        route("/api/projects") {
            get {
                call.respond(emptyList<String>())
            }
        }
    }
}
