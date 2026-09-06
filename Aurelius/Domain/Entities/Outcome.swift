import Foundation

struct Outcome: Identifiable, Hashable {
    let id: UUID
    var name: String
    var initiativeID: UUID?
    var status: WorkStatus
    var startDate: Date
    var targetDate: Date?

    init(
        id: UUID = UUID(),
        name: String,
        initiativeID: UUID? = nil,
        status: WorkStatus = .notStarted,
        startDate: Date = .now,
        targetDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.initiativeID = initiativeID
        self.status = status
        self.startDate = startDate
        self.targetDate = targetDate
    }
}
