import SwiftUI

enum StorageMode: String, CaseIterable, Codable {
    case local = "Local Only"
    case googleDrive = "Google Drive"
    case oneDrive = "OneDrive"
    case iCloud = "iCloud"
    case selfHosted = "Self-Hosted Server"

    var icon: String {
        switch self {
        case .local: return "iphone"
        case .googleDrive: return "g.circle.fill"
        case .oneDrive: return "square.grid.2x2.fill"
        case .iCloud: return "icloud.fill"
        case .selfHosted: return "server.rack"
        }
    }

    var iconColor: Color {
        switch self {
        case .local: return .secondary
        case .googleDrive: return Color(red: 0.26, green: 0.52, blue: 0.96)
        case .oneDrive: return Color(red: 0.0, green: 0.64, blue: 0.94)
        case .iCloud: return Color(red: 0.08, green: 0.49, blue: 0.98)
        case .selfHosted: return .secondary
        }
    }

    var description: String {
        switch self {
        case .local: return "Everything stays on this device. Export manually via Files app."
        case .googleDrive: return "Sync objects, reports, and images to your Google Drive."
        case .oneDrive: return "Sync to Microsoft OneDrive for backup and access."
        case .iCloud: return "Sync across your Apple devices via iCloud Drive."
        case .selfHosted: return "Connect to your own Conservatio server (Raspberry Pi, VPS, etc.)."
        }
    }

    /// Whether this backend is actually implemented. The default Conservatio
    /// server and self-hosted servers are wired through `APIClient`; the
    /// third-party cloud providers are not yet available. To connect a
    /// provider, see the Cloud Storage screen.
    var isAvailable: Bool {
        switch self {
        case .local, .selfHosted: return true
        case .googleDrive, .oneDrive, .iCloud: return false
        }
    }
}

struct SyncSettingsView: View {
    var objectStore: ObjectStore?

    @AppStorage("storageMode") private var storageMode: StorageMode = .local
    @AppStorage("serverURL") private var serverURL: String = ""
    @AppStorage("autoSync") private var autoSync: Bool = true
    @AppStorage("syncPhotos") private var syncPhotos: Bool = true
    @AppStorage("syncOnWiFiOnly") private var syncOnWiFiOnly: Bool = true
    @AppStorage("lastSyncAt") private var lastSyncAtRaw: Double = 0

    @State private var isSyncing = false
    @State private var isTesting = false
    @State private var testResult: TestResult?

    private var engine: SyncEngine { SyncEngine.shared }

    private var lastSyncDate: Date? {
        lastSyncAtRaw > 0 ? Date(timeIntervalSince1970: lastSyncAtRaw) : nil
    }

    private var statusText: String {
        switch engine.status {
        case .idle: return engine.pendingCount > 0 ? "Waiting" : "Up to date"
        case .syncing: return "Syncing"
        case .offline: return "Offline"
        case .authRequired: return "Sign in required"
        case .error: return "Needs attention"
        }
    }

    private var statusIcon: String {
        switch engine.status {
        case .idle: return engine.pendingCount > 0 ? "clock" : "checkmark.circle.fill"
        case .syncing: return "arrow.triangle.2.circlepath"
        case .offline: return "wifi.slash"
        case .authRequired: return "person.crop.circle.badge.exclamationmark"
        case .error: return "exclamationmark.triangle.fill"
        }
    }

    private var statusColor: Color {
        switch engine.status {
        case .idle: return engine.pendingCount > 0 ? .orange : .green
        case .syncing: return .secondary
        case .offline: return .secondary
        case .authRequired: return .orange
        case .error: return .red
        }
    }

