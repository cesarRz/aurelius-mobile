import Foundation
import Testing
@testable import Aurelius

@MainActor
struct AgendaTests {
    @Test func filtersByLocalDayIncludingCompletedTasksAndDaylightSaving() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: "America/New_York"))
        let day = try #require(calendar.date(from: DateComponents(year: 2026, month: 3, day: 8)))
        let nextDay = try #require(calendar.date(byAdding: .day, value: 1, to: day))
        let late = nextDay.addingTimeInterval(-1)
        let store = WorkspaceStore()
        let first = TaskItem(name: "Start", scheduledStart: day)
        let completed = TaskItem(name: "End", status: .done, scheduledStart: late)
        store.tasks = [first, completed,
                       TaskItem(name: "Tomorrow", scheduledStart: nextDay),
                       TaskItem(name: "Yesterday", scheduledStart: day.addingTimeInterval(-1)),
                       TaskItem(name: "No schedule")]
        #expect(store.tasks(forAgendaOn: day, calendar: calendar).map(\.id) == [first.id, completed.id])
        #expect(store.tasks(forAgendaOn: nextDay, calendar: calendar).map(\.name) == ["Tomorrow"])
    }

    @Test func areaFilterCombinesDateAndPlanningHierarchy() {
        let store = WorkspaceStore()
        let area = Area(name: "Business")
        let other = Area(name: "Personal")
        let initiative = Initiative(name: "Launch", areaID: area.id)
        let outcome = Outcome(name: "Release", initiativeID: initiative.id)
        let date = Date.now
        store.initiatives = [initiative]
        store.outcomes = [outcome]
        let direct = TaskItem(name: "Direct", areaID: area.id, scheduledStart: date)
        let inherited = TaskItem(name: "Inherited", outcomeID: outcome.id, scheduledStart: date)
        let override = TaskItem(name: "Override", areaID: other.id, outcomeID: outcome.id, scheduledStart: date)
        let unassigned = TaskItem(name: "Unassigned", scheduledStart: date)
        store.tasks = [direct, inherited, override, unassigned,
                       TaskItem(name: "Undated", areaID: area.id)]
        #expect(store.tasks(forAgendaOn: date, areaID: area.id).map(\.id) == [direct.id, inherited.id])
        #expect(store.tasks(forAgendaOn: date, areaID: other.id).map(\.id) == [override.id])
        #expect(store.tasks(forAgendaOn: date).count == 4)
    }

    @Test func workLogKeepsTaskVisibleAfterScheduleMoves() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: "America/New_York"))
        let monday = try #require(calendar.date(from: DateComponents(year: 2026, month: 3, day: 9)))
        let tuesday = try #require(calendar.date(byAdding: .day, value: 1, to: monday))
        let wednesday = try #require(calendar.date(byAdding: .day, value: 2, to: monday))
        let store = WorkspaceStore()
        let task = TaskItem(name: "Carry over", scheduledStart: monday, scheduledEnd: tuesday)
        store.tasks = [task]
        store.logWork(on: task.id, date: monday, calendar: calendar)
        store.pushScheduledWork(taskID: task.id, calendar: calendar)

        #expect(store.tasks(forAgendaOn: monday, calendar: calendar).map(\.id) == [task.id])
        #expect(store.tasks(forAgendaOn: tuesday, calendar: calendar).map(\.id) == [task.id])
        #expect(store.tasks(forAgendaOn: wednesday, calendar: calendar).map(\.id) == [task.id])
    }

    @Test func multiDayScheduleAppearsOnEachDayInRange() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: "America/New_York"))
        let start = try #require(calendar.date(from: DateComponents(year: 2026, month: 3, day: 9)))
        let middle = try #require(calendar.date(byAdding: .day, value: 1, to: start))
        let end = try #require(calendar.date(byAdding: .day, value: 2, to: start))
        let store = WorkspaceStore()
        let task = TaskItem(name: "Spanning", scheduledStart: start, scheduledEnd: end)
        store.tasks = [task]

        #expect(store.tasks(forAgendaOn: start, calendar: calendar).count == 1)
        #expect(store.tasks(forAgendaOn: middle, calendar: calendar).count == 1)
        #expect(store.tasks(forAgendaOn: end, calendar: calendar).count == 1)
    }
}
