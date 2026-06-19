import SwiftUI

/// SwiftUI versions of the Greek heritage monument line drawings used as
/// decorative motifs behind the glass on the web. These are stroked shapes
/// drawn with `Path` so they scale crisply at any size.

// MARK: - Parthenon

struct ParthenonGlyph: View {
    var stroke: Color = .conservatioPrimary.opacity(0.30)

    var body: some View {
        Canvas { ctx, size in
            let s = scale(size, base: CGSize(width: 240, height: 120))
            ctx.translateBy(x: s.offsetX, y: s.offsetY)
            ctx.scaleBy(x: s.k, y: s.k)
            let line = Color.clear // unused, set per stroke

            var path = Path()
            // steps
            path.move(to: CGPoint(x: 6, y: 112)); path.addLine(to: CGPoint(x: 234, y: 112))
            path.move(to: CGPoint(x: 14, y: 105)); path.addLine(to: CGPoint(x: 226, y: 105))
            path.move(to: CGPoint(x: 22, y: 98)); path.addLine(to: CGPoint(x: 218, y: 98))
            // architrave
            path.move(to: CGPoint(x: 22, y: 48)); path.addLine(to: CGPoint(x: 218, y: 48))
            path.move(to: CGPoint(x: 22, y: 55)); path.addLine(to: CGPoint(x: 218, y: 55))
            // triglyphs
            for x in [30, 60, 90, 120, 150, 180, 210] {
                path.move(to: CGPoint(x: x, y: 48)); path.addLine(to: CGPoint(x: x, y: 55))
            }
            // pediment
            path.move(to: CGPoint(x: 22, y: 48))
            path.addLine(to: CGPoint(x: 120, y: 12))
            path.addLine(to: CGPoint(x: 218, y: 48))
            // columns with flutes
            for x in [34, 60, 86, 112, 138, 164, 190, 216] {
                let xd = Double(x)
                // capital
                path.move(to: CGPoint(x: xd - 6, y: 55)); path.addLine(to: CGPoint(x: xd + 6, y: 55))
                path.move(to: CGPoint(x: xd - 5, y: 58)); path.addLine(to: CGPoint(x: xd + 5, y: 58))
                // shaft
                path.move(to: CGPoint(x: xd - 5, y: 60)); path.addLine(to: CGPoint(x: xd - 5, y: 96))
                path.move(to: CGPoint(x: xd + 5, y: 60)); path.addLine(to: CGPoint(x: xd + 5, y: 96))
                // flutes
                for fx in [xd - 2.5, xd, xd + 2.5] {
                    path.move(to: CGPoint(x: fx, y: 62)); path.addLine(to: CGPoint(x: fx, y: 95))
                }
                _ = line
            }
            ctx.stroke(path, with: .color(stroke), style: StrokeStyle(lineWidth: 1.2, lineCap: .round, lineJoin: .round))
        }
    }
}

// MARK: - Nike of Samothrace

struct NikeGlyph: View {
    var stroke: Color = .conservatioPrimary.opacity(0.30)

    var body: some View {
        Canvas { ctx, size in
            let s = scale(size, base: CGSize(width: 120, height: 200))
            ctx.translateBy(x: s.offsetX, y: s.offsetY)
            ctx.scaleBy(x: s.k, y: s.k)

            // ship prow base (filled)
            var prow = Path()
            prow.move(to: CGPoint(x: 22, y: 175))
            prow.addQuadCurve(to: CGPoint(x: 96, y: 178), control: CGPoint(x: 60, y: 170))
            prow.addLine(to: CGPoint(x: 96, y: 188))
            prow.addQuadCurve(to: CGPoint(x: 22, y: 188), control: CGPoint(x: 60, y: 184))
            prow.closeSubpath()
            ctx.fill(prow, with: .color(stroke.opacity(0.35)))
            ctx.stroke(prow, with: .color(stroke), style: StrokeStyle(lineWidth: 1.2, lineCap: .round, lineJoin: .round))

            var body = Path()
            // drapery silhouette
            body.move(to: CGPoint(x: 55, y: 36))
            body.addQuadCurve(to: CGPoint(x: 50, y: 70), control: CGPoint(x: 47, y: 50))
            body.addLine(to: CGPoint(x: 44, y: 100))
            body.addQuadCurve(to: CGPoint(x: 46, y: 170), control: CGPoint(x: 40, y: 130))
            body.addLine(to: CGPoint(x: 78, y: 170))
            body.addQuadCurve(to: CGPoint(x: 80, y: 100), control: CGPoint(x: 84, y: 130))
            body.addLine(to: CGPoint(x: 74, y: 70))
            body.addQuadCurve(to: CGPoint(x: 70, y: 36), control: CGPoint(x: 78, y: 50))
            body.closeSubpath()
            ctx.stroke(body, with: .color(stroke), style: StrokeStyle(lineWidth: 1.2, lineCap: .round, lineJoin: .round))

            var folds = Path()
            for y in [80.0, 100.0, 120.0, 140.0, 158.0] {
                folds.move(to: CGPoint(x: 47, y: y))
                folds.addQuadCurve(to: CGPoint(x: 77, y: y), control: CGPoint(x: 60, y: y + 6))
            }
            // wing
            folds.move(to: CGPoint(x: 70, y: 48))
            folds.addQuadCurve(to: CGPoint(x: 108, y: 14), control: CGPoint(x: 102, y: 22))
            folds.addQuadCurve(to: CGPoint(x: 80, y: 70), control: CGPoint(x: 90, y: 50))
            ctx.stroke(folds, with: .color(stroke.opacity(0.8)), style: StrokeStyle(lineWidth: 0.9, lineCap: .round))
        }
    }
}

