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

    @MainActor
    func add(_ report: ConditionReport) {
        reports.insert(report, at: 0)
        save()
        SyncEngine.shared.enqueue(.report, id: report.id.uuidString, operation: .create, body: Self.request(for: report))
    }

    @MainActor
    func update(_ report: ConditionReport) {
        guard let index = reports.firstIndex(where: { $0.id == report.id }) else { return }
        var updated = report
        updated.updatedAt = Date()
        reports[index] = updated
        save()
        SyncEngine.shared.enqueue(.report, id: updated.id.uuidString, operation: .update, body: Self.request(for: updated))
    }

    @MainActor
    func delete(_ report: ConditionReport) {
        reports.removeAll { $0.id == report.id }
        save()
        SyncEngine.shared.enqueueDelete(.report, id: report.id.uuidString)
    }

    func reports(for objectId: UUID) -> [ConditionReport] {
        reports.filter { $0.objectId == objectId }
    }

    /// Pushes pending changes, then pulls server reports and merges. Local
    /// reports always win, because damage annotations live only on the client
    /// (the server does not return them), so a pull must never overwrite them.
    @MainActor
    func syncFromServer() async {
        guard APIClient.shared.isLoggedIn else { return }
        await SyncEngine.shared.flush()
        do {
            let serverReports = try await APIClient.shared.fetchReports()
            merge(serverReports.compactMap { $0.conditionReport })
            save()
        } catch {
            print("Failed to pull reports: \(error)")
        }
    }

    @MainActor
    private func merge(_ serverReports: [ConditionReport]) {
        var byId: [UUID: ConditionReport] = [:]
        for server in serverReports { byId[server.id] = server }
        // Local always wins: it carries the damage annotations the server omits.
        for local in reports { byId[local.id] = local }
        reports = byId.values.sorted { $0.updatedAt > $1.updatedAt }
    }

    static func request(for report: ConditionReport) -> CreateReportRequest {
        let annotationsJSON = (try? JSONEncoder().encode(report.damageAnnotations))
            .flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        return CreateReportRequest(
            id: report.id.uuidString,
            objectId: report.objectId.uuidString,
            reportType: report.reportType.rawValue,
            overallCondition: report.overallCondition.rawValue,
            examiner: report.examiner,
            examinationDate: ISO8601DateFormatter().string(from: report.examinationDate),
            notes: report.notes,
            recommendations: report.recommendations,
            imageIds: report.imageIds,
            damageAnnotations: annotationsJSON
        )
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

private extension ServerReport {
    var conditionReport: ConditionReport? {
        guard let reportUUID = UUID(uuidString: id),
              let objectUUID = UUID(uuidString: objectId) else { return nil }
        let formatter = ISO8601DateFormatter()
        return ConditionReport(
            id: reportUUID,
            objectId: objectUUID,
            reportType: ReportType(rawValue: reportType) ?? .initialAssessment,
            overallCondition: ConditionRating(rawValue: overallCondition) ?? .fair,
            examiner: examiner,
            examinationDate: formatter.date(from: examinationDate) ?? Date(),
            // The server does not return annotations; the local copy is the
            // source of truth and is preserved by the merge.
            damageAnnotations: [],
            notes: notes,
            recommendations: recommendations,
            imageIds: imageIds ?? [],
            createdAt: formatter.date(from: createdAt ?? "") ?? Date(),
            updatedAt: formatter.date(from: updatedAt ?? "") ?? Date()
        )
    }
}
