import SwiftUI

struct AppearanceSettingsView: View {
    @AppStorage("appColorScheme") private var appColorScheme: String = "system"

    var body: some View {
        List {
            Section("Theme") {
                Picker("Appearance", selection: $appColorScheme) {
                    Text("System").tag("system")
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
                .pickerStyle(.inline)
            }
        }
        .navigationTitle("Appearance")
    }
}
