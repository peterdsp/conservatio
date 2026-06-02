import SwiftUI

struct ImageAnnotationView: View {
    let image: UIImage
    let imageId: String
    @Binding var annotations: [DamageAnnotation]

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var selectedAnnotation: DamageAnnotation?
    @State private var showAnnotationSheet = false
    @State private var editingAnnotation: DamageAnnotation?

    var body: some View {
        VStack(spacing: 0) {
            annotationCanvas
            annotationList
        }
        .background(Color.conservatioBackground)
        .sheet(isPresented: $showAnnotationSheet, onDismiss: handleSheetDismiss) {
            if let editing = editingAnnotation {
                AnnotationEditSheet(
                    annotation: editing,
                    isNew: !annotations.contains(where: { $0.id == editing.id }),
                    onSave: { saved in
                        saveAnnotation(saved)
                        showAnnotationSheet = false
                    },
                    onDelete: {
                        deleteAnnotation(editing.id)
                        showAnnotationSheet = false
                    },
                    onCancel: {
                        showAnnotationSheet = false
                    }
                )
            }
        }
    }

    // MARK: - Canvas

    private var annotationCanvas: some View {
        GeometryReader { geometry in
            let imageSize = imageFitSize(in: geometry.size)
            let imageOrigin = CGPoint(
                x: (geometry.size.width - imageSize.width) / 2,
                y: (geometry.size.height - imageSize.height) / 2
            )

            ZStack {
                Color.black.opacity(0.05)

                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .offset(offset)

                markersOverlay(imageSize: imageSize, imageOrigin: imageOrigin)
            }
            .clipped()
            .contentShape(Rectangle())
            .gesture(pinchGesture)
            .simultaneousGesture(panGesture)
            .onTapGesture { location in
                handleCanvasTap(at: location, imageSize: imageSize, imageOrigin: imageOrigin)
            }
        }
        .frame(height: 350)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .padding(.top)
    }

    private func markersOverlay(imageSize: CGSize, imageOrigin: CGPoint) -> some View {
        let imageAnnotations = annotations.filter { $0.imageId == imageId }
        return ForEach(Array(imageAnnotations.enumerated()), id: \.element.id) { index, annotation in
            if let xPct = annotation.xPercent, let yPct = annotation.yPercent {
                let markerX = imageOrigin.x + (xPct / 100.0) * imageSize.width
                let markerY = imageOrigin.y + (yPct / 100.0) * imageSize.height

                AnnotationMarker(
                    number: index + 1,
                    severity: annotation.severity,
                    isSelected: selectedAnnotation?.id == annotation.id
                )
                .position(
                    x: markerX * scale + offset.width,
                    y: markerY * scale + offset.height
                )
                .onTapGesture {
                    selectedAnnotation = annotation
                    editingAnnotation = annotation
                    showAnnotationSheet = true
                }
            }
        }
    }

    // MARK: - Annotation List

    private var annotationList: some View {
        let imageAnnotations = annotations.filter { $0.imageId == imageId }

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Annotations")
                    .font(.conservatioTitleSmall)
                Spacer()
                Text("\(imageAnnotations.count)")
                    .font(.conservatioLabelMedium)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.top, 12)

            if imageAnnotations.isEmpty {
                Text("Tap on the image to place a damage marker.")
                    .font(.conservatioBodySmall)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(Array(imageAnnotations.enumerated()), id: \.element.id) { index, annotation in
                            AnnotationRow(
                                number: index + 1,
                                annotation: annotation,
                                isSelected: selectedAnnotation?.id == annotation.id
                            )
                            .onTapGesture {
                                selectedAnnotation = annotation
                                editingAnnotation = annotation
                                showAnnotationSheet = true
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    // MARK: - Gestures

    private var pinchGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                let newScale = lastScale * value.magnification
                scale = min(max(newScale, 1.0), 5.0)
            }
            .onEnded { _ in
                lastScale = scale
                if scale <= 1.0 {
                    withAnimation(.easeOut(duration: 0.2)) {
                        offset = .zero
                        lastOffset = .zero
                    }
                }
            }
    }

    private var panGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard scale > 1.0 else { return }
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }

    // MARK: - Helpers

    private func imageFitSize(in containerSize: CGSize) -> CGSize {
        let imageAspect = image.size.width / image.size.height
        let containerAspect = containerSize.width / containerSize.height

        if imageAspect > containerAspect {
            let width = containerSize.width
            let height = width / imageAspect
            return CGSize(width: width, height: height)
        } else {
            let height = containerSize.height
            let width = height * imageAspect
            return CGSize(width: width, height: height)
        }
    }

    private func handleCanvasTap(at location: CGPoint, imageSize: CGSize, imageOrigin: CGPoint) {
        guard scale <= 1.05 else { return }

        let adjustedX = (location.x - offset.width) / scale
        let adjustedY = (location.y - offset.height) / scale

        let relativeX = adjustedX - imageOrigin.x
        let relativeY = adjustedY - imageOrigin.y

        guard relativeX >= 0, relativeX <= imageSize.width,
              relativeY >= 0, relativeY <= imageSize.height else {
            return
        }

        let xPercent = (relativeX / imageSize.width) * 100.0
        let yPercent = (relativeY / imageSize.height) * 100.0

        let newAnnotation = DamageAnnotation(
            imageId: imageId,
            xPercent: xPercent,
            yPercent: yPercent
        )

        editingAnnotation = newAnnotation
        showAnnotationSheet = true
    }

