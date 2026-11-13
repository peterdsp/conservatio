import SwiftUI

struct StorageInfoView: View {
    @State private var documentsSize: String = "Calculating..."
    @State private var cacheSize: String = "Calculating..."
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
                HStack {
                    Label("Cache", systemImage: "clock.arrow.circlepath")
                    Spacer()
                    Text(cacheSize)
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Button(role: .destructive) {
                    clearCache()
                } label: {
                    Label("Clear Image Cache", systemImage: "trash")
                }
            } footer: {
                Text("Removes temporary files and cached thumbnails only. Original photos and records are preserved.")
            }
        }
        .navigationTitle("Storage")
        .onAppear {
            calculateStorage()
        }
    }

    /// Temporary exports and system caches. Nothing under Documents lives here.
    private var cacheDirectories: [URL] {
        var dirs = [FileManager.default.temporaryDirectory]
        if let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            dirs.append(caches)
        }
        return dirs
    }

    private func clearCache() {
        let fileManager = FileManager.default
        for dir in cacheDirectories {
            let items = (try? fileManager.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)) ?? []
            for item in items {
                try? fileManager.removeItem(at: item)
            }
        }
        calculateStorage()
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

        var cacheBytes: Int64 = 0
        for dir in cacheDirectories {
            if let enumerator = fileManager.enumerator(at: dir, includingPropertiesForKeys: [.fileSizeKey]) {
                for case let fileURL as URL in enumerator {
                    if let size = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                        cacheBytes += Int64(size)
                    }
                }
            }
        }

        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        documentsSize = formatter.string(fromByteCount: totalSize)
        cacheSize = formatter.string(fromByteCount: cacheBytes)
        imageCount = images
    }
}
