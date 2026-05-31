import SwiftUI

struct ExportSettingsView: View {
    @AppStorage("exportFormat") private var exportFormat: String = "PDF"
    @AppStorage("includePhotos") private var includePhotos: Bool = true
    @AppStorage("includeAnnotations") private var includeAnnotations: Bool = true
    @AppStorage("includeConditionGauge") private var includeConditionGauge: Bool = true
    @AppStorage("paperSize") private var paperSize: String = "A4"

    var body: some View {
        List {
            Section("Format") {
                Picker("Export Format", selection: $exportFormat) {
                    Text("PDF").tag("PDF")
                    Text("PDF + Images ZIP").tag("PDF_ZIP")
                }

                Picker("Paper Size", selection: $paperSize) {
                    Text("A4 (210 x 297 mm)").tag("A4")
                    Text("Letter (8.5 x 11 in)").tag("Letter")
                }
            }

            Section("Content") {
                Toggle("Include Photos", isOn: $includePhotos)
                Toggle("Include Damage Annotations", isOn: $includeAnnotations)
                Toggle("Include Condition Gauge", isOn: $includeConditionGauge)
            }
        }
        .navigationTitle("Export Settings")
    }
}
