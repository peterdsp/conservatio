import SwiftUI

struct ObjectDetailView: View {
    let object: ConservationObject
    var reportStore: ReportStore
    @State private var showCreateReport = false
    @State private var showPDFPreview = false
    @State private var pdfData: Data?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                if !object.imageIds.isEmpty { imageGallerySection }
                detailsSection
                if let dims = object.dimensions { dimensionsSection(dims) }
                reportsSection
            }
            .padding()
        }
        .background(Color.conservatioBackground)
        .navigationTitle(object.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showCreateReport = true
                    } label: {
                        Label("New Report", systemImage: "doc.badge.plus")
                    }

                    if let latestReport = reportStore.reports(for: object.id).first {
                        Button {
                            generatePDF(for: latestReport)
                        } label: {
                            Label("Export PDF", systemImage: "arrow.down.doc")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showCreateReport) {
            CreateReportView(objectId: object.id, reportStore: reportStore)
        }
        .sheet(isPresented: $showPDFPreview) {
            if let data = pdfData {
                PDFPreviewView(
                    pdfData: data,
                    fileName: buildPDFFileName()
                )
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(object.objectType.displayName, systemImage: object.objectType.iconName)
                    .font(.conservatioLabelLarge)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.conservatioPrimary)
                    .clipShape(Capsule())

                Spacer()

                if let inv = object.inventoryNumber {
                    Text(inv)
                        .font(.conservatioLabelMedium)
                        .foregroundStyle(.secondary)
                }
            }

            if !object.materials.isEmpty {
                Text(object.materials.joined(separator: ", "))
                    .font(.conservatioBodyMedium)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var imageGallerySection: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                ForEach(object.imageIds, id: \.self) { imageId in
                    if let image = ImageStore.shared.load(imageId) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let owner = object.ownerName {
                DetailRow(label: "Owner", value: owner)
            }
            if let location = object.locationDescription {
                DetailRow(label: "Location", value: location)
            }
            if let date = object.acquisitionDate {
                DetailRow(label: "Acquisition", value: date.formatted(date: .long, time: .omitted))
            }
            if let desc = object.description, !desc.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Description")
                        .font(.conservatioLabelMedium)
                        .foregroundStyle(.secondary)
                    Text(desc)
                        .font(.conservatioBodyMedium)
                }
            }
        }
        .padding()
        .background(Color.conservatioSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func dimensionsSection(_ dims: Dimensions) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Dimensions")
                .font(.conservatioTitleSmall)

            HStack(spacing: 16) {
                if let h = dims.height {
                    DimensionChip(label: "H", value: h, unit: dims.unit)
                }
                if let w = dims.width {
                    DimensionChip(label: "W", value: w, unit: dims.unit)
                }
                if let d = dims.depth {
                    DimensionChip(label: "D", value: d, unit: dims.unit)
                }
            }
        }
        .padding()
        .background(Color.conservatioSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var reportsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Condition Reports")
                    .font(.conservatioTitleMedium)
                Spacer()
                Button("Add") { showCreateReport = true }
                    .font(.conservatioLabelLarge)
            }

            let objectReports = reportStore.reports(for: object.id)
            if objectReports.isEmpty {
                Text("No condition reports yet. Tap Add to create the first one.")
                    .font(.conservatioBodySmall)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            } else {
                ForEach(objectReports) { report in
                    ReportCard(report: report)
                }
            }
        }
        .padding()
        .background(Color.conservatioSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - PDF Export

    private func generatePDF(for report: ConditionReport) {
        let images: [UIImage] = object.imageIds.compactMap { ImageStore.shared.load($0) }
        let generator = PDFReportGenerator()
        pdfData = generator.generateReport(
            object: object,
            report: report,
            objectImages: images,
            conservatorName: report.examiner.isEmpty ? "Conservator" : report.examiner
        )
        showPDFPreview = true
    }

    private func buildPDFFileName() -> String {
        guard let latestReport = reportStore.reports(for: object.id).first else {
            return "CR-\(object.title)"
        }
        let idPrefix = latestReport.id.uuidString.prefix(8)
        let sanitizedTitle = object.title
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "-")
        return "CR-\(idPrefix)-\(sanitizedTitle)"
    }
}

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.conservatioLabelMedium)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.conservatioBodyMedium)
        }
    }
}

struct DimensionChip: View {
    let label: String
    let value: Double
    let unit: MeasurementUnit

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text("\(value, specifier: "%.1f") \(unit.displayName)")
                .font(.conservatioLabelMedium)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.conservatioSurfaceVariant)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct ReportCard: View {
    let report: ConditionReport

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(report.reportType.displayName)
                    .font(.conservatioTitleSmall)
                Text(report.examinationDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.conservatioBodySmall)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            ConditionBadge(rating: report.overallCondition)
        }
        .padding()
        .background(Color.conservatioSurfaceVariant)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct ConditionBadge: View {
    let rating: ConditionRating

    var body: some View {
        Text(rating.displayName)
            .font(.conservatioLabelSmall)
            .fontWeight(.semibold)
            .foregroundStyle(ratingColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(ratingColor.opacity(0.12))
            .clipShape(Capsule())
    }

    private var ratingColor: Color {
        switch rating {
        case .excellent: return .conditionExcellent
        case .good: return .conditionGood
        case .fair: return .conditionFair
        case .poor: return .conditionPoor
        case .critical: return .conditionCritical
        }
    }
}
