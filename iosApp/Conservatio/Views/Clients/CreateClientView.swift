import SwiftUI

/// Dual-purpose create + edit form for a Client. Pass `existing` to switch
/// the view into edit mode; the navigation title and the Save action both
/// adjust automatically.
struct CreateClientView: View {
    var clientStore: ClientStore
    var existing: Client?

    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var type: ClientType
    @State private var contactPerson: String
    @State private var email: String
    @State private var phone: String
    @State private var address: String
    @State private var notes: String

    init(clientStore: ClientStore, existing: Client? = nil) {
        self.clientStore = clientStore
        self.existing = existing
        _name = State(initialValue: existing?.name ?? "")
        _type = State(initialValue: existing?.type ?? .other)
        _contactPerson = State(initialValue: existing?.contactPerson ?? "")
        _email = State(initialValue: existing?.email ?? "")
        _phone = State(initialValue: existing?.phone ?? "")
        _address = State(initialValue: existing?.address ?? "")
        _notes = State(initialValue: existing?.notes ?? "")
    }

    private var isEditing: Bool { existing != nil }

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
            .scrollContentBackground(.hidden)
            .background(ConservatioAmbientBackground())
            .navigationTitle(isEditing ? "Edit Client" : "New Client")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(t("g.cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(t("g.save")) {
                        let updated = Client(
                            id: existing?.id ?? UUID().uuidString,
                            name: name,
                            type: type,
                            contactPerson: contactPerson,
                            email: email,
                            phone: phone,
                            address: address,
                            notes: notes,
                            createdAt: existing?.createdAt ?? Date(),
                            updatedAt: Date()
                        )
                        if isEditing {
                            clientStore.update(updated)
                        } else {
                            clientStore.add(updated)
                        }
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
