import XCTest
@testable import Conservatio

/// The "Export All Data" bundle must carry every store verbatim and still be
/// produced when a store has never been saved.
final class DataExportTests: XCTestCase {

    private func tempDir() throws -> URL {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    func testBundleCarriesEveryStore() throws {
        let docs = try tempDir()
        let out = try tempDir()

        let object = ConservationObject(title: "Panel icon", objectType: .icon, latitude: 37.9, longitude: 23.7)
        try JSONEncoder().encode([object]).write(to: docs.appendingPathComponent("conservation_objects.json"))
        let report = ConditionReport(
            objectId: object.id,
            previousInterventions: "Relined in 1980",
            examinationConditions: ExaminationConditions(lightSource: "Daylight", relativeHumidity: 55, temperature: 21)
        )
        try JSONEncoder().encode([report]).write(to: docs.appendingPathComponent("condition_reports.json"))
        // No clients.json or projects.json on purpose.

        let url = try DataExport.writeBundle(documents: docs, to: out)
        let bundle = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any])

        XCTAssertEqual(bundle["format"] as? String, "conservatio-export")
        XCTAssertEqual((bundle["objects"] as? [Any])?.count, 1)
        XCTAssertEqual((bundle["reports"] as? [Any])?.count, 1)
        XCTAssertEqual((bundle["clients"] as? [Any])?.count, 0)
        XCTAssertEqual((bundle["projects"] as? [Any])?.count, 0)

        let exportedObject = try XCTUnwrap((bundle["objects"] as? [[String: Any]])?.first)
        XCTAssertEqual(exportedObject["latitude"] as? Double, 37.9)
        let exportedReport = try XCTUnwrap((bundle["reports"] as? [[String: Any]])?.first)
        XCTAssertEqual(exportedReport["previousInterventions"] as? String, "Relined in 1980")
    }

    func testOldReportJSONWithoutNewFieldsStillDecodes() throws {
        let json = """
        [{"id":"8F0B1E2C-1111-4222-8333-444455556666","objectId":"8F0B1E2C-1111-4222-8333-444455557777",
          "reportType":"INITIAL_ASSESSMENT","overallCondition":"FAIR","examiner":"A. Boura",
          "examinationDate":0,"damageAnnotations":[],"imageIds":[],"createdAt":0,"updatedAt":0}]
        """
        let reports = try JSONDecoder().decode([ConditionReport].self, from: Data(json.utf8))
        XCTAssertEqual(reports.count, 1)
        XCTAssertNil(reports[0].previousInterventions)
        XCTAssertNil(reports[0].examinationConditions)

        let objectJSON = """
        [{"id":"8F0B1E2C-1111-4222-8333-444455557777","title":"Panel","objectType":"ICON","materials":[],
          "imageIds":[],"createdAt":0,"updatedAt":0}]
        """
        let objects = try JSONDecoder().decode([ConservationObject].self, from: Data(objectJSON.utf8))
        XCTAssertNil(objects[0].latitude)
        XCTAssertNil(objects[0].coordinateText)
    }
}
