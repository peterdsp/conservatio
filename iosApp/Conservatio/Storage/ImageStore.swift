import SwiftUI
import UIKit

class ImageStore {
    static let shared = ImageStore()

    private let imageDirectory: URL

    private init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        imageDirectory = docs.appendingPathComponent("conservation_images", isDirectory: true)
        try? FileManager.default.createDirectory(at: imageDirectory, withIntermediateDirectories: true)
    }

    func save(_ image: UIImage, quality: CGFloat = 0.85) -> String? {
        let id = UUID().uuidString
        let fileURL = imageDirectory.appendingPathComponent("\(id).jpg")
        guard let data = image.jpegData(compressionQuality: quality) else { return nil }
        do {
            try data.write(to: fileURL)
            return id
        } catch {
            print("Failed to save image: \(error)")
            return nil
        }
    }

    func load(_ id: String) -> UIImage? {
        guard let data = data(id) else { return nil }
        return UIImage(data: data)
    }

    /// The stored JPEG bytes, untouched, for exports that ship the originals.
    func data(_ id: String) -> Data? {
        let fileURL = imageDirectory.appendingPathComponent("\(id).jpg")
        return try? Data(contentsOf: fileURL)
    }

    func delete(_ id: String) {
        let fileURL = imageDirectory.appendingPathComponent("\(id).jpg")
        try? FileManager.default.removeItem(at: fileURL)
    }
}
