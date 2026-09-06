import Foundation

extension WorkspaceStore {
    func workLogs(for taskID: UUID) -> [TaskWorkLog] {
        taskWorkLogs
            .filter { $0.taskID == taskID }
            .sorted { $0.workDate < $1.workDate }
    }

    func hasWorkLog(for taskID: UUID, on date: Date, calendar: Calendar = .current) -> Bool {
        taskWorkLogs.contains { log in
            log.taskID == taskID
                && calendar.isDate(log.workDate, inSameDayAs: date)
        }
    }

    /// Tasks planned or logged for a calendar day in the Agenda.
    func tasks(
        forAgendaOn date: Date,
        areaID: UUID? = nil,
        initiativeID: UUID? = nil,
        outcomeID: UUID? = nil,
        calendar: Calendar = .current
    ) -> [TaskItem] {
        tasks.filter { task in
            matchesAgendaFilters(
                task,
                areaID: areaID,
                initiativeID: initiativeID,
                outcomeID: outcomeID
            )
            && (
                task.isScheduled(on: date, calendar: calendar)
                || hasWorkLog(for: task.id, on: date, calendar: calendar)
            )
        }
    }

    func scheduleWork(
        taskID: UUID,
        from start: Date,
        to end: Date? = nil,
        calendar: Calendar = .current
    ) {
        guard let index = tasks.firstIndex(where: { $0.id == taskID }) else { return }
        let period = TaskScheduling.normalizedPeriod(from: start, to: end, calendar: calendar)
        tasks[index].scheduledStart = period.start
        tasks[index].scheduledEnd = period.end
    }

    func logWork(
        on taskID: UUID,
        date: Date = .now,
        calendar: Calendar = .current
    ) {
        let day = TaskScheduling.normalizedDay(date, calendar: calendar)
        guard !hasWorkLog(for: taskID, on: day, calendar: calendar) else { return }
        taskWorkLogs.append(TaskWorkLog(taskID: taskID, workDate: day))

        guard let index = tasks.firstIndex(where: { $0.id == taskID }) else { return }
        if tasks[index].status == .notStarted {
            tasks[index].status = .inProgress
        }
    }

    func removeWorkLog(on taskID: UUID, date: Date, calendar: Calendar = .current) {
        taskWorkLogs.removeAll { log in
            log.taskID == taskID && calendar.isDate(log.workDate, inSameDayAs: date)
        }
    }

    /// Moves the planned work period forward without changing work logs.
    func pushScheduledWork(
        taskID: UUID,
        by days: Int = 1,
        calendar: Calendar = .current
    ) {
        guard let index = tasks.firstIndex(where: { $0.id == taskID }),
              let start = tasks[index].scheduledStart else { return }
        let end = tasks[index].scheduledEnd ?? start
        guard let shiftedStart = calendar.date(byAdding: .day, value: days, to: start),
              let shiftedEnd = calendar.date(byAdding: .day, value: days, to: end) else { return }
        let period = TaskScheduling.normalizedPeriod(from: shiftedStart, to: shiftedEnd, calendar: calendar)
        tasks[index].scheduledStart = period.start
        tasks[index].scheduledEnd = period.end
    }

    func extendScheduledWork(
        taskID: UUID,
        through date: Date,
        calendar: Calendar = .current
    ) {
        guard let index = tasks.firstIndex(where: { $0.id == taskID }) else { return }
        let target = TaskScheduling.normalizedDay(date, calendar: calendar)
        if let start = tasks[index].scheduledStart {
            let period = TaskScheduling.normalizedPeriod(from: start, to: target, calendar: calendar)
            tasks[index].scheduledStart = period.start
            tasks[index].scheduledEnd = period.end
        } else {
            tasks[index].scheduledStart = target
            tasks[index].scheduledEnd = target
        }
    }

    func clearSchedule(taskID: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == taskID }) else { return }
        tasks[index].scheduledStart = nil
        tasks[index].scheduledEnd = nil
    }

    private func matchesAgendaFilters(
        _ task: TaskItem,
        areaID: UUID?,
        initiativeID: UUID?,
        outcomeID: UUID?
    ) -> Bool {
        (areaID == nil || resolvedAreaID(for: task) == areaID)
            && (initiativeID == nil || resolvedInitiativeID(for: task) == initiativeID)
            && (outcomeID == nil || resolvedOutcomeID(for: task) == outcomeID)
    }
}
