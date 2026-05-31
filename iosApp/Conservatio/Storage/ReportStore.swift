import Foundation

@Observable
class ReportStore {
    private(set) var reports: [ConditionReport] = []
    private let fileURL: URL

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = docs.appendingPathComponent("condition_reports.json")
        load()
    }

    func add(_ report: ConditionReport) {
        reports.insert(report, at: 0)
        save()
    }

    func update(_ report: ConditionReport) {
        if let index = reports.firstIndex(where: { $0.id == report.id }) {
            var updated = report
            updated.updatedAt = Date()
            reports[index] = updated
            save()
        }
    }

    func delete(_ report: ConditionReport) {
        reports.removeAll { $0.id == report.id }
        save()
    }

    func reports(for objectId: UUID) -> [ConditionReport] {
        reports.filter { $0.objectId == objectId }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(reports)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save reports: \(error)")
        }
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            reports = try JSONDecoder().decode([ConditionReport].self, from: data)
        } catch {
            print("Failed to load reports: \(error)")
        }
    }
}
