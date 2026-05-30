package com.conservatio.domain.repository

import com.conservatio.domain.model.ConservationObject
import kotlinx.coroutines.flow.Flow

interface ObjectRepository {
    fun observeAll(): Flow<List<ConservationObject>>
    fun observeById(id: String): Flow<ConservationObject?>
    fun observeByProject(projectId: String): Flow<List<ConservationObject>>
    suspend fun getById(id: String): ConservationObject?
    suspend fun insert(obj: ConservationObject)
    suspend fun update(obj: ConservationObject)
    suspend fun delete(id: String)
    suspend fun search(query: String): List<ConservationObject>
}
