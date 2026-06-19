import SwiftUI

struct DashboardView: View {
    var objectStore: ObjectStore
    var reportStore: ReportStore
    @State private var showCreateObject = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Heritage monuments faded behind the glass content.
                ConservatioHeritageBackdrop()
                    .opacity(0.7)

                ScrollView {
                    VStack(spacing: 16) {
                        welcomeSection
                        statsSection
                        quickActionsSection
                        recentObjectsSection
                    }
                    .padding()
                }
                .scrollContentBackground(.hidden)
            }
            .background(Color.clear)
            .navigationTitle(t("dash.title"))
            .sheet(isPresented: $showCreateObject) {
                CreateObjectView(objectStore: objectStore)
            }
        }
    }

    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(t("dash.welcome").uppercased())
                .font(.system(size: 12, weight: .semibold))
                .tracking(2.5)
                .foregroundStyle(Color.conservatioPrimary)
            Text(t("dash.title"))
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(Color.conservatioText)
            Text(t("dash.intro"))
                .font(.conservatioBodyMedium)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassPanel(cornerRadius: 24)
    }

    private var statsSection: some View {
        HStack(spacing: 12) {
            StatCard(title: t("stat.objects"), value: "\(objectStore.objects.count)", icon: "cube", color: .conservatioPrimary)
            StatCard(title: t("stat.reports"), value: "\(reportStore.reports.count)", icon: "doc.text", color: .conservatioSecondary)
        }
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(t("dash.quickActions").nilIfEmpty ?? "Quick Actions")
                .font(.conservatioTitleMedium)
                .foregroundStyle(Color.conservatioText)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickActionCard(title: t("dash.newObject"), icon: "cube.box", color: .conservatioPrimary) {
                    showCreateObject = true
                }
                QuickActionCard(title: t("dash.takePhoto"), icon: "camera", color: .conservatioSecondary) {}
                QuickActionCard(title: t("dash.newReport"), icon: "doc.text", color: .conservatioTertiary) {}
                QuickActionCard(title: t("dash.newProject"), icon: "folder.badge.plus", color: .conservatioPrimaryDark) {}
            }
        }
    }

    private var recentObjectsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(t("dash.recentObjects"))
                .font(.conservatioTitleMedium)
                .foregroundStyle(Color.conservatioText)

            if objectStore.objects.isEmpty {
                Text("No objects yet. Create your first one to get started.")
                    .font(.conservatioBodyMedium)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .glassPanel(cornerRadius: 18)
            } else {
                VStack(spacing: 8) {
                    ForEach(objectStore.objects.prefix(5)) { object in
                        HStack(spacing: 12) {
                            Image(systemName: object.objectType.iconName)
                                .font(.title3)
                                .frame(width: 40, height: 40)
                                .background(Color.conservatioPrimary.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .foregroundStyle(Color.conservatioPrimary)
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
                        .glassPanel(cornerRadius: 14)
                    }
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
                .foregroundStyle(Color.conservatioText)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassPanel(cornerRadius: 18)
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
                    .foregroundStyle(Color.conservatioText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .glassPanel(cornerRadius: 16)
        }
        .buttonStyle(.plain)
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
