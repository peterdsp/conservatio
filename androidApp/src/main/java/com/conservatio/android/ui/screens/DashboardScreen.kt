package com.conservatio.android.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Add
import androidx.compose.material.icons.outlined.CameraAlt
import androidx.compose.material.icons.outlined.CreateNewFolder
import androidx.compose.material.icons.outlined.Description
import androidx.compose.material.icons.outlined.Inventory2
import androidx.compose.material.icons.outlined.NoteAdd
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.foundation.clickable
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.conservatio.android.data.ConservationObject
import com.conservatio.android.data.ObjectStore
import com.conservatio.android.ui.str
import com.conservatio.android.ui.theme.ConservatioAmbientBackground
import com.conservatio.android.ui.theme.ConservatioColors
import com.conservatio.android.ui.theme.ConservatioHeritageBackdrop
import com.conservatio.android.ui.theme.glassPanel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DashboardScreen(
    objectStore: ObjectStore,
    onNavigateToNewObject: () -> Unit,
    onNavigateToObjects: () -> Unit,
    onNavigateToEditObject: (String) -> Unit = {},
) {
    val objects by objectStore.objects.collectAsState()
    val reports by objectStore.reports.collectAsState()

    Box(modifier = Modifier.fillMaxSize()) {
        ConservatioAmbientBackground()
        ConservatioHeritageBackdrop()

        Scaffold(
            containerColor = Color.Transparent,
            topBar = {
                TopAppBar(
                    title = { Text(str("dash.title"), fontWeight = FontWeight.Bold) },
                    colors = TopAppBarDefaults.topAppBarColors(
                        containerColor = Color.Transparent,
                    ),
                )
            },
        ) { padding ->
            LazyColumn(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(padding)
                    .padding(horizontal = 16.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp),
                contentPadding = PaddingValues(vertical = 16.dp),
            ) {
                item { HeroCard() }

                item {
                    Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                        StatCard(str("stat.objects"), "${objects.size}", Icons.Outlined.Inventory2, Modifier.weight(1f))
                        StatCard(str("stat.reports"), "${reports.size}", Icons.Outlined.Description, Modifier.weight(1f))
                    }
                }

                item {
                    Text(
                        "Quick Actions",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.SemiBold,
                    )
                }

                item {
                    Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                        QuickActionCard(str("dash.newObject"), Icons.Outlined.Add, ConservatioColors.primary, Modifier.weight(1f)) { onNavigateToNewObject() }
                        QuickActionCard(str("dash.takePhoto"), Icons.Outlined.CameraAlt, ConservatioColors.secondary, Modifier.weight(1f)) {}
                    }
                }

                item {
                    Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                        QuickActionCard(str("dash.newReport"), Icons.Outlined.NoteAdd, ConservatioColors.tertiary, Modifier.weight(1f)) {}
                        QuickActionCard(str("dash.newProject"), Icons.Outlined.CreateNewFolder, ConservatioColors.primaryDark, Modifier.weight(1f)) {}
                    }
                }

                item {
                    Text(
                        str("dash.recentObjects"),
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.SemiBold,
                    )
                }

                if (objects.isEmpty()) {
                    item {
                        Text(
                            "No objects yet. Create your first one to get started.",
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                            modifier = Modifier.padding(vertical = 24.dp),
                        )
                    }
                } else {
                    objects.sortedByDescending { it.createdAt }.take(5).forEach { obj ->
                        item { ObjectListItem(obj) { onNavigateToEditObject(obj.id) } }
                    }
                }
            }
        }
    }
}

@Composable
private fun HeroCard() {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .glassPanel()
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        Text(
            str("dash.welcome").uppercase(),
            style = MaterialTheme.typography.labelSmall,
            color = ConservatioColors.primary,
            fontWeight = FontWeight.SemiBold,
        )
        Text(
            str("dash.title"),
            style = MaterialTheme.typography.headlineMedium,
            fontWeight = FontWeight.Bold,
        )
        Text(
            str("dash.intro"),
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
        )
    }
}

@Composable
private fun StatCard(label: String, value: String, icon: ImageVector, modifier: Modifier = Modifier) {
    Row(
        modifier = modifier
            .glassPanel(cornerRadius = 18)
            .padding(20.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Column {
            Text(label, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
            Text(value, style = MaterialTheme.typography.headlineMedium, fontWeight = FontWeight.Bold)
        }
        Icon(icon, contentDescription = label, tint = ConservatioColors.primary)
    }
}

@Composable
private fun QuickActionCard(
    title: String,
    icon: ImageVector,
    color: Color,
    modifier: Modifier = Modifier,
    onClick: () -> Unit,
) {
    Column(
        modifier = modifier
            .glassPanel(cornerRadius = 16)
            .clickable(onClick = onClick)
            .padding(20.dp)
            .fillMaxWidth(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        Icon(icon, contentDescription = title, tint = color)
        Text(title, style = MaterialTheme.typography.labelLarge)
    }
}

@Composable
private fun ObjectListItem(obj: ConservationObject, onClick: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .glassPanel(cornerRadius = 14)
            .clickable(onClick = onClick)
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Column(modifier = Modifier.weight(1f)) {
            Text(obj.title, style = MaterialTheme.typography.titleSmall, fontWeight = FontWeight.SemiBold)
            Text(obj.objectType.displayName, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
        }
    }
}
