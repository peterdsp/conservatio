package com.conservatio.domain.model

import kotlinx.datetime.Instant
import kotlinx.serialization.Serializable

@Serializable
data class Client(
    val id: String,
    val name: String,
    val type: ClientType,
    val contactPerson: String?,
    val email: String?,
    val phone: String?,
    val address: String?,
    val notes: String?,
    val createdAt: Instant,
    val updatedAt: Instant,
    val syncStatus: SyncStatus
)

@Serializable
enum class ClientType {
    PRIVATE_COLLECTOR,
    MUSEUM,
    GALLERY,
    CHURCH,
    MONASTERY,
    MUNICIPALITY,
    ARCHAEOLOGICAL_SERVICE,
    UNIVERSITY,
    FOUNDATION,
    ARCHITECT,
    INSURANCE_COMPANY,
    OTHER
}
