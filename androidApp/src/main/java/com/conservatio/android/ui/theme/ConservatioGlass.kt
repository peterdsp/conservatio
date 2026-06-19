package com.conservatio.android.ui.theme

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp

/**
 * Conservatio liquid-glass design language for Android. Mirrors the iOS
 * `ConservatioGlass.swift` and the web `.glass-*` primitives so all three
 * platforms render the same material.
 *
 * Android can't do live-blur on arbitrary content the way iOS can with
 * `.ultraThinMaterial` (it would require a `RenderEffect` + a layer copy,
 * which is fragile across vendors and SDK levels). Instead we approximate
 * the look with very translucent white surfaces, soft inset rings, layered
 * shadows, and a top specular highlight. Google's own "Material You" /
 * Privacy Sandbox dialogs ship this look on stock Android.
 */
object ConservatioGlass {
    val cardColor = Color(0xCCFFFFFF)   // ~80% white
    val cardTint = Color(0x80FFFFFF)
    val ringColor = Color(0x66FFFFFF)
    val ambientPeach = Color(0xFFE8B89E)
    val ambientBlue = Color(0xFFAAC5DC)
    val ambientCream = Color(0xFFFFE0C5)
}

/** Ambient peach + blue + cream backdrop. Place under content. */
@Composable
fun ConservatioAmbientBackground() {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.linearGradient(
                    colors = listOf(
                        Color(0xFFFAF5F0),
                        Color(0xFFF5EDE5),
                    ),
                ),
            )
            .background(
                Brush.radialGradient(
                    colors = listOf(ConservatioGlass.ambientPeach.copy(alpha = 0.55f), Color.Transparent),
                    center = Offset(x = -300f, y = -300f),
                    radius = 900f,
                ),
            )
            .background(
                Brush.radialGradient(
                    colors = listOf(ConservatioGlass.ambientBlue.copy(alpha = 0.5f), Color.Transparent),
                    center = Offset(x = 2200f, y = -300f),
                    radius = 900f,
                ),
            )
            .background(
                Brush.radialGradient(
                    colors = listOf(ConservatioGlass.ambientCream.copy(alpha = 0.5f), Color.Transparent),
                    center = Offset(x = 1100f, y = 2400f),
                    radius = 1000f,
                ),
            ),
    )
}

/** Standard glass panel modifier. */
fun Modifier.glassPanel(cornerRadius: Int = 24): Modifier =
    this
        .shadow(
            elevation = 16.dp,
            shape = RoundedCornerShape(cornerRadius.dp),
            ambientColor = Color(0x33000000),
            spotColor = Color(0x55000000),
        )
        .background(
            color = ConservatioGlass.cardColor,
            shape = RoundedCornerShape(cornerRadius.dp),
        )
        .background(
            brush = Brush.verticalGradient(
                colors = listOf(
                    Color(0x66FFFFFF),
                    Color(0x00FFFFFF),
                ),
                startY = 0f,
                endY = 220f,
            ),
            shape = RoundedCornerShape(cornerRadius.dp),
        )
        .border(
            width = 1.dp,
            color = ConservatioGlass.ringColor,
            shape = RoundedCornerShape(cornerRadius.dp),
        )

/** Tighter glass surface for chips, badges, search bars. */
fun Modifier.glassChip(): Modifier = glassPanel(cornerRadius = 14)

/** Primary glass CTA button background (use behind a Button content). */
fun Modifier.glassPrimaryBackground(): Modifier =
    this
        .shadow(
            elevation = 12.dp,
            shape = RoundedCornerShape(18.dp),
            ambientColor = Color(0x55C25B3A),
            spotColor = Color(0x66C25B3A),
        )
        .background(
            brush = Brush.verticalGradient(
                colors = listOf(
                    Color(0xFFC25B3A),
                    Color(0xFF8B3D24),
                ),
            ),
            shape = RoundedCornerShape(18.dp),
        )
        .border(
            width = 1.dp,
            color = Color(0x55FFFFFF),
            shape = RoundedCornerShape(18.dp),
        )

/** Material 3 colors picked to harmonise with the glass palette. */
@Composable
fun glassSurfaceColor() = MaterialTheme.colorScheme.surface.copy(alpha = 0.7f)
