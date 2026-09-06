import Foundation

/// Records that work actually happened on a calendar day, independent of the current schedule.
struct TaskWorkLog: Identifiable, Hashable {
    let id: UUID
    let taskID: UUID
    var workDate: Date

    init(id: UUID = UUID(), taskID: UUID, workDate: Date) {
        self.id = id
        self.taskID = taskID
        self.workDate = workDate
    }
}
