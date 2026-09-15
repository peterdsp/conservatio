import XCTest
import UIKit
@testable import Conservatio

/// Pure geometry checks for annotation placement. These prove markers map from
/// stored percentages to the correct point in a drawn photo rect, independent
/// of the photo's pixel size (resize) and its EXIF orientation.
final class PDFGeometryTests: XCTestCase {

    func testMarkerPointCentre() {
        let rect = CGRect(x: 10, y: 20, width: 200, height: 100)
        let p = PDFReportGenerator.markerPoint(in: rect, xPercent: 50, yPercent: 50)
        XCTAssertEqual(p.x, 110, accuracy: 0.001)
        XCTAssertEqual(p.y, 70, accuracy: 0.001)
    }

    func testMarkerPointCorners() {
        let rect = CGRect(x: 10, y: 20, width: 200, height: 100)
        let topLeft = PDFReportGenerator.markerPoint(in: rect, xPercent: 0, yPercent: 0)
        XCTAssertEqual(topLeft.x, 10, accuracy: 0.001)
        XCTAssertEqual(topLeft.y, 20, accuracy: 0.001)

        let bottomRight = PDFReportGenerator.markerPoint(in: rect, xPercent: 100, yPercent: 100)
        XCTAssertEqual(bottomRight.x, 210, accuracy: 0.001)
        XCTAssertEqual(bottomRight.y, 120, accuracy: 0.001)
    }

    /// The same percentage lands at the same relative spot regardless of the
    /// drawn size: this is what makes markers survive resizing.
    func testMarkerPointIsResolutionIndependent() {
        let small = CGRect(x: 0, y: 0, width: 200, height: 150)
        let large = CGRect(x: 0, y: 0, width: 600, height: 450)
        let ps = PDFReportGenerator.markerPoint(in: small, xPercent: 40, yPercent: 80)
        let pl = PDFReportGenerator.markerPoint(in: large, xPercent: 40, yPercent: 80)
        XCTAssertEqual(ps.x / small.width, pl.x / large.width, accuracy: 0.0001)
        XCTAssertEqual(ps.y / small.height, pl.y / large.height, accuracy: 0.0001)
    }

    func testMarkerPointClampsOutOfRange() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
        let p = PDFReportGenerator.markerPoint(in: rect, xPercent: 150, yPercent: -20)
        XCTAssertEqual(p.x, 100, accuracy: 0.001)
        XCTAssertEqual(p.y, 0, accuracy: 0.001)
    }

    func testMarkerRectCentredOnPoint() {
        let rect = CGRect(x: 0, y: 0, width: 200, height: 100)
        let box = PDFReportGenerator.markerRect(
            in: rect, xPercent: 50, yPercent: 50, widthPercent: 20, heightPercent: 40
        )
        XCTAssertEqual(box.midX, 100, accuracy: 0.001)
        XCTAssertEqual(box.midY, 50, accuracy: 0.001)
        XCTAssertEqual(box.width, 40, accuracy: 0.001)   // 20% of 200
        XCTAssertEqual(box.height, 40, accuracy: 0.001)  // 40% of 100
    }

    /// Orientation normalization must preserve the display dimensions the
    /// annotation percentages were captured against, and return an `.up` image
    /// so the drawn pixels are not rotated relative to the markers.
    func testNormalizedUpPreservesDisplaySizeAndFixesOrientation() {
        let base = solidImage(width: 100, height: 60, color: .red)
        guard let cg = base.cgImage else { return XCTFail("no cgImage") }

        // .right swaps width/height in `size` (display space).
        let rotated = UIImage(cgImage: cg, scale: base.scale, orientation: .right)
        XCTAssertEqual(rotated.size.width, 60, accuracy: 0.5)
        XCTAssertEqual(rotated.size.height, 100, accuracy: 0.5)

        let up = PDFReportGenerator.normalizedUp(rotated)
        XCTAssertEqual(up.imageOrientation, .up)
        XCTAssertEqual(up.size.width, rotated.size.width, accuracy: 0.5)
        XCTAssertEqual(up.size.height, rotated.size.height, accuracy: 0.5)
    }

    func testNormalizedUpIsNoOpForUpImage() {
        let base = solidImage(width: 80, height: 40, color: .blue)
        let up = PDFReportGenerator.normalizedUp(base)
        XCTAssertEqual(up.imageOrientation, .up)
        XCTAssertEqual(up.size.width, 80, accuracy: 0.5)
        XCTAssertEqual(up.size.height, 40, accuracy: 0.5)
    }

    private func solidImage(width: CGFloat, height: CGFloat, color: UIColor) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format).image { ctx in
            color.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
        }
    }
}
