import Foundation

/// Unclassified capture; its content can later become a workspace entity.
struct InboxEntry: Identifiable {
    enum Source: String {
        case text
        case voice
    }

    let id: UUID
    var text: String
    let createdAt: Date
    let source: Source

    init(id: UUID = UUID(), text: String, createdAt: Date = .now, source: Source = .text) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
        self.source = source
    }
}