    var body: some View {
        List {
            Section {
                ForEach(StorageMode.allCases, id: \.self) { mode in
                    Button {
                        guard mode.isAvailable else { return }
                        storageMode = mode
                    } label: {
                        HStack {
                            Label {
                                Text(mode.rawValue)
                                    .foregroundStyle(mode.isAvailable ? Color.primary : Color.secondary)
                            } icon: {
                                Image(systemName: mode.icon)
                                    .foregroundStyle(mode.iconColor)
                            }

                            Spacer()

                            if !mode.isAvailable {
                                Text("Coming soon")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            } else if storageMode == mode {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.conservatioPrimary)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    .disabled(!mode.isAvailable)
                }
            } header: {
                Text("Storage Location")
            } footer: {
                Text(storageMode.description + "\n\nTo mirror your data to Google Drive, iCloud, or OneDrive, open Cloud Storage in Settings.")
            }

            if storageMode == .selfHosted {
                Section("Server Configuration") {
                    HStack {
                        Text("URL")
                        Spacer()
                        TextField("https://api.example.com", text: $serverURL)
                            .multilineTextAlignment(.trailing)
                            .textContentType(.URL)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                    }

                    Button {
                        Task { await testConnection() }
                    } label: {
                        HStack {
                            Label("Test Connection", systemImage: "antenna.radiowaves.left.and.right")
                            Spacer()
                            if isTesting {
                                ProgressView()
                            } else if let result = testResult {
                                Image(systemName: result.systemImage)
                                    .foregroundStyle(result.color)
                            }
                        }
                    }
                    .disabled(isTesting)

                    if let result = testResult {
                        Text(result.message)
                            .font(.caption)
                            .foregroundStyle(result.color)
                    }
                }
            }

            if objectStore?.isSignedIn == true {
                Section {
                    HStack {
                        Text("Status")
                        Spacer()
                        HStack(spacing: 6) {
                            Image(systemName: statusIcon)
                                .foregroundStyle(statusColor)
                            Text(statusText)
                                .foregroundStyle(.secondary)
                            if isSyncing { ProgressView() }
                        }
                    }

                    if engine.pendingCount > 0 {
                        HStack {
                            Text("Pending changes")
                            Spacer()
                            Text("\(engine.pendingCount)")
                                .foregroundStyle(.secondary)
                        }
                    }

                    HStack {
                        Text("Last Sync")
                        Spacer()
                        Text(lastSyncDate.map { formatDate($0) } ?? "Never")
                            .foregroundStyle(.secondary)
                    }

                    Button {
                        Task { await syncNow() }
                    } label: {
                        HStack {
                            Label("Sync Now", systemImage: "arrow.triangle.2.circlepath")
                            Spacer()
                            if isSyncing { ProgressView() }
                        }
                    }
                    .disabled(isSyncing)
                } header: {
                    Text("Sync")
                } footer: {
                    if let error = engine.lastError, engine.pendingCount > 0 {
                        Text("Some changes could not sync yet: \(error) They stay saved on this device and retry automatically.")
                    } else {
                        Text("Objects, reports, projects, and clients sync to the Conservatio server. Changes made offline are saved locally and pushed when you reconnect.")
                    }
                }

                if storageMode != .local {
                    Section("Sync Options") {
                        Toggle("Auto Sync", isOn: $autoSync)
                        Toggle("Sync Photos", isOn: $syncPhotos)
                        Toggle("Wi-Fi Only", isOn: $syncOnWiFiOnly)
                    }
                }
            }

            Section {
                NavigationLink {
                    LocalFilesView()
                } label: {
                    Label("Browse Local Files", systemImage: "folder")
                }
            } header: {
                Text("Data Management")
            }
        }
        .navigationTitle("Sync & Storage")
    }

    @MainActor
    private func syncNow() async {
        guard let objectStore, objectStore.isSignedIn else { return }
        isSyncing = true
        // Pushes every pending change (all record types) and pulls objects.
        // The engine records the successful sync time in `lastSyncAt`.
        await objectStore.syncFromServer()
        isSyncing = false
    }

    @MainActor
    private func testConnection() async {
        testResult = nil
        isTesting = true
        defer { isTesting = false }

        let candidate = serverURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: candidate), url.scheme != nil, url.host != nil else {
            testResult = .init(ok: false, message: "Enter a valid URL, for example https://api.example.com")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if response is HTTPURLResponse {
                // Any HTTP response means the host answered and is reachable.
                testResult = .init(ok: true, message: "Server reachable.")
            } else {
                testResult = .init(ok: false, message: "No HTTP response from server.")
            }
        } catch {
            testResult = .init(ok: false, message: "Could not reach server: \(error.localizedDescription)")
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    private struct TestResult {
        let ok: Bool
        let message: String
        var color: Color { ok ? .green : .red }
        var systemImage: String { ok ? "checkmark.circle.fill" : "xmark.circle.fill" }
    }
}

struct LocalFilesView: View {
    @State private var objectCount = 0
    @State private var reportCount = 0
    @State private var imageCount = 0
    @State private var imageBytes: Int64 = 0

    var body: some View {
        List {
            Section("Objects") {
                LabeledContent("Saved Objects", value: "\(objectCount)")
            }

            Section("Images") {
                LabeledContent("Stored Images", value: "\(imageCount)")
                LabeledContent("Total Size", value: ByteCountFormatter.string(fromByteCount: imageBytes, countStyle: .file))
            }

            Section("Reports") {
                LabeledContent("Saved Reports", value: "\(reportCount)")
            }
        }
        .navigationTitle("Local Files")
        .onAppear(perform: calculate)
    }

    private func calculate() {
        let fm = FileManager.default
        guard let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

        objectCount = decodeCount(at: docs.appendingPathComponent("conservation_objects.json"))
        reportCount = decodeCount(at: docs.appendingPathComponent("condition_reports.json"))

        var images = 0
        var bytes: Int64 = 0
        if let enumerator = fm.enumerator(at: docs, includingPropertiesForKeys: [.fileSizeKey]) {
            for case let fileURL as URL in enumerator {
                let ext = fileURL.pathExtension.lowercased()
                if ext == "jpeg" || ext == "jpg" || ext == "png" {
                    images += 1
                    if let size = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                        bytes += Int64(size)
                    }
                }
            }
        }
        imageCount = images
        imageBytes = bytes
    }

    private func decodeCount(at url: URL) -> Int {
        guard let data = try? Data(contentsOf: url),
              let array = try? JSONSerialization.jsonObject(with: data) as? [Any] else { return 0 }
        return array.count
    }
}
