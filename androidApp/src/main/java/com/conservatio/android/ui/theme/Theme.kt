package com.conservatio.android.ui.theme

import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext

private val LightColorScheme = lightColorScheme(
    primary = Color(0xFFC25B3A),
    onPrimary = Color.White,
    primaryContainer = Color(0xFFFFDBCF),
    secondary = Color(0xFF3A6B8C),
    onSecondary = Color.White,
    secondaryContainer = Color(0xFFD0E6F5),
    tertiary = Color(0xFFD4A843),
    background = Color(0xFFFAF7F4),
    surface = Color(0xFFFFFFFF),
    surfaceVariant = Color(0xFFF2EEEA),
    onBackground = Color(0xFF1C1B1F),
    onSurface = Color(0xFF1C1B1F),
    onSurfaceVariant = Color(0xFF49454F),
    outline = Color(0xFF79747E),
)

private val DarkColorScheme = darkColorScheme(
    primary = Color(0xFFE8967A),
    onPrimary = Color(0xFF5C1A00),
    primaryContainer = Color(0xFF8B3D24),
    secondary = Color(0xFF6999B8),
    onSecondary = Color(0xFF003548),
    secondaryContainer = Color(0xFF1E4460),
    tertiary = Color(0xFFEEC96E),
    background = Color(0xFF1C1B1F),
    surface = Color(0xFF2B2930),
    surfaceVariant = Color(0xFF3B383E),
    onBackground = Color(0xFFE6E1E5),
    onSurface = Color(0xFFE6E1E5),
    onSurfaceVariant = Color(0xFFCAC4D0),
    outline = Color(0xFF938F99),
)

@Composable
fun ConservatioTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    dynamicColor: Boolean = false,
    content: @Composable () -> Unit
) {
    val colorScheme = when {
        dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            val context = LocalContext.current
            if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
        }
        darkTheme -> DarkColorScheme
        else -> LightColorScheme
    }

    MaterialTheme(
        colorScheme = colorScheme,
        content = content
    )
}
