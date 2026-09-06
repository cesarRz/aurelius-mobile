import Foundation

struct TaskItem: Identifiable, Hashable {
    let id: UUID
    var name: String

    var areaID: UUID?
    var initiativeID: UUID?
    var outcomeID: UUID?
    var milestoneID: UUID?

    var status: WorkStatus
    var priority: Priority

    /// First calendar day planned for working on this task (inclusive).
    var scheduledStart: Date?
    /// Last calendar day planned for working on this task (inclusive).
    var scheduledEnd: Date?
    var dueDate: Date?

    func isScheduled(on date: Date, calendar: Calendar = .current) -> Bool {
        TaskScheduling.rangeContains(
            date: date,
            start: scheduledStart,
            end: scheduledEnd,
            calendar: calendar
        )
    }

    init(
        id: UUID = UUID(),
        name: String,
        areaID: UUID? = nil,
        initiativeID: UUID? = nil,
        outcomeID: UUID? = nil,
        milestoneID: UUID? = nil,
        status: WorkStatus = .notStarted,
        priority: Priority = .medium,
        scheduledStart: Date? = nil,
        scheduledEnd: Date? = nil,
        dueDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.areaID = areaID
        self.initiativeID = initiativeID
        self.outcomeID = outcomeID
        self.milestoneID = milestoneID
        self.status = status
        self.priority = priority
        self.scheduledStart = scheduledStart
        self.scheduledEnd = scheduledEnd
        self.dueDate = dueDate
    }
}
