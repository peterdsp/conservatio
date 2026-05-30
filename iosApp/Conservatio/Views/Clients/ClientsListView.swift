import SwiftUI

struct ClientsListView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "No Clients Yet",
                systemImage: "person.2",
                description: Text("Add clients to manage conservation projects.")
            )
            .navigationTitle("Clients")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        // TODO: navigate to new client
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}
