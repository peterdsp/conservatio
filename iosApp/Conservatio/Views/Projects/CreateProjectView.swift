import SwiftUI

struct CreateProjectView: View {
    var projectStore: ProjectStore
    var existing: Project?

    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var clientName: String
    @State private var status: ProjectStatus
    @State private var budget: String
    @State private var currency: String
    @State private var description: String
    @State private var hasStartDate: Bool
    @State private var startDate: Date
    @State private var hasEndDate: Bool
    @State private var endDate: Date

    init(projectStore: ProjectStore, existing: Project? = nil) {
        self.projectStore = projectStore
        self.existing = existing
        _title = State(initialValue: existing?.title ?? "")
        _clientName = State(initialValue: existing?.clientName ?? "")
        _status = State(initialValue: existing?.status ?? .inquiry)
        _budget = State(initialValue: existing?.budget.map { String($0) } ?? "")
        _currency = State(initialValue: existing?.currency ?? "EUR")
        _description = State(initialValue: existing?.description ?? "")
        _hasStartDate = State(initialValue: existing?.startDate != nil)
        _startDate = State(initialValue: existing?.startDate ?? Date())
        _hasEndDate = State(initialValue: existing?.endDate != nil)
        _endDate = State(initialValue: existing?.endDate ?? Date())
    }

    private var isEditing: Bool { existing != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Project Info") {
                    TextField("Project title", text: $title)
                    TextField("Client name", text: $clientName)
                    Picker("Status", selection: $status) {
                        ForEach(ProjectStatus.allCases, id: \.self) { status in
                            Label(status.rawValue, systemImage: status.icon).tag(status)
                        }
                    }
                }

                Section("Budget") {
                    HStack {
                        TextField("Amount", text: $budget).keyboardType(.decimalPad)
                        Picker("", selection: $currency) {
                            Text("EUR").tag("EUR")
                            Text("USD").tag("USD")
                            Text("GBP").tag("GBP")
                        }
                        .frame(width: 80)
                    }
                }

                Section("Timeline") {
                    Toggle("Start date", isOn: $hasStartDate)
                    if hasStartDate {
                        DatePicker("Start", selection: $startDate, displayedComponents: .date)
                    }
                    Toggle("End date", isOn: $hasEndDate)
                    if hasEndDate {
                        DatePicker("End", selection: $endDate, displayedComponents: .date)
                    }
                }

                Section("Description") {
                    TextEditor(text: $description).frame(minHeight: 80)
                }
            }
            .scrollContentBackground(.hidden)
            .background(ConservatioAmbientBackground())
            .navigationTitle(isEditing ? "Edit Project" : "New Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(t("g.cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(t("g.save")) {
                        let project = Project(
                            id: existing?.id ?? UUID().uuidString,
                            title: title,
                            clientName: clientName,
                            status: status,
                            objectIds: existing?.objectIds ?? [],
                            startDate: hasStartDate ? startDate : nil,
                            endDate: hasEndDate ? endDate : nil,
                            budget: Double(budget),
                            currency: currency,
                            description: description,
                            createdAt: existing?.createdAt ?? Date(),
                            updatedAt: Date()
                        )
                        if isEditing {
                            projectStore.update(project)
                        } else {
                            projectStore.add(project)
                        }
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}
