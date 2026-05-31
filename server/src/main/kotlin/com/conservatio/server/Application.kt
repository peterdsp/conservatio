package com.conservatio.server

import com.conservatio.server.config.configureCors
import com.conservatio.server.config.configureDatabase
import com.conservatio.server.config.configureAuth
import com.conservatio.server.config.configureSerialization
import com.conservatio.server.config.configureStatusPages
import com.conservatio.server.routes.authRoutes
import com.conservatio.server.routes.objectRoutes
import com.conservatio.server.routes.reportRoutes
import com.conservatio.server.routes.projectRoutes
import com.conservatio.server.routes.clientRoutes
import com.conservatio.server.routes.imageRoutes
import io.ktor.server.application.*
import io.ktor.server.netty.*
import io.ktor.server.plugins.calllogging.*
import io.ktor.server.routing.*

fun main(args: Array<String>) = EngineMain.main(args)

fun Application.module() {
    install(CallLogging)

    configureSerialization()
    configureCors()
    configureStatusPages()
    configureDatabase()
    configureAuth()

    routing {
        authRoutes()
        objectRoutes()
        reportRoutes()
        projectRoutes()
        clientRoutes()
        imageRoutes()
    }
}
