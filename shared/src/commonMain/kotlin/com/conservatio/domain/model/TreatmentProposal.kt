package com.conservatio.domain.model

import kotlinx.datetime.Instant
import kotlinx.serialization.Serializable

@Serializable
data class TreatmentProposal(
    val id: String,
    val objectId: String,
    val conditionReportId: String?,
    val title: String,
    val proposedBy: String,
    val status: ProposalStatus,
    val methodology: String?,
    val materialsRequired: List<String>,
    val estimatedDuration: String?,
    val estimatedCost: Double?,
    val currency: String?,
    val steps: List<TreatmentStep>,
    val risks: String?,
    val createdAt: Instant,
    val updatedAt: Instant,
    val syncStatus: SyncStatus
)

@Serializable
enum class ProposalStatus {
    DRAFT, SUBMITTED, APPROVED, IN_PROGRESS, COMPLETED, CANCELLED
}

@Serializable
data class TreatmentStep(
    val order: Int,
    val title: String,
    val description: String?,
    val materialsUsed: List<String>,
    val completed: Boolean
)
