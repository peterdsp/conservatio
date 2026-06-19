package com.conservatio.android.ui.screens.settings

import android.content.Context
import android.net.Uri
import androidx.browser.customtabs.CustomTabsIntent
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
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.compose.foundation.lazy.LazyColumn
import com.conservatio.android.data.ObjectStore
import com.conservatio.android.data.OAuthCallback
import com.conservatio.android.data.ServerSyncClient
import com.conservatio.android.ui.theme.ConservatioColors
import kotlinx.coroutines.launch
import java.util.UUID

enum class StorageMode(val label: String, val desc: String) {
    LOCAL("Local Only", "Everything stays on this device."),
    GOOGLE_DRIVE("Google Drive", "Sync to Google Drive."),
    ONEDRIVE("OneDrive", "Sync to Microsoft OneDrive."),
    SELF_HOSTED("Self-Hosted Server", "Connect to your own Conservatio server.")
}

/**
 * Browser-based OAuth launcher (Chrome Custom Tabs). The provider redirects
 * back to `conservatio://oauth-callback/<provider>?code=...&state=...`; the
 * MainActivity catches that deep link and forwards it via [OAuthCallback].
 */
private enum class OAuthProvider(
    val id: String,
    val label: String,
    val authorizeUrl: String,
    val clientId: String,
    val scope: String,
) {
    GOOGLE(
        "google",
        "Continue with Google",
        "https://accounts.google.com/o/oauth2/v2/auth",
        "877268079515-bdcjldgs1mdqmjdkatsl8cg46nimd1og.apps.googleusercontent.com",
        "openid email profile",
    ),
    APPLE(
        "apple",
        "Continue with Apple",
        "https://appleid.apple.com/auth/authorize",
        "dev.peterdsp.conservatio.web",
        "name email",
    ),
    GITHUB(
        "github",
        "Continue with GitHub",
        "https://github.com/login/oauth/authorize",
        "Ov23liW3UmdSJ76Cn2ov",
        "read:user user:email",
    ),
    ;

    fun callbackUri(): String = "conservatio://oauth-callback/$id"

    fun authorizeUri(state: String): Uri {
        val builder = Uri.parse(authorizeUrl).buildUpon()
            .appendQueryParameter("client_id", clientId)
            .appendQueryParameter("redirect_uri", callbackUri())
            .appendQueryParameter("response_type", "code")
            .appendQueryParameter("scope", scope)
            .appendQueryParameter("state", state)
        if (this == APPLE) {
            builder.appendQueryParameter("response_mode", "fragment")
        }
        return builder.build()
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SyncScreen(objectStore: ObjectStore, onBack: () -> Unit) {
    val context = LocalContext.current
    val prefs = context.getSharedPreferences("conservatio", Context.MODE_PRIVATE)
    val syncClient = remember { ServerSyncClient(context.applicationContext) }
    val scope = rememberCoroutineScope()
    var selectedMode by remember {
        mutableStateOf(StorageMode.valueOf(prefs.getString("storage_mode", "LOCAL") ?: "LOCAL"))
    }
    var serverUrl by remember {
        mutableStateOf(prefs.getString("server_url", "https://conservatio-api.peterdsp.dev") ?: "")
    }
    var status by remember {
        mutableStateOf(
            if (syncClient.isAuthenticated) {
                "Signed in as ${prefs.getString("auth_email", "") ?: ""}"
            } else {
                "Not signed in"
            },
        )
    }
    var autoSync by remember { mutableStateOf(prefs.getBoolean("auto_sync", true)) }
    var syncPhotos by remember { mutableStateOf(prefs.getBoolean("sync_photos", true)) }
    var wifiOnly by remember { mutableStateOf(prefs.getBoolean("wifi_only", true)) }

    // State used to validate the deep-link callback once the browser closes.
    var pendingState by remember { mutableStateOf<String?>(null) }
    var pendingProvider by remember { mutableStateOf<OAuthProvider?>(null) }

    fun save() {
        prefs.edit()
            .putString("storage_mode", selectedMode.name)
            .putString("server_url", serverUrl)
            .putBoolean("auto_sync", autoSync)
            .putBoolean("sync_photos", syncPhotos)
            .putBoolean("wifi_only", wifiOnly)
            .apply()
    }

    fun launchOAuth(provider: OAuthProvider) {
        save()
        val state = UUID.randomUUID().toString()
        pendingState = state
        pendingProvider = provider
        status = "Opening ${provider.label}..."
        val intent = CustomTabsIntent.Builder().build()
        intent.launchUrl(context, provider.authorizeUri(state))
    }

    // Wait for MainActivity to forward the OAuth deep link, then exchange the
    // code with the backend.
    DisposableEffect(Unit) {
        val handler = OAuthCallback.OnReceive { uri ->
            val provider = pendingProvider ?: return@OnReceive false
            val expectedState = pendingState
            val params = parseOAuthParams(uri)
            val state = params["state"]
            val code = params["code"]
            if (state == null || code == null || state != expectedState) return@OnReceive false
            pendingState = null
            pendingProvider = null
            scope.launch {
                status = "Finishing sign-in..."
                runCatching {
                    syncClient.oauthExchange(
                        provider = provider.id,
                        code = code,
                        redirectUri = provider.callbackUri(),
                    )
                    objectStore.syncFromServer()
                }.onSuccess {
                    status = "Signed in. Objects synced."
                }.onFailure {
                    status = it.message ?: "Sign-in failed."
                }
            }
            true
        }
        OAuthCallback.register(handler)
        onDispose { OAuthCallback.unregister(handler) }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Sync & Storage") },
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
            item { Text("Storage Location", style = MaterialTheme.typography.titleSmall) }

            StorageMode.entries.forEach { mode ->
                item {
                    Card(
                        onClick = { selectedMode = mode },
                        colors = if (selectedMode == mode) {
                            CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.primaryContainer)
                        } else {
                            CardDefaults.cardColors()
                        },
                    ) {
                        Row(modifier = Modifier.padding(16.dp).fillMaxWidth()) {
                            Column(modifier = Modifier.weight(1f)) {
                                Text(mode.label, style = MaterialTheme.typography.bodyLarge)
                                Text(
                                    mode.desc,
                                    style = MaterialTheme.typography.bodySmall,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                                )
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
                        value = serverUrl,
                        onValueChange = { serverUrl = it },
                        label = { Text("Server URL") },
                        placeholder = { Text("https://conservatio-api.peterdsp.dev") },
                        modifier = Modifier.fillMaxWidth(),
                        singleLine = true,
                    )
                }
                item {
                    Spacer(Modifier.height(8.dp))
                    Text("Sign In", style = MaterialTheme.typography.titleSmall)
                }
                OAuthProvider.entries.forEach { provider ->
                    item {
                        Button(
                            onClick = { launchOAuth(provider) },
                            modifier = Modifier.fillMaxWidth(),
                        ) {
                            Text(provider.label)
                        }
                    }
                }
                item {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
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
                            },
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
                            Row(
                                modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp).fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween,
                            ) {
                                Text("Auto Sync"); Switch(checked = autoSync, onCheckedChange = { autoSync = it })
                            }
                            Row(
                                modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp).fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween,
                            ) {
                                Text("Sync Photos"); Switch(checked = syncPhotos, onCheckedChange = { syncPhotos = it })
                            }
                            Row(
                                modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp).fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween,
                            ) {
                                Text("Wi-Fi Only"); Switch(checked = wifiOnly, onCheckedChange = { wifiOnly = it })
                            }
                        }
                    }
                }
            }
        }
    }
}

private fun parseOAuthParams(uri: Uri): Map<String, String> {
    val out = mutableMapOf<String, String>()
    // Query params (Google / GitHub)
    uri.queryParameterNames.forEach { name ->
        uri.getQueryParameter(name)?.let { out[name] = it }
    }
    // Fragment params (Apple)
    val fragment = uri.fragment
    if (!fragment.isNullOrBlank()) {
        fragment.split("&").forEach { pair ->
            val parts = pair.split("=", limit = 2)
            if (parts.size == 2) out[parts[0]] = Uri.decode(parts[1])
        }
    }
    return out
}
