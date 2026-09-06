import Foundation

extension WorkspaceStore {


    func addArea(
        name: String,
        icon: String
    ) {
        areas.append(
            Area(
                name: name,
                icon: icon
            )
        )
    }

    func addInitiative(
        name: String,
        areaID: UUID?,
        status: WorkStatus
    ) {
        initiatives.append(
            Initiative(
                name: name,
                areaID: areaID,
                status: status
            )
        )
    }

    func addOutcome(
        name: String,
        initiativeID: UUID?,
        status: WorkStatus,
        targetDate: Date?
    ) {
        outcomes.append(
            Outcome(
                name: name,
                initiativeID: initiativeID,
                status: status,
                targetDate: targetDate
            )
        )
    }

    func addMilestone(name: String, outcomeID: UUID) {
        milestones.append(
            Milestone(
                name: name,
                outcomeID: outcomeID
            )
        )
    }

    func updateArea(id: UUID, name: String, icon: String) {
        guard let index = areas.firstIndex(where: { $0.id == id }) else { return }
        areas[index].name = name
        areas[index].icon = icon
    }

    func updateInitiative(id: UUID, name: String, areaID: UUID?, status: WorkStatus) {
        guard let index = initiatives.firstIndex(where: { $0.id == id }) else { return }
        initiatives[index].name = name
        initiatives[index].areaID = areaID
        initiatives[index].status = status
    }

    func updateOutcome(
        id: UUID,
        name: String,
        initiativeID: UUID?,
        status: WorkStatus,
        targetDate: Date?
    ) {
        guard let index = outcomes.firstIndex(where: { $0.id == id }) else { return }
        outcomes[index].name = name
        outcomes[index].initiativeID = initiativeID
        outcomes[index].status = status
        outcomes[index].targetDate = targetDate
    }

    func updateTask(
        id: UUID,
        name: String,
        areaID: UUID?,
        initiativeID: UUID?,
        outcomeID: UUID?,
        priority: Priority,
        scheduledStart: Date?,
        scheduledEnd: Date?,
        dueDate: Date?
    ) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        let period = scheduledStart.map {
            TaskScheduling.normalizedPeriod(from: $0, to: scheduledEnd)
        }
        tasks[index].name = name
        tasks[index].areaID = areaID
        tasks[index].initiativeID = initiativeID
        tasks[index].outcomeID = outcomeID
        tasks[index].priority = priority
        tasks[index].scheduledStart = period?.start
        tasks[index].scheduledEnd = period?.end
        tasks[index].dueDate = dueDate
    }

    func addTask(
        name: String,
        areaID: UUID?,
        initiativeID: UUID?,
        outcomeID: UUID?,
        priority: Priority,
        scheduledStart: Date? = nil,
        scheduledEnd: Date? = nil,
        dueDate: Date?
    ) {
        let period = scheduledStart.map {
            TaskScheduling.normalizedPeriod(from: $0, to: scheduledEnd)
        }
        tasks.append(
            TaskItem(
                name: name,
                areaID: areaID,
                initiativeID: initiativeID,
                outcomeID: outcomeID,
                status: .notStarted,
                priority: priority,
                scheduledStart: period?.start,
                scheduledEnd: period?.end,
                dueDate: dueDate
            )
        )
    }



    func toggleTask(_ taskID: UUID) {
        guard let index = tasks.firstIndex(where: {
            $0.id == taskID
        }) else {
            return
        }

        tasks[index].status =
        tasks[index].status == .done
        ? .notStarted
        : .done
    }
}
