import Foundation
import Testing
@testable import Aurelius

struct TaskSchedulingTests {
    @Test func normalizedPeriodOrdersDates() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: "America/New_York"))
        let later = try #require(calendar.date(from: DateComponents(year: 2026, month: 3, day: 10)))
        let earlier = try #require(calendar.date(from: DateComponents(year: 2026, month: 3, day: 8)))
        let period = TaskScheduling.normalizedPeriod(from: later, to: earlier, calendar: calendar)
        #expect(calendar.isDate(period.start, inSameDayAs: earlier))
        #expect(calendar.isDate(period.end, inSameDayAs: earlier))
    }

    @Test func rangeContainsInclusiveDays() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: "America/New_York"))
        let start = try #require(calendar.date(from: DateComponents(year: 2026, month: 3, day: 8)))
        let end = try #require(calendar.date(byAdding: .day, value: 2, to: start))
        let middle = try #require(calendar.date(byAdding: .day, value: 1, to: start))
        let outside = try #require(calendar.date(byAdding: .day, value: 3, to: start))
        #expect(TaskScheduling.rangeContains(date: start, start: start, end: end, calendar: calendar))
        #expect(TaskScheduling.rangeContains(date: middle, start: start, end: end, calendar: calendar))
        #expect(TaskScheduling.rangeContains(date: end, start: start, end: end, calendar: calendar))
        #expect(!TaskScheduling.rangeContains(date: outside, start: start, end: end, calendar: calendar))
    }
}

@MainActor
struct TaskSchedulingStoreTests {
    @Test func logWorkIsIdempotentPerDay() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: "America/New_York"))
        let day = try #require(calendar.date(from: DateComponents(year: 2026, month: 3, day: 8)))
        let store = WorkspaceStore()
        let task = TaskItem(name: "Work")
        store.tasks = [task]
        store.logWork(on: task.id, date: day, calendar: calendar)
        store.logWork(on: task.id, date: day, calendar: calendar)
        #expect(store.workLogs(for: task.id).count == 1)
        #expect(store.tasks[0].status == .inProgress)
    }

    @Test func extendScheduledWorkGrowsPeriod() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: "America/New_York"))
        let today = try #require(calendar.date(from: DateComponents(year: 2026, month: 3, day: 8)))
        let tomorrow = try #require(calendar.date(byAdding: .day, value: 1, to: today))
        let store = WorkspaceStore()
        let task = TaskItem(name: "Stretch")
        store.tasks = [task]
        store.scheduleWork(taskID: task.id, from: today, calendar: calendar)
        store.extendScheduledWork(taskID: task.id, through: tomorrow, calendar: calendar)
        #expect(calendar.isDate(store.tasks[0].scheduledStart!, inSameDayAs: today))
        #expect(calendar.isDate(store.tasks[0].scheduledEnd!, inSameDayAs: tomorrow))
    }
}
