import SwiftUI

struct CreateReportView: View {
    @Environment(\.dismiss) private var dismiss
    let objectId: UUID
    var reportStore: ReportStore

    @State private var reportType: ReportType = .initialAssessment
    @State private var overallCondition: ConditionRating = .fair
    @State private var examiner = ""
    @State private var examinationDate = Date()
    @State private var notes = ""
    @State private var recommendations = ""
    @State private var damageAnnotations: [DamageAnnotation] = []
    @State private var showAddDamage = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Report Type") {
                    Picker("Type", selection: $reportType) {
                        ForEach(ReportType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                }

                Section("Condition Assessment") {
                    Picker("Overall Condition", selection: $overallCondition) {
                        ForEach(ConditionRating.allCases) { rating in
                            Text(rating.displayName).tag(rating)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Examiner") {
                    TextField("Your name", text: $examiner)
                    DatePicker("Date", selection: $examinationDate, displayedComponents: .date)
                }

                Section {
                    if damageAnnotations.isEmpty {
                        Text("No damage recorded")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(damageAnnotations) { annotation in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(annotation.damageType.displayName)
                                        .font(.conservatioBodyMedium)
                                    Text(annotation.severity.displayName)
                                        .font(.conservatioBodySmall)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                        }
                        .onDelete { indexSet in
                            damageAnnotations.remove(atOffsets: indexSet)
                        }
                    }

                    Button {
                        showAddDamage = true
                    } label: {
                        Label("Add Damage", systemImage: "plus.circle")
                    }
                } header: {
                    Text("Damage")
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 60)
                }

                Section("Recommendations") {
                    TextEditor(text: $recommendations)
                        .frame(minHeight: 60)
                }
            }
            .navigationTitle("New Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveReport() }
                        .disabled(examiner.isEmpty)
                        .bold()
                }
            }
            .sheet(isPresented: $showAddDamage) {
                AddDamageView { annotation in
                    damageAnnotations.append(annotation)
                }
            }
        }
    }

    private func saveReport() {
        let report = ConditionReport(
            objectId: objectId,
            reportType: reportType,
            overallCondition: overallCondition,
            examiner: examiner,
            examinationDate: examinationDate,
            damageAnnotations: damageAnnotations,
            notes: notes.isEmpty ? nil : notes,
            recommendations: recommendations.isEmpty ? nil : recommendations
        )
        reportStore.add(report)
        dismiss()
    }
}

struct AddDamageView: View {
    @Environment(\.dismiss) private var dismiss
    var onAdd: (DamageAnnotation) -> Void

    @State private var damageType: DamageType = .crack
    @State private var severity: DamageSeverity = .moderate
    @State private var description = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Damage Type") {
                    Picker("Type", selection: $damageType) {
                        ForEach(DamageType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                }

                Section("Severity") {
                    Picker("Severity", selection: $severity) {
                        ForEach(DamageSeverity.allCases) { sev in
                            Text(sev.displayName).tag(sev)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Description") {
                    TextField("Describe the damage", text: $description)
                }
            }
            .navigationTitle("Add Damage")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let annotation = DamageAnnotation(
                            damageType: damageType,
                            severity: severity,
                            description: description.isEmpty ? nil : description
                        )
                        onAdd(annotation)
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
}
