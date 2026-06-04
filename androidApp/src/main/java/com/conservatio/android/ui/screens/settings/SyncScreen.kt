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
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import androidx.compose.foundation.lazy.LazyColumn
import com.conservatio.android.data.ObjectStore
import com.conservatio.android.data.ServerSyncClient
import com.conservatio.android.ui.theme.ConservatioColors
import kotlinx.coroutines.launch

enum class StorageMode(val label: String, val desc: String) {
    LOCAL("Local Only", "Everything stays on this device."),
    GOOGLE_DRIVE("Google Drive", "Sync to Google Drive."),
    ONEDRIVE("OneDrive", "Sync to Microsoft OneDrive."),
    SELF_HOSTED("Self-Hosted Server", "Connect to your own Conservatio server.")
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SyncScreen(objectStore: ObjectStore, onBack: () -> Unit) {
    val context = LocalContext.current
    val prefs = context.getSharedPreferences("conservatio", Context.MODE_PRIVATE)
    val syncClient = remember { ServerSyncClient(context.applicationContext) }
    val scope = rememberCoroutineScope()
    var selectedMode by remember { mutableStateOf(StorageMode.valueOf(prefs.getString("storage_mode", "LOCAL") ?: "LOCAL")) }
    var serverUrl by remember { mutableStateOf(prefs.getString("server_url", "https://api.conservatio.peterdsp.dev") ?: "") }
    var email by remember { mutableStateOf(prefs.getString("auth_email", "") ?: "") }
    var password by remember { mutableStateOf("") }
    var status by remember {
        mutableStateOf(if (syncClient.isAuthenticated) "Signed in as $email" else "Not signed in")
    }
    var autoSync by remember { mutableStateOf(prefs.getBoolean("auto_sync", true)) }
    var syncPhotos by remember { mutableStateOf(prefs.getBoolean("sync_photos", true)) }
    var wifiOnly by remember { mutableStateOf(prefs.getBoolean("wifi_only", true)) }

    fun save() {
        prefs.edit()
            .putString("storage_mode", selectedMode.name)
            .putString("server_url", serverUrl)
            .putBoolean("auto_sync", autoSync)
            .putBoolean("sync_photos", syncPhotos)
            .putBoolean("wifi_only", wifiOnly)
            .apply()
    }

    fun authenticate(register: Boolean) {
        if (email.isBlank() || password.isBlank()) {
            status = "Email and password are required."
            return
        }
        save()
        scope.launch {
            status = if (register) "Registering..." else "Signing in..."
            runCatching {
                if (register) {
                    syncClient.register(email.trim(), password, email.substringBefore("@").ifBlank { "Conservator" })
                } else {
                    syncClient.login(email.trim(), password)
                }
                objectStore.syncFromServer()
            }.onSuccess {
                status = "Signed in as ${email.trim()}. Objects synced."
            }.onFailure {
                status = it.message ?: "Sync failed."
            }
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Sync & Storage") },
                navigationIcon = { IconButton(onClick = { save(); onBack() }) { Icon(Icons.Default.ArrowBack, "Back") } }
            )
        }
    ) { padding ->
        LazyColumn(
            modifier = Modifier.fillMaxSize().padding(padding),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            item { Text("Storage Location", style = MaterialTheme.typography.titleSmall) }

            StorageMode.entries.forEach { mode ->
                item {
                    Card(
                        onClick = { selectedMode = mode },
                        colors = if (selectedMode == mode) CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.primaryContainer) else CardDefaults.cardColors()
                    ) {
                        Row(modifier = Modifier.padding(16.dp).fillMaxWidth()) {
                            Column(modifier = Modifier.weight(1f)) {
                                Text(mode.label, style = MaterialTheme.typography.bodyLarge)
                                Text(mode.desc, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
                            }
                            if (selectedMode == mode) {
                                Icon(Icons.Outlined.CheckCircle, "Selected", tint = ConservatioColors.primary)
                            }
                        }
                    }
                }
            }

            if (selectedMode == StorageMode.SELF_HOSTED) {
                item {
                    Spacer(Modifier.height(8.dp))
                    Text("Server Configuration", style = MaterialTheme.typography.titleSmall)
                    OutlinedTextField(
                        value = serverUrl, onValueChange = { serverUrl = it },
                        label = { Text("Server URL") },
                        placeholder = { Text("https://api.conservatio.peterdsp.dev") },
                        modifier = Modifier.fillMaxWidth(), singleLine = true
                    )
                }
                item {
                    OutlinedTextField(
                        value = email,
                        onValueChange = { email = it },
                        label = { Text("Email") },
                        modifier = Modifier.fillMaxWidth(),
                        singleLine = true
                    )
                }
                item {
                    OutlinedTextField(
                        value = password,
                        onValueChange = { password = it },
                        label = { Text("Password") },
                        modifier = Modifier.fillMaxWidth(),
                        singleLine = true,
                        visualTransformation = PasswordVisualTransformation()
                    )
                }
                item {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Button(
                            onClick = { authenticate(register = false) },
                            modifier = Modifier.weight(1f)
                        ) {
                            Text("Sign In")
                        }
                        Button(
                            onClick = { authenticate(register = true) },
                            modifier = Modifier.weight(1f)
                        ) {
                            Text("Register")
                        }
                    }
                }
                item {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text(status, style = MaterialTheme.typography.bodySmall)
                        TextButton(
                            onClick = {
                                save()
                                scope.launch {
                                    status = "Syncing..."
                                    objectStore.syncFromServer()
                                    status = "Objects synced."
                                }
                            }
                        ) {
                            Text("Pull From Server")
                        }
                    }
                }
            }

            if (selectedMode != StorageMode.LOCAL) {
                item {
                    Spacer(Modifier.height(8.dp))
                    Text("Sync Options", style = MaterialTheme.typography.titleSmall)
                }
                item {
                    Card {
                        Column {
                            Row(modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp).fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                                Text("Auto Sync"); Switch(checked = autoSync, onCheckedChange = { autoSync = it })
                            }
                            Row(modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp).fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                                Text("Sync Photos"); Switch(checked = syncPhotos, onCheckedChange = { syncPhotos = it })
                            }
                            Row(modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp).fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                                Text("Wi-Fi Only"); Switch(checked = wifiOnly, onCheckedChange = { wifiOnly = it })
                            }
                        }
                    }
                }
            }
        }
    }
}
