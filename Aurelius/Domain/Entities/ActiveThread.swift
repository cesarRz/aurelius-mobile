import Foundation

struct ActiveThread: Identifiable, Hashable {
    let id: UUID
    var name: String
    var outcomeID: UUID?
    var detail: String
}
