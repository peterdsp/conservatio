package com.conservatio.android.data

import android.content.Context
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL
import java.time.Instant

private const val DEFAULT_API_URL = "https://api.conservatio.peterdsp.dev"

class ServerSyncClient(context: Context) {
    private val prefs = context.getSharedPreferences("conservatio", Context.MODE_PRIVATE)

    val isAuthenticated: Boolean
        get() = prefs.getString("auth_token", "").orEmpty().isNotBlank()

    suspend fun login(email: String, password: String) = authenticate(
        path = "/api/auth/login",
        body = JSONObject()
            .put("email", email)
            .put("password", password)
    )

    suspend fun register(email: String, password: String, displayName: String) = authenticate(
        path = "/api/auth/register",
        body = JSONObject()
            .put("email", email)
            .put("password", password)
            .put("displayName", displayName)
    )

    suspend fun fetchObjects(): List<ConservationObject> = withContext(Dispatchers.IO) {
        val response = request("GET", "/api/objects")
        val array = JSONArray(response)
        buildList {
            for (index in 0 until array.length()) {
                add(array.getJSONObject(index).toConservationObject())
            }
        }
    }

    suspend fun fetchReports(): List<ConditionReport> = withContext(Dispatchers.IO) {
        val response = request("GET", "/api/reports")
        val array = JSONArray(response)
        buildList {
            for (index in 0 until array.length()) {
                add(array.getJSONObject(index).toConditionReport())
            }
        }
    }

    suspend fun createObject(obj: ConservationObject) = withContext(Dispatchers.IO) {
        request("POST", "/api/objects", obj.toApiJson())
    }

    suspend fun deleteObject(id: String) = withContext(Dispatchers.IO) {
        request("DELETE", "/api/objects/$id")
    }

    suspend fun createReport(report: ConditionReport) = withContext(Dispatchers.IO) {
        request("POST", "/api/reports", report.toApiJson())
    }

    suspend fun deleteReport(id: String) = withContext(Dispatchers.IO) {
        request("DELETE", "/api/reports/$id")
    }

    private suspend fun authenticate(path: String, body: JSONObject) = withContext(Dispatchers.IO) {
        val response = JSONObject(request("POST", path, body, includeAuth = false))
        prefs.edit()
            .putString("auth_token", response.getString("token"))
            .putString("auth_email", response.getString("email"))
            .putString("display_name", response.optString("displayName"))
            .putString("storage_mode", StorageModeName.SELF_HOSTED.name)
            .apply()
    }

    private fun request(
        method: String,
        path: String,
        body: JSONObject? = null,
        includeAuth: Boolean = true
    ): String {
        val connection = URL("${baseUrl()}$path").openConnection() as HttpURLConnection
        connection.requestMethod = method
        connection.setRequestProperty("Content-Type", "application/json")
        if (includeAuth) {
            connection.setRequestProperty("Authorization", "Bearer ${token()}")
        }
        if (body != null) {
            connection.doOutput = true
            connection.outputStream.use { it.write(body.toString().toByteArray()) }
        }

        val status = connection.responseCode
        val stream = if (status in 200..299) connection.inputStream else connection.errorStream
        val text = stream?.bufferedReader()?.use { it.readText() }.orEmpty()
        connection.disconnect()

        if (status !in 200..299) {
            throw IllegalStateException(text.ifBlank { "API request failed with status $status" })
        }
        return text
    }

    private fun baseUrl(): String {
        val configured = prefs.getString("server_url", "").orEmpty().trim().trimEnd('/')
        return configured.ifBlank { DEFAULT_API_URL }
    }

    private fun token() = prefs.getString("auth_token", "").orEmpty()
}

private enum class StorageModeName {
    SELF_HOSTED
}

private fun JSONObject.toConservationObject(): ConservationObject {
    return ConservationObject(
        id = getString("id"),
        title = getString("title"),
        objectType = apiObjectType(optString("objectType")),
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
        createdAt = optInstantMillis("createdAt"),
        updatedAt = optInstantMillis("updatedAt")
    )
}

private fun ConservationObject.toApiJson(): JSONObject {
    return JSONObject()
        .put("id", id)
        .put("title", title)
        .put("objectType", objectType.name)
        .put("materials", JSONArray(materials))
        .putNullable("height", height)
        .putNullable("width", width)
        .putNullable("depth", depth)
        .put("measurementUnit", measurementUnit)
        .putNullable("ownerName", ownerName)
        .putNullable("locationDescription", locationDescription)
        .putNullable("inventoryNumber", inventoryNumber)
        .putNullable("description", description)
        .put("imageIds", JSONArray(imageIds))
}

private fun ConditionReport.toApiJson(): JSONObject {
    return JSONObject()
        .put("id", id)
        .put("objectId", objectId)
        .put("reportType", reportType.name)
        .put("overallCondition", overallCondition.name)
        .put("examiner", examiner)
        .put("examinationDate", Instant.ofEpochMilli(examinationDate).toString())
        .put("damageAnnotations", "[]")
        .putNullable("notes", notes)
        .putNullable("recommendations", recommendations)
        .put("imageIds", JSONArray(imageIds))
}

private fun JSONObject.toConditionReport(): ConditionReport {
    return ConditionReport(
        id = getString("id"),
        objectId = getString("objectId"),
        reportType = ReportType.entries.firstOrNull { it.name == optString("reportType") } ?: ReportType.INITIAL_ASSESSMENT,
        overallCondition = ConditionRating.entries.firstOrNull { it.name == optString("overallCondition") } ?: ConditionRating.FAIR,
        examiner = optString("examiner"),
        examinationDate = optInstantMillis("examinationDate"),
        notes = optString("notes"),
        recommendations = optString("recommendations"),
        imageIds = optJSONArray("imageIds").toStringList(),
        createdAt = optInstantMillis("createdAt")
    )
}

private fun apiObjectType(value: String): ObjectType = ObjectType.entries.firstOrNull {
    it.name == value || it.displayName.equals(value.replace("_", " "), ignoreCase = true)
} ?: ObjectType.OTHER

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

private fun JSONObject.optInstantMillis(name: String): Long =
    runCatching { Instant.parse(optString(name)).toEpochMilli() }.getOrElse { System.currentTimeMillis() }

private fun JSONObject.putNullable(name: String, value: Any?): JSONObject =
    put(name, value ?: JSONObject.NULL)
