package com.conservatio.data.remote

import com.conservatio.domain.model.Client
import com.conservatio.domain.model.ConditionReport
import com.conservatio.domain.model.ConservationObject
import com.conservatio.domain.model.Project
import io.ktor.client.HttpClient
import io.ktor.client.call.body
import io.ktor.client.request.delete
import io.ktor.client.request.get
import io.ktor.client.request.post
import io.ktor.client.request.put
import io.ktor.client.request.setBody
import io.ktor.http.ContentType
import io.ktor.http.contentType

class KtorConservatioApi(
    private val client: HttpClient,
    private val baseUrl: String
) : ConservatioApi {

    override suspend fun fetchObjects(): List<ConservationObject> =
        client.get("$baseUrl/api/objects").body()

    override suspend fun fetchObject(id: String): ConservationObject? =
        client.get("$baseUrl/api/objects/$id").body()

    override suspend fun createObject(obj: ConservationObject): ConservationObject =
        client.post("$baseUrl/api/objects") {
            contentType(ContentType.Application.Json)
            setBody(obj)
        }.body()

    override suspend fun updateObject(obj: ConservationObject): ConservationObject =
        client.put("$baseUrl/api/objects/${obj.id}") {
            contentType(ContentType.Application.Json)
            setBody(obj)
        }.body()

    override suspend fun deleteObject(id: String) {
        client.delete("$baseUrl/api/objects/$id")
    }

    override suspend fun fetchReports(objectId: String): List<ConditionReport> =
        client.get("$baseUrl/api/objects/$objectId/reports").body()

    override suspend fun createReport(report: ConditionReport): ConditionReport =
        client.post("$baseUrl/api/reports") {
            contentType(ContentType.Application.Json)
            setBody(report)
        }.body()

    override suspend fun updateReport(report: ConditionReport): ConditionReport =
        client.put("$baseUrl/api/reports/${report.id}") {
            contentType(ContentType.Application.Json)
            setBody(report)
        }.body()

    override suspend fun deleteReport(id: String) {
        client.delete("$baseUrl/api/reports/$id")
    }

    override suspend fun fetchProjects(): List<Project> =
        client.get("$baseUrl/api/projects").body()

    override suspend fun createProject(project: Project): Project =
        client.post("$baseUrl/api/projects") {
            contentType(ContentType.Application.Json)
            setBody(project)
        }.body()

    override suspend fun updateProject(project: Project): Project =
        client.put("$baseUrl/api/projects/${project.id}") {
            contentType(ContentType.Application.Json)
            setBody(project)
        }.body()

    override suspend fun deleteProject(id: String) {
        client.delete("$baseUrl/api/projects/$id")
    }

    override suspend fun fetchClients(): List<Client> =
        client.get("$baseUrl/api/clients").body()

    override suspend fun createClient(client: Client): Client =
        this.client.post("$baseUrl/api/clients") {
            contentType(ContentType.Application.Json)
            setBody(client)
        }.body()

    override suspend fun updateClient(client: Client): Client =
        this.client.put("$baseUrl/api/clients/${client.id}") {
            contentType(ContentType.Application.Json)
            setBody(client)
        }.body()

    override suspend fun deleteClient(id: String) {
        client.delete("$baseUrl/api/clients/$id")
    }

    override suspend fun uploadImage(imageBytes: ByteArray, filename: String): String =
        client.post("$baseUrl/api/images") {
            setBody(imageBytes)
        }.body()

    override suspend fun downloadImage(imageId: String): ByteArray =
        client.get("$baseUrl/api/images/$imageId").body()
}
