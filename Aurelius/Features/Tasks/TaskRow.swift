import SwiftUI

enum TaskRowStyle {
    case standard
    case agenda
}

struct TaskRow: View {
    @Environment(WorkspaceStore.self) private var store
    @Environment(EntityEditor.self) private var editor
    @Environment(\.calendar) private var calendar

    let taskID: UUID
    var contextDate: Date?
    var style: TaskRowStyle = .standard

    private var task: TaskItem? {
        store.tasks.first { $0.id == taskID }
    }

    private var referenceDate: Date {
        contextDate ?? .now
    }

    var body: some View {
        if let task {
            HStack(alignment: .center, spacing: 14) {
                Button {
                    store.toggleTask(task.id)
                } label: {
                    Image(systemName: task.status == .done ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(task.status == .done ? Color.accentColor : .secondary)
                }
                .buttonStyle(.plain)

                Button {
                    editor.target = .task(task.id)
                } label: {
                    VStack(alignment: .leading, spacing: style == .agenda ? 3 : 6) {
                        Text(task.name)
                            .font(.body)
                            .strikethrough(task.status == .done)
                            .lineLimit(2)
                            .foregroundStyle(.primary)

                        if style == .standard {
                            standardMetadata(for: task)
                        } else if let subtitle = agendaSubtitle(for: task) {
                            Text(subtitle)
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                                .lineLimit(1)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Spacer(minLength: 0)

                if style == .agenda {
                    agendaTrailing(for: task)
                }
            }
            .padding(.vertical, style == .agenda ? 2 : 5)
            .contextMenu { taskContextMenu(for: task) }
        }
    }

    @ViewBuilder
    private func standardMetadata(for task: TaskItem) -> some View {
        HStack(spacing: 10) {
            if task.priority == .high {
                PriorityBadge(priority: task.priority)
            }

            if let outcome = store.outcome(for: task.outcomeID) {
                Text(outcome.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            if let scheduleLabel = scheduleLabel(for: task) {
                Text(scheduleLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            if let dueDate = task.dueDate {
                Text(dueDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }

    @ViewBuilder
    private func agendaTrailing(for task: TaskItem) -> some View {
        HStack(spacing: 6) {
            if store.hasWorkLog(for: task.id, on: referenceDate, calendar: calendar) {
                Image(systemName: "circle.fill")
                    .font(.system(size: 6))
                    .foregroundStyle(.tertiary)
                    .accessibilityLabel("Work logged")
            }

            if task.priority == .high {
                Image(systemName: "flag.fill")
                    .font(.caption2)
                    .foregroundStyle(.orange)
                    .accessibilityLabel("High priority")
            }
        }
    }

    private func agendaSubtitle(for task: TaskItem) -> String? {
        guard let dueDate = task.dueDate else { return nil }
        if calendar.isDate(dueDate, inSameDayAs: referenceDate) {
            return "Due today"
        }
        return "Due \(dueDate.formatted(.dateTime.month(.abbreviated).day()))"
    }

    @ViewBuilder
    private func taskContextMenu(for task: TaskItem) -> some View {
        if store.hasWorkLog(for: task.id, on: referenceDate, calendar: calendar) {
            Button("Remove work log for this day") {
                store.removeWorkLog(on: task.id, date: referenceDate, calendar: calendar)
            }
        } else {
            Button("Log work for this day") {
                store.logWork(on: task.id, date: referenceDate, calendar: calendar)
            }
        }

        Button("Schedule for this day") {
            store.scheduleWork(taskID: task.id, from: referenceDate, calendar: calendar)
        }

        Button("Schedule today through tomorrow") {
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: referenceDate) ?? referenceDate
            store.scheduleWork(taskID: task.id, from: referenceDate, to: tomorrow, calendar: calendar)
        }

        if task.scheduledStart != nil {
            Button("Push schedule 1 day") {
                store.pushScheduledWork(taskID: task.id, calendar: calendar)
            }

            Button("Clear schedule", role: .destructive) {
                store.clearSchedule(taskID: task.id)
            }
        }
    }

    private func scheduleLabel(for task: TaskItem) -> String? {
        guard let start = task.scheduledStart else { return nil }
        let end = task.scheduledEnd ?? start
        if calendar.isDate(start, inSameDayAs: end) {
            return start.formatted(date: .abbreviated, time: .omitted)
        }
        let startText = start.formatted(.dateTime.month(.abbreviated).day())
        let endText = end.formatted(.dateTime.month(.abbreviated).day())
        return "\(startText) – \(endText)"
    }
}
