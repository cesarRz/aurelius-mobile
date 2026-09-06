import Foundation

struct WorkspaceDocument: Identifiable {
    let id: UUID
    var name: String
    var initiativeID: UUID?
    var outcomeID: UUID?
    var blocks: [DocumentBlock]

    init(
        id: UUID = UUID(),
        name: String,
        initiativeID: UUID? = nil,
        outcomeID: UUID? = nil,
        blocks: [DocumentBlock] = []
    ) {
        self.id = id
        self.name = name
        self.initiativeID = initiativeID
        self.outcomeID = outcomeID
        self.blocks = blocks
    }
}
