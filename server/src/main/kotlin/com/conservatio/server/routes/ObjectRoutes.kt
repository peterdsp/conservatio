package com.conservatio.server.routes

import com.conservatio.server.db.ConservationObjectsTable
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
data class CreateObjectRequest(
    val id: String? = null,
    val title: String,
    val objectType: String,
    val materials: List<String> = emptyList(),
    val height: Double? = null,
    val width: Double? = null,
    val depth: Double? = null,
    val diameter: Double? = null,
    val weight: Double? = null,
    val measurementUnit: String? = null,
    val ownerName: String? = null,
    val locationDescription: String? = null,
    val inventoryNumber: String? = null,
    val description: String? = null,
    val imageIds: List<String> = emptyList()
)

@Serializable
data class ObjectResponse(
    val id: String,
    val title: String,
    val objectType: String,
    val materials: List<String>,
    val height: Double? = null,
    val width: Double? = null,
    val depth: Double? = null,
    val diameter: Double? = null,
    val weight: Double? = null,
    val measurementUnit: String? = null,
    val ownerName: String? = null,
    val locationDescription: String? = null,
    val inventoryNumber: String? = null,
    val description: String? = null,
    val imageIds: List<String>,
    val createdAt: String,
    val updatedAt: String
)

fun Route.objectRoutes() {
    authenticate("auth-jwt") {
        route("/api/objects") {
            get {
                val userId = call.principal<JWTPrincipal>()!!.payload.getClaim("userId").asString()
                val objects = transaction {
                    ConservationObjectsTable.selectAll()
                        .where { ConservationObjectsTable.userId eq UUID.fromString(userId) }
                        .orderBy(ConservationObjectsTable.updatedAt, SortOrder.DESC)
                        .map { it.toObjectResponse() }
                }
                call.respond(objects)
            }

            get("/{id}") {
                val userId = call.principal<JWTPrincipal>()!!.payload.getClaim("userId").asString()
                val objectId = call.parameters["id"] ?: throw IllegalArgumentException("Missing id")
                val obj = transaction {
                    ConservationObjectsTable.selectAll()
                        .where {
                            (ConservationObjectsTable.id eq UUID.fromString(objectId)) and
                            (ConservationObjectsTable.userId eq UUID.fromString(userId))
                        }
                        .firstOrNull()?.toObjectResponse()
                } ?: throw NoSuchElementException("Object not found")
                call.respond(obj)
            }

            post {
                val userId = call.principal<JWTPrincipal>()!!.payload.getClaim("userId").asString()
                val request = call.receive<CreateObjectRequest>()
                val id = request.id?.takeIf { it.isNotBlank() }?.let(UUID::fromString) ?: UUID.randomUUID()
                val now = Clock.System.now()

                transaction {
                    ConservationObjectsTable.insert {
                        it[ConservationObjectsTable.id] = id
                        it[title] = request.title
                        it[objectType] = request.objectType
                        it[materials] = request.materials.joinToString(",")
                        it[height] = request.height
                        it[width] = request.width
                        it[depth] = request.depth
                        it[diameter] = request.diameter
                        it[ConservationObjectsTable.weight] = request.weight
                        it[measurementUnit] = request.measurementUnit
                        it[ownerName] = request.ownerName
                        it[locationDescription] = request.locationDescription
                        it[inventoryNumber] = request.inventoryNumber
                        it[description] = request.description
                        it[imageIds] = request.imageIds.joinToString(",")
                        it[ConservationObjectsTable.userId] = UUID.fromString(userId)
                        it[createdAt] = now
                        it[updatedAt] = now
                    }
                }

                call.respond(HttpStatusCode.Created, ObjectResponse(
                    id = id.toString(), title = request.title, objectType = request.objectType,
                    materials = request.materials, height = request.height, width = request.width,
                    depth = request.depth, diameter = request.diameter, weight = request.weight,
                    measurementUnit = request.measurementUnit, ownerName = request.ownerName,
                    locationDescription = request.locationDescription, inventoryNumber = request.inventoryNumber,
                    description = request.description, imageIds = request.imageIds,
                    createdAt = now.toString(), updatedAt = now.toString()
                ))
            }

            delete("/{id}") {
                val userId = call.principal<JWTPrincipal>()!!.payload.getClaim("userId").asString()
                val objectId = call.parameters["id"] ?: throw IllegalArgumentException("Missing id")
                transaction {
                    ConservationObjectsTable.deleteWhere {
                        (ConservationObjectsTable.id eq UUID.fromString(objectId)) and
                        (ConservationObjectsTable.userId eq UUID.fromString(userId))
                    }
                }
                call.respond(HttpStatusCode.NoContent)
            }
        }
    }
}

private fun ResultRow.toObjectResponse() = ObjectResponse(
    id = this[ConservationObjectsTable.id].toString(),
    title = this[ConservationObjectsTable.title],
    objectType = this[ConservationObjectsTable.objectType],
    materials = this[ConservationObjectsTable.materials].split(",").filter { it.isNotBlank() },
    height = this[ConservationObjectsTable.height],
    width = this[ConservationObjectsTable.width],
    depth = this[ConservationObjectsTable.depth],
    diameter = this[ConservationObjectsTable.diameter],
    weight = this[ConservationObjectsTable.weight],
    measurementUnit = this[ConservationObjectsTable.measurementUnit],
    ownerName = this[ConservationObjectsTable.ownerName],
    locationDescription = this[ConservationObjectsTable.locationDescription],
    inventoryNumber = this[ConservationObjectsTable.inventoryNumber],
    description = this[ConservationObjectsTable.description],
    imageIds = this[ConservationObjectsTable.imageIds].split(",").filter { it.isNotBlank() },
    createdAt = this[ConservationObjectsTable.createdAt].toString(),
    updatedAt = this[ConservationObjectsTable.updatedAt].toString()
)
