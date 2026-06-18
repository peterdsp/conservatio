package com.conservatio.server.config

import com.zaxxer.hikari.HikariConfig
import com.zaxxer.hikari.HikariDataSource
import io.ktor.server.application.*
import org.jetbrains.exposed.sql.Database
import org.jetbrains.exposed.sql.SchemaUtils
import org.jetbrains.exposed.sql.transactions.TransactionManager
import org.jetbrains.exposed.sql.transactions.transaction
import com.conservatio.server.db.*

fun Application.configureDatabase() {
    val url = environment.config.property("database.url").getString()
    val user = environment.config.property("database.user").getString()
    val password = environment.config.property("database.password").getString()

    val config = HikariConfig().apply {
        jdbcUrl = url
        driverClassName = "org.postgresql.Driver"
        username = user
        this.password = password
        maximumPoolSize = 5
        isAutoCommit = false
        transactionIsolation = "TRANSACTION_REPEATABLE_READ"
        validate()
    }

    Database.connect(HikariDataSource(config))

    transaction {
        SchemaUtils.create(
            UsersTable,
            ConservationObjectsTable,
            ConditionReportsTable,
            ProjectsTable,
            ClientsTable,
            TreatmentProposalsTable
        )
        // Online migration for OAuth columns on the existing users table.
        // SchemaUtils.create is a no-op when the table already exists, so we
        // ALTER it ourselves. Each statement is idempotent.
        val conn = TransactionManager.current().connection
        for (sql in listOf(
            "ALTER TABLE users ADD COLUMN IF NOT EXISTS oauth_provider VARCHAR(32) NULL",
            "ALTER TABLE users ADD COLUMN IF NOT EXISTS oauth_subject VARCHAR(255) NULL",
            "ALTER TABLE users ALTER COLUMN password_hash DROP NOT NULL",
            """
            CREATE UNIQUE INDEX IF NOT EXISTS users_oauth_provider_subject_key
              ON users (oauth_provider, oauth_subject)
              WHERE oauth_provider IS NOT NULL
            """.trimIndent(),
        )) {
            conn.prepareStatement(sql, false).executeUpdate()
        }
    }
}
