import Foundation

struct WorkspaceNote: Identifiable {
    let id: UUID
    var name: String
    var outcomeID: UUID?
    var blocks: [DocumentBlock]

    init(
        id: UUID = UUID(),
        name: String,
        outcomeID: UUID? = nil,
        blocks: [DocumentBlock] = []
    ) {
        self.id = id
        self.name = name
        self.outcomeID = outcomeID
        self.blocks = blocks
    }
}
