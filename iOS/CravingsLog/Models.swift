import Foundation

struct CravingEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var date: Date = Date()
    var title: String
    var metric: Int          // Intensity
    var tag: String          // Outcome
    var note: String = ""
}

enum CravingsLogTags {
    static let all: [String] = ["Gave in", "Resisted", "Substituted", "Rode it out"]
}
