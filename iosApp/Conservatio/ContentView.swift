import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .dashboard
    @State private var objectStore = ObjectStore()
    @State private var reportStore = ReportStore()

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(objectStore: objectStore, reportStore: reportStore)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(Tab.dashboard)

            ObjectsListView(objectStore: objectStore, reportStore: reportStore)
                .tabItem {
                    Label("Objects", systemImage: "cube")
                }
                .tag(Tab.objects)

            ProjectsListView()
                .tabItem {
                    Label("Projects", systemImage: "folder")
                }
                .tag(Tab.projects)

            ClientsListView()
                .tabItem {
                    Label("Clients", systemImage: "person.2")
                }
                .tag(Tab.clients)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(Tab.settings)
        }
        .tint(Color.conservatioPrimary)
    }
}

enum Tab {
    case dashboard, objects, projects, clients, settings
}
