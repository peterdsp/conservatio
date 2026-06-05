package com.conservatio.di

import com.conservatio.data.remote.ConservatioApi
import com.conservatio.data.remote.KtorConservatioApi
import io.ktor.client.HttpClient
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.plugins.logging.LogLevel
import io.ktor.client.plugins.logging.Logging
import io.ktor.serialization.kotlinx.json.json
import kotlinx.serialization.json.Json
import org.koin.core.module.Module
import org.koin.dsl.module

val sharedModule: Module = module {
    single {
        HttpClient {
            install(ContentNegotiation) {
                json(Json {
                    ignoreUnknownKeys = true
                    isLenient = true
                    prettyPrint = false
                })
            }
            install(Logging) {
                level = LogLevel.HEADERS
            }
        }
    }

    single<ConservatioApi> {
        KtorConservatioApi(
            client = get(),
            baseUrl = "https://conservatio-api.peterdsp.dev"
        )
    }
}
