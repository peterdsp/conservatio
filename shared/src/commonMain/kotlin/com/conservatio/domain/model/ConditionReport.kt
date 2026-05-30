package com.conservatio.domain.model

import kotlinx.datetime.Instant
import kotlinx.serialization.Serializable

@Serializable
data class ConditionReport(
    val id: String,
    val objectId: String,
    val reportType: ReportType,
    val overallCondition: ConditionRating,
    val examiner: String,
    val examinationDate: Instant,
    val damageAnnotations: List<DamageAnnotation>,
    val notes: String?,
    val recommendations: String?,
    val imageIds: List<String>,
    val createdAt: Instant,
    val updatedAt: Instant,
    val syncStatus: SyncStatus
)

@Serializable
enum class ReportType {
    INITIAL_ASSESSMENT,
    PRE_TREATMENT,
    POST_TREATMENT,
    LOAN_OUTGOING,
    LOAN_INCOMING,
    INSURANCE,
    TRANSPORT,
    PERIODIC_CHECK,
    EMERGENCY
}

@Serializable
enum class ConditionRating {
    EXCELLENT,
    GOOD,
    FAIR,
    POOR,
    CRITICAL
}

@Serializable
data class DamageAnnotation(
    val id: String,
    val damageType: DamageType,
    val severity: DamageSeverity,
    val description: String?,
    val imageId: String?,
    val xPercent: Double?,
    val yPercent: Double?,
    val widthPercent: Double?,
    val heightPercent: Double?
)

@Serializable
enum class DamageType {
    CRACK,
    PAINT_LOSS,
    FLAKING,
    DISCOLORATION,
    STAIN,
    SCRATCH,
    DENT,
    TEAR,
    HOLE,
    CORROSION,
    BIOLOGICAL_GROWTH,
    INSECT_DAMAGE,
    WATER_DAMAGE,
    FIRE_DAMAGE,
    STRUCTURAL_DAMAGE,
    SURFACE_DIRT,
    ABRASION,
    DEFORMATION,
    MISSING_PART,
    PREVIOUS_REPAIR,
    OTHER
}

@Serializable
enum class DamageSeverity {
    MINOR, MODERATE, SEVERE, CRITICAL
}
