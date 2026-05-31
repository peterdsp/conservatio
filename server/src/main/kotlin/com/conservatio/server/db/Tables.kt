package com.conservatio.server.db

import org.jetbrains.exposed.dao.id.UUIDTable
import org.jetbrains.exposed.sql.Column
import org.jetbrains.exposed.sql.kotlin.datetime.timestamp

object UsersTable : UUIDTable("users") {
    val email = varchar("email", 255).uniqueIndex()
    val passwordHash = varchar("password_hash", 255)
    val displayName = varchar("display_name", 255)
    val createdAt = timestamp("created_at")
    val updatedAt = timestamp("updated_at")
}

object ConservationObjectsTable : UUIDTable("conservation_objects") {
    val title = varchar("title", 500)
    val objectType = varchar("object_type", 50)
    val materials = text("materials")
    val height = double("height").nullable()
    val width = double("width").nullable()
    val depth = double("depth").nullable()
    val diameter = double("diameter").nullable()
    val weight = double("weight").nullable()
    val measurementUnit = varchar("measurement_unit", 10).nullable()
    val ownerName = varchar("owner_name", 255).nullable()
    val locationDescription = text("location_description").nullable()
    val acquisitionDate = timestamp("acquisition_date").nullable()
    val inventoryNumber = varchar("inventory_number", 100).nullable()
    val description = text("description").nullable()
    val imageIds = text("image_ids")
    val userId = reference("user_id", UsersTable)
    val createdAt = timestamp("created_at")
    val updatedAt = timestamp("updated_at")
}

object ConditionReportsTable : UUIDTable("condition_reports") {
    val objectId = reference("object_id", ConservationObjectsTable)
    val reportType = varchar("report_type", 50)
    val overallCondition = varchar("overall_condition", 20)
    val examiner = varchar("examiner", 255)
    val examinationDate = timestamp("examination_date")
    val damageAnnotations = text("damage_annotations")
    val notes = text("notes").nullable()
    val recommendations = text("recommendations").nullable()
    val imageIds = text("image_ids")
    val userId = reference("user_id", UsersTable)
    val createdAt = timestamp("created_at")
    val updatedAt = timestamp("updated_at")
}

object ProjectsTable : UUIDTable("projects") {
    val title = varchar("title", 500)
    val clientId = reference("client_id", ClientsTable).nullable()
    val objectIds = text("object_ids")
    val status = varchar("status", 20)
    val startDate = timestamp("start_date").nullable()
    val endDate = timestamp("end_date").nullable()
    val description = text("description").nullable()
    val totalBudget = double("total_budget").nullable()
    val currency = varchar("currency", 3).nullable()
    val userId = reference("user_id", UsersTable)
    val createdAt = timestamp("created_at")
    val updatedAt = timestamp("updated_at")
}

object ClientsTable : UUIDTable("clients") {
    val name = varchar("name", 255)
    val type = varchar("type", 50)
    val contactPerson = varchar("contact_person", 255).nullable()
    val email = varchar("email", 255).nullable()
    val phone = varchar("phone", 50).nullable()
    val address = text("address").nullable()
    val notes = text("notes").nullable()
    val userId = reference("user_id", UsersTable)
    val createdAt = timestamp("created_at")
    val updatedAt = timestamp("updated_at")
}

object TreatmentProposalsTable : UUIDTable("treatment_proposals") {
    val objectId = reference("object_id", ConservationObjectsTable)
    val conditionReportId = reference("condition_report_id", ConditionReportsTable).nullable()
    val title = varchar("title", 500)
    val proposedBy = varchar("proposed_by", 255)
    val status = varchar("status", 20)
    val methodology = text("methodology").nullable()
    val materialsRequired = text("materials_required")
    val estimatedDuration = varchar("estimated_duration", 100).nullable()
    val estimatedCost = double("estimated_cost").nullable()
    val currency = varchar("currency", 3).nullable()
    val steps = text("steps")
    val risks = text("risks").nullable()
    val userId = reference("user_id", UsersTable)
    val createdAt = timestamp("created_at")
    val updatedAt = timestamp("updated_at")
}
