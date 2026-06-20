import SwiftUI

struct CloudStorageView: View {
    @State private var usage: StorageUsage?
    @State private var error: String?
    @State private var interested: Set<String> = {
        let raw = UserDefaults.standard.stringArray(forKey: "providerInterest") ?? []
        return Set(raw)
    }()

    private let api = APIClient.shared
    private var signedIn: Bool { api.isLoggedIn }

    private let providers: [(key: String, name: String, icon: String, color: Color)] = [
        ("google-drive", "cloud.connectGoogleDrive", "g.circle.fill", Color(red: 0.26, green: 0.52, blue: 0.96)),
        ("icloud", "cloud.connectICloud", "icloud.fill", Color(red: 0.08, green: 0.49, blue: 0.98)),
        ("onedrive", "cloud.connectOneDrive", "square.grid.2x2.fill", Color(red: 0.0, green: 0.64, blue: 0.94)),
        ("mega", "cloud.connectMega", "m.circle.fill", Color(red: 0.85, green: 0.15, blue: 0.18)),
        ("dropbox", "cloud.connectDropbox", "shippingbox.fill", Color(red: 0.0, green: 0.38, blue: 1.0)),
    ]

    var body: some View {
        List {
            // Conservatio Cloud
            Section {
                HStack {
                    Image(systemName: "cloud.fill")
                        .font(.title2)
                        .foregroundStyle(Color.conservatioPrimary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(t("cloud.conservatio"))
                            .font(.conservatioBodyLarge)
                            .fontWeight(.semibold)
                        Text(t("cloud.conservatioFreeNote"))
                            .font(.conservatioBodySmall)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(signedIn ? t("cloud.connected") : t("g.offline"))
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .textCase(.uppercase)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(signedIn ? Color.green.opacity(0.15) : Color.secondary.opacity(0.15))
                        )
                        .foregroundStyle(signedIn ? .green : .secondary)
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(t("cloud.usageLabel"))
                            .font(.conservatioBodySmall)
                            .foregroundStyle(.secondary)
                        Spacer()
                        if let usage = usage {
                            Text("\(usage.usedFormatted) / \(usage.limitFormatted) · \(String(format: "%.1f", usage.percentUsed))%")
                                .font(.conservatioBodySmall)
                                .foregroundStyle(.secondary)
                        } else if signedIn {
                            Text("…")
                                .font(.conservatioBodySmall)
                                .foregroundStyle(.secondary)
                        } else {
                            Text(t("cloud.signedOutUsage"))
                                .font(.conservatioBodySmall)
                                .foregroundStyle(.secondary)
                        }
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.secondary.opacity(0.2))
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.conservatioPrimary)
                                .frame(width: geo.size.width * percent, height: 6)
                        }
                    }
                    .frame(height: 6)

                    if let error = error {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            } header: {
                Text(t("cloud.title"))
            } footer: {
                Text(t("cloud.subtitle"))
            }

            // Third-party providers
            Section {
                ForEach(providers, id: \.key) { provider in
                    let noted = interested.contains(provider.key)
                    Button {
                        expressInterest(provider.key)
                    } label: {
                        HStack {
                            Image(systemName: provider.icon)
                                .foregroundStyle(provider.color)
                                .frame(width: 28)
                            Text(t(provider.name))
                                .foregroundStyle(Color.primary)
                            Spacer()
                            if noted {
                                Label(t("cloud.interestNoted"), systemImage: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(.green)
                            } else {
                                Text(t("cloud.comingSoon"))
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .textCase(.uppercase)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(Color.secondary.opacity(0.12))
                                    )
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            } header: {
                Text(t("cloud.providers"))
            } footer: {
                Text(t("cloud.providersHint"))
            }
        }
        .navigationTitle(t("cloud.title"))
        .task {
            guard signedIn else { return }
            do {
                usage = try await api.fetchStorageUsage()
            } catch {
                self.error = error.localizedDescription
            }
        }
    }

    private var percent: CGFloat {
        guard let usage = usage else { return 0 }
        return min(1, max(0, CGFloat(usage.percentUsed) / 100))
    }

    private func expressInterest(_ key: String) {
        interested.insert(key)
        UserDefaults.standard.set(Array(interested), forKey: "providerInterest")
    }
}
