import SwiftUI

struct AboutView: View {
    var body: some View {
        List {
            Section {
                VStack(spacing: 12) {
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.conservatioPrimary)

                    Text("Conservatio")
                        .font(.conservatioHeadlineSmall)

                    Text("v0.1.0")
                        .font(.conservatioBodySmall)
                        .foregroundStyle(.secondary)

                    Text("Document heritage. Protect history.")
                        .font(.conservatioBodyMedium)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            }

            Section("Links") {
                Link(destination: URL(string: "https://conservatio.peterdsp.dev")!) {
                    Label("Website", systemImage: "globe")
                }
                Link(destination: URL(string: "https://github.com/peterdsp/conservatio")!) {
                    Label("GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                }
            }

            Section("Developer") {
                HStack {
                    Text("Created by")
                    Spacer()
                    Text("Petros Dhespollari")
                        .foregroundStyle(.secondary)
                }
                Link(destination: URL(string: "https://peterdsp.dev")!) {
                    Label("peterdsp.dev", systemImage: "person")
                }
            }

            Section {
                HStack {
                    Text("License")
                    Spacer()
                    Text("MIT")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("About")
    }
}
