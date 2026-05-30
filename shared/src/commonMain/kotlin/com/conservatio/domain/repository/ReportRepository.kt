package com.conservatio.domain.repository

import com.conservatio.domain.model.ConditionReport
import kotlinx.coroutines.flow.Flow

interface ReportRepository {
    fun observeAll(): Flow<List<ConditionReport>>
    fun observeByObject(objectId: String): Flow<List<ConditionReport>>
    fun observeById(id: String): Flow<ConditionReport?>
    suspend fun getById(id: String): ConditionReport?
    suspend fun insert(report: ConditionReport)
    suspend fun update(report: ConditionReport)
    suspend fun delete(id: String)
}
