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
    val imageIds: List<String> = emptyList(),
    val previousInterventions: String? = null,
    val lightSource: String? = null,
    val relativeHumidity: Double? = null,
    val temperature: Double? = null,
    val examinationNotes: String? = null
)

@Serializable
data class ReportResponse(
    val id: String,
    val objectId: String,
    val reportType: String,
    val overallCondition: String,
    val examiner: String,
    val examinationDate: String,
    val notes: String? = null,
    val recommendations: String? = null,
    val imageIds: List<String>,
    val previousInterventions: String? = null,
    val lightSource: String? = null,
    val relativeHumidity: Double? = null,
    val temperature: Double? = null,
    val examinationNotes: String? = null,
    val createdAt: String,
    val updatedAt: String
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
                        .map { it.toReportResponse() }
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
                        it[previousInterventions] = request.previousInterventions
                        it[lightSource] = request.lightSource
                        it[relativeHumidity] = request.relativeHumidity
                        it[temperature] = request.temperature
                        it[examinationNotes] = request.examinationNotes
                        it[ConditionReportsTable.userId] = UUID.fromString(userId)
                        it[createdAt] = now
                        it[updatedAt] = now
                    }
                }

                call.respond(HttpStatusCode.Created, mapOf("id" to id.toString()))
            }

            put("/{id}") {
                val userId = call.principal<JWTPrincipal>()!!.payload.getClaim("userId").asString()
                val reportId = call.parameters["id"] ?: throw IllegalArgumentException("Missing id")
                val request = call.receive<CreateReportRequest>()
                val now = Clock.System.now()

                val updated = transaction {
                    ConditionReportsTable.update({
                        (ConditionReportsTable.id eq UUID.fromString(reportId)) and
                            (ConditionReportsTable.userId eq UUID.fromString(userId))
                    }) {
                        it[objectId] = UUID.fromString(request.objectId)
                        it[reportType] = request.reportType
                        it[overallCondition] = request.overallCondition
                        it[examiner] = request.examiner
                        it[examinationDate] = parseApiInstant(request.examinationDate)
                        it[damageAnnotations] = request.damageAnnotations
                        it[notes] = request.notes
                        it[recommendations] = request.recommendations
                        it[imageIds] = request.imageIds.joinToString(",")
                        it[previousInterventions] = request.previousInterventions
                        it[lightSource] = request.lightSource
                        it[relativeHumidity] = request.relativeHumidity
                        it[temperature] = request.temperature
                        it[examinationNotes] = request.examinationNotes
                        it[updatedAt] = now
                    }
                }
                if (updated == 0) {
                    call.respond(HttpStatusCode.NotFound)
                    return@put
                }
                call.respond(mapOf("id" to reportId))
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

private fun ResultRow.toReportResponse() = ReportResponse(
    id = this[ConditionReportsTable.id].toString(),
    objectId = this[ConditionReportsTable.objectId].toString(),
    reportType = this[ConditionReportsTable.reportType],
    overallCondition = this[ConditionReportsTable.overallCondition],
    examiner = this[ConditionReportsTable.examiner],
    examinationDate = this[ConditionReportsTable.examinationDate].toString(),
    notes = this[ConditionReportsTable.notes],
    recommendations = this[ConditionReportsTable.recommendations],
    imageIds = this[ConditionReportsTable.imageIds].split(",").filter { it.isNotBlank() },
    previousInterventions = this[ConditionReportsTable.previousInterventions],
    lightSource = this[ConditionReportsTable.lightSource],
    relativeHumidity = this[ConditionReportsTable.relativeHumidity],
    temperature = this[ConditionReportsTable.temperature],
    examinationNotes = this[ConditionReportsTable.examinationNotes],
    createdAt = this[ConditionReportsTable.createdAt].toString(),
    updatedAt = this[ConditionReportsTable.updatedAt].toString()
)
