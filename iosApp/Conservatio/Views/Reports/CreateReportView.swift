import SwiftUI

struct CreateReportView: View {
    @Environment(\.dismiss) private var dismiss
    let objectId: UUID
    var reportStore: ReportStore
    var existing: ConditionReport?
    /// The object's photo ids, so damage markers can be placed on them and the
    /// report can document those photos in its exported PDF.
    var objectImageIds: [String] = []
    /// "annotate" opens the first photo for marking as soon as the form
    /// appears, for the debug launch keys.
    var initialOpen: String? = nil

    @State private var reportType: ReportType
    @State private var overallCondition: ConditionRating
    @State private var examiner: String
    @State private var examinationDate: Date
    @State private var notes: String
    @State private var recommendations: String
    @State private var previousInterventions: String
    @State private var lightSource: String
    @State private var relativeHumidity: String
    @State private var temperature: String
    @State private var conditionNotes: String
    @State private var damageAnnotations: [DamageAnnotation]
    @State private var showAddDamage = false
    @State private var openImageId: String?

    init(objectId: UUID, reportStore: ReportStore, existing: ConditionReport? = nil, objectImageIds: [String] = [],
         initialOpen: String? = nil) {
        self.objectId = objectId
        self.reportStore = reportStore
        self.existing = existing
        self.objectImageIds = objectImageIds
        self.initialOpen = initialOpen
        _reportType = State(initialValue: existing?.reportType ?? .initialAssessment)
        _overallCondition = State(initialValue: existing?.overallCondition ?? .fair)
        _examiner = State(initialValue: existing?.examiner ?? "")
        _examinationDate = State(initialValue: existing?.examinationDate ?? Date())
        _notes = State(initialValue: existing?.notes ?? "")
        _recommendations = State(initialValue: existing?.recommendations ?? "")
        _previousInterventions = State(initialValue: existing?.previousInterventions ?? "")
        let conditions = existing?.examinationConditions
        _lightSource = State(initialValue: conditions?.lightSource ?? "")
        _relativeHumidity = State(initialValue: conditions?.relativeHumidity.map { String(format: "%g", $0) } ?? "")
        _temperature = State(initialValue: conditions?.temperature.map { String(format: "%g", $0) } ?? "")
        _conditionNotes = State(initialValue: conditions?.notes ?? "")
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

                Section {
                    TextEditor(text: $previousInterventions)
                        .frame(minHeight: 60)
                } header: {
                    Text("Previous Interventions")
                } footer: {
                    Text("Earlier treatments, repairs or restorations known for this object.")
                }

                Section("Examination Conditions") {
                    TextField("Light source (e.g. daylight, LED, UV)", text: $lightSource)
                    HStack {
                        Text("Relative humidity")
                        Spacer()
                        TextField("%", text: $relativeHumidity)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: 100)
                        Text("%").foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Temperature")
                        Spacer()
                        TextField("C", text: $temperature)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: 100)
                        Text("C").foregroundStyle(.secondary)
                    }
                    TextField("Other conditions", text: $conditionNotes)
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
            .navigationDestination(item: $openImageId) { imageId in
                if let image = ImageStore.shared.load(imageId) {
                    annotationView(for: imageId, image: image)
                }
            }
            .onAppear {
                if initialOpen == "annotate" { openImageId = objectImageIds.first }
            }
        }
    }

    private func annotationView(for imageId: String, image: UIImage) -> some View {
        ImageAnnotationView(
            image: image,
            imageId: imageId,
            annotations: $damageAnnotations
        )
        .navigationTitle("Annotate Photo")
        .navigationBarTitleDisplayMode(.inline)
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
                            annotationView(for: imageId, image: image)
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

    /// Nil when every condition field is blank, so empty reports stay compact.
    private var examinationConditionsValue: ExaminationConditions? {
        let conditions = ExaminationConditions(
            lightSource: lightSource.isEmpty ? nil : lightSource,
            relativeHumidity: Double(relativeHumidity.replacingOccurrences(of: ",", with: ".")),
            temperature: Double(temperature.replacingOccurrences(of: ",", with: ".")),
            notes: conditionNotes.isEmpty ? nil : conditionNotes
        )
        return conditions.isEmpty ? nil : conditions
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
            previousInterventions: previousInterventions.isEmpty ? nil : previousInterventions,
            examinationConditions: examinationConditionsValue,
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
