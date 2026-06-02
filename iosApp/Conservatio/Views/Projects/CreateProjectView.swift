import SwiftUI

struct CreateProjectView: View {
    var projectStore: ProjectStore
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var clientName = ""
    @State private var status: ProjectStatus = .inquiry
    @State private var budget = ""
    @State private var currency = "EUR"
    @State private var description = ""
    @State private var hasStartDate = false
    @State private var startDate = Date()
    @State private var hasEndDate = false
    @State private var endDate = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section("Project Info") {
                    TextField("Project title", text: $title)

                    TextField("Client name", text: $clientName)

                    Picker("Status", selection: $status) {
                        ForEach(ProjectStatus.allCases, id: \.self) { status in
                            Label(status.rawValue, systemImage: status.icon)
                                .tag(status)
                        }
                    }
                }

                Section("Budget") {
                    HStack {
                        TextField("Amount", text: $budget)
                            .keyboardType(.decimalPad)

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
                    TextEditor(text: $description)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let project = Project(
                            title: title,
                            clientName: clientName,
                            status: status,
                            startDate: hasStartDate ? startDate : nil,
                            endDate: hasEndDate ? endDate : nil,
                            budget: Double(budget),
                            currency: currency,
                            description: description
                        )
                        projectStore.add(project)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}
