package com.conservatio.domain.repository

import com.conservatio.domain.model.Project
import kotlinx.coroutines.flow.Flow

interface ProjectRepository {
    fun observeAll(): Flow<List<Project>>
    fun observeById(id: String): Flow<Project?>
    fun observeByClient(clientId: String): Flow<List<Project>>
    suspend fun getById(id: String): Project?
    suspend fun insert(project: Project)
    suspend fun update(project: Project)
    suspend fun delete(id: String)
}
