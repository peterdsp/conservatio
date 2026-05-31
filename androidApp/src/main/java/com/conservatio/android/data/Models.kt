package com.conservatio.android.data

import java.util.UUID

enum class ObjectType(val displayName: String) {
    PAINTING("Painting"), ICON("Icon"), WALL_PAINTING("Wall Painting"),
    SCULPTURE("Sculpture"), CERAMIC("Ceramic"), METAL("Metal"),
    TEXTILE("Textile"), PAPER("Paper"), WOOD("Wood"), STONE("Stone"),
    GLASS("Glass"), MOSAIC("Mosaic"), ARCHAEOLOGICAL_FIND("Archaeological Find"),
    FURNITURE("Furniture"), OTHER("Other")
}

enum class ConditionRating(val displayName: String) {
    EXCELLENT("Excellent"), GOOD("Good"), FAIR("Fair"),
    POOR("Poor"), CRITICAL("Critical")
}

enum class ReportType(val displayName: String) {
    INITIAL_ASSESSMENT("Initial Assessment"), PRE_TREATMENT("Pre-Treatment"),
    POST_TREATMENT("Post-Treatment"), LOAN_OUTGOING("Loan (Outgoing)"),
    LOAN_INCOMING("Loan (Incoming)"), INSURANCE("Insurance"),
    TRANSPORT("Transport"), PERIODIC_CHECK("Periodic Check"),
    EMERGENCY("Emergency")
}

enum class DamageType(val displayName: String) {
    CRACK("Crack"), PAINT_LOSS("Paint Loss"), FLAKING("Flaking"),
    DISCOLORATION("Discoloration"), STAIN("Stain"), SCRATCH("Scratch"),
    ABRASION("Abrasion"), TEAR("Tear"), HOLE("Hole"), DENT("Dent"),
    CORROSION("Corrosion"), BIOLOGICAL_GROWTH("Biological Growth"),
    INSECT_DAMAGE("Insect Damage"), WATER_DAMAGE("Water Damage"),
    FIRE_DAMAGE("Fire Damage"), STRUCTURAL_DAMAGE("Structural Damage"),
    DEFORMATION("Deformation"), EFFLORESCENCE("Efflorescence"),
    PREVIOUS_REPAIR("Previous Repair"), MISSING_ELEMENT("Missing Element"),
    OTHER("Other")
}

enum class DamageSeverity(val displayName: String) {
    MINOR("Minor"), MODERATE("Moderate"), SEVERE("Severe"), CRITICAL("Critical")
}

data class ConservationObject(
    val id: String = UUID.randomUUID().toString(),
    val title: String = "",
    val objectType: ObjectType = ObjectType.OTHER,
    val materials: List<String> = emptyList(),
    val height: Double? = null,
    val width: Double? = null,
    val depth: Double? = null,
    val measurementUnit: String = "cm",
    val ownerName: String = "",
    val locationDescription: String = "",
    val inventoryNumber: String = "",
    val description: String = "",
    val imageIds: List<String> = emptyList(),
    val createdAt: Long = System.currentTimeMillis(),
    val updatedAt: Long = System.currentTimeMillis()
)

data class DamageAnnotation(
    val id: String = UUID.randomUUID().toString(),
    val type: DamageType = DamageType.OTHER,
    val severity: DamageSeverity = DamageSeverity.MINOR,
    val description: String = ""
)

data class ConditionReport(
    val id: String = UUID.randomUUID().toString(),
    val objectId: String = "",
    val reportType: ReportType = ReportType.INITIAL_ASSESSMENT,
    val overallCondition: ConditionRating = ConditionRating.FAIR,
    val examiner: String = "",
    val examinationDate: Long = System.currentTimeMillis(),
    val damageAnnotations: List<DamageAnnotation> = emptyList(),
    val notes: String = "",
    val recommendations: String = "",
    val imageIds: List<String> = emptyList(),
    val createdAt: Long = System.currentTimeMillis()
)