// MARK: - Doric column

struct DoricColumnGlyph: View {
    var stroke: Color = .conservatioPrimary.opacity(0.30)

    var body: some View {
        Canvas { ctx, size in
            let s = scale(size, base: CGSize(width: 70, height: 240))
            ctx.translateBy(x: s.offsetX, y: s.offsetY)
            ctx.scaleBy(x: s.k, y: s.k)

            var path = Path()
            // abacus
            path.addRect(CGRect(x: 6, y: 14, width: 58, height: 6))
            // echinus
            path.move(to: CGPoint(x: 12, y: 20))
            path.addQuadCurve(to: CGPoint(x: 58, y: 20), control: CGPoint(x: 35, y: 32))
            // shaft + flutes
            path.move(to: CGPoint(x: 16, y: 32)); path.addLine(to: CGPoint(x: 16, y: 214))
            path.move(to: CGPoint(x: 54, y: 32)); path.addLine(to: CGPoint(x: 54, y: 214))
            for x in [22, 28, 35, 42, 48] {
                path.move(to: CGPoint(x: x, y: 34)); path.addLine(to: CGPoint(x: x, y: 212))
            }
            // base
            path.addRect(CGRect(x: 6, y: 214, width: 58, height: 7))
            path.addRect(CGRect(x: 2, y: 221, width: 66, height: 6))
            path.move(to: CGPoint(x: 0, y: 232)); path.addLine(to: CGPoint(x: 70, y: 232))
            ctx.stroke(path, with: .color(stroke), style: StrokeStyle(lineWidth: 1.2, lineCap: .round, lineJoin: .round))
        }
    }
}

// MARK: - Byzantine domed church

struct ByzantineChurchGlyph: View {
    var stroke: Color = .conservatioPrimary.opacity(0.30)

    var body: some View {
        Canvas { ctx, size in
            let s = scale(size, base: CGSize(width: 220, height: 140))
            ctx.translateBy(x: s.offsetX, y: s.offsetY)
            ctx.scaleBy(x: s.k, y: s.k)

            var path = Path()
            // body
            path.addRect(CGRect(x: 34, y: 74, width: 152, height: 56))
            // arched windows
            for x in [52, 92, 132] {
                let xd = Double(x)
                path.move(to: CGPoint(x: xd, y: 130))
                path.addLine(to: CGPoint(x: xd, y: 100))
                path.addQuadCurve(to: CGPoint(x: xd + 18, y: 92), control: CGPoint(x: xd + 4, y: 92))
                path.addQuadCurve(to: CGPoint(x: xd + 26, y: 100), control: CGPoint(x: xd + 22, y: 92))
                path.addLine(to: CGPoint(x: xd + 26, y: 130))
            }
            // drum
            path.addRect(CGRect(x: 86, y: 44, width: 48, height: 30))
            // dome
            path.move(to: CGPoint(x: 78, y: 44))
            path.addQuadCurve(to: CGPoint(x: 142, y: 44), control: CGPoint(x: 110, y: -4))
            // cross
            path.move(to: CGPoint(x: 110, y: 6)); path.addLine(to: CGPoint(x: 110, y: 26))
            path.move(to: CGPoint(x: 100, y: 14)); path.addLine(to: CGPoint(x: 120, y: 14))
            ctx.stroke(path, with: .color(stroke), style: StrokeStyle(lineWidth: 1.2, lineCap: .round, lineJoin: .round))
        }
    }
}

// MARK: - Heritage backdrop

/// Drop-in backdrop placed under glass content. Sized to fill its parent,
/// the monuments tucked into the four corners.
struct ConservatioHeritageBackdrop: View {
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            ZStack {
                ParthenonGlyph()
                    .frame(width: 240, height: 120)
                    .position(x: w * 0.20, y: h * 0.22)
                NikeGlyph()
                    .frame(width: 110, height: 200)
                    .position(x: w * 0.85, y: h * 0.22)
                DoricColumnGlyph()
                    .frame(width: 60, height: 220)
                    .position(x: w * 0.08, y: h * 0.72)
                ByzantineChurchGlyph()
                    .frame(width: 220, height: 140)
                    .position(x: w * 0.80, y: h * 0.78)
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Helpers

private func scale(_ size: CGSize, base: CGSize) -> (k: Double, offsetX: Double, offsetY: Double) {
    let k = min(size.width / base.width, size.height / base.height)
    let offsetX = (size.width - base.width * k) / 2
    let offsetY = (size.height - base.height * k) / 2
    return (k, offsetX, offsetY)
}
