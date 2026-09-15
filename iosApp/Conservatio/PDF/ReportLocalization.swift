import Foundation
import UIKit

/// Report output language. This is independent of the app's display language
/// (`LanguagePreference`). It only controls the fixed headings, field labels,
/// controlled vocabulary, and dates that Conservatio prints in an exported
/// PDF. User-entered text (titles, notes, recommendations, descriptions,
/// materials, owner, location, examiner) is always printed verbatim and is
/// never translated.
enum ReportLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case greek = "el"
    /// Bilingual Greek / English, in that order.
    case bilingual = "el+en"

    var id: String { rawValue }

    /// The value persisted by `LanguageSettingsView` under `reportLanguage`.
    /// Anything unrecognised falls back to English so an old or unsupported
    /// stored value never produces an empty report.
    static func fromStoredValue(_ value: String?) -> ReportLanguage {
        guard let value else { return .english }
        return ReportLanguage(rawValue: value) ?? .english
    }
}

/// Paper size for the exported page. Mirrors the choices in
/// `ExportSettingsView`.
enum ReportPaperSize: String {
    case a4 = "A4"
    case letter = "Letter"

    /// Point size at 72 dpi.
    var pointSize: CGSize {
        switch self {
        case .a4: return CGSize(width: 595.0, height: 842.0)
        case .letter: return CGSize(width: 612.0, height: 792.0)
        }
    }
}

/// Options that drive PDF generation, sourced from the settings the user has
/// already chosen in Settings. Reading them from `UserDefaults` keeps the two
/// call sites (object detail and the export button) to a single line.
struct PDFExportOptions {
    var language: ReportLanguage
    var paperSize: ReportPaperSize
    var includePhotos: Bool
    var includeAnnotations: Bool
    var includeConditionGauge: Bool

    static let `default` = PDFExportOptions(
        language: .english,
        paperSize: .a4,
        includePhotos: true,
        includeAnnotations: true,
        includeConditionGauge: true
    )

    /// Builds options from the same UserDefaults keys the settings screens
    /// write to. Missing keys fall back to the shipped defaults (photos,
    /// annotations, and the gauge on; A4; English).
    static func fromUserDefaults(_ defaults: UserDefaults = .standard) -> PDFExportOptions {
        PDFExportOptions(
            language: ReportLanguage.fromStoredValue(defaults.string(forKey: "reportLanguage")),
            paperSize: ReportPaperSize(rawValue: defaults.string(forKey: "paperSize") ?? "A4") ?? .a4,
            includePhotos: defaults.object(forKey: "includePhotos") as? Bool ?? true,
            includeAnnotations: defaults.object(forKey: "includeAnnotations") as? Bool ?? true,
            includeConditionGauge: defaults.object(forKey: "includeConditionGauge") as? Bool ?? true
        )
    }
}

/// Resolves fixed report strings and controlled vocabulary into the chosen
/// report language. English strings come from the model `displayName`s so the
/// PDF and the app stay in sync; Greek strings live here as the single Greek
/// source for report output.
struct ReportL10n {
    let language: ReportLanguage

    init(_ language: ReportLanguage) {
        self.language = language
    }

    /// Picks an English or Greek label, or both for the bilingual report.
    /// Bilingual is rendered Greek first, then English, separated by " / ".
    func pick(en: String, el: String) -> String {
        switch language {
        case .english: return en
        case .greek: return el
        case .bilingual:
            if en == el { return en }
            return "\(el) / \(en)"
        }
    }

    // MARK: Fixed headings and labels

    var conditionReportTitle: String { pick(en: "CONDITION REPORT", el: "ΕΚΘΕΣΗ ΚΑΤΑΣΤΑΣΗΣ") }
    var reportIdLabel: String { pick(en: "Report ID:", el: "Κωδικός:") }
    var dateLabel: String { pick(en: "Date:", el: "Ημερομηνία:") }
    var conservatorLabel: String { pick(en: "Conservator:", el: "Συντηρητής:") }

    var objectSection: String { pick(en: "OBJECT", el: "ΑΝΤΙΚΕΙΜΕΝΟ") }
    var titleLabel: String { pick(en: "Title:", el: "Τίτλος:") }
    var typeLabel: String { pick(en: "Type:", el: "Τύπος:") }
    var materialsLabel: String { pick(en: "Materials:", el: "Υλικά:") }
    var dimensionsLabel: String { pick(en: "Dimensions:", el: "Διαστάσεις:") }
    var locationLabel: String { pick(en: "Location:", el: "Θέση:") }
    var ownerLabel: String { pick(en: "Owner:", el: "Ιδιοκτήτης:") }
    var inventoryLabel: String { pick(en: "Inventory:", el: "Αρ. καταλόγου:") }
    var weightLabel: String { pick(en: "Weight", el: "Βάρος") }
    var notSpecified: String { pick(en: "Not specified", el: "Δεν έχει οριστεί") }

    var conditionSummarySection: String { pick(en: "CONDITION SUMMARY", el: "ΣΥΝΟΨΗ ΚΑΤΑΣΤΑΣΗΣ") }
    var overallConditionLabel: String { pick(en: "Overall condition", el: "Γενική κατάσταση") }
    var reportTypeLabel: String { pick(en: "Report type", el: "Τύπος έκθεσης") }
    var noDamageRecorded: String { pick(en: "No specific damage recorded.", el: "Δεν καταγράφηκαν συγκεκριμένες φθορές.") }

    var photoDocumentationSection: String { pick(en: "PHOTO DOCUMENTATION", el: "ΦΩΤΟΓΡΑΦΙΚΗ ΤΕΚΜΗΡΙΩΣΗ") }
    var legendHeading: String { pick(en: "Legend", el: "Υπόμνημα") }
    var photoLabel: String { pick(en: "Photo", el: "Φωτογραφία") }

