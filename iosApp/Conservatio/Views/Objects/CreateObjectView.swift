import SwiftUI
import PhotosUI

struct CreateObjectView: View {
    @Environment(\.dismiss) private var dismiss
    var objectStore: ObjectStore
    var existing: ConservationObject?
    var onSave: ((ConservationObject) -> Void)?

    @State private var title: String
    @State private var objectType: ObjectType
    @State private var materialsText: String
    @State private var ownerName: String
    @State private var locationDescription: String
    @State private var inventoryNumber: String
    @State private var descriptionText: String
    @State private var acquisitionDate: Date
    @State private var hasAcquisitionDate: Bool

    @State private var height: String
    @State private var width: String
    @State private var depth: String
    @State private var measurementUnit: MeasurementUnit

    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var capturedImages: [UIImage] = []
    @State private var existingImageIds: [String]
    @State private var showCamera = false

    init(
        objectStore: ObjectStore,
        existing: ConservationObject? = nil,
        onSave: ((ConservationObject) -> Void)? = nil
    ) {
        self.objectStore = objectStore
        self.existing = existing
        self.onSave = onSave
        _title = State(initialValue: existing?.title ?? "")
        _objectType = State(initialValue: existing?.objectType ?? .painting)
        _materialsText = State(initialValue: existing?.materials.joined(separator: ", ") ?? "")
        _ownerName = State(initialValue: existing?.ownerName ?? "")
        _locationDescription = State(initialValue: existing?.locationDescription ?? "")
        _inventoryNumber = State(initialValue: existing?.inventoryNumber ?? "")
        _descriptionText = State(initialValue: existing?.description ?? "")
        _acquisitionDate = State(initialValue: existing?.acquisitionDate ?? Date())
        _hasAcquisitionDate = State(initialValue: existing?.acquisitionDate != nil)
        _height = State(initialValue: existing?.dimensions?.height.map { v in String(format: "%g", v) } ?? "")
        _width = State(initialValue: existing?.dimensions?.width.map { v in String(format: "%g", v) } ?? "")
        _depth = State(initialValue: existing?.dimensions?.depth.map { v in String(format: "%g", v) } ?? "")
        _measurementUnit = State(initialValue: existing?.dimensions?.unit ?? .cm)
        _existingImageIds = State(initialValue: existing?.imageIds ?? [])
    }

    private var isEditing: Bool { existing != nil }

