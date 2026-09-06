import Foundation

struct Milestone: Identifiable, Hashable {
    let id: UUID
    var name: String
    var outcomeID: UUID
    var isCompleted: Bool

    init(
        id: UUID = UUID(),
        name: String,
        outcomeID: UUID,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.name = name
        self.outcomeID = outcomeID
        self.isCompleted = isCompleted
    }
}
