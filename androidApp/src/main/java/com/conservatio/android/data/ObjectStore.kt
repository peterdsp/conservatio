package com.conservatio.android.data

import android.content.Context
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import java.io.File

class ObjectStore(private val context: Context) {
    private val _objects = MutableStateFlow<List<ConservationObject>>(emptyList())
    val objects: StateFlow<List<ConservationObject>> = _objects.asStateFlow()

    private val _reports = MutableStateFlow<List<ConditionReport>>(emptyList())
    val reports: StateFlow<List<ConditionReport>> = _reports.asStateFlow()

    private val objectsFile get() = File(context.filesDir, "objects.json")
    private val reportsFile get() = File(context.filesDir, "reports.json")

    init {
        load()
    }

    fun addObject(obj: ConservationObject) {
        _objects.value = _objects.value + obj
        save()
    }

    fun deleteObject(id: String) {
        _objects.value = _objects.value.filter { it.id != id }
        _reports.value = _reports.value.filter { it.objectId != id }
        save()
    }

    fun addReport(report: ConditionReport) {
        _reports.value = _reports.value + report
        save()
    }

    fun reportsForObject(objectId: String): List<ConditionReport> {
        return _reports.value.filter { it.objectId == objectId }
    }

    private fun save() {
        // Simple JSON file persistence for MVP
        try {
            val objectsJson = _objects.value.map { obj ->
                """{"id":"${obj.id}","title":"${obj.title}","objectType":"${obj.objectType.name}","materials":[${obj.materials.joinToString(",") { "\"$it\"" }}],"ownerName":"${obj.ownerName}","locationDescription":"${obj.locationDescription}","createdAt":${obj.createdAt}}"""
            }
            objectsFile.writeText("[${objectsJson.joinToString(",")}]")
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun load() {
        // Load from JSON files on init
        // For MVP, just start with empty lists
    }
}
