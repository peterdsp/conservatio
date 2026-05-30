import SwiftUI

struct ProjectsListView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "No Projects Yet",
                systemImage: "folder",
                description: Text("Create your first project to organize conservation work.")
            )
            .navigationTitle("Projects")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        // TODO: navigate to new project
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}