    var body: some View {
        NavigationStack {
            Form {
                basicInfoSection
                materialsSection
                dimensionsSection
                locationSection
                photosSection
                notesSection
            }
            .scrollContentBackground(.hidden)
            .background(ConservatioAmbientBackground())
            .navigationTitle(isEditing ? "Edit Object" : "New Object")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(t("g.cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(t("g.save")) { saveObject() }
                        .disabled(title.isEmpty)
                        .bold()
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraView { image in
                    capturedImages.append(image)
                }
            }
            .onChange(of: selectedPhotos) { _, newItems in
                loadPhotos(from: newItems)
            }
        }
    }

    private var basicInfoSection: some View {
        Section("Basic Information") {
            TextField("Object title", text: $title)

            Picker("Type", selection: $objectType) {
                ForEach(ObjectType.allCases) { type in
                    Label(type.displayName, systemImage: type.iconName)
                        .tag(type)
                }
            }

            TextField("Inventory number", text: $inventoryNumber)

            Toggle("Acquisition date", isOn: $hasAcquisitionDate)
            if hasAcquisitionDate {
                DatePicker("Date", selection: $acquisitionDate, displayedComponents: .date)
            }
        }
    }

    private var materialsSection: some View {
        Section {
            TextField("e.g. tempera, wood panel, gold leaf", text: $materialsText)
        } header: {
            Text("Materials")
        } footer: {
            Text("Separate multiple materials with commas")
        }
    }

    private var dimensionsSection: some View {
        Section("Dimensions") {
            Picker("Unit", selection: $measurementUnit) {
                ForEach(MeasurementUnit.allCases, id: \.self) { unit in
                    Text(unit.displayName).tag(unit)
                }
            }
            .pickerStyle(.segmented)

            HStack {
                VStack(alignment: .leading) {
                    Text("H").font(.caption).foregroundStyle(.secondary)
                    TextField("Height", text: $height)
                        .keyboardType(.decimalPad)
                }
                VStack(alignment: .leading) {
                    Text("W").font(.caption).foregroundStyle(.secondary)
                    TextField("Width", text: $width)
                        .keyboardType(.decimalPad)
                }
                VStack(alignment: .leading) {
                    Text("D").font(.caption).foregroundStyle(.secondary)
                    TextField("Depth", text: $depth)
                        .keyboardType(.decimalPad)
                }
            }
        }
    }

    private var locationSection: some View {
        Section("Location and Owner") {
            TextField("Owner name", text: $ownerName)
            TextField("Location description", text: $locationDescription)
        }
    }

    private var photosSection: some View {
        Section {
            if !capturedImages.isEmpty {
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(capturedImages.indices, id: \.self) { index in
                            Image(uiImage: capturedImages[index])
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(alignment: .topTrailing) {
                                    Button {
                                        capturedImages.remove(at: index)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.white, .red)
                                    }
                                    .padding(4)
                                }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            HStack {
                Button {
                    showCamera = true
                } label: {
                    Label("Camera", systemImage: "camera")
                }

                Spacer()

                PhotosPicker(
                    selection: $selectedPhotos,
                    maxSelectionCount: 10,
                    matching: .images
                ) {
                    Label("Gallery", systemImage: "photo.on.rectangle")
                }
            }
        } header: {
            Text("Photos")
        } footer: {
            Text("\(capturedImages.count) photo(s) attached")
        }
    }

    private var notesSection: some View {
        Section("Description") {
            TextEditor(text: $descriptionText)
                .frame(minHeight: 80)
        }
    }

    private func saveObject() {
        Task { await saveObjectAsync() }
    }

    private func saveObjectAsync() async {
        // Newly attached photos. In edit mode we keep the existing imageIds
        // (so old photos don't disappear) and append the newly captured ones.
        var newIds: [String] = capturedImages.compactMap { ImageStore.shared.save($0) }
        if APIClient.shared.isLoggedIn {
            var uploaded: [String] = []
            for image in capturedImages {
                guard let data = image.jpegData(compressionQuality: 0.85) else { continue }
                if let serverId = try? await APIClient.shared.uploadImage(data: data) {
                    uploaded.append(serverId)
                }
            }
            if !uploaded.isEmpty { newIds = uploaded }
        }
        let imageIds = existingImageIds + newIds

        let materials = materialsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        let dimensions = Dimensions(
            height: Double(height),
            width: Double(width),
            depth: Double(depth),
            unit: measurementUnit
        )

        let object = ConservationObject(
            id: existing?.id ?? UUID(),
            title: title,
            objectType: objectType,
            materials: materials,
            dimensions: dimensions,
            ownerName: ownerName.isEmpty ? nil : ownerName,
            locationDescription: locationDescription.isEmpty ? nil : locationDescription,
            acquisitionDate: hasAcquisitionDate ? acquisitionDate : nil,
            inventoryNumber: inventoryNumber.isEmpty ? nil : inventoryNumber,
            description: descriptionText.isEmpty ? nil : descriptionText,
            imageIds: imageIds,
            createdAt: existing?.createdAt ?? Date(),
            updatedAt: Date()
        )

        await MainActor.run {
            if isEditing {
                objectStore.update(object)
            } else {
                objectStore.add(object)
            }
            onSave?(object)
            dismiss()
        }
    }

    private func loadPhotos(from items: [PhotosPickerItem]) {
        for item in items {
            item.loadTransferable(type: Data.self) { result in
                if case .success(let data) = result, let data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        capturedImages.append(image)
                    }
                }
            }
        }
    }
}
