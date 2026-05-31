import SwiftUI

struct StorageInfoView: View {
    @State private var documentsSize: String = "Calculating..."
    @State private var imageCount: Int = 0

    var body: some View {
        List {
            Section("Device Storage") {
                HStack {
                    Label("App Data", systemImage: "doc.on.doc")
                    Spacer()
                    Text(documentsSize)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Label("Stored Images", systemImage: "photo.on.rectangle")
                    Spacer()
                    Text("\(imageCount)")
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Button(role: .destructive) {
                    // TODO: clear cache
                } label: {
                    Label("Clear Image Cache", systemImage: "trash")
                }
            } footer: {
                Text("This removes cached thumbnails only. Original images are preserved.")
            }
        }
        .navigationTitle("Storage")
        .onAppear {
            calculateStorage()
        }
    }

    private func calculateStorage() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let url = documentsURL else { return }

        let fileManager = FileManager.default
        var totalSize: Int64 = 0
        var images = 0

        if let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey]) {
            for case let fileURL as URL in enumerator {
                if let size = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    totalSize += Int64(size)
                }
                if fileURL.pathExtension == "jpeg" || fileURL.pathExtension == "jpg" || fileURL.pathExtension == "png" {
                    images += 1
                }
            }
        }

        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        documentsSize = formatter.string(fromByteCount: totalSize)
        imageCount = images
    }
}
