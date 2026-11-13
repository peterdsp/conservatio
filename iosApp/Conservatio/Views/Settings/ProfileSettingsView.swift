import SwiftUI
import PhotosUI

struct ProfileSettingsView: View {
    @AppStorage("conservatorName") private var conservatorName: String = ""
    @AppStorage("conservatorTitle") private var conservatorTitle: String = ""
    @AppStorage("conservatorEmail") private var conservatorEmail: String = ""
    @AppStorage("conservatorPhone") private var conservatorPhone: String = ""
    @AppStorage("studioName") private var studioName: String = ""
    @AppStorage("studioAddress") private var studioAddress: String = ""
    /// Ids of images kept in `ImageStore`, the same store as object photos.
    @AppStorage("studioLogoImageId") private var studioLogoImageId: String = ""
    @AppStorage("signatureImageId") private var signatureImageId: String = ""

    var body: some View {
        List {
            Section("Conservator") {
                HStack {
                    Text("Name")
                    Spacer()
                    TextField("Your name", text: $conservatorName)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Title")
                    Spacer()
                    TextField("e.g. Conservation Specialist", text: $conservatorTitle)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Email")
                    Spacer()
                    TextField("email@example.com", text: $conservatorEmail)
                        .multilineTextAlignment(.trailing)
                        .textContentType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                HStack {
                    Text("Phone")
                    Spacer()
                    TextField("+30 ...", text: $conservatorPhone)
                        .multilineTextAlignment(.trailing)
                        .textContentType(.telephoneNumber)
                }
            }

            Section("Studio / Organization") {
                HStack {
                    Text("Name")
                    Spacer()
                    TextField("Studio name", text: $studioName)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Address")
                    Spacer()
                    TextField("Address", text: $studioAddress)
                        .multilineTextAlignment(.trailing)
                }
            }

            Section {
                LetterheadImageRow(title: "Studio logo", imageId: $studioLogoImageId)
                LetterheadImageRow(title: "Signature", imageId: $signatureImageId)
            } header: {
                Text("Letterhead")
            } footer: {
                Text("The logo prints at the top of every report and the signature in its signature area. A photo of your signature on white paper works best.")
            }

            Section {
                Text("This information appears on your exported PDF reports and is used as the default conservator name on condition reports.")
                    .font(.conservatioBodySmall)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Profile")
    }
}

/// A row that shows the chosen image, lets the user pick a new one from the
/// photo library, and removes it. The image is saved through `ImageStore` and
/// only its id is kept in the bound setting.
private struct LetterheadImageRow: View {
    let title: String
    @Binding var imageId: String
    @State private var pickerItem: PhotosPickerItem?

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
            Spacer()
            if !imageId.isEmpty, let image = ImageStore.shared.load(imageId) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 36)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                Button(role: .destructive) {
                    ImageStore.shared.delete(imageId)
                    imageId = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.borderless)
            }
            PhotosPicker(selection: $pickerItem, matching: .images) {
                Text(imageId.isEmpty ? "Choose" : "Change")
            }
            .buttonStyle(.borderless)
        }
        .onChange(of: pickerItem) { _, item in
            guard let item else { return }
            item.loadTransferable(type: Data.self) { result in
                guard case .success(let data) = result, let data, let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    if let newId = ImageStore.shared.save(image) {
                        if !imageId.isEmpty { ImageStore.shared.delete(imageId) }
                        imageId = newId
                    }
                    pickerItem = nil
                }
            }
        }
    }
}
