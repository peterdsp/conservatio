import Foundation

struct ConditionReport: Identifiable, Codable {
    let id: UUID
    var objectId: UUID
    var reportType: ReportType
    var overallCondition: ConditionRating
    var examiner: String
    var examinationDate: Date
    var damageAnnotations: [DamageAnnotation]
    var notes: String?
    var recommendations: String?
    /// Treatments the object received before this examination, as told by the
    /// owner or found in the records. Optional so reports saved before the
    /// field existed still decode.
    var previousInterventions: String?
    /// The environment the examination took place in. Optional for the same
    /// reason as `previousInterventions`.
    var examinationConditions: ExaminationConditions?
    var imageIds: [String]
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        objectId: UUID,
        reportType: ReportType = .initialAssessment,
        overallCondition: ConditionRating = .fair,
        examiner: String = "",
        examinationDate: Date = Date(),
        damageAnnotations: [DamageAnnotation] = [],
        notes: String? = nil,
        recommendations: String? = nil,
        previousInterventions: String? = nil,
        examinationConditions: ExaminationConditions? = nil,
        imageIds: [String] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.objectId = objectId
        self.reportType = reportType
        self.overallCondition = overallCondition
        self.examiner = examiner
        self.examinationDate = examinationDate
        self.damageAnnotations = damageAnnotations
        self.notes = notes
        self.recommendations = recommendations
        self.previousInterventions = previousInterventions
        self.examinationConditions = examinationConditions
        self.imageIds = imageIds
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Conditions under which an examination was carried out. Every field is
/// optional; `isEmpty` is true when nothing was recorded so views and the PDF
/// can skip the section entirely.
struct ExaminationConditions: Codable, Equatable {
    var lightSource: String?
    /// Relative humidity in percent.
    var relativeHumidity: Double?
    /// Temperature in degrees Celsius.
    var temperature: Double?
    var notes: String?

    init(
        lightSource: String? = nil,
        relativeHumidity: Double? = nil,
        temperature: Double? = nil,
        notes: String? = nil
    ) {
        self.lightSource = lightSource
        self.relativeHumidity = relativeHumidity
        self.temperature = temperature
        self.notes = notes
    }

    var isEmpty: Bool {
        (lightSource ?? "").isEmpty && relativeHumidity == nil && temperature == nil && (notes ?? "").isEmpty
    }

    /// One-line summary for list rows, for example "Daylight, RH 55%, 21 C".
    var summary: String {
        var parts: [String] = []
        if let lightSource, !lightSource.isEmpty { parts.append(lightSource) }
        if let relativeHumidity { parts.append("RH \(Self.format(relativeHumidity))%") }
        if let temperature { parts.append("\(Self.format(temperature)) C") }
        if let notes, !notes.isEmpty { parts.append(notes) }
        return parts.joined(separator: ", ")
    }

    static func format(_ value: Double) -> String {
        value == value.rounded() ? String(format: "%.0f", value) : String(format: "%.1f", value)
    }
}

enum ReportType: String, Codable, CaseIterable, Identifiable {
    case initialAssessment = "INITIAL_ASSESSMENT"
    case preTreatment = "PRE_TREATMENT"
    case postTreatment = "POST_TREATMENT"
    case loanOutgoing = "LOAN_OUTGOING"
    case loanIncoming = "LOAN_INCOMING"
    case insurance = "INSURANCE"
    case transport = "TRANSPORT"
    case periodicCheck = "PERIODIC_CHECK"
    case emergency = "EMERGENCY"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .initialAssessment: return "Initial Assessment"
        case .preTreatment: return "Pre-Treatment"
        case .postTreatment: return "Post-Treatment"
        case .loanOutgoing: return "Loan (Outgoing)"
        case .loanIncoming: return "Loan (Incoming)"
        case .insurance: return "Insurance"
        case .transport: return "Transport"
        case .periodicCheck: return "Periodic Check"
        case .emergency: return "Emergency"
        }
    }
}

