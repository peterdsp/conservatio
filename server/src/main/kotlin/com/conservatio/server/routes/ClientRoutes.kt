package com.conservatio.server.routes

import com.conservatio.server.db.ClientsTable
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
import java.util.UUID

@Serializable
data class CreateClientRequest(
    val id: String? = null,
    val name: String,
    val type: String,
    val contactPerson: String? = null,
    val email: String? = null,
    val phone: String? = null,
    val address: String? = null,
    val notes: String? = null
)

@Serializable
data class ClientResponse(
    val id: String,
    val name: String,
    val type: String,
    val contactPerson: String? = null,
    val email: String? = null,
    val phone: String? = null,
    val address: String? = null,
    val notes: String? = null,
    val createdAt: String,
    val updatedAt: String
)

fun Route.clientRoutes() {
    authenticate("auth-jwt") {
        route("/api/clients") {
            get {
                val userId = call.principal<JWTPrincipal>()!!.payload.getClaim("userId").asString()
                val clients = transaction {
                    ClientsTable.selectAll()
                        .where { ClientsTable.userId eq UUID.fromString(userId) }
                        .orderBy(ClientsTable.updatedAt, SortOrder.DESC)
                        .map { it.toClientResponse() }
                }
                call.respond(clients)
            }

            post {
                val userId = call.principal<JWTPrincipal>()!!.payload.getClaim("userId").asString()
                val request = call.receive<CreateClientRequest>()
                val id = request.id?.takeIf { it.isNotBlank() }?.let(UUID::fromString) ?: UUID.randomUUID()
                val now = Clock.System.now()

                transaction {
                    ClientsTable.insert {
                        it[ClientsTable.id] = id
                        it[name] = request.name
                        it[type] = request.type
                        it[contactPerson] = request.contactPerson
                        it[email] = request.email
                        it[phone] = request.phone
                        it[address] = request.address
                        it[notes] = request.notes
                        it[ClientsTable.userId] = UUID.fromString(userId)
                        it[createdAt] = now
                        it[updatedAt] = now
                    }
                }

                call.respond(
                    HttpStatusCode.Created,
                    ClientResponse(
                        id = id.toString(),
                        name = request.name,
                        type = request.type,
                        contactPerson = request.contactPerson,
                        email = request.email,
                        phone = request.phone,
                        address = request.address,
                        notes = request.notes,
                        createdAt = now.toString(),
                        updatedAt = now.toString()
                    )
                )
            }

            delete("/{id}") {
                val userId = call.principal<JWTPrincipal>()!!.payload.getClaim("userId").asString()
                val clientId = call.parameters["id"] ?: throw IllegalArgumentException("Missing id")
                transaction {
                    ClientsTable.deleteWhere {
                        (ClientsTable.id eq UUID.fromString(clientId)) and
                            (ClientsTable.userId eq UUID.fromString(userId))
                    }
                }
                call.respond(HttpStatusCode.NoContent)
            }
        }
    }
}

private fun ResultRow.toClientResponse() = ClientResponse(
    id = this[ClientsTable.id].toString(),
    name = this[ClientsTable.name],
    type = this[ClientsTable.type],
    contactPerson = this[ClientsTable.contactPerson],
    email = this[ClientsTable.email],
    phone = this[ClientsTable.phone],
    address = this[ClientsTable.address],
    notes = this[ClientsTable.notes],
    createdAt = this[ClientsTable.createdAt].toString(),
    updatedAt = this[ClientsTable.updatedAt].toString()
)
