package com.conservatio.domain.repository

import com.conservatio.domain.model.Client
import kotlinx.coroutines.flow.Flow

interface ClientRepository {
    fun observeAll(): Flow<List<Client>>
    fun observeById(id: String): Flow<Client?>
    suspend fun getById(id: String): Client?
    suspend fun insert(client: Client)
    suspend fun update(client: Client)
    suspend fun delete(id: String)
    suspend fun search(query: String): List<Client>
}
