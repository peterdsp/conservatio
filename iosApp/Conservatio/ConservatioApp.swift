import SwiftUI

@main
struct ConservatioApp: App {
    @State private var showSplash = true
    @State private var initialTab: Tab? = nil

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView(initialTab: initialTab)
                    .opacity(showSplash ? 0 : 1)

                if showSplash {
                    SplashView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.6), value: showSplash)
            .onAppear {
                // Check UserDefaults for debug navigation (set via simctl defaults write)
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

                let splashDelay: Double = defaults.bool(forKey: "debug_no_splash") ? 0 : 1.5
                DispatchQueue.main.asyncAfter(deadline: .now() + splashDelay) {
                    showSplash = false
                }
            }
        }
    }
}
