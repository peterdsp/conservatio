import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    welcomeSection
                    quickActionsSection
                    recentActivitySection
                }
                .padding()
            }
            .background(Color.conservatioBackground)
            .navigationTitle("Conservatio")
        }
    }

    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome back")
                .font(.conservatioHeadlineSmall)
            Text("Your conservation workspace")
                .font(.conservatioBodyMedium)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.conservatioTitleMedium)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickActionCard(
                    title: "New Report",
                    icon: "doc.text",
                    color: .conservatioPrimary
                )
                QuickActionCard(
                    title: "Add Object",
                    icon: "cube.box",
                    color: .conservatioSecondary
                )
                QuickActionCard(
                    title: "Take Photo",
                    icon: "camera",
                    color: .conservatioTertiary
                )
                QuickActionCard(
                    title: "New Project",
                    icon: "folder.badge.plus",
                    color: .conservatioPrimaryDark
                )
            }
        }
    }

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.conservatioTitleMedium)

            Text("No recent activity yet. Create your first object to get started.")
                .font(.conservatioBodyMedium)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
        }
    }
}

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(title)
                .font(.conservatioLabelLarge)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.conservatioSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}
