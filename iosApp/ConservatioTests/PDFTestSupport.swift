import UIKit
import PDFKit
@testable import Conservatio

/// Shared fixtures for the PDF tests: a synthetic photo with known reference
/// points and a representative object + report carrying positioned markers.
enum PDFTestSupport {

    static let photoId = "test-photo-1"

    /// Draws an 800x600 photo split into four coloured quadrants with a centre
    /// crosshair and quadrant dots at 25/75 percent, so a marker placed at a
    /// known percentage can be visually confirmed to land on the right spot.
    static func syntheticPhoto() -> UIImage {
        let size = CGSize(width: 800, height: 600)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let g = ctx.cgContext
            let quads: [(CGRect, UIColor)] = [
                (CGRect(x: 0, y: 0, width: 400, height: 300), UIColor(white: 0.85, alpha: 1)),
                (CGRect(x: 400, y: 0, width: 400, height: 300), UIColor(white: 0.72, alpha: 1)),
                (CGRect(x: 0, y: 300, width: 400, height: 300), UIColor(white: 0.72, alpha: 1)),
                (CGRect(x: 400, y: 300, width: 400, height: 300), UIColor(white: 0.85, alpha: 1)),
            ]
            for (rect, color) in quads {
                color.setFill()
                g.fill(rect)
            }
            // Centre crosshair
            UIColor.black.setStroke()
            let cross = UIBezierPath()
            cross.move(to: CGPoint(x: 400, y: 280)); cross.addLine(to: CGPoint(x: 400, y: 320))
            cross.move(to: CGPoint(x: 380, y: 300)); cross.addLine(to: CGPoint(x: 420, y: 300))
            cross.lineWidth = 2
            cross.stroke()
        }
    }

    static func sampleObject() -> ConservationObject {
        ConservationObject(
            title: "Saint Nicholas panel icon",
            objectType: .icon,
            materials: ["tempera", "wood panel", "gold leaf"],
            dimensions: Dimensions(height: 45, width: 32, depth: 3, unit: .cm),
            ownerName: "Agios Nikolaos Church",
            locationDescription: "North nave storage cabinet",
            inventoryNumber: "CN-1842-07",
            description: "Panel icon with edge abrasions and localized flaking.",
            imageIds: [photoId]
        )
    }

    /// A report whose user-entered text is deliberately distinctive so tests
    /// can assert it is never translated.
    static let userNotes = "Surface grime across the lower third of the panel."
    static let userRecommendations = "Consolidate flaking areas.\nSurface clean with conservation-grade solvent.\nInpaint losses with reversible media."
    static let crackDescription = "Vertical crack running through the halo."
    static let paintLossDescription = "Localized paint loss near the base moulding."

    static func sampleReport() -> ConditionReport {
        ConditionReport(
            objectId: sampleObject().id,
            reportType: .initialAssessment,
            overallCondition: .poor,
            examiner: "A. Boura",
            examinationDate: Date(timeIntervalSince1970: 1_788_700_000), // stable date
            damageAnnotations: [
                DamageAnnotation(
                    damageType: .crack,
                    severity: .severe,
                    description: crackDescription,
                    imageId: photoId,
                    xPercent: 25,
                    yPercent: 30
                ),
                DamageAnnotation(
                    damageType: .paintLoss,
                    severity: .moderate,
                    description: paintLossDescription,
                    imageId: photoId,
                    xPercent: 70,
                    yPercent: 65
                ),
                // Non-positional damage: appears in the summary, not as a marker.
                DamageAnnotation(
                    damageType: .surfaceDirt,
                    severity: .minor,
                    description: "General surface grime.",
                    imageId: nil
                ),
            ],
            notes: userNotes,
            recommendations: userRecommendations,
            imageIds: [photoId]
        )
    }

    static func samplePhotos() -> [ReportPhoto] {
        [ReportPhoto(id: photoId, image: syntheticPhoto())]
    }

    /// Extracts all text from a generated PDF for assertions.
    static func text(in data: Data) -> String {
        guard let doc = PDFDocument(data: data) else { return "" }
        var out = ""
        for i in 0..<doc.pageCount {
            out += doc.page(at: i)?.string ?? ""
            out += "\n"
        }
        return out
    }
}
