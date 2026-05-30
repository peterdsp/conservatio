package com.conservatio.data.remote

import com.conservatio.domain.model.Client
import com.conservatio.domain.model.ConditionReport
import com.conservatio.domain.model.ConservationObject
import com.conservatio.domain.model.Project

interface ConservatioApi {
    suspend fun fetchObjects(): List<ConservationObject>
    suspend fun fetchObject(id: String): ConservationObject?
    suspend fun createObject(obj: ConservationObject): ConservationObject
    suspend fun updateObject(obj: ConservationObject): ConservationObject
    suspend fun deleteObject(id: String)

    suspend fun fetchReports(objectId: String): List<ConditionReport>
    suspend fun createReport(report: ConditionReport): ConditionReport
    suspend fun updateReport(report: ConditionReport): ConditionReport
    suspend fun deleteReport(id: String)

    suspend fun fetchProjects(): List<Project>
    suspend fun createProject(project: Project): Project
    suspend fun updateProject(project: Project): Project
    suspend fun deleteProject(id: String)

    suspend fun fetchClients(): List<Client>
    suspend fun createClient(client: Client): Client
    suspend fun updateClient(client: Client): Client
    suspend fun deleteClient(id: String)

    suspend fun uploadImage(imageBytes: ByteArray, filename: String): String
    suspend fun downloadImage(imageId: String): ByteArray
}
