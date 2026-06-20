import SwiftUI

struct SettingsView: View {
    var objectStore: ObjectStore?
    @State private var showClearConfirm = false

    var body: some View {
        NavigationStack {
            List {
                Section(t("settings.account")) {
                    NavigationLink {
                        ProfileSettingsView()
                    } label: {
                        Label(t("settings.profile"), systemImage: "person.circle")
                    }

                    NavigationLink {
                        SyncSettingsView()
                    } label: {
                        Label("Sync & Storage", systemImage: "arrow.triangle.2.circlepath")
                    }

                    NavigationLink {
                        CloudStorageView()
                    } label: {
                        Label(t("cloud.title"), systemImage: "cloud")
                    }
                }

                Section("Reports") {
                    NavigationLink {
                        ComingSoonView(title: "Templates", description: "Customize report templates with your logo, header, and default fields.")
                    } label: {
                        Label("Templates", systemImage: "doc.text")
                    }

                    NavigationLink {
                        ExportSettingsView()
                    } label: {
                        Label("Export Settings", systemImage: "square.and.arrow.up")
                    }

                    NavigationLink {
                        LanguageSettingsView()
                    } label: {
                        Label(t("settings.language"), systemImage: "globe")
                    }
                }

                Section("App") {
                    NavigationLink {
                        AppearanceSettingsView()
                    } label: {
                        Label("Appearance", systemImage: "paintbrush")
                    }

                    NavigationLink {
                        StorageInfoView()
                    } label: {
                        Label("Storage", systemImage: "internaldrive")
                    }

                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("About", systemImage: "info.circle")
                    }
                }

                Section {
                    Button {
                        objectStore?.loadSampleData()
                    } label: {
                        Label(t("settings.loadSample"), systemImage: "tray.and.arrow.down")
                    }

                    Button(role: .destructive) {
                        showClearConfirm = true
                    } label: {
                        Label(t("settings.clearAll"), systemImage: "trash")
                    }
                } header: {
                    Text(t("settings.dangerTitle"))
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .navigationTitle(t("settings.title"))
            .alert(t("settings.clearAll"), isPresented: $showClearConfirm) {
                Button(t("settings.clearAll"), role: .destructive) {
                    objectStore?.clearAllData()
                }
                Button(t("g.cancel"), role: .cancel) {}
            } message: {
                Text(t("settings.clearConfirm"))
            }
        }
    }
}
