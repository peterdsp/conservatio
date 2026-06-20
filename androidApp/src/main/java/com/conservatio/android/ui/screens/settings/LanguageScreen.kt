package com.conservatio.android.ui.screens.settings

import android.content.Context
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
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
import androidx.compose.foundation.lazy.LazyColumn
import com.conservatio.android.ui.theme.ConservatioColors

private data class LangOption(val code: String, val label: String)

private val appLanguages = listOf(
    LangOption("en", "English"),
    LangOption("el", "Ελληνικά"),
)

private val reportLanguages = listOf(
    LangOption("en", "English"),
    LangOption("el", "Ελληνικά"),
    LangOption("it", "Italiano"),
    LangOption("es", "Español"),
    LangOption("fr", "Français"),
    LangOption("de", "Deutsch"),
    LangOption("tr", "Türkçe"),
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LanguageScreen(onBack: () -> Unit) {
    val context = LocalContext.current
    val prefs = context.getSharedPreferences("conservatio", Context.MODE_PRIVATE)
    var appLang by remember { mutableStateOf(prefs.getString("app_language", "en") ?: "en") }
    var reportLang by remember { mutableStateOf(prefs.getString("report_language", "en") ?: "en") }

    fun save() {
        prefs.edit()
            .putString("app_language", appLang)
            .putString("report_language", reportLang)
            .apply()
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Language") },
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
            item { Text("App Language", style = MaterialTheme.typography.titleSmall) }
            appLanguages.forEach { lang ->
                item {
                    Card(
                        onClick = { appLang = lang.code },
                        colors = if (appLang == lang.code) {
                            CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.primaryContainer)
                        } else {
                            CardDefaults.cardColors()
                        },
                    ) {
                        Row(
                            modifier = Modifier.padding(16.dp).fillMaxWidth(),
                        ) {
                            Text(lang.label, modifier = Modifier.weight(1f), style = MaterialTheme.typography.bodyLarge)
                            if (appLang == lang.code) {
                                Icon(Icons.Outlined.CheckCircle, "Selected", tint = ConservatioColors.primary)
                            }
                        }
                    }
                }
            }
            item {
                Text(
                    "Changes the language of the app itself. Restart the app if any text doesn't refresh.",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }

            item { Spacer(Modifier.height(16.dp)); Text("Report Language", style = MaterialTheme.typography.titleSmall) }
            reportLanguages.forEach { lang ->
                item {
                    Card(
                        onClick = { reportLang = lang.code },
                        colors = if (reportLang == lang.code) {
                            CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.primaryContainer)
                        } else {
                            CardDefaults.cardColors()
                        },
                    ) {
                        Row(modifier = Modifier.padding(16.dp).fillMaxWidth()) {
                            Text(lang.label, modifier = Modifier.weight(1f), style = MaterialTheme.typography.bodyLarge)
                            if (reportLang == lang.code) {
                                Icon(Icons.Outlined.CheckCircle, "Selected", tint = ConservatioColors.primary)
                            }
                        }
                    }
                }
            }
            item {
                Text(
                    "Language used for section headers and labels in exported PDF reports. Object content stays in whatever you typed.",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
        }
    }
}
