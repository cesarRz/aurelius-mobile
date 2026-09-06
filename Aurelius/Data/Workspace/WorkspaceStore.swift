import Foundation
import Observation

@Observable
final class WorkspaceStore {

    var inboxEntries: [InboxEntry] = []

    var areas: [Area] = []
    var initiatives: [Initiative] = []
    var outcomes: [Outcome] = []
    var milestones: [Milestone] = []
    var tasks: [TaskItem] = []
    var taskWorkLogs: [TaskWorkLog] = []
    var threads: [ActiveThread] = []

    var docs: [WorkspaceDocument] = []
    var notes: [WorkspaceNote] = []

    init() {}
}
