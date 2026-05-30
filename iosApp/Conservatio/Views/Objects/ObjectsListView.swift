import SwiftUI

struct ObjectsListView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "No Objects Yet",
                systemImage: "cube",
                description: Text("Add your first conservation object to get started.")
            )
            .navigationTitle("Objects")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        // TODO: navigate to new object
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}