enum ConditionRating: String, Codable, CaseIterable, Identifiable {
    case excellent = "EXCELLENT"
    case good = "GOOD"
    case fair = "FAIR"
    case poor = "POOR"
    case critical = "CRITICAL"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .excellent: return "Excellent"
        case .good: return "Good"
        case .fair: return "Fair"
        case .poor: return "Poor"
        case .critical: return "Critical"
        }
    }

    var color: String {
        switch self {
        case .excellent: return "conditionExcellent"
        case .good: return "conditionGood"
        case .fair: return "conditionFair"
        case .poor: return "conditionPoor"
        case .critical: return "conditionCritical"
        }
    }
}

struct DamageAnnotation: Identifiable, Codable {
    let id: UUID
    var damageType: DamageType
    var severity: DamageSeverity
    var description: String?
    var imageId: String?
    var xPercent: Double?
    var yPercent: Double?
    var widthPercent: Double?
    var heightPercent: Double?

    init(
        id: UUID = UUID(),
        damageType: DamageType = .other,
        severity: DamageSeverity = .moderate,
        description: String? = nil,
        imageId: String? = nil,
        xPercent: Double? = nil,
        yPercent: Double? = nil,
        widthPercent: Double? = nil,
        heightPercent: Double? = nil
    ) {
        self.id = id
        self.damageType = damageType
        self.severity = severity
        self.description = description
        self.imageId = imageId
        self.xPercent = xPercent
        self.yPercent = yPercent
        self.widthPercent = widthPercent
        self.heightPercent = heightPercent
    }
}

enum DamageType: String, Codable, CaseIterable, Identifiable {
    case crack = "CRACK"
    case paintLoss = "PAINT_LOSS"
    case flaking = "FLAKING"
    case discoloration = "DISCOLORATION"
    case stain = "STAIN"
    case scratch = "SCRATCH"
    case dent = "DENT"
    case tear = "TEAR"
    case hole = "HOLE"
    case corrosion = "CORROSION"
    case biologicalGrowth = "BIOLOGICAL_GROWTH"
    case insectDamage = "INSECT_DAMAGE"
    case waterDamage = "WATER_DAMAGE"
    case fireDamage = "FIRE_DAMAGE"
    case structuralDamage = "STRUCTURAL_DAMAGE"
    case surfaceDirt = "SURFACE_DIRT"
    case abrasion = "ABRASION"
    case deformation = "DEFORMATION"
    case missingPart = "MISSING_PART"
    case previousRepair = "PREVIOUS_REPAIR"
    case other = "OTHER"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .crack: return "Crack"
        case .paintLoss: return "Paint Loss"
        case .flaking: return "Flaking"
        case .discoloration: return "Discoloration"
        case .stain: return "Stain"
        case .scratch: return "Scratch"
        case .dent: return "Dent"
        case .tear: return "Tear"
        case .hole: return "Hole"
        case .corrosion: return "Corrosion"
        case .biologicalGrowth: return "Biological Growth"
        case .insectDamage: return "Insect Damage"
        case .waterDamage: return "Water Damage"
        case .fireDamage: return "Fire Damage"
        case .structuralDamage: return "Structural Damage"
        case .surfaceDirt: return "Surface Dirt"
        case .abrasion: return "Abrasion"
        case .deformation: return "Deformation"
        case .missingPart: return "Missing Part"
        case .previousRepair: return "Previous Repair"
        case .other: return "Other"
        }
    }
}

enum DamageSeverity: String, Codable, CaseIterable, Identifiable {
    case minor = "MINOR"
    case moderate = "MODERATE"
    case severe = "SEVERE"
    case critical = "CRITICAL"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .minor: return "Minor"
        case .moderate: return "Moderate"
        case .severe: return "Severe"
        case .critical: return "Critical"
        }
    }
}
