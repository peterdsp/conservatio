package com.conservatio.android.ui.screens

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.ChevronRight
import androidx.compose.material.icons.outlined.Description
import androidx.compose.material.icons.outlined.Info
import androidx.compose.material.icons.outlined.Language
import androidx.compose.material.icons.outlined.Palette
import androidx.compose.material.icons.outlined.Person
import androidx.compose.material.icons.outlined.Storage
import androidx.compose.material.icons.outlined.Sync
import androidx.compose.material.icons.outlined.Upload
import androidx.compose.material3.Card
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp
import com.conservatio.android.ui.theme.ConservatioColors

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(onNavigate: (String) -> Unit) {
    Scaffold(
        topBar = { TopAppBar(title = { Text("Settings") }) }
    ) { padding ->
        LazyColumn(
            modifier = Modifier.fillMaxSize().padding(padding),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            item {
                Text("Account", style = MaterialTheme.typography.labelLarge, color = ConservatioColors.primary, modifier = Modifier.padding(start = 16.dp, bottom = 4.dp))
            }
            item {
                SettingsCard {
                    SettingsItem(Icons.Outlined.Person, "Profile", "Conservator name, studio info") { onNavigate("profile") }
                    HorizontalDivider(modifier = Modifier.padding(horizontal = 16.dp))
                    SettingsItem(Icons.Outlined.Sync, "Sync & Storage", "Local, cloud, or self-hosted") { onNavigate("sync") }
                }
            }

            item {
                Text("Reports", style = MaterialTheme.typography.labelLarge, color = ConservatioColors.primary, modifier = Modifier.padding(start = 16.dp, top = 8.dp, bottom = 4.dp))
            }
            item {
                SettingsCard {
                    SettingsItem(Icons.Outlined.Description, "Templates", "Report templates") { onNavigate("templates") }
                    HorizontalDivider(modifier = Modifier.padding(horizontal = 16.dp))
                    SettingsItem(Icons.Outlined.Upload, "Export Settings", "PDF format, paper size") { onNavigate("export") }
                    HorizontalDivider(modifier = Modifier.padding(horizontal = 16.dp))
                    SettingsItem(Icons.Outlined.Language, "Language", "Report language") { onNavigate("language") }
                }
            }

            item {
                Text("App", style = MaterialTheme.typography.labelLarge, color = ConservatioColors.primary, modifier = Modifier.padding(start = 16.dp, top = 8.dp, bottom = 4.dp))
            }
            item {
                SettingsCard {
                    SettingsItem(Icons.Outlined.Palette, "Appearance", "Theme") { onNavigate("appearance") }
                    HorizontalDivider(modifier = Modifier.padding(horizontal = 16.dp))
                    SettingsItem(Icons.Outlined.Storage, "Storage", "App data usage") { onNavigate("storage") }
                    HorizontalDivider(modifier = Modifier.padding(horizontal = 16.dp))
                    SettingsItem(Icons.Outlined.Info, "About", "Version, links") { onNavigate("about") }
                }
            }
        }
    }
}

@Composable
private fun SettingsCard(content: @Composable ColumnScope.() -> Unit) {
    Card(modifier = Modifier.fillMaxWidth()) {
        Column(content = content)
    }
}

@Composable
private fun SettingsItem(
    icon: ImageVector,
    title: String,
    subtitle: String = "",
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Icon(icon, title, tint = ConservatioColors.primary)
        Column(modifier = Modifier.weight(1f)) {
            Text(title, style = MaterialTheme.typography.bodyLarge)
            if (subtitle.isNotEmpty()) {
                Text(subtitle, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
        }
        Icon(Icons.Outlined.ChevronRight, "Navigate", tint = MaterialTheme.colorScheme.onSurfaceVariant)
    }
}