    private func saveAnnotation(_ annotation: DamageAnnotation) {
        if let index = annotations.firstIndex(where: { $0.id == annotation.id }) {
            annotations[index] = annotation
        } else {
            annotations.append(annotation)
        }
        selectedAnnotation = annotation
    }

    private func deleteAnnotation(_ id: UUID) {
        annotations.removeAll { $0.id == id }
        if selectedAnnotation?.id == id {
            selectedAnnotation = nil
        }
    }

    private func handleSheetDismiss() {
        editingAnnotation = nil
    }
}

// MARK: - Annotation Marker

struct AnnotationMarker: View {
    let number: Int
    let severity: DamageSeverity
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(severityColor.opacity(0.9))
                .frame(width: markerSize, height: markerSize)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)

            if isSelected {
                Circle()
                    .stroke(Color.white, lineWidth: 2.5)
                    .frame(width: markerSize + 4, height: markerSize + 4)
            }

            Text("\(number)")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
        }
    }

    private var markerSize: CGFloat { isSelected ? 30 : 26 }

    private var severityColor: Color {
        switch severity {
        case .minor: return .conditionGood
        case .moderate: return .conditionFair
        case .severe: return .conditionPoor
        case .critical: return .conditionCritical
        }
    }
}

// MARK: - Annotation Row

struct AnnotationRow: View {
    let number: Int
    let annotation: DamageAnnotation
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            AnnotationMarker(number: number, severity: annotation.severity, isSelected: false)

            VStack(alignment: .leading, spacing: 2) {
                Text(annotation.damageType.displayName)
                    .font(.conservatioLabelLarge)
                if let desc = annotation.description, !desc.isEmpty {
                    Text(desc)
                        .font(.conservatioBodySmall)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Text(annotation.severity.displayName)
                .font(.conservatioLabelSmall)
                .foregroundStyle(severityColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(severityColor.opacity(0.12))
                .clipShape(Capsule())
        }
        .padding(10)
        .background(isSelected ? Color.conservatioPrimary.opacity(0.08) : Color.conservatioSurface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.conservatioPrimary : Color.clear, lineWidth: 1.5)
        )
    }

    private var severityColor: Color {
        switch annotation.severity {
        case .minor: return .conditionGood
        case .moderate: return .conditionFair
        case .severe: return .conditionPoor
        case .critical: return .conditionCritical
        }
    }
}

// MARK: - Annotation Edit Sheet

struct AnnotationEditSheet: View {
    @State private var annotation: DamageAnnotation
    let isNew: Bool
    let onSave: (DamageAnnotation) -> Void
    let onDelete: () -> Void
    let onCancel: () -> Void

    @State private var descriptionText: String = ""

    init(
        annotation: DamageAnnotation,
        isNew: Bool,
        onSave: @escaping (DamageAnnotation) -> Void,
        onDelete: @escaping () -> Void,
        onCancel: @escaping () -> Void = {}
    ) {
        _annotation = State(initialValue: annotation)
        self.isNew = isNew
        self.onSave = onSave
        self.onDelete = onDelete
        self.onCancel = onCancel
        _descriptionText = State(initialValue: annotation.description ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Damage Type") {
                    Picker("Type", selection: $annotation.damageType) {
                        ForEach(DamageType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Severity") {
                    Picker("Severity", selection: $annotation.severity) {
                        ForEach(DamageSeverity.allCases) { severity in
                            HStack {
                                Circle()
                                    .fill(colorForSeverity(severity))
                                    .frame(width: 10, height: 10)
                                Text(severity.displayName)
                            }
                            .tag(severity)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section("Description") {
                    TextField("Describe the damage observed...", text: $descriptionText, axis: .vertical)
                        .lineLimit(3...6)
                }

                if let x = annotation.xPercent, let y = annotation.yPercent {
                    Section("Position") {
                        HStack {
                            Label("X: \(x, specifier: "%.1f")%", systemImage: "arrow.left.and.right")
                            Spacer()
                            Label("Y: \(y, specifier: "%.1f")%", systemImage: "arrow.up.and.down")
                        }
                        .font(.conservatioBodySmall)
                        .foregroundStyle(.secondary)
                    }
                }

                if !isNew {
                    Section {
                        Button(role: .destructive) {
                            onDelete()
                        } label: {
                            Label("Delete Annotation", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle(isNew ? "New Annotation" : "Edit Annotation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var saved = annotation
                        saved.description = descriptionText.isEmpty ? nil : descriptionText
                        onSave(saved)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func colorForSeverity(_ severity: DamageSeverity) -> Color {
        switch severity {
        case .minor: return .conditionGood
        case .moderate: return .conditionFair
        case .severe: return .conditionPoor
        case .critical: return .conditionCritical
        }
    }
}
