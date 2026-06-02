import SwiftUI

struct ContentView: View {
    var initialTab: Tab?
    @State private var selectedTab: Tab = .dashboard
    @State private var objectStore = ObjectStore()
    @State private var reportStore = ReportStore()
    @State private var showCreateObject = false
    @State private var showCreateReport = false

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
        .onAppear {
            if let tab = initialTab {
                selectedTab = tab
            }
        }
        .onOpenURL { url in
            handleDeepLink(url)
        }
        .sheet(isPresented: $showCreateObject) {
            CreateObjectView(objectStore: objectStore)
        }
    }

    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "conservatio" else { return }
        let path = url.host ?? ""

        switch path {
        case "dashboard", "home":
            selectedTab = .dashboard
        case "objects":
            selectedTab = .objects
        case "projects":
            selectedTab = .projects
        case "clients":
            selectedTab = .clients
        case "settings":
            selectedTab = .settings
        case "new-object":
            selectedTab = .objects
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showCreateObject = true
            }
        default:
            break
        }
    }
}

enum Tab {
    case dashboard, objects, projects, clients, settings
}
