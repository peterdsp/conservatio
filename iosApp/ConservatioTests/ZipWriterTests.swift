import XCTest
@testable import Conservatio

/// Checks the archive layout the report export produces, so a reader such as
/// Files or Finder can open it.
final class ZipWriterTests: XCTestCase {

    func testCRC32MatchesKnownValue() {
        // Standard check value for the ASCII string "123456789".
        XCTAssertEqual(ZipWriter.crc32(Data("123456789".utf8)), 0xCBF4_3926)
        XCTAssertEqual(ZipWriter.crc32(Data()), 0)
    }

    func testArchiveLayout() throws {
        var writer = ZipWriter()
        let pdf = Data("%PDF-1.4 test".utf8)
        let photo = Data(repeating: 0xAB, count: 1024)
        writer.add("report.pdf", data: pdf)
        writer.add("originals/photo.jpg", data: photo)
        XCTAssertEqual(writer.count, 2)

        let archive = writer.makeData(date: Date(timeIntervalSince1970: 1_788_700_000))

        // Local file header signature at the start.
        XCTAssertEqual(Array(archive.prefix(4)), [0x50, 0x4B, 0x03, 0x04])

        // End of central directory record is the last 22 bytes.
        let trailer = archive.suffix(22)
        XCTAssertEqual(Array(trailer.prefix(4)), [0x50, 0x4B, 0x05, 0x06])
        let entryCount = UInt16(trailer[trailer.startIndex + 10]) | UInt16(trailer[trailer.startIndex + 11]) << 8
        XCTAssertEqual(entryCount, 2)

        // Both names and both payloads are present verbatim (stored entries).
        XCTAssertNotNil(archive.range(of: Data("report.pdf".utf8)))
        XCTAssertNotNil(archive.range(of: Data("originals/photo.jpg".utf8)))
        XCTAssertNotNil(archive.range(of: pdf))
        XCTAssertNotNil(archive.range(of: photo))

        // Total size is headers plus payloads, nothing compressed away.
        let localHeaders = 30 + "report.pdf".utf8.count + 30 + "originals/photo.jpg".utf8.count
        let centralHeaders = 46 + "report.pdf".utf8.count + 46 + "originals/photo.jpg".utf8.count
        XCTAssertEqual(archive.count, localHeaders + centralHeaders + pdf.count + photo.count + 22)
    }
}
