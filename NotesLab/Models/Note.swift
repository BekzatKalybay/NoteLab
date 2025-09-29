import Foundation

struct Note: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var body: String
    var updatedAt: Date
    var isPinned: Bool
    
    init(id: String = UUID().uuidString, title: String, body: String, updatedAt: Date = .init(), isPinned: Bool = false) {
        self.id = id
        self.title = title
        self.body = body
        self.updatedAt = updatedAt
        self.isPinned = isPinned
    }
}
