import SwiftUI

struct ClientsListView: View {
    var clientStore: ClientStore
    @State private var showCreate = false

    var body: some View {
        NavigationStack {
            Group {
                if clientStore.clients.isEmpty {
                    ContentUnavailableView(
                        "No Clients Yet",
                        systemImage: "person.2",
                        description: Text("Add clients to manage conservation projects.")
                    )
                } else {
                    List {
                        ForEach(clientStore.clients.sorted(by: { $0.createdAt > $1.createdAt })) { client in
                            NavigationLink {
                                ClientDetailView(client: client, clientStore: clientStore)
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: client.type.icon)
                                        .foregroundStyle(Color.conservatioSecondary)
                                        .frame(width: 32)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(client.name)
                                            .font(.conservatioTitleSmall)

                                        Text(client.type.rawValue)
                                            .font(.conservatioBodySmall)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    if !client.email.isEmpty {
                                        Image(systemName: "envelope")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        .onDelete { indexSet in
                            let sorted = clientStore.clients.sorted(by: { $0.createdAt > $1.createdAt })
                            for index in indexSet {
                                clientStore.delete(id: sorted[index].id)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Clients")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showCreate = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreate) {
                CreateClientView(clientStore: clientStore)
            }
        }
    }
}

struct ClientDetailView: View {
    let client: Client
    var clientStore: ClientStore

    var body: some View {
        List {
            Section("Contact") {
                LabeledContent("Type", value: client.type.rawValue)
                if !client.contactPerson.isEmpty {
                    LabeledContent("Contact Person", value: client.contactPerson)
                }
                if !client.email.isEmpty {
                    LabeledContent("Email", value: client.email)
                }
                if !client.phone.isEmpty {
                    LabeledContent("Phone", value: client.phone)
                }
                if !client.address.isEmpty {
                    LabeledContent("Address", value: client.address)
                }
            }

            if !client.notes.isEmpty {
                Section("Notes") {
                    Text(client.notes)
                        .font(.conservatioBodyMedium)
                }
            }
        }
        .navigationTitle(client.name)
    }
}
