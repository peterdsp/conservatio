import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    NavigationLink {
                        ProfileSettingsView()
                    } label: {
                        Label("Profile", systemImage: "person.circle")
                    }

                    NavigationLink {
                        SyncSettingsView()
                    } label: {
                        Label("Sync & Storage", systemImage: "arrow.triangle.2.circlepath")
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
                        Label("Language", systemImage: "globe")
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
            }
            .navigationTitle("Settings")
        }
    }
}
