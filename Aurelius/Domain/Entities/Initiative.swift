import Foundation

struct Initiative: Identifiable, Hashable {
    let id: UUID
    var name: String
    var areaID: UUID?
    var status: WorkStatus

    init(
        id: UUID = UUID(),
        name: String,
        areaID: UUID? = nil,
        status: WorkStatus = .notStarted
    ) {
        self.id = id
        self.name = name
        self.areaID = areaID
        self.status = status
    }
}
