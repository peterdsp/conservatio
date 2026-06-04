package com.conservatio.android.data

import android.content.Context
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import org.json.JSONArray
import org.json.JSONObject
import java.io.File

class ObjectStore(private val context: Context) {
    private val _objects = MutableStateFlow<List<ConservationObject>>(emptyList())
    val objects: StateFlow<List<ConservationObject>> = _objects.asStateFlow()

    private val _reports = MutableStateFlow<List<ConditionReport>>(emptyList())
    val reports: StateFlow<List<ConditionReport>> = _reports.asStateFlow()

    private val objectsFile get() = File(context.filesDir, "objects.json")
    private val reportsFile get() = File(context.filesDir, "reports.json")
    private val syncClient = ServerSyncClient(context.applicationContext)
    private val syncScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    init {
        load()
    }

    fun addObject(obj: ConservationObject) {
        _objects.value = _objects.value + obj
        save()
        syncScope.launch {
            if (syncClient.isAuthenticated) {
                runCatching { syncClient.createObject(obj) }
            }
        }
    }

    fun deleteObject(id: String) {
        _objects.value = _objects.value.filter { it.id != id }
        _reports.value = _reports.value.filter { it.objectId != id }
        save()
        syncScope.launch {
            if (syncClient.isAuthenticated) {
                runCatching { syncClient.deleteObject(id) }
            }
        }
    }

    fun addReport(report: ConditionReport) {
        _reports.value = _reports.value + report
        save()
        syncScope.launch {
            if (syncClient.isAuthenticated) {
                runCatching { syncClient.createReport(report) }
            }
        }
    }

    fun reportsForObject(objectId: String): List<ConditionReport> {
        return _reports.value.filter { it.objectId == objectId }
    }

    suspend fun syncFromServer() {
        if (!syncClient.isAuthenticated) return
        runCatching {
            _objects.value = syncClient.fetchObjects()
            _reports.value = syncClient.fetchReports()
            save()
        }
    }

    private fun save() {
        try {
            objectsFile.writeText(JSONArray(_objects.value.map { it.toJson() }).toString())
            reportsFile.writeText(JSONArray(_reports.value.map { it.toJson() }).toString())
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun load() {
        runCatching {
            if (objectsFile.exists()) {
                val json = JSONArray(objectsFile.readText())
                _objects.value = buildList {
                    for (index in 0 until json.length()) {
                        add(json.getJSONObject(index).toConservationObject())
                    }
                }
            }
            if (reportsFile.exists()) {
                val json = JSONArray(reportsFile.readText())
                _reports.value = buildList {
                    for (index in 0 until json.length()) {
                        add(json.getJSONObject(index).toConditionReport())
                    }
                }
            }
        }
    }
}

private fun ConservationObject.toJson(): JSONObject {
    return JSONObject()
        .put("id", id)
        .put("title", title)
        .put("objectType", objectType.name)
        .put("materials", JSONArray(materials))
        .putNullable("height", height)
        .putNullable("width", width)
        .putNullable("depth", depth)
        .put("measurementUnit", measurementUnit)
        .put("ownerName", ownerName)
        .put("locationDescription", locationDescription)
        .put("inventoryNumber", inventoryNumber)
        .put("description", description)
        .put("imageIds", JSONArray(imageIds))
        .put("createdAt", createdAt)
        .put("updatedAt", updatedAt)
}

private fun JSONObject.toConservationObject(): ConservationObject {
    return ConservationObject(
        id = getString("id"),
        title = getString("title"),
        objectType = ObjectType.entries.firstOrNull { it.name == optString("objectType") } ?: ObjectType.OTHER,
        materials = optJSONArray("materials").toStringList(),
        height = optNullableDouble("height"),
        width = optNullableDouble("width"),
        depth = optNullableDouble("depth"),
        measurementUnit = optString("measurementUnit", "cm"),
        ownerName = optString("ownerName"),
        locationDescription = optString("locationDescription"),
        inventoryNumber = optString("inventoryNumber"),
        description = optString("description"),
        imageIds = optJSONArray("imageIds").toStringList(),
        createdAt = optLong("createdAt", System.currentTimeMillis()),
        updatedAt = optLong("updatedAt", System.currentTimeMillis())
    )
}

private fun ConditionReport.toJson(): JSONObject {
    return JSONObject()
        .put("id", id)
        .put("objectId", objectId)
        .put("reportType", reportType.name)
        .put("overallCondition", overallCondition.name)
        .put("examiner", examiner)
        .put("examinationDate", examinationDate)
        .put("notes", notes)
        .put("recommendations", recommendations)
        .put("imageIds", JSONArray(imageIds))
        .put("createdAt", createdAt)
}

private fun JSONObject.toConditionReport(): ConditionReport {
    return ConditionReport(
        id = getString("id"),
        objectId = getString("objectId"),
        reportType = ReportType.entries.firstOrNull { it.name == optString("reportType") } ?: ReportType.INITIAL_ASSESSMENT,
        overallCondition = ConditionRating.entries.firstOrNull { it.name == optString("overallCondition") } ?: ConditionRating.FAIR,
        examiner = optString("examiner"),
        examinationDate = optLong("examinationDate", System.currentTimeMillis()),
        notes = optString("notes"),
        recommendations = optString("recommendations"),
        imageIds = optJSONArray("imageIds").toStringList(),
        createdAt = optLong("createdAt", System.currentTimeMillis())
    )
}

private fun JSONArray?.toStringList(): List<String> {
    if (this == null) return emptyList()
    return buildList {
        for (index in 0 until length()) {
            add(getString(index))
        }
    }
}

private fun JSONObject.optNullableDouble(name: String): Double? =
    if (has(name) && !isNull(name)) optDouble(name) else null

private fun JSONObject.putNullable(name: String, value: Any?): JSONObject =
    put(name, value ?: JSONObject.NULL)
