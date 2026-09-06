import Foundation

enum AgendaTaskGrouping: String, CaseIterable, Identifiable {
    case initiative = "Initiative"
    case outcome = "Outcome"

    var id: String { rawValue }

    func groups(for tasks: [TaskItem], in store: WorkspaceStore) -> [AgendaTaskGroup] {
        let grouped = Dictionary(grouping: tasks) { task -> UUID? in
            switch self {
            case .initiative: return store.initiative(for: store.resolvedInitiativeID(for: task))?.id
            case .outcome: return store.outcome(for: store.resolvedOutcomeID(for: task))?.id
            }
        }
        return grouped.map { id, tasks in
            let title: String
            switch self {
            case .initiative: title = store.initiative(for: id)?.name ?? "No initiative"
            case .outcome: title = store.outcome(for: id)?.name ?? "No outcome"
            }
            return AgendaTaskGroup(id: id, title: title, tasks: tasks)
        }.sorted { lhs, rhs in
            if lhs.id == nil { return false }
            if rhs.id == nil { return true }
            if lhs.title == rhs.title { return lhs.id!.uuidString < rhs.id!.uuidString }
            return lhs.title.localizedStandardCompare(rhs.title) == .orderedAscending
        }
    }
}

struct AgendaTaskGroup: Identifiable {
    let id: UUID?
    let title: String
    let tasks: [TaskItem]
}
