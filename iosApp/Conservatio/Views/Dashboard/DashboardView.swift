import SwiftUI

struct DashboardView: View {
    var objectStore: ObjectStore
    var reportStore: ReportStore
    @State private var showCreateObject = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    welcomeSection
                    statsSection
                    quickActionsSection
                    recentObjectsSection
                }
                .padding()
            }
            .background(Color.conservatioBackground)
            .navigationTitle("Conservatio")
            .sheet(isPresented: $showCreateObject) {
                CreateObjectView(objectStore: objectStore)
            }
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

    private var statsSection: some View {
        HStack(spacing: 12) {
            StatCard(title: "Objects", value: "\(objectStore.objects.count)", icon: "cube", color: .conservatioPrimary)
            StatCard(title: "Reports", value: "\(reportStore.reports.count)", icon: "doc.text", color: .conservatioSecondary)
        }
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.conservatioTitleMedium)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickActionCard(title: "New Object", icon: "cube.box", color: .conservatioPrimary) {
                    showCreateObject = true
                }
                QuickActionCard(title: "Take Photo", icon: "camera", color: .conservatioSecondary) {}
                QuickActionCard(title: "New Report", icon: "doc.text", color: .conservatioTertiary) {}
                QuickActionCard(title: "New Project", icon: "folder.badge.plus", color: .conservatioPrimaryDark) {}
            }
        }
    }

    private var recentObjectsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Objects")
                .font(.conservatioTitleMedium)

            if objectStore.objects.isEmpty {
                Text("No objects yet. Create your first one to get started.")
                    .font(.conservatioBodyMedium)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
            } else {
                ForEach(objectStore.objects.prefix(5)) { object in
                    HStack(spacing: 12) {
                        Image(systemName: object.objectType.iconName)
                            .font(.title3)
                            .frame(width: 40, height: 40)
                            .background(Color.conservatioSurfaceVariant)
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(object.title)
                                .font(.conservatioTitleSmall)
                            Text(object.objectType.displayName)
                                .font(.conservatioBodySmall)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(object.updatedAt.formatted(date: .abbreviated, time: .omitted))
                            .font(.conservatioLabelSmall)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(12)
                    .background(Color.conservatioSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.conservatioLabelMedium)
                    .foregroundStyle(.secondary)
                Spacer()
                Image(systemName: icon)
                    .foregroundStyle(color)
            }
            Text(value)
                .font(.system(size: 28, weight: .bold))
        }
        .padding()
        .background(Color.conservatioSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
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
        .buttonStyle(.plain)
    }
}
