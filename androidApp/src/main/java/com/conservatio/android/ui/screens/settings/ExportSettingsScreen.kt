package com.conservatio.android.ui.screens.settings

import android.content.Context
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.outlined.CheckCircle
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import com.conservatio.android.ui.theme.ConservatioColors

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ExportSettingsScreen(onBack: () -> Unit) {
    val context = LocalContext.current
    val prefs = context.getSharedPreferences("conservatio", Context.MODE_PRIVATE)
    var exportFormat by remember { mutableStateOf(prefs.getString("export_format", "PDF") ?: "PDF") }
    var paperSize by remember { mutableStateOf(prefs.getString("paper_size", "A4") ?: "A4") }
    var includePhotos by remember { mutableStateOf(prefs.getBoolean("export_photos", true)) }
    var includeAnnotations by remember { mutableStateOf(prefs.getBoolean("export_annotations", true)) }
    var includeGauge by remember { mutableStateOf(prefs.getBoolean("export_gauge", true)) }

    fun save() {
        prefs.edit()
            .putString("export_format", exportFormat)
            .putString("paper_size", paperSize)
            .putBoolean("export_photos", includePhotos)
            .putBoolean("export_annotations", includeAnnotations)
            .putBoolean("export_gauge", includeGauge)
            .apply()
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Export Settings") },
                navigationIcon = {
                    IconButton(onClick = { save(); onBack() }) {
                        Icon(Icons.Default.ArrowBack, "Back")
                    }
                },
            )
        },
    ) { padding ->
        LazyColumn(
            modifier = Modifier.fillMaxSize().padding(padding),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            item { Text("Format", style = MaterialTheme.typography.titleSmall) }
            listOf("PDF" to "PDF", "PDF + Images ZIP" to "ZIP").forEach { (label, value) ->
                item {
                    Card(
                        onClick = { exportFormat = value },
                        colors = if (exportFormat == value) {
                            CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.primaryContainer)
                        } else {
                            CardDefaults.cardColors()
                        },
                    ) {
                        Row(modifier = Modifier.padding(16.dp).fillMaxWidth()) {
                            Text(label, modifier = Modifier.weight(1f))
                            if (exportFormat == value) {
                                Icon(Icons.Outlined.CheckCircle, "Selected", tint = ConservatioColors.primary)
                            }
                        }
                    }
                }
            }

            item { Text("Paper Size", style = MaterialTheme.typography.titleSmall) }
            listOf("A4 (210 × 297 mm)" to "A4", "Letter (8.5 × 11 in)" to "Letter").forEach { (label, value) ->
                item {
                    Card(
                        onClick = { paperSize = value },
                        colors = if (paperSize == value) {
                            CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.primaryContainer)
                        } else {
                            CardDefaults.cardColors()
                        },
                    ) {
                        Row(modifier = Modifier.padding(16.dp).fillMaxWidth()) {
                            Text(label, modifier = Modifier.weight(1f))
                            if (paperSize == value) {
                                Icon(Icons.Outlined.CheckCircle, "Selected", tint = ConservatioColors.primary)
                            }
                        }
                    }
                }
            }

            item { Text("Content", style = MaterialTheme.typography.titleSmall) }
            item {
                Card {
                    Column {
                        Row(
                            modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp).fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                        ) {
                            Text("Include Photos"); Switch(checked = includePhotos, onCheckedChange = { includePhotos = it })
                        }
                        Row(
                            modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp).fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                        ) {
                            Text("Include Damage Annotations"); Switch(checked = includeAnnotations, onCheckedChange = { includeAnnotations = it })
                        }
                        Row(
                            modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp).fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                        ) {
                            Text("Include Condition Gauge"); Switch(checked = includeGauge, onCheckedChange = { includeGauge = it })
                        }
                    }
                }
            }
        }
    }
}
