package com.conservatio.server.routes

import com.conservatio.server.db.ConditionReportsTable
import io.ktor.http.*
import io.ktor.server.auth.*
import io.ktor.server.auth.jwt.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import kotlinx.datetime.Clock
import kotlinx.serialization.Serializable
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.transactions.transaction
import java.util.*

@Serializable
data class CreateReportRequest(
    val id: String? = null,
    val objectId: String,
    val reportType: String,
    val overallCondition: String,
    val examiner: String,
    val examinationDate: String,
    val damageAnnotations: String = "[]",
    val notes: String? = null,
    val recommendations: String? = null,
    val imageIds: List<String> = emptyList()
)

fun Route.reportRoutes() {
    authenticate("auth-jwt") {
        route("/api/reports") {
            get {
                val userId = call.principal<JWTPrincipal>()!!.payload.getClaim("userId").asString()
                val objectId = call.request.queryParameters["objectId"]
                val reports = transaction {
                    val query = ConditionReportsTable.selectAll()
                        .where { ConditionReportsTable.userId eq UUID.fromString(userId) }
                    if (objectId != null) {
                        query.andWhere { ConditionReportsTable.objectId eq UUID.fromString(objectId) }
                    }
                    query.orderBy(ConditionReportsTable.examinationDate, SortOrder.DESC)
                        .map { row ->
                            mapOf(
                                "id" to row[ConditionReportsTable.id].toString(),
                                "objectId" to row[ConditionReportsTable.objectId].toString(),
                                "reportType" to row[ConditionReportsTable.reportType],
                                "overallCondition" to row[ConditionReportsTable.overallCondition],
                                "examiner" to row[ConditionReportsTable.examiner],
                                "examinationDate" to row[ConditionReportsTable.examinationDate].toString(),
                                "notes" to (row[ConditionReportsTable.notes] ?: ""),
                                "recommendations" to (row[ConditionReportsTable.recommendations] ?: ""),
                                "imageIds" to row[ConditionReportsTable.imageIds].split(",").filter { it.isNotBlank() },
                                "createdAt" to row[ConditionReportsTable.createdAt].toString(),
                                "updatedAt" to row[ConditionReportsTable.updatedAt].toString()
                            )
                        }
                }
                call.respond(reports)
            }

            post {
                val userId = call.principal<JWTPrincipal>()!!.payload.getClaim("userId").asString()
                val request = call.receive<CreateReportRequest>()
                val id = request.id?.takeIf { it.isNotBlank() }?.let(UUID::fromString) ?: UUID.randomUUID()
                val now = Clock.System.now()

                transaction {
                    ConditionReportsTable.insert {
                        it[ConditionReportsTable.id] = id
                        it[objectId] = UUID.fromString(request.objectId)
                        it[reportType] = request.reportType
                        it[overallCondition] = request.overallCondition
                        it[examiner] = request.examiner
                        it[examinationDate] = parseApiInstant(request.examinationDate)
                        it[damageAnnotations] = request.damageAnnotations
                        it[notes] = request.notes
                        it[recommendations] = request.recommendations
                        it[imageIds] = request.imageIds.joinToString(",")
                        it[ConditionReportsTable.userId] = UUID.fromString(userId)
                        it[createdAt] = now
                        it[updatedAt] = now
                    }
                }

                call.respond(HttpStatusCode.Created, mapOf("id" to id.toString()))
            }

            delete("/{id}") {
                val userId = call.principal<JWTPrincipal>()!!.payload.getClaim("userId").asString()
                val reportId = call.parameters["id"] ?: throw IllegalArgumentException("Missing id")
                transaction {
                    ConditionReportsTable.deleteWhere {
                        (ConditionReportsTable.id eq UUID.fromString(reportId)) and
                        (ConditionReportsTable.userId eq UUID.fromString(userId))
                    }
                }
                call.respond(HttpStatusCode.NoContent)
            }
        }
    }
}
