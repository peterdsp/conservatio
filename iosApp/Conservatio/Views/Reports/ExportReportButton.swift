import SwiftUI

struct ExportReportButton: View {
    let object: ConservationObject
    let report: ConditionReport
    let objectImages: [UIImage]

    @State private var showPreview = false
    @State private var pdfData: Data?

    var body: some View {
        Button {
            let generator = PDFReportGenerator()
            pdfData = generator.generateReport(
                object: object,
                report: report,
                objectImages: objectImages,
                conservatorName: report.examiner.isEmpty ? "Conservator" : report.examiner
            )
            showPreview = true
        } label: {
            Label("Export PDF Report", systemImage: "doc.text")
        }
        .sheet(isPresented: $showPreview) {
            if let data = pdfData {
                PDFPreviewView(
                    pdfData: data,
                    fileName: buildFileName()
                )
            }
        }
    }

    private func buildFileName() -> String {
        let idPrefix = report.id.uuidString.prefix(8)
        let sanitizedTitle = object.title
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "-")
        return "CR-\(idPrefix)-\(sanitizedTitle)"
    }
}
