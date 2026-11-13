import XCTest
import PDFKit
@testable import Conservatio

/// Verifies the exported report honours the report language and the export
/// content toggles, and that user-entered text is printed verbatim (never
/// translated) in every language.
final class PDFReportLanguageTests: XCTestCase {

    private func generate(_ language: ReportLanguage,
                          includePhotos: Bool = true,
                          includeAnnotations: Bool = true,
                          includeGauge: Bool = true) -> String {
        let options = PDFExportOptions(
            language: language,
            paperSize: .a4,
            includePhotos: includePhotos,
            includeAnnotations: includeAnnotations,
            includeConditionGauge: includeGauge
        )
        let data = PDFReportGenerator().generateReport(
            object: PDFTestSupport.sampleObject(),
            report: PDFTestSupport.sampleReport(),
            photos: PDFTestSupport.samplePhotos(),
            conservatorName: "A. Boura",
            options: options
        )
        XCTAssertNotNil(PDFDocument(data: data), "generated PDF must be a valid document")
        return PDFTestSupport.text(in: data)
    }

    // MARK: Language of headings and vocabulary

    func testEnglishHeadingsAndVocabulary() {
        let t = generate(.english)
        XCTAssertTrue(t.contains("CONDITION REPORT"))
        XCTAssertTrue(t.contains("OBJECT"))
        XCTAssertTrue(t.contains("CONDITION SUMMARY"))
        XCTAssertTrue(t.contains("PHOTO DOCUMENTATION"))
        XCTAssertTrue(t.contains("Crack"))
        XCTAssertTrue(t.contains("Paint Loss"))
        XCTAssertTrue(t.contains("Severe"))
        XCTAssertFalse(t.contains("ΕΚΘΕΣΗ"), "English report must not contain Greek headings")
    }

    // Note: PDFKit's text extraction cannot reliably recover Greek glyphs from
    // the font subset UIKit embeds, so Greek headings are validated at the
    // localization source (`ReportL10n`) below, and the rendered Greek output
    // is inspected visually via `PDFArtifactRendererTests`. The Greek report
    // must still not carry English headings, which we can assert because the
    // English strings would extract if present.
    func testGreekReportHasNoEnglishHeadings() {
        let t = generate(.greek)
        XCTAssertFalse(t.contains("CONDITION REPORT"))
        XCTAssertFalse(t.contains("OBJECT"))
        XCTAssertFalse(t.contains("CONDITION SUMMARY"))
        XCTAssertFalse(t.contains("PHOTO DOCUMENTATION"))
    }

    func testGreekVocabularyAtSource() {
        let g = ReportL10n(.greek)
        XCTAssertEqual(g.conditionReportTitle, "ΕΚΘΕΣΗ ΚΑΤΑΣΤΑΣΗΣ")
        XCTAssertEqual(g.objectSection, "ΑΝΤΙΚΕΙΜΕΝΟ")
        XCTAssertEqual(g.damageType(.crack), "Ρωγμή")
        XCTAssertEqual(g.damageType(.paintLoss), "Απώλεια χρώματος")
        XCTAssertEqual(g.severity(.severe), "Σοβαρή")
        XCTAssertEqual(g.conditionRating(.poor), "Κακή")
        XCTAssertEqual(g.objectType(.icon), "Εικόνα")
    }

    func testBilingualVocabularyAtSource() {
        let b = ReportL10n(.bilingual)
        XCTAssertEqual(b.conditionReportTitle, "ΕΚΘΕΣΗ ΚΑΤΑΣΤΑΣΗΣ / CONDITION REPORT")
        XCTAssertEqual(b.damageType(.crack), "Ρωγμή / Crack")
        XCTAssertEqual(b.severity(.severe), "Σοβαρή / Severe")
    }

    func testBilingualPDFContainsEnglishHalf() {
        // The English half of the bilingual output extracts cleanly.
        let t = generate(.bilingual)
        XCTAssertTrue(t.contains("CONDITION REPORT"))
        XCTAssertTrue(t.contains("Crack"))
        XCTAssertTrue(t.contains("OBJECT"))
    }

    func testLanguageChangesOutput() {
        let en = PDFReportGenerator().generateReport(
            object: PDFTestSupport.sampleObject(), report: PDFTestSupport.sampleReport(),
            photos: PDFTestSupport.samplePhotos(), conservatorName: "A. Boura",
            options: PDFExportOptions(language: .english, paperSize: .a4, includePhotos: true, includeAnnotations: true, includeConditionGauge: true)
        )
        let el = PDFReportGenerator().generateReport(
            object: PDFTestSupport.sampleObject(), report: PDFTestSupport.sampleReport(),
            photos: PDFTestSupport.samplePhotos(), conservatorName: "A. Boura",
            options: PDFExportOptions(language: .greek, paperSize: .a4, includePhotos: true, includeAnnotations: true, includeConditionGauge: true)
        )
        XCTAssertNotEqual(en, el, "changing report language must change the PDF")
    }

    // MARK: User text is never translated

    func testUserTextPreservedVerbatimInGreek() {
        let t = generate(.greek)
        XCTAssertTrue(t.contains("Saint Nicholas panel icon"), "object title stays as typed")
        XCTAssertTrue(t.contains("Agios Nikolaos Church"), "owner stays as typed")
        XCTAssertTrue(t.contains("CN-1842-07"), "inventory number stays as typed")
        XCTAssertTrue(t.contains("A. Boura"), "examiner stays as typed")
        XCTAssertTrue(t.contains(PDFTestSupport.crackDescription), "annotation description stays as typed")
        XCTAssertTrue(t.contains("Surface grime across the lower third"), "notes stay as typed")
        XCTAssertTrue(t.contains("Consolidate flaking areas"), "recommendations stay as typed")
    }

    func testUserTextPreservedVerbatimInBilingual() {
        let t = generate(.bilingual)
        XCTAssertTrue(t.contains("Saint Nicholas panel icon"))
        XCTAssertTrue(t.contains(PDFTestSupport.paintLossDescription))
    }

    // MARK: Export content toggles

    func testAnnotationsToggleSuppressesPhotoDocumentation() {
        let with = generate(.english, includeAnnotations: true)
        XCTAssertTrue(with.contains("PHOTO DOCUMENTATION"))

        let without = generate(.english, includeAnnotations: false)
        XCTAssertFalse(without.contains("PHOTO DOCUMENTATION"))
        // Damage still summarised textually.
        XCTAssertTrue(without.contains("CONDITION SUMMARY"))
    }

    func testPhotosToggleSuppressesPhotoDocumentation() {
        let without = generate(.english, includePhotos: false)
        XCTAssertFalse(without.contains("PHOTO DOCUMENTATION"))
    }

    func testGaugeToggle() {
        let with = generate(.english, includeGauge: true)
        XCTAssertTrue(with.contains("CONDITION RATING"))
        let without = generate(.english, includeGauge: false)
        XCTAssertFalse(without.contains("CONDITION RATING"))
    }

    // MARK: Stored-value mapping

    func testReportLanguageFromStoredValue() {
        XCTAssertEqual(ReportLanguage.fromStoredValue("en"), .english)
        XCTAssertEqual(ReportLanguage.fromStoredValue("el"), .greek)
        XCTAssertEqual(ReportLanguage.fromStoredValue("el+en"), .bilingual)
        XCTAssertEqual(ReportLanguage.fromStoredValue("it"), .english, "unsupported value falls back to English")
        XCTAssertEqual(ReportLanguage.fromStoredValue(nil), .english)
    }
}
