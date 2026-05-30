import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    Label("Profile", systemImage: "person.circle")
                    Label("Sync", systemImage: "arrow.triangle.2.circlepath")
                }

                Section("Reports") {
                    Label("Templates", systemImage: "doc.text")
                    Label("Export Settings", systemImage: "square.and.arrow.up")
                    Label("Language", systemImage: "globe")
                }

                Section("App") {
                    Label("Appearance", systemImage: "paintbrush")
                    Label("Storage", systemImage: "internaldrive")
                    Label("About", systemImage: "info.circle")
                }
            }
            .navigationTitle("Settings")
        }
    }
}
