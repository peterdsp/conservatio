import Foundation

/// A minimal ZIP archive writer built on Foundation only, so a report and its
/// original photos can be shared as one file without a third-party package.
/// Entries are stored uncompressed: JPEGs and PDFs are already compressed, so
/// deflating them again would cost time for no gain.
struct ZipWriter {
    private struct Entry {
        let name: String
        let data: Data
    }

    private var entries: [Entry] = []

    /// Adds a file. `name` is the path inside the archive, using "/" as the
    /// directory separator (for example "originals/photo.jpg").
    mutating func add(_ name: String, data: Data) {
        entries.append(Entry(name: name, data: data))
    }

    var count: Int { entries.count }

    /// Serialises the archive. Layout is the standard one: each local file
    /// header followed by its data, then the central directory, then the end
    /// of central directory record.
    func makeData(date: Date = Date()) -> Data {
        var body = Data()
        var central = Data()
        let (dosTime, dosDate) = Self.dosDateTime(date)

        for entry in entries {
            let name = Array(entry.name.utf8)
            let crc = Self.crc32(entry.data)
            let size = UInt32(truncatingIfNeeded: entry.data.count)
            let offset = UInt32(truncatingIfNeeded: body.count)

            // Local file header.
            body.appendLE32(0x0403_4b50)
            body.appendLE16(20)       // version needed to extract
            body.appendLE16(0x0800)   // general purpose flags: UTF-8 names
            body.appendLE16(0)        // compression method: stored
            body.appendLE16(dosTime)
            body.appendLE16(dosDate)
            body.appendLE32(crc)
            body.appendLE32(size)     // compressed size
            body.appendLE32(size)     // uncompressed size
            body.appendLE16(UInt16(name.count))
            body.appendLE16(0)        // extra field length
            body.append(contentsOf: name)
            body.append(entry.data)

            // Central directory file header.
            central.appendLE32(0x0201_4b50)
            central.appendLE16(20)    // version made by
            central.appendLE16(20)    // version needed to extract
            central.appendLE16(0x0800)
            central.appendLE16(0)
            central.appendLE16(dosTime)
            central.appendLE16(dosDate)
            central.appendLE32(crc)
            central.appendLE32(size)
            central.appendLE32(size)
            central.appendLE16(UInt16(name.count))
            central.appendLE16(0)     // extra field length
            central.appendLE16(0)     // file comment length
            central.appendLE16(0)     // disk number start
            central.appendLE16(0)     // internal attributes
            central.appendLE32(0)     // external attributes
            central.appendLE32(offset)
            central.append(contentsOf: name)
        }

        var archive = body
        let centralOffset = UInt32(truncatingIfNeeded: body.count)
        archive.append(central)

        // End of central directory record.
        archive.appendLE32(0x0605_4b50)
        archive.appendLE16(0)         // this disk
        archive.appendLE16(0)         // disk with the central directory
        archive.appendLE16(UInt16(entries.count))
        archive.appendLE16(UInt16(entries.count))
        archive.appendLE32(UInt32(truncatingIfNeeded: central.count))
        archive.appendLE32(centralOffset)
        archive.appendLE16(0)         // comment length
        return archive
    }

    // MARK: - Helpers

    private static let crcTable: [UInt32] = (0..<256).map { index -> UInt32 in
        var c = UInt32(index)
        for _ in 0..<8 {
            c = (c & 1) == 1 ? (0xEDB8_8320 ^ (c >> 1)) : (c >> 1)
        }
        return c
    }

    static func crc32(_ data: Data) -> UInt32 {
        var crc: UInt32 = 0xFFFF_FFFF
        for byte in data {
            crc = crcTable[Int((crc ^ UInt32(byte)) & 0xFF)] ^ (crc >> 8)
        }
        return crc ^ 0xFFFF_FFFF
    }

    /// MS-DOS packed time and date, the only timestamp format a basic ZIP
    /// entry carries. Years before 1980 clamp to 1980.
    private static func dosDateTime(_ date: Date) -> (UInt16, UInt16) {
        let parts = Calendar(identifier: .gregorian).dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let year = max((parts.year ?? 1980) - 1980, 0)
        let time = UInt16((parts.hour ?? 0) << 11 | (parts.minute ?? 0) << 5 | (parts.second ?? 0) / 2)
        let day = UInt16(year << 9 | (parts.month ?? 1) << 5 | (parts.day ?? 1))
        return (time, day)
    }
}

private extension Data {
    mutating func appendLE16(_ value: UInt16) {
        append(UInt8(value & 0xFF))
        append(UInt8(value >> 8))
    }

    mutating func appendLE32(_ value: UInt32) {
        append(UInt8(value & 0xFF))
        append(UInt8((value >> 8) & 0xFF))
        append(UInt8((value >> 16) & 0xFF))
        append(UInt8(value >> 24))
    }
}
