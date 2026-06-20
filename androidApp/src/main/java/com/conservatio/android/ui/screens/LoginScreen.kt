package com.conservatio.android.ui.screens

import android.content.Context
import androidx.browser.customtabs.CustomTabsIntent
import android.net.Uri
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Shield
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.foundation.clickable
import androidx.compose.foundation.shape.RoundedCornerShape
import com.conservatio.android.data.OAuthCallback
import com.conservatio.android.data.ServerSyncClient
import com.conservatio.android.ui.LocalLanguageCode
import com.conservatio.android.ui.Strings
import com.conservatio.android.ui.str
import com.conservatio.android.ui.theme.ConservatioAmbientBackground
import com.conservatio.android.ui.theme.ConservatioColors
import com.conservatio.android.ui.theme.ConservatioHeritageBackdrop
import com.conservatio.android.ui.theme.glassPanel
import com.conservatio.android.ui.theme.glassPrimaryBackground
import kotlinx.coroutines.launch
import java.util.UUID

/**
 * Splash-level OAuth-only entry. Mirrors the iOS LoginView and the web
 * LoginScreen: ambient glass backdrop, heritage monuments, three glass
 * pill buttons, no email/password.
 */

private enum class OAuthProvider(
    val id: String,
    val labelKey: String,
    val authorizeUrl: String,
    val clientId: String,
    val scope: String,
) {
    GOOGLE(
        "google",
        "login.continueGoogle",
        "https://accounts.google.com/o/oauth2/v2/auth",
        "877268079515-bdcjldgs1mdqmjdkatsl8cg46nimd1og.apps.googleusercontent.com",
        "openid email profile",
    ),
    APPLE(
        "apple",
        "login.continueApple",
        "https://appleid.apple.com/auth/authorize",
        "dev.peterdsp.conservatio.web",
        "name email",
    ),
    GITHUB(
        "github",
        "login.continueGitHub",
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
        if (this == APPLE) builder.appendQueryParameter("response_mode", "fragment")
        return builder.build()
    }
}

@Composable
fun LoginScreen(onSignedIn: () -> Unit) {
    val context = LocalContext.current
    val syncClient = remember { ServerSyncClient(context.applicationContext) }
    val scope = rememberCoroutineScope()
    var pendingProvider by remember { mutableStateOf<OAuthProvider?>(null) }
    var pendingState by remember { mutableStateOf<String?>(null) }
    var status by remember { mutableStateOf<String?>(null) }
    var errorText by remember { mutableStateOf<String?>(null) }

    val langCode = LocalLanguageCode.current
    fun launch(provider: OAuthProvider) {
        val state = UUID.randomUUID().toString()
        pendingProvider = provider
        pendingState = state
        status = Strings.t(langCode, "login.finishingOauth")
        errorText = null
        val intent = CustomTabsIntent.Builder().build()
        intent.launchUrl(context, provider.authorizeUri(state))
    }

    DisposableEffect(Unit) {
        val handler = OAuthCallback.OnReceive { uri ->
            val provider = pendingProvider ?: return@OnReceive false
            val params = parseOAuthParams(uri)
            if (params["state"] != pendingState) return@OnReceive false
            val code = params["code"] ?: return@OnReceive false
            pendingState = null
            pendingProvider = null
            scope.launch {
                runCatching {
                    syncClient.oauthExchange(provider.id, code, provider.callbackUri())
                }.onSuccess { onSignedIn() }
                    .onFailure { errorText = Strings.t(langCode, "login.errSignIn") }
                status = null
            }
            true
        }
        OAuthCallback.register(handler)
        onDispose { OAuthCallback.unregister(handler) }
    }

    Box(modifier = Modifier.fillMaxSize()) {
        ConservatioAmbientBackground()
        ConservatioHeritageBackdrop()

        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 32.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
        ) {
            // Logo plaque
            Box(
                modifier = Modifier
                    .size(88.dp)
                    .glassPanel(cornerRadius = 28),
                contentAlignment = Alignment.Center,
            ) {
                Icon(
                    Icons.Outlined.Shield,
                    contentDescription = null,
                    tint = ConservatioColors.primary,
                    modifier = Modifier.size(40.dp),
                )
            }

            Spacer(Modifier.height(22.dp))
            Text(
                "Conservatio",
                style = MaterialTheme.typography.headlineMedium,
                color = ConservatioColors.primary,
                fontWeight = FontWeight.SemiBold,
            )

            Spacer(Modifier.height(32.dp))

            OAuthProvider.entries.forEach { provider ->
                ProviderButton(
                    label = str(provider.labelKey),
                    isBusy = pendingProvider == provider,
                ) { launch(provider) }
                Spacer(Modifier.height(10.dp))
            }

            errorText?.let {
                Spacer(Modifier.height(12.dp))
                Text(it, color = Color(0xFFD32F2F), style = MaterialTheme.typography.bodySmall)
            }
            status?.let {
                Spacer(Modifier.height(12.dp))
                Text(it, color = MaterialTheme.colorScheme.onSurfaceVariant, style = MaterialTheme.typography.bodySmall)
            }
        }
    }
}

@Composable
private fun ProviderButton(label: String, isBusy: Boolean, onClick: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .glassPanel(cornerRadius = 18)
            .clickable(enabled = !isBusy, onClick = onClick)
            .padding(vertical = 14.dp, horizontal = 18.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.Center,
    ) {
        Text(label, fontWeight = FontWeight.SemiBold, color = ConservatioColors.text)
        if (isBusy) {
            Spacer(Modifier.width(12.dp))
            CircularProgressIndicator(modifier = Modifier.size(16.dp), strokeWidth = 2.dp)
        }
    }
}

private fun parseOAuthParams(uri: Uri): Map<String, String> {
    val out = mutableMapOf<String, String>()
    uri.queryParameterNames.forEach { name ->
        uri.getQueryParameter(name)?.let { out[name] = it }
    }
    val fragment = uri.fragment
    if (!fragment.isNullOrBlank()) {
        fragment.split("&").forEach { pair ->
            val parts = pair.split("=", limit = 2)
            if (parts.size == 2) out[parts[0]] = Uri.decode(parts[1])
        }
    }
    return out
}
