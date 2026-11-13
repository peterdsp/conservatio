import SwiftUI

@main
struct ConservatioApp: App {
    @State private var showSplash = true
    @State private var initialTab: Tab? = nil
    @State private var initialOpen: String? = nil
    @State private var apiClient = APIClient.shared
    @State private var isAuthenticated = false
    /// The app is offline-first. Once the user chooses to work without an
    /// account, we remember it so they are not forced through the sign-in wall
    /// on every launch (they can still sign in later from Settings to sync).
    @State private var offlineMode = UserDefaults.standard.bool(forKey: "offlineMode")

    var body: some Scene {
        WindowGroup {
            ZStack {
                if isAuthenticated || offlineMode || !showSplash {
                    if apiClient.isLoggedIn || isAuthenticated || offlineMode {
                        ContentView(initialTab: initialTab, initialOpen: initialOpen)
                    } else {
                        LoginView(apiClient: apiClient) {
                            withAnimation { isAuthenticated = true }
                        } onContinueOffline: {
                            UserDefaults.standard.set(true, forKey: "offlineMode")
                            withAnimation { offlineMode = true }
                        }
                    }
                }

                if showSplash {
                    SplashView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.6), value: showSplash)
            .onAppear {
                let defaults = UserDefaults.standard
                if let tab = defaults.string(forKey: "debug_tab") {
                    switch tab {
                    case "objects": initialTab = .objects
                    case "projects": initialTab = .projects
                    case "clients": initialTab = .clients
                    case "settings": initialTab = .settings
                    default: break
                    }
                    defaults.removeObject(forKey: "debug_tab")
                }

                #if DEBUG
                // Screenshot runs land on one screen at launch, the way
                // `debug_tab` picks a tab: annotate, pdf and detail open the
                // first sample object; objects and projects open the lists.
                if let open = defaults.string(forKey: "debug_open") {
                    initialOpen = open
                    switch open {
                    case "annotate", "pdf", "detail", "objects": initialTab = .objects
                    case "projects": initialTab = .projects
                    default: break
                    }
                    defaults.removeObject(forKey: "debug_open")
                }
                #endif

                if defaults.bool(forKey: "debug_sample") {
                    let objectStore = ObjectStore()
                    objectStore.loadSampleData()
                    #if DEBUG
                    // Debug builds also attach the bundled photographs, one
                    // annotated report, a letterhead and a few projects.
                    objectStore.attachSamplePhotos()
                    ReportStore().loadSampleReport(for: objectStore.objects)
                    ProjectStore().loadSampleProjects()
                    #endif
                    defaults.removeObject(forKey: "debug_sample")
                }
                let splashDelay: Double = defaults.bool(forKey: "debug_no_splash") ? 0 : 1.5
                DispatchQueue.main.asyncAfter(deadline: .now() + splashDelay) {
                    showSplash = false
                    // Auto-authenticate if token exists
                    if apiClient.isLoggedIn {
                        isAuthenticated = true
                    }
                }
            }
        }
    }
}
