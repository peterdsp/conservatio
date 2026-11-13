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
        // Online migrations for columns added after the tables first shipped.
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
            // Site location on objects.
            "ALTER TABLE conservation_objects ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION NULL",
            "ALTER TABLE conservation_objects ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION NULL",
            // Previous interventions and examination conditions on reports.
            "ALTER TABLE condition_reports ADD COLUMN IF NOT EXISTS previous_interventions TEXT NULL",
            "ALTER TABLE condition_reports ADD COLUMN IF NOT EXISTS light_source VARCHAR(255) NULL",
            "ALTER TABLE condition_reports ADD COLUMN IF NOT EXISTS relative_humidity DOUBLE PRECISION NULL",
            "ALTER TABLE condition_reports ADD COLUMN IF NOT EXISTS temperature DOUBLE PRECISION NULL",
            "ALTER TABLE condition_reports ADD COLUMN IF NOT EXISTS examination_notes TEXT NULL",
        )) {
            conn.prepareStatement(sql, false).executeUpdate()
        }
    }
}