    var recommendedTreatmentSection: String { pick(en: "RECOMMENDED TREATMENT", el: "ΠΡΟΤΕΙΝΟΜΕΝΗ ΕΠΕΜΒΑΣΗ") }
    var notesSection: String { pick(en: "NOTES", el: "ΣΗΜΕΙΩΣΕΙΣ") }
    var conditionRatingSection: String { pick(en: "CONDITION RATING", el: "ΑΞΙΟΛΟΓΗΣΗ ΚΑΤΑΣΤΑΣΗΣ") }

    var generatedByConservatio: String { pick(en: "Generated by Conservatio", el: "Δημιουργήθηκε με το Conservatio") }

    // MARK: Controlled vocabulary

    func objectType(_ value: ObjectType) -> String {
        pick(en: value.displayName, el: Self.objectTypeGreek[value.rawValue] ?? value.displayName)
    }

    func reportType(_ value: ReportType) -> String {
        pick(en: value.displayName, el: Self.reportTypeGreek[value.rawValue] ?? value.displayName)
    }

    func conditionRating(_ value: ConditionRating) -> String {
        pick(en: value.displayName, el: Self.conditionRatingGreek[value.rawValue] ?? value.displayName)
    }

    func damageType(_ value: DamageType) -> String {
        pick(en: value.displayName, el: Self.damageTypeGreek[value.rawValue] ?? value.displayName)
    }

    func severity(_ value: DamageSeverity) -> String {
        pick(en: value.displayName, el: Self.severityGreek[value.rawValue] ?? value.displayName)
    }

    // MARK: Dates

    /// Formats a date as "dd MMM yyyy" in the report language. Bilingual shows
    /// the Greek rendering then the English one.
    func date(_ date: Date) -> String {
        switch language {
        case .english: return Self.format(date, localeId: "en_US_POSIX")
        case .greek: return Self.format(date, localeId: "el_GR")
        case .bilingual:
            return "\(Self.format(date, localeId: "el_GR")) / \(Self.format(date, localeId: "en_US_POSIX"))"
        }
    }

    private static func format(_ date: Date, localeId: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: localeId)
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }

    // MARK: Greek vocabulary tables
    //
    // Keyed by the model rawValue so they stay aligned with the enums even if
    // display names change. These are the report-output translations of the
    // controlled vocabulary; they are not user text.

    private static let objectTypeGreek: [String: String] = [
        "PAINTING": "Ζωγραφικός πίνακας",
        "ICON": "Εικόνα",
        "WALL_PAINTING": "Τοιχογραφία",
        "SCULPTURE": "Γλυπτό",
        "CERAMIC": "Κεραμικό",
        "METAL": "Μεταλλικό αντικείμενο",
        "TEXTILE": "Ύφασμα",
        "PAPER": "Χαρτί",
        "WOOD": "Ξύλο",
        "STONE": "Λίθος",
        "GLASS": "Γυαλί",
        "MOSAIC": "Ψηφιδωτό",
        "ARCHAEOLOGICAL_FIND": "Αρχαιολογικό εύρημα",
        "FURNITURE": "Έπιπλο",
        "OTHER": "Άλλο",
    ]

    private static let reportTypeGreek: [String: String] = [
        "INITIAL_ASSESSMENT": "Αρχική εκτίμηση",
        "PRE_TREATMENT": "Πριν την επέμβαση",
        "POST_TREATMENT": "Μετά την επέμβαση",
        "LOAN_OUTGOING": "Δανεισμός (εξερχόμενος)",
        "LOAN_INCOMING": "Δανεισμός (εισερχόμενος)",
        "INSURANCE": "Ασφάλιση",
        "TRANSPORT": "Μεταφορά",
        "PERIODIC_CHECK": "Περιοδικός έλεγχος",
        "EMERGENCY": "Έκτακτη ανάγκη",
    ]

    private static let conditionRatingGreek: [String: String] = [
        "EXCELLENT": "Άριστη",
        "GOOD": "Καλή",
        "FAIR": "Μέτρια",
        "POOR": "Κακή",
        "CRITICAL": "Κρίσιμη",
    ]

    private static let damageTypeGreek: [String: String] = [
        "CRACK": "Ρωγμή",
        "PAINT_LOSS": "Απώλεια χρώματος",
        "FLAKING": "Αποφλοίωση",
        "DISCOLORATION": "Αποχρωματισμός",
        "STAIN": "Κηλίδα",
        "SCRATCH": "Αμυχή",
        "DENT": "Βαθούλωμα",
        "TEAR": "Σχίσιμο",
        "HOLE": "Οπή",
        "CORROSION": "Διάβρωση",
        "BIOLOGICAL_GROWTH": "Βιολογική ανάπτυξη",
        "INSECT_DAMAGE": "Φθορά από έντομα",
        "WATER_DAMAGE": "Φθορά από υγρασία",
        "FIRE_DAMAGE": "Φθορά από φωτιά",
        "STRUCTURAL_DAMAGE": "Δομική φθορά",
        "SURFACE_DIRT": "Επιφανειακή ρύπανση",
        "ABRASION": "Απότριψη",
        "DEFORMATION": "Παραμόρφωση",
        "MISSING_PART": "Ελλείπον τμήμα",
        "PREVIOUS_REPAIR": "Παλαιότερη επέμβαση",
        "OTHER": "Άλλο",
    ]

    private static let severityGreek: [String: String] = [
        "MINOR": "Ήπια",
        "MODERATE": "Μέτρια",
        "SEVERE": "Σοβαρή",
        "CRITICAL": "Κρίσιμη",
    ]
}
