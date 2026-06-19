import SwiftUI

struct LanguageSettingsView: View {
    @AppStorage("reportLanguage") private var reportLanguage: String = "en"

    /// The app's display language. Drives `t("...")` everywhere via
    /// LanguagePreference.shared, so toggling here flips the dashboard,
    /// tab bar, settings, etc. on the next render.
    @State private var appLanguage: String = LanguagePreference.shared.code

    private let appLanguages: [(String, String)] = [
        ("en", "English"),
        ("el", "Ελληνικά"),
    ]

    private let reportLanguages: [(String, String)] = [
        ("en", "English"),
        ("el", "Ελληνικά"),
        ("it", "Italiano"),
        ("es", "Español"),
        ("fr", "Français"),
        ("de", "Deutsch"),
        ("tr", "Türkçe"),
    ]

    var body: some View {
        List {
            Section {
                ForEach(appLanguages, id: \.0) { code, name in
                    Button {
                        appLanguage = code
                        LanguagePreference.shared.code = code
                    } label: {
                        HStack {
                            Text(name).foregroundStyle(Color.primary)
                            Spacer()
                            if appLanguage == code {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.conservatioPrimary)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
            } header: {
                Text(t("settings.language"))
            } footer: {
                Text("Changes the language of the app itself. Restart the app if any text doesn't refresh.")
            }

            Section {
                ForEach(reportLanguages, id: \.0) { code, name in
                    Button {
                        reportLanguage = code
                    } label: {
                        HStack {
                            Text(name).foregroundStyle(Color.primary)
                            Spacer()
                            if reportLanguage == code {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.conservatioPrimary)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
            } header: {
                Text("Report Language")
            } footer: {
                Text("Language used for section headers and labels in exported PDF reports. Object content stays in whatever you typed.")
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .navigationTitle(t("settings.language"))
    }
}
