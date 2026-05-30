package com.conservatio.domain.model

import kotlinx.datetime.Instant
import kotlinx.serialization.Serializable

@Serializable
data class ConservationObject(
    val id: String,
    val title: String,
    val objectType: ObjectType,
    val materials: List<String>,
    val dimensions: Dimensions?,
    val ownerName: String?,
    val locationDescription: String?,
    val acquisitionDate: Instant?,
    val inventoryNumber: String?,
    val description: String?,
    val imageIds: List<String>,
    val createdAt: Instant,
    val updatedAt: Instant,
    val syncStatus: SyncStatus
)

@Serializable
enum class ObjectType {
    PAINTING,
    ICON,
    WALL_PAINTING,
    SCULPTURE,
    CERAMIC,
    METAL,
    TEXTILE,
    PAPER,
    WOOD,
    STONE,
    GLASS,
    MOSAIC,
    ARCHAEOLOGICAL_FIND,
    FURNITURE,
    OTHER
}

@Serializable
data class Dimensions(
    val height: Double?,
    val width: Double?,
    val depth: Double?,
    val diameter: Double?,
    val weight: Double?,
    val unit: MeasurementUnit
)

@Serializable
enum class MeasurementUnit {
    CM, MM, M, INCH, KG, G
}

@Serializable
enum class SyncStatus {
    SYNCED, PENDING, CONFLICT
}
