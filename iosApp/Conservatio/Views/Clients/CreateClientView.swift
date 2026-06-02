import SwiftUI

struct CreateClientView: View {
    var clientStore: ClientStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var type: ClientType = .other
    @State private var contactPerson = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Client Info") {
                    TextField("Client name", text: $name)

                    Picker("Type", selection: $type) {
                        ForEach(ClientType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                }

                Section("Contact") {
                    TextField("Contact person", text: $contactPerson)

                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)

                    TextField("Phone", text: $phone)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)

                    TextField("Address", text: $address)
                        .textContentType(.fullStreetAddress)
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("New Client")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let client = Client(
                            name: name,
                            type: type,
                            contactPerson: contactPerson,
                            email: email,
                            phone: phone,
                            address: address,
                            notes: notes
                        )
                        clientStore.add(client)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
