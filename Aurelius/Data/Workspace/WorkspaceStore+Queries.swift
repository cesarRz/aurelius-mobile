import Foundation

extension WorkspaceStore {
    /// Tasks with a due date on this calendar day, including completed tasks.
    func tasks(dueOn date: Date, areaID: UUID? = nil, initiativeID: UUID? = nil, outcomeID: UUID? = nil, calendar: Calendar = .current) -> [TaskItem] {
        tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return calendar.isDate(dueDate, inSameDayAs: date)
                && (areaID == nil || resolvedAreaID(for: task) == areaID)
                && (initiativeID == nil || resolvedInitiativeID(for: task) == initiativeID)
                && (outcomeID == nil || resolvedOutcomeID(for: task) == outcomeID)
        }
    }



    /// Explicit area wins; otherwise resolve the task's planning hierarchy.
    func resolvedAreaID(for task: TaskItem) -> UUID? {
        if let areaID = task.areaID { return areaID }
        if let areaID = initiative(for: task.initiativeID)?.areaID { return areaID }
        return initiative(for: resolvedInitiativeID(for: task))?.areaID
    }

    func resolvedOutcomeID(for task: TaskItem) -> UUID? {
        task.outcomeID ?? milestones.first { $0.id == task.milestoneID }?.outcomeID
    }

    func resolvedInitiativeID(for task: TaskItem) -> UUID? {
        task.initiativeID ?? outcome(for: resolvedOutcomeID(for: task))?.initiativeID
    }

    func area(for id: UUID?) -> Area? {
        guard let id else { return nil }
        return areas.first { $0.id == id }
    }

    func initiative(for id: UUID?) -> Initiative? {
        guard let id else { return nil }
        return initiatives.first { $0.id == id }
    }

    func outcome(for id: UUID?) -> Outcome? {
        guard let id else { return nil }
        return outcomes.first { $0.id == id }
    }

    func initiatives(forArea id: UUID) -> [Initiative] {
        initiatives.filter { $0.areaID == id }
    }

    func outcomes(forInitiative id: UUID) -> [Outcome] {
        outcomes.filter { $0.initiativeID == id }
    }

    func tasks(forOutcome id: UUID) -> [TaskItem] {
        tasks.filter { $0.outcomeID == id }
    }

    func tasks(forInitiative id: UUID) -> [TaskItem] {
        tasks.filter { $0.initiativeID == id }
    }

    func docs(forOutcome id: UUID) -> [WorkspaceDocument] {
        docs.filter { $0.outcomeID == id }
    }

    func notes(forOutcome id: UUID) -> [WorkspaceNote] {
        notes.filter { $0.outcomeID == id }
    }

    func progress(for outcomeID: UUID) -> Double {
        let relevantTasks = tasks(forOutcome: outcomeID)

        guard !relevantTasks.isEmpty else {
            return 0
        }

        let completed = relevantTasks.filter {
            $0.status == .done
        }.count

        return Double(completed) / Double(relevantTasks.count)
    }
}
