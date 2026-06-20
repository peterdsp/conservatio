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
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Cloud
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.conservatio.android.ui.theme.ConservatioColors
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL

private data class StorageUsageData(
    val usedFormatted: String,
    val limitFormatted: String,
    val percentUsed: Float,
)

private data class ProviderItem(
    val key: String,
    val name: String,
    val color: Color,
    val letter: String,
)

private val providers = listOf(
    ProviderItem("google-drive", "Google Drive", Color(0xFF4285F4), "G"),
    ProviderItem("icloud", "iCloud", Color(0xFF147EFB), ""),
    ProviderItem("onedrive", "OneDrive", Color(0xFF00A4EF), ""),
    ProviderItem("mega", "MEGA", Color(0xFFD9272E), "M"),
    ProviderItem("dropbox", "Dropbox", Color(0xFF0061FF), "D"),
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CloudStorageScreen(onBack: () -> Unit) {
    val context = LocalContext.current
    val prefs = context.getSharedPreferences("conservatio", Context.MODE_PRIVATE)
    val token = prefs.getString("auth_token", "").orEmpty()
    val signedIn = token.isNotBlank()
    val serverUrl = prefs.getString("server_url", "").orEmpty().trim().trimEnd('/')
        .ifBlank { "https://conservatio-api.peterdsp.dev" }

    var usage by remember { mutableStateOf<StorageUsageData?>(null) }
    var error by remember { mutableStateOf<String?>(null) }
    var interested by remember {
        mutableStateOf(
            prefs.getStringSet("provider_interest", emptySet())?.toSet() ?: emptySet()
        )
    }

    LaunchedEffect(signedIn) {
        if (!signedIn) return@LaunchedEffect
        withContext(Dispatchers.IO) {
            try {
                val conn = URL("$serverUrl/api/storage/usage").openConnection() as HttpURLConnection
                conn.setRequestProperty("Authorization", "Bearer $token")
                val status = conn.responseCode
                val text = conn.inputStream.bufferedReader().use { it.readText() }
                conn.disconnect()
                if (status in 200..299) {
                    val json = JSONObject(text)
                    usage = StorageUsageData(
                        usedFormatted = json.getString("usedFormatted"),
                        limitFormatted = json.getString("limitFormatted"),
                        percentUsed = json.getDouble("percentUsed").toFloat(),
                    )
                } else {
                    error = "Could not fetch storage usage."
                }
            } catch (e: Exception) {
                error = e.message ?: "Network error"
            }
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Cloud Storage") },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Default.ArrowBack, "Back")
                    }
                },
            )
        },
    ) { padding ->
        LazyColumn(
            modifier = Modifier.fillMaxSize().padding(padding),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            // Conservatio Cloud
            item {
                Card(modifier = Modifier.fillMaxWidth()) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(
                                Icons.Default.Cloud,
                                "Cloud",
                                tint = ConservatioColors.primary,
                                modifier = Modifier.size(32.dp),
                            )
                            Spacer(Modifier.width(12.dp))
                            Column(modifier = Modifier.weight(1f)) {
                                Text("Conservatio Cloud", fontWeight = FontWeight.SemiBold)
                                Text(
                                    "Included with every account. 2 GB free, then upgradeable.",
                                    style = MaterialTheme.typography.bodySmall,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                                )
                            }
                            Surface(
                                shape = RoundedCornerShape(50),
                                color = if (signedIn) Color(0x2200C853) else MaterialTheme.colorScheme.surfaceVariant,
                            ) {
                                Text(
                                    if (signedIn) "CONNECTED" else "OFFLINE",
                                    modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp),
                                    fontSize = 10.sp,
                                    fontWeight = FontWeight.SemiBold,
                                    color = if (signedIn) Color(0xFF00C853) else MaterialTheme.colorScheme.onSurfaceVariant,
                                )
                            }
                        }
                        Spacer(Modifier.height(16.dp))
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                        ) {
                            Text("Storage used", style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
                            Text(
                                when {
                                    usage != null -> "${usage!!.usedFormatted} / ${usage!!.limitFormatted} · ${"%.1f".format(usage!!.percentUsed)}%"
                                    signedIn -> "…"
                                    else -> "Sign in to see your cloud usage."
                                },
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                            )
                        }
                        Spacer(Modifier.height(8.dp))
                        LinearProgressIndicator(
                            progress = { (usage?.percentUsed ?: 0f) / 100f },
                            modifier = Modifier.fillMaxWidth().height(6.dp),
                            color = ConservatioColors.primary,
                            trackColor = MaterialTheme.colorScheme.surfaceVariant,
                        )
                        if (error != null) {
                            Spacer(Modifier.height(4.dp))
                            Text(error!!, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.error)
                        }
                    }
                }
            }

            // Other providers
            item {
                Text(
                    "Other providers",
                    style = MaterialTheme.typography.titleSmall,
                    modifier = Modifier.padding(top = 4.dp),
                )
                Spacer(Modifier.height(4.dp))
                Text(
                    "Connecting a third-party provider lets Conservatio mirror your records and photos there. None are wired yet; tap to express interest.",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }

            providers.forEach { provider ->
                item {
                    val noted = interested.contains(provider.key)
                    Card(
                        onClick = {
                            val next = interested + provider.key
                            interested = next
                            prefs.edit().putStringSet("provider_interest", next).apply()
                        },
                        modifier = Modifier.fillMaxWidth(),
                        colors = CardDefaults.cardColors(
                            containerColor = MaterialTheme.colorScheme.surfaceContainerLow,
                        ),
                    ) {
                        Row(
                            modifier = Modifier.padding(horizontal = 16.dp, vertical = 12.dp).fillMaxWidth(),
                            verticalAlignment = Alignment.CenterVertically,
                        ) {
                            Surface(
                                shape = RoundedCornerShape(8.dp),
                                color = provider.color.copy(alpha = 0.15f),
                                modifier = Modifier.size(28.dp),
                            ) {
                                if (provider.letter.isNotEmpty()) {
                                    Text(
                                        provider.letter,
                                        modifier = Modifier.padding(4.dp),
                                        color = provider.color,
                                        fontWeight = FontWeight.Bold,
                                        fontSize = 12.sp,
                                    )
                                } else {
                                    Icon(
                                        Icons.Default.Cloud,
                                        provider.name,
                                        modifier = Modifier.padding(4.dp).size(20.dp),
                                        tint = provider.color,
                                    )
                                }
                            }
                            Spacer(Modifier.width(12.dp))
                            Text(provider.name, modifier = Modifier.weight(1f), style = MaterialTheme.typography.bodyLarge)
                            if (noted) {
                                Icon(Icons.Default.Check, "Noted", tint = Color(0xFF00C853), modifier = Modifier.size(16.dp))
                                Spacer(Modifier.width(4.dp))
                                Text("Noted", fontSize = 10.sp, fontWeight = FontWeight.SemiBold, color = Color(0xFF00C853))
                            } else {
                                Surface(
                                    shape = RoundedCornerShape(50),
                                    color = MaterialTheme.colorScheme.surfaceVariant,
                                ) {
                                    Text(
                                        "COMING SOON",
                                        modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp),
                                        fontSize = 10.sp,
                                        fontWeight = FontWeight.SemiBold,
                                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
