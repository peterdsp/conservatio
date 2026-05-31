import SwiftUI

struct ObjectsListView: View {
    var objectStore: ObjectStore
    var reportStore: ReportStore
    @State private var showCreateObject = false
    @State private var searchText = ""

    private var filteredObjects: [ConservationObject] {
        if searchText.isEmpty {
            return objectStore.objects
        }
        return objectStore.objects.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.objectType.displayName.localizedCaseInsensitiveContains(searchText) ||
            ($0.inventoryNumber?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if objectStore.objects.isEmpty {
                    ContentUnavailableView(
                        "No Objects Yet",
                        systemImage: "cube",
                        description: Text("Add your first conservation object to get started.")
                    )
                } else {
                    List {
                        ForEach(filteredObjects) { object in
                            NavigationLink(destination: ObjectDetailView(object: object, reportStore: reportStore)) {
                                ObjectRow(object: object)
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                objectStore.delete(filteredObjects[index])
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search objects")
                }
            }
            .navigationTitle("Objects")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showCreateObject = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateObject) {
                CreateObjectView(objectStore: objectStore)
            }
        }
    }
}

struct ObjectRow: View {
    let object: ConservationObject

    var body: some View {
        HStack(spacing: 12) {
            if let firstImageId = object.imageIds.first, let image = ImageStore.shared.load(firstImageId) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: object.objectType.iconName)
                    .font(.title2)
                    .frame(width: 56, height: 56)
                    .background(Color.conservatioSurfaceVariant)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(object.title)
                    .font(.conservatioTitleSmall)
                    .lineLimit(1)
                HStack(spacing: 8) {
                    Text(object.objectType.displayName)
                        .font(.conservatioBodySmall)
                        .foregroundStyle(.secondary)
                    if let inv = object.inventoryNumber {
                        Text(inv)
                            .font(.conservatioBodySmall)
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}
