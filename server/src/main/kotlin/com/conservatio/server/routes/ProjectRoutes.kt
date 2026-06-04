package com.conservatio.server.routes

import com.conservatio.server.db.ProjectsTable
import io.ktor.http.*
import io.ktor.server.auth.*
import io.ktor.server.auth.jwt.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import kotlinx.datetime.Clock
import kotlinx.datetime.Instant
import kotlinx.serialization.Serializable
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.transactions.transaction
import java.util.UUID

@Serializable
data class CreateProjectRequest(
    val id: String? = null,
    val title: String,
    val clientId: String? = null,
    val objectIds: List<String> = emptyList(),
    val status: String,
    val startDate: String? = null,
    val endDate: String? = null,
    val description: String? = null,
    val totalBudget: Double? = null,
    val currency: String? = null
)

@Serializable
data class ProjectResponse(
    val id: String,
    val title: String,
    val clientId: String? = null,
    val objectIds: List<String>,
    val status: String,
    val startDate: String? = null,
    val endDate: String? = null,
    val description: String? = null,
    val totalBudget: Double? = null,
    val currency: String? = null,
    val createdAt: String,
    val updatedAt: String
)

fun Route.projectRoutes() {
    authenticate("auth-jwt") {
        route("/api/projects") {
            get {
                val userId = call.principal<JWTPrincipal>()!!.payload.getClaim("userId").asString()
                val projects = transaction {
                    ProjectsTable.selectAll()
                        .where { ProjectsTable.userId eq UUID.fromString(userId) }
                        .orderBy(ProjectsTable.updatedAt, SortOrder.DESC)
                        .map { it.toProjectResponse() }
                }
                call.respond(projects)
            }

            post {
                val userId = call.principal<JWTPrincipal>()!!.payload.getClaim("userId").asString()
                val request = call.receive<CreateProjectRequest>()
                val id = request.id?.takeIf { it.isNotBlank() }?.let(UUID::fromString) ?: UUID.randomUUID()
                val now = Clock.System.now()

                transaction {
                    ProjectsTable.insert {
                        it[ProjectsTable.id] = id
                        it[title] = request.title
                        it[clientId] = request.clientId
                            ?.takeIf { value -> value.isNotBlank() }
                            ?.let(UUID::fromString)
                        it[objectIds] = request.objectIds.joinToString(",")
                        it[status] = request.status
                        it[startDate] = request.startDate?.let(::parseApiInstant)
                        it[endDate] = request.endDate?.let(::parseApiInstant)
                        it[description] = request.description
                        it[totalBudget] = request.totalBudget
                        it[currency] = request.currency
                        it[ProjectsTable.userId] = UUID.fromString(userId)
                        it[createdAt] = now
                        it[updatedAt] = now
                    }
                }

                call.respond(
                    HttpStatusCode.Created,
                    ProjectResponse(
                        id = id.toString(),
                        title = request.title,
                        clientId = request.clientId,
                        objectIds = request.objectIds,
                        status = request.status,
                        startDate = request.startDate,
                        endDate = request.endDate,
                        description = request.description,
                        totalBudget = request.totalBudget,
                        currency = request.currency,
                        createdAt = now.toString(),
                        updatedAt = now.toString()
                    )
                )
            }

            delete("/{id}") {
                val userId = call.principal<JWTPrincipal>()!!.payload.getClaim("userId").asString()
                val projectId = call.parameters["id"] ?: throw IllegalArgumentException("Missing id")
                transaction {
                    ProjectsTable.deleteWhere {
                        (ProjectsTable.id eq UUID.fromString(projectId)) and
                            (ProjectsTable.userId eq UUID.fromString(userId))
                    }
                }
                call.respond(HttpStatusCode.NoContent)
            }
        }
    }
}

internal fun parseApiInstant(value: String): Instant =
    if (value.contains("T")) Instant.parse(value) else Instant.parse("${value}T00:00:00Z")

private fun ResultRow.toProjectResponse() = ProjectResponse(
    id = this[ProjectsTable.id].toString(),
    title = this[ProjectsTable.title],
    clientId = this[ProjectsTable.clientId]?.toString(),
    objectIds = this[ProjectsTable.objectIds].split(",").filter { it.isNotBlank() },
    status = this[ProjectsTable.status],
    startDate = this[ProjectsTable.startDate]?.toString(),
    endDate = this[ProjectsTable.endDate]?.toString(),
    description = this[ProjectsTable.description],
    totalBudget = this[ProjectsTable.totalBudget],
    currency = this[ProjectsTable.currency],
    createdAt = this[ProjectsTable.createdAt].toString(),
    updatedAt = this[ProjectsTable.updatedAt].toString()
)
