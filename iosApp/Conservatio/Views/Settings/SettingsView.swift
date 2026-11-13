import SwiftUI

struct SettingsView: View {
    var objectStore: ObjectStore?
    @State private var showClearConfirm = false
    @State private var api = APIClient.shared
    @State private var showLogin = false
    @State private var showDeleteAccountConfirm = false
    @State private var isDeletingAccount = false
    @State private var deleteAccountError: String?

    var body: some View {
        NavigationStack {
            List {
                Section(t("settings.account")) {
                    if api.isLoggedIn {
                        Button(role: .destructive) {
                            api.logout()
                            // Stay inside the offline-first app after signing out.
                            UserDefaults.standard.set(true, forKey: "offlineMode")
                        } label: {
                            Label(t("g.signOut"), systemImage: "rectangle.portrait.and.arrow.right")
                        }

                        Button(role: .destructive) {
                            showDeleteAccountConfirm = true
                        } label: {
                            HStack {
                                Label("Delete account", systemImage: "person.crop.circle.badge.xmark")
                                Spacer()
                                if isDeletingAccount { ProgressView() }
                            }
                        }
                        .disabled(isDeletingAccount)

                        if let deleteAccountError {
                            Text(deleteAccountError)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    } else {
                        Button {
                            showLogin = true
                        } label: {
                            Label(t("login.signInToSync"), systemImage: "person.crop.circle.badge.plus")
                        }
                    }

                    NavigationLink {
                        ProfileSettingsView()
                    } label: {
                        Label(t("settings.profile"), systemImage: "person.circle")
                    }

                    NavigationLink {
                        SyncSettingsView(objectStore: objectStore)
                    } label: {
                        Label("Sync & Storage", systemImage: "arrow.triangle.2.circlepath")
                    }

                    NavigationLink {
                        CloudStorageView()
                    } label: {
                        Label(t("cloud.title"), systemImage: "cloud")
                    }
                }

                Section("Reports") {
                    NavigationLink {
                        ComingSoonView(title: "Templates", description: "Customize report templates with your logo, header, and default fields.")
                    } label: {
                        Label("Templates", systemImage: "doc.text")
                    }

                    NavigationLink {
                        ExportSettingsView()
                    } label: {
                        Label("Export Settings", systemImage: "square.and.arrow.up")
                    }

                    NavigationLink {
                        LanguageSettingsView()
                    } label: {
                        Label(t("settings.language"), systemImage: "globe")
                    }
                }

                Section("App") {
                    NavigationLink {
                        AppearanceSettingsView()
                    } label: {
                        Label("Appearance", systemImage: "paintbrush")
                    }

                    NavigationLink {
                        StorageInfoView()
                    } label: {
                        Label("Storage", systemImage: "internaldrive")
                    }

                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("About", systemImage: "info.circle")
                    }
                }

                Section {
                    Button {
                        objectStore?.loadSampleData()
                    } label: {
                        Label(t("settings.loadSample"), systemImage: "tray.and.arrow.down")
                    }

                    Button(role: .destructive) {
                        showClearConfirm = true
                    } label: {
                        Label(t("settings.clearAll"), systemImage: "trash")
                    }
                } header: {
                    Text(t("settings.dangerTitle"))
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .navigationTitle(t("settings.title"))
            .alert(t("settings.clearAll"), isPresented: $showClearConfirm) {
                Button(t("settings.clearAll"), role: .destructive) {
                    objectStore?.clearAllData()
                }
                Button(t("g.cancel"), role: .cancel) {}
            } message: {
                Text(t("settings.clearConfirm"))
            }
            .confirmationDialog(
                "Delete your account?",
                isPresented: $showDeleteAccountConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete account", role: .destructive) {
                    Task { await deleteAccount() }
                }
                Button(t("g.cancel"), role: .cancel) {}
            } message: {
                Text("This permanently removes your account and every object, report, project, client and photo stored on the server. Records on this device are kept and you can keep working without an account.")
            }
            .sheet(isPresented: $showLogin) {
                LoginView(apiClient: api) {
                    showLogin = false
                    // Pull down anything already on the account after signing in.
                    Task { await objectStore?.syncFromServer() }
                }
            }
        }
    }

    /// Deletes the server account, then forgets everything tied to it locally:
    /// the token, queued sync changes and the last sync time. Local records
    /// are untouched and the app continues in offline mode.
    @MainActor
    private func deleteAccount() async {
        isDeletingAccount = true
        deleteAccountError = nil
        defer { isDeletingAccount = false }
        do {
            try await api.deleteAccount()
        } catch APIError.unauthorized {
            // The session was already gone; the account cannot be reached, so
            // fall through to the signed-out state.
        } catch {
            deleteAccountError = error.localizedDescription
            return
        }
        api.logout()
        SyncEngine.shared.outbox.clear()
        SyncEngine.shared.status = .idle
        SyncEngine.shared.lastError = nil
        UserDefaults.standard.removeObject(forKey: "lastSyncAt")
        UserDefaults.standard.set(true, forKey: "offlineMode")
    }
}
