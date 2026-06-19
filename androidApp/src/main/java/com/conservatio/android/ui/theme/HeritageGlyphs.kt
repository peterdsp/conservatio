package com.conservatio.android.ui.theme

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.unit.dp

private val defaultStroke = Color(0xFFC25B3A)
private val defaultStrokeAlpha = 0.30f

/**
 * Greek heritage monument line drawings rendered to Canvas. Mirrors the
 * SwiftUI HeritageGlyphs.swift / web HeritageBackdrop SVGs so the design
 * language is consistent across iOS / Android / web.
 */

@Composable
fun ParthenonGlyph(modifier: Modifier = Modifier, stroke: Color = defaultStroke.copy(alpha = defaultStrokeAlpha)) {
    Canvas(modifier = modifier) {
        val sx = size.width / 240f
        val sy = size.height / 120f
        val k = minOf(sx, sy)
        val offX = (size.width - 240f * k) / 2f
        val offY = (size.height - 120f * k) / 2f
        val path = Path().apply {
            // steps
            moveTo(6f, 112f); lineTo(234f, 112f)
            moveTo(14f, 105f); lineTo(226f, 105f)
            moveTo(22f, 98f); lineTo(218f, 98f)
            // architrave
            moveTo(22f, 48f); lineTo(218f, 48f)
            moveTo(22f, 55f); lineTo(218f, 55f)
            // triglyphs
            for (x in listOf(30, 60, 90, 120, 150, 180, 210)) {
                moveTo(x.toFloat(), 48f); lineTo(x.toFloat(), 55f)
            }
            // pediment
            moveTo(22f, 48f); lineTo(120f, 12f); lineTo(218f, 48f)
            // columns
            for (x in listOf(34, 60, 86, 112, 138, 164, 190, 216)) {
                val xf = x.toFloat()
                moveTo(xf - 6, 55f); lineTo(xf + 6, 55f)
                moveTo(xf - 5, 58f); lineTo(xf + 5, 58f)
                moveTo(xf - 5, 60f); lineTo(xf - 5, 96f)
                moveTo(xf + 5, 60f); lineTo(xf + 5, 96f)
                moveTo(xf - 2.5f, 62f); lineTo(xf - 2.5f, 95f)
                moveTo(xf, 62f); lineTo(xf, 95f)
                moveTo(xf + 2.5f, 62f); lineTo(xf + 2.5f, 95f)
            }
        }
        scale(k, k, pivot = androidx.compose.ui.geometry.Offset(offX, offY)) {}
        translate(offX, offY) {
            scale(k, k) {
                drawPath(path, stroke, style = Stroke(width = 1.2f, cap = StrokeCap.Round, join = StrokeJoin.Round))
            }
        }
    }
}

@Composable
fun NikeGlyph(modifier: Modifier = Modifier, stroke: Color = defaultStroke.copy(alpha = defaultStrokeAlpha)) {
    Canvas(modifier = modifier) {
        val k = minOf(size.width / 120f, size.height / 200f)
        val offX = (size.width - 120f * k) / 2f
        val offY = (size.height - 200f * k) / 2f
        translate(offX, offY) {
            scale(k, k) {
                val prow = Path().apply {
                    moveTo(22f, 175f)
                    quadraticBezierTo(60f, 170f, 96f, 178f)
                    lineTo(96f, 188f)
                    quadraticBezierTo(60f, 184f, 22f, 188f)
                    close()
                }
                drawPath(prow, stroke.copy(alpha = stroke.alpha * 0.5f))
                drawPath(prow, stroke, style = Stroke(width = 1.2f, cap = StrokeCap.Round, join = StrokeJoin.Round))

                val body = Path().apply {
                    moveTo(55f, 36f)
                    quadraticBezierTo(47f, 50f, 50f, 70f)
                    lineTo(44f, 100f)
                    quadraticBezierTo(40f, 130f, 46f, 170f)
                    lineTo(78f, 170f)
                    quadraticBezierTo(84f, 130f, 80f, 100f)
                    lineTo(74f, 70f)
                    quadraticBezierTo(78f, 50f, 70f, 36f)
                    close()
                }
                drawPath(body, stroke, style = Stroke(width = 1.2f, cap = StrokeCap.Round, join = StrokeJoin.Round))

                val folds = Path()
                for (y in listOf(80f, 100f, 120f, 140f, 158f)) {
                    folds.moveTo(47f, y)
                    folds.quadraticBezierTo(60f, y + 6, 77f, y)
                }
                folds.moveTo(70f, 48f)
                folds.quadraticBezierTo(102f, 22f, 108f, 14f)
                folds.quadraticBezierTo(90f, 50f, 80f, 70f)
                drawPath(folds, stroke.copy(alpha = stroke.alpha * 0.85f), style = Stroke(width = 0.9f, cap = StrokeCap.Round))
            }
        }
    }
}

