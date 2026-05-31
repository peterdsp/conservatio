import SwiftUI
import PhotosUI

struct CreateObjectView: View {
    @Environment(\.dismiss) private var dismiss
    var objectStore: ObjectStore
    var onSave: ((ConservationObject) -> Void)?

    @State private var title = ""
    @State private var objectType: ObjectType = .painting
    @State private var materialsText = ""
    @State private var ownerName = ""
    @State private var locationDescription = ""
    @State private var inventoryNumber = ""
    @State private var descriptionText = ""
    @State private var acquisitionDate = Date()
    @State private var hasAcquisitionDate = false

    @State private var height = ""
    @State private var width = ""
    @State private var depth = ""
    @State private var measurementUnit: MeasurementUnit = .cm

    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var capturedImages: [UIImage] = []
    @State private var showCamera = false

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
            .navigationTitle("New Object")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveObject() }
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
        let imageIds = capturedImages.compactMap { ImageStore.shared.save($0) }
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
            title: title,
            objectType: objectType,
            materials: materials,
            dimensions: dimensions,
            ownerName: ownerName.isEmpty ? nil : ownerName,
            locationDescription: locationDescription.isEmpty ? nil : locationDescription,
            acquisitionDate: hasAcquisitionDate ? acquisitionDate : nil,
            inventoryNumber: inventoryNumber.isEmpty ? nil : inventoryNumber,
            description: descriptionText.isEmpty ? nil : descriptionText,
            imageIds: imageIds
        )

        objectStore.add(object)
        onSave?(object)
        dismiss()
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
