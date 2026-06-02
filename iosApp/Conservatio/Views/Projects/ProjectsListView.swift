import SwiftUI

struct ProjectsListView: View {
    var projectStore: ProjectStore
    @State private var showCreate = false

    var body: some View {
        NavigationStack {
            Group {
                if projectStore.projects.isEmpty {
                    ContentUnavailableView(
                        "No Projects Yet",
                        systemImage: "folder",
                        description: Text("Create your first project to organize conservation work.")
                    )
                } else {
                    List {
                        ForEach(projectStore.projects.sorted(by: { $0.createdAt > $1.createdAt })) { project in
                            NavigationLink {
                                ProjectDetailView(project: project, projectStore: projectStore)
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: project.status.icon)
                                        .foregroundStyle(Color.conservatioPrimary)
                                        .frame(width: 32)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(project.title)
                                            .font(.conservatioTitleSmall)

                                        if !project.clientName.isEmpty {
                                            Text(project.clientName)
                                                .font(.conservatioBodySmall)
                                                .foregroundStyle(.secondary)
                                        }
                                    }

                                    Spacer()

                                    Text(project.status.rawValue)
                                        .font(.conservatioLabelSmall)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.conservatioSurfaceVariant)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .onDelete { indexSet in
                            let sorted = projectStore.projects.sorted(by: { $0.createdAt > $1.createdAt })
                            for index in indexSet {
                                projectStore.delete(id: sorted[index].id)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Projects")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showCreate = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreate) {
                CreateProjectView(projectStore: projectStore)
            }
        }
    }
}

struct ProjectDetailView: View {
    let project: Project
    var projectStore: ProjectStore

    var body: some View {
        List {
            Section("Details") {
                LabeledContent("Status", value: project.status.rawValue)
                if !project.clientName.isEmpty {
                    LabeledContent("Client", value: project.clientName)
                }
                if let budget = project.budget {
                    LabeledContent("Budget", value: String(format: "%.2f %@", budget, project.currency))
                }
            }

            if !project.description.isEmpty {
                Section("Description") {
                    Text(project.description)
                        .font(.conservatioBodyMedium)
                }
            }

            Section("Timeline") {
                if let start = project.startDate {
                    LabeledContent("Start", value: start.formatted(date: .abbreviated, time: .omitted))
                }
                if let end = project.endDate {
                    LabeledContent("End", value: end.formatted(date: .abbreviated, time: .omitted))
                }
            }
        }
        .navigationTitle(project.title)
    }
}