@Composable
fun DoricColumnGlyph(modifier: Modifier = Modifier, stroke: Color = defaultStroke.copy(alpha = defaultStrokeAlpha)) {
    Canvas(modifier = modifier) {
        val k = minOf(size.width / 70f, size.height / 240f)
        val offX = (size.width - 70f * k) / 2f
        val offY = (size.height - 240f * k) / 2f
        translate(offX, offY) {
            scale(k, k) {
                val path = Path().apply {
                    addRect(androidx.compose.ui.geometry.Rect(6f, 14f, 64f, 20f))
                    moveTo(12f, 20f); quadraticBezierTo(35f, 32f, 58f, 20f)
                    moveTo(16f, 32f); lineTo(16f, 214f)
                    moveTo(54f, 32f); lineTo(54f, 214f)
                    for (x in listOf(22, 28, 35, 42, 48)) {
                        moveTo(x.toFloat(), 34f); lineTo(x.toFloat(), 212f)
                    }
                    addRect(androidx.compose.ui.geometry.Rect(6f, 214f, 64f, 221f))
                    addRect(androidx.compose.ui.geometry.Rect(2f, 221f, 68f, 227f))
                    moveTo(0f, 232f); lineTo(70f, 232f)
                }
                drawPath(path, stroke, style = Stroke(width = 1.2f, cap = StrokeCap.Round, join = StrokeJoin.Round))
            }
        }
    }
}

@Composable
fun ByzantineChurchGlyph(modifier: Modifier = Modifier, stroke: Color = defaultStroke.copy(alpha = defaultStrokeAlpha)) {
    Canvas(modifier = modifier) {
        val k = minOf(size.width / 220f, size.height / 140f)
        val offX = (size.width - 220f * k) / 2f
        val offY = (size.height - 140f * k) / 2f
        translate(offX, offY) {
            scale(k, k) {
                val path = Path().apply {
                    addRect(androidx.compose.ui.geometry.Rect(34f, 74f, 186f, 130f))
                    for (x in listOf(52, 92, 132)) {
                        val xf = x.toFloat()
                        moveTo(xf, 130f); lineTo(xf, 100f)
                        quadraticBezierTo(xf + 4, 92f, xf + 18, 92f)
                        quadraticBezierTo(xf + 22, 92f, xf + 26, 100f)
                        lineTo(xf + 26, 130f)
                    }
                    addRect(androidx.compose.ui.geometry.Rect(86f, 44f, 134f, 74f))
                    moveTo(78f, 44f); quadraticBezierTo(110f, -4f, 142f, 44f)
                    moveTo(110f, 6f); lineTo(110f, 26f)
                    moveTo(100f, 14f); lineTo(120f, 14f)
                }
                drawPath(path, stroke, style = Stroke(width = 1.2f, cap = StrokeCap.Round, join = StrokeJoin.Round))
            }
        }
    }
}

/** Drop-in heritage backdrop placed under glass content. */
@Composable
fun ConservatioHeritageBackdrop(modifier: Modifier = Modifier) {
    Box(modifier = modifier.fillMaxSize()) {
        ParthenonGlyph(
            modifier = Modifier
                .size(width = 220.dp, height = 110.dp)
                .align(Alignment.TopStart),
        )
        NikeGlyph(
            modifier = Modifier
                .size(width = 110.dp, height = 200.dp)
                .align(Alignment.TopEnd),
        )
        DoricColumnGlyph(
            modifier = Modifier
                .size(width = 60.dp, height = 220.dp)
                .align(Alignment.BottomStart),
        )
        ByzantineChurchGlyph(
            modifier = Modifier
                .size(width = 220.dp, height = 140.dp)
                .align(Alignment.BottomEnd),
        )
    }
}
