package com.conservatio.domain.model

import kotlinx.datetime.Instant
import kotlinx.serialization.Serializable

@Serializable
data class Project(
    val id: String,
    val title: String,
    val clientId: String?,
    val objectIds: List<String>,
    val status: ProjectStatus,
    val startDate: Instant?,
    val endDate: Instant?,
    val description: String?,
    val totalBudget: Double?,
    val currency: String?,
    val createdAt: Instant,
    val updatedAt: Instant,
    val syncStatus: SyncStatus
)

@Serializable
enum class ProjectStatus {
    INQUIRY, QUOTED, APPROVED, IN_PROGRESS, ON_HOLD, COMPLETED, ARCHIVED
}
