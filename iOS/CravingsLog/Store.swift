import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var entries: [CravingEntry] = []
    @Published var isPro: Bool = false

    // Free-tier cap. Kept comfortably above seed-data count so a fresh
    // install never trips the paywall immediately.
    static let freeLimit = 40

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("cravingslog_entries.json")
        load()
    }

    func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([CravingEntry].self, from: data) {
            entries = decoded
        } else {
            entries = [
            CravingEntry(date: Date().addingTimeInterval(-0), title: "Sugar craving after lunch", metric: 6, tag: "Resisted"),
            CravingEntry(date: Date().addingTimeInterval(-86400), title: "Nicotine urge, stressful call", metric: 8, tag: "Gave in"),
            CravingEntry(date: Date().addingTimeInterval(-172800), title: "Late-night snack pull", metric: 4, tag: "Substituted")
            ]
            save()
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(entries) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }

    var canAddMore: Bool {
        isPro || entries.count < Store.freeLimit
    }

    @discardableResult
    func add(title: String, metric: Int, tag: String, note: String = "") -> Bool {
        guard canAddMore else { return false }
        entries.insert(CravingEntry(title: title, metric: metric, tag: tag, note: note), at: 0)
        save()
        Haptics.success()
        return true
    }

    func update(_ entry: CravingEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: CravingEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }
}
