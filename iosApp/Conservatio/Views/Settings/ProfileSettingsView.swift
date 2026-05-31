import SwiftUI

struct ProfileSettingsView: View {
    @AppStorage("conservatorName") private var conservatorName: String = ""
    @AppStorage("conservatorTitle") private var conservatorTitle: String = ""
    @AppStorage("conservatorEmail") private var conservatorEmail: String = ""
    @AppStorage("conservatorPhone") private var conservatorPhone: String = ""
    @AppStorage("studioName") private var studioName: String = ""
    @AppStorage("studioAddress") private var studioAddress: String = ""

    var body: some View {
        List {
            Section("Conservator") {
                HStack {
                    Text("Name")
                    Spacer()
                    TextField("Your name", text: $conservatorName)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Title")
                    Spacer()
                    TextField("e.g. Conservation Specialist", text: $conservatorTitle)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Email")
                    Spacer()
                    TextField("email@example.com", text: $conservatorEmail)
                        .multilineTextAlignment(.trailing)
                        .textContentType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                HStack {
                    Text("Phone")
                    Spacer()
                    TextField("+30 ...", text: $conservatorPhone)
                        .multilineTextAlignment(.trailing)
                        .textContentType(.telephoneNumber)
                }
            }

            Section("Studio / Organization") {
                HStack {
                    Text("Name")
                    Spacer()
                    TextField("Studio name", text: $studioName)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Address")
                    Spacer()
                    TextField("Address", text: $studioAddress)
                        .multilineTextAlignment(.trailing)
                }
            }

            Section {
                Text("This information appears on your exported PDF reports and is used as the default conservator name on condition reports.")
                    .font(.conservatioBodySmall)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Profile")
    }
}
