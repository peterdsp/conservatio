import SwiftUI

struct SettingsView: View {
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
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .navigationTitle(t("settings.title"))
        }
    }
}
