import XCTest
import PDFKit
import UIKit
@testable import Conservatio

/// Not a pass/fail test: it writes representative PDFs and page PNGs into the
/// app container so the rendered output can be inspected outside the simulator.
/// Files land in Documents/pdf_artifacts.
final class PDFArtifactRendererTests: XCTestCase {

    func testWriteRepresentativePDFs() throws {
        let dir = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("pdf_artifacts", isDirectory: true)
        try? FileManager.default.removeItem(at: dir)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        let variants: [(String, PDFExportOptions)] = [
            ("english", PDFExportOptions(language: .english, paperSize: .a4, includePhotos: true, includeAnnotations: true, includeConditionGauge: true)),
            ("greek", PDFExportOptions(language: .greek, paperSize: .a4, includePhotos: true, includeAnnotations: true, includeConditionGauge: true)),
            ("bilingual", PDFExportOptions(language: .bilingual, paperSize: .a4, includePhotos: true, includeAnnotations: true, includeConditionGauge: true)),
            ("english-no-annotations", PDFExportOptions(language: .english, paperSize: .a4, includePhotos: true, includeAnnotations: false, includeConditionGauge: true)),
            ("letter-bilingual", PDFExportOptions(language: .bilingual, paperSize: .letter, includePhotos: true, includeAnnotations: true, includeConditionGauge: true)),
        ]

        for (name, options) in variants {
            let data = PDFReportGenerator().generateReport(
                object: PDFTestSupport.sampleObject(),
                report: PDFTestSupport.sampleReport(),
                photos: PDFTestSupport.samplePhotos(),
                conservatorName: "A. Boura",
                options: options
            )
            let pdfURL = dir.appendingPathComponent("\(name).pdf")
            try data.write(to: pdfURL)

            guard let doc = PDFDocument(data: data) else {
                XCTFail("could not parse \(name)")
                continue
            }
            for pageIndex in 0..<doc.pageCount {
                guard let page = doc.page(at: pageIndex) else { continue }
                let bounds = page.bounds(for: .mediaBox)
                let scale: CGFloat = 2.0
                let format = UIGraphicsImageRendererFormat()
                format.scale = 1
                let renderer = UIGraphicsImageRenderer(
                    size: CGSize(width: bounds.width * scale, height: bounds.height * scale),
                    format: format
                )
                let png = renderer.pngData { ctx in
                    UIColor.white.set()
                    ctx.fill(CGRect(origin: .zero, size: CGSize(width: bounds.width * scale, height: bounds.height * scale)))
                    ctx.cgContext.translateBy(x: 0, y: bounds.height * scale)
                    ctx.cgContext.scaleBy(x: scale, y: -scale)
                    page.draw(with: .mediaBox, to: ctx.cgContext)
                }
                let pngURL = dir.appendingPathComponent("\(name)-page\(pageIndex + 1).png")
                try png.write(to: pngURL)
            }
        }

        print("PDF_ARTIFACTS_DIR=\(dir.path)")
        XCTAssertTrue(FileManager.default.fileExists(atPath: dir.path))
    }
}
