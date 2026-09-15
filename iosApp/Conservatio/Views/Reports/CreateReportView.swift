import SwiftUI

struct CreateReportView: View {
    @Environment(\.dismiss) private var dismiss
    let objectId: UUID
    var reportStore: ReportStore
    var existing: ConditionReport?
    /// The object's photo ids, so damage markers can be placed on them and the
    /// report can document those photos in its exported PDF.
    var objectImageIds: [String] = []

    @State private var reportType: ReportType
    @State private var overallCondition: ConditionRating
    @State private var examiner: String
    @State private var examinationDate: Date
    @State private var notes: String
    @State private var recommendations: String
    @State private var damageAnnotations: [DamageAnnotation]
    @State private var showAddDamage = false

    init(objectId: UUID, reportStore: ReportStore, existing: ConditionReport? = nil, objectImageIds: [String] = []) {
        self.objectId = objectId
        self.reportStore = reportStore
        self.existing = existing
        self.objectImageIds = objectImageIds
        _reportType = State(initialValue: existing?.reportType ?? .initialAssessment)
        _overallCondition = State(initialValue: existing?.overallCondition ?? .fair)
        _examiner = State(initialValue: existing?.examiner ?? "")
        _examinationDate = State(initialValue: existing?.examinationDate ?? Date())
        _notes = State(initialValue: existing?.notes ?? "")
        _recommendations = State(initialValue: existing?.recommendations ?? "")
        _damageAnnotations = State(initialValue: existing?.damageAnnotations ?? [])
    }

    private var isEditing: Bool { existing != nil }

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

                photoAnnotationSection

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
            .scrollContentBackground(.hidden)
            .background(ConservatioAmbientBackground())
            .navigationTitle(isEditing ? "Edit Report" : "New Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(t("g.cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(t("g.save")) { saveReport() }
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

    /// Lets the conservator open each object photo and drop numbered damage
    /// markers on it. Markers are stored as percentage coordinates against the
    /// photo, so they render on the matching photo in the exported PDF.
    @ViewBuilder
    private var photoAnnotationSection: some View {
        if !objectImageIds.isEmpty {
            Section {
                ForEach(objectImageIds, id: \.self) { imageId in
                    if let image = ImageStore.shared.load(imageId) {
                        NavigationLink {
                            ImageAnnotationView(
                                image: image,
                                imageId: imageId,
                                annotations: $damageAnnotations
                            )
                            .navigationTitle("Annotate Photo")
                            .navigationBarTitleDisplayMode(.inline)
                        } label: {
                            HStack(spacing: 12) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 56, height: 56)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                let count = markerCount(for: imageId)
                                Text(count == 0
                                     ? "Tap to place damage markers"
                                     : "\(count) marker\(count == 1 ? "" : "s")")
                                    .font(.conservatioBodyMedium)
                                    .foregroundStyle(count == 0 ? .secondary : .primary)
                            }
                        }
                    }
                }
            } header: {
                Text("Photos")
            } footer: {
                Text("Open a photo to mark damage directly on it. Markers appear on the matching photo in the exported PDF.")
            }
        }
    }

    private func markerCount(for imageId: String) -> Int {
        damageAnnotations.filter { $0.imageId == imageId && $0.xPercent != nil }.count
    }

    private func saveReport() {
        let report = ConditionReport(
            id: existing?.id ?? UUID(),
            objectId: objectId,
            reportType: reportType,
            overallCondition: overallCondition,
            examiner: examiner,
            examinationDate: examinationDate,
            damageAnnotations: damageAnnotations,
            notes: notes.isEmpty ? nil : notes,
            recommendations: recommendations.isEmpty ? nil : recommendations,
            imageIds: existing?.imageIds.isEmpty == false ? existing!.imageIds : objectImageIds,
            createdAt: existing?.createdAt ?? Date(),
            updatedAt: Date()
        )
        if isEditing {
            reportStore.update(report)
        } else {
            reportStore.add(report)
        }
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
