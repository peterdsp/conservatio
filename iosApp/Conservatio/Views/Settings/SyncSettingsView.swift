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
        case .googleDrive: return "externaldrive.badge.icloud"
        case .oneDrive: return "cloud"
        case .iCloud: return "icloud"
        case .selfHosted: return "server.rack"
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
}

struct SyncSettingsView: View {
    @AppStorage("storageMode") private var storageMode: StorageMode = .local
    @AppStorage("serverURL") private var serverURL: String = ""
    @AppStorage("autoSync") private var autoSync: Bool = true
    @AppStorage("syncPhotos") private var syncPhotos: Bool = true
    @AppStorage("syncOnWiFiOnly") private var syncOnWiFiOnly: Bool = true
    @State private var lastSyncDate: Date? = nil
    @State private var showServerConfig = false

    var body: some View {
        List {
            Section {
                ForEach(StorageMode.allCases, id: \.self) { mode in
                    Button {
                        storageMode = mode
                        if mode == .selfHosted {
                            showServerConfig = true
                        }
                    } label: {
                        HStack {
                            Label(mode.rawValue, systemImage: mode.icon)
                                .foregroundStyle(Color.primary)

                            Spacer()

                            if storageMode == mode {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.conservatioPrimary)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
            } header: {
                Text("Storage Location")
            } footer: {
                Text(storageMode.description)
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
                    }

                    Button {
                        // TODO: test connection
                    } label: {
                        Label("Test Connection", systemImage: "antenna.radiowaves.left.and.right")
                    }
                }
            }

            if storageMode != .local {
                Section("Sync Options") {
                    Toggle("Auto Sync", isOn: $autoSync)
                    Toggle("Sync Photos", isOn: $syncPhotos)
                    Toggle("Wi-Fi Only", isOn: $syncOnWiFiOnly)
                }

                Section("Status") {
                    HStack {
                        Text("Last Sync")
                        Spacer()
                        Text(lastSyncDate.map { formatDate($0) } ?? "Never")
                            .foregroundStyle(.secondary)
                    }

                    Button {
                        // TODO: trigger sync
                    } label: {
                        Label("Sync Now", systemImage: "arrow.triangle.2.circlepath")
                    }
                }
            }

            Section {
                NavigationLink {
                    LocalFilesView()
                } label: {
                    Label("Browse Local Files", systemImage: "folder")
                }

                Button {
                    // TODO: export all data
                } label: {
                    Label("Export All Data", systemImage: "square.and.arrow.up")
                }
            } header: {
                Text("Data Management")
            }
        }
        .navigationTitle("Sync & Storage")
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct LocalFilesView: View {
    var body: some View {
        List {
            Section("Objects") {
                HStack {
                    Text("Saved Objects")
                    Spacer()
                    Text("0")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Images") {
                HStack {
                    Text("Stored Images")
                    Spacer()
                    Text("0")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Total Size")
                    Spacer()
                    Text("0 MB")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Reports") {
                HStack {
                    Text("Saved Reports")
                    Spacer()
                    Text("0")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Exported PDFs")
                    Spacer()
                    Text("0")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Local Files")
    }
}
