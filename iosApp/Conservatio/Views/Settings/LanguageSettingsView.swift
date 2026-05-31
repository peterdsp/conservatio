import SwiftUI

struct LanguageSettingsView: View {
    @AppStorage("reportLanguage") private var reportLanguage: String = "en"

    let languages = [
        ("en", "English"),
        ("el", "Greek"),
        ("it", "Italian"),
        ("es", "Spanish"),
        ("fr", "French"),
        ("de", "German"),
        ("tr", "Turkish"),
    ]

    var body: some View {
        List {
            Section {
                ForEach(languages, id: \.0) { code, name in
                    Button {
                        reportLanguage = code
                    } label: {
                        HStack {
                            Text(name)
                                .foregroundStyle(Color.primary)
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
                Text("The language used for section headers and labels in exported PDF reports. Object content is always in the language you type it.")
            }
        }
        .navigationTitle("Language")
    }
}
