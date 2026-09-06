import Foundation

enum TaskScheduling {
    static func normalizedDay(_ date: Date, calendar: Calendar = .current) -> Date {
        calendar.startOfDay(for: date)
    }

    static func normalizedPeriod(
        from start: Date,
        to end: Date?,
        calendar: Calendar = .current
    ) -> (start: Date, end: Date) {
        let normalizedStart = normalizedDay(start, calendar: calendar)
        let normalizedEnd = normalizedDay(end ?? start, calendar: calendar)
        if normalizedEnd < normalizedStart {
            return (normalizedEnd, normalizedEnd)
        }
        return (normalizedStart, normalizedEnd)
    }

    static func rangeContains(
        date: Date,
        start: Date?,
        end: Date?,
        calendar: Calendar = .current
    ) -> Bool {
        guard let start else { return false }
        let period = normalizedPeriod(from: start, to: end, calendar: calendar)
        let day = normalizedDay(date, calendar: calendar)
        return day >= period.start && day <= period.end
    }
}
