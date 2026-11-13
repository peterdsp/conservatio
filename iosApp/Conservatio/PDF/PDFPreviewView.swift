import SwiftUI
import UIKit
import PDFKit

struct PDFPreviewView: View {
    let pdfData: Data
    let fileName: String
    /// Ids of the original photos to bundle when Export Settings asks for
    /// "PDF + Images ZIP". Empty means the PDF is shared on its own.
    var originalImageIds: [String] = []

    @Environment(\.dismiss) private var dismiss
    @AppStorage("exportFormat") private var exportFormat: String = "PDF"
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []

    var body: some View {
        NavigationStack {
            PDFKitView(data: pdfData)
                .navigationTitle("Report Preview")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { dismiss() }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            // A named file shares better than raw bytes, and the
                            // ZIP variant needs a file anyway.
                            let file = ReportExport.shareFile(
                                pdfData: pdfData,
                                fileName: fileName,
                                originalImageIds: originalImageIds,
                                format: exportFormat
                            )
                            shareItems = file.map { [$0] } ?? [pdfData]
                            showShareSheet = true
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
                .sheet(isPresented: $showShareSheet) {
                    ShareSheet(items: shareItems)
                }
        }
    }
}

// MARK: - Export file

/// Builds the file the share sheet hands out: the PDF alone, or a ZIP holding
/// the PDF plus the original JPEGs when Export Settings is set to
/// "PDF + Images ZIP" (`exportFormat == "PDF_ZIP"`).
enum ReportExport {
    static func shareFile(pdfData: Data, fileName: String, originalImageIds: [String], format: String) -> URL? {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("report-export", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        if format == "PDF_ZIP" {
            var zip = ZipWriter()
            zip.add("\(fileName).pdf", data: pdfData)
            for id in originalImageIds {
                if let data = ImageStore.shared.data(id) {
                    zip.add("originals/\(id).jpg", data: data)
                }
            }
            let url = dir.appendingPathComponent("\(fileName).zip")
            guard (try? zip.makeData().write(to: url, options: .atomic)) != nil else { return nil }
            return url
        }

        let url = dir.appendingPathComponent("\(fileName).pdf")
        guard (try? pdfData.write(to: url, options: .atomic)) != nil else { return nil }
        return url
    }
}

// MARK: - PDF Display

/// Renders the full multi-page document. Reports now span several pages (object
/// summary, annotated photo documentation, treatment, notes), so PDFKit's
/// paginated, scrollable view replaces the previous single-page image render.
struct PDFKitView: UIViewRepresentable {
    let data: Data

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        view.displayMode = .singlePageContinuous
        view.displayDirection = .vertical
        view.backgroundColor = .systemGroupedBackground
        view.document = PDFDocument(data: data)
        return view
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        if uiView.document?.dataRepresentation() != data {
            uiView.document = PDFDocument(data: data)
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: Context
    ) {}
}
