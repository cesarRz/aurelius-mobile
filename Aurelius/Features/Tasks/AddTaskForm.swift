import SwiftUI

struct AddTaskForm: View {

    @Environment(WorkspaceStore.self)
    private var store

    @Environment(\.dismiss)
    private var dismiss

    var taskID: UUID? = nil

    @State private var name = ""

    @State private var areaID: UUID?
    @State private var initiativeID: UUID?
    @State private var outcomeID: UUID?

    @State private var priority: Priority = .medium

    @State private var hasDueDate = false
    @State private var dueDate = Date.now

    @State private var hasWorkSchedule = false
    @State private var scheduledStart = Date.now
    @State private var hasScheduleEnd = false
    @State private var scheduledEnd = Date.now

    private var availableInitiatives: [Initiative] {

        guard let areaID else {
            return store.initiatives
        }

        return store.initiatives.filter {
            $0.areaID == areaID
        }
    }

    private var availableOutcomes: [Outcome] {

        guard let initiativeID else {
            return store.outcomes
        }

        return store.outcomes.filter {
            $0.initiativeID == initiativeID
        }
    }

    var body: some View {

        NavigationStack {

            Form {

                Section("Task") {

                    TextField(
                        "What needs to be done?",
                        text: $name
                    )

                    Picker(
                        "Priority",
                        selection: $priority
                    ) {

                        ForEach(
                            Priority.allCases
                        ) { priority in

                            Text(priority.rawValue)
                                .tag(priority)
                        }
                    }
                }

                Section("Context") {

                    Picker(
                        "Area",
                        selection: $areaID
                    ) {

                        Text("None")
                            .tag(UUID?.none)

                        ForEach(store.areas) { area in

                            Text(area.name)
                                .tag(
                                    Optional(area.id)
                                )
                        }
                    }

                    Picker(
                        "Initiative",
                        selection: $initiativeID
                    ) {

                        Text("None")
                            .tag(UUID?.none)

                        ForEach(
                            availableInitiatives
                        ) { initiative in

                            Text(initiative.name)
                                .tag(
                                    Optional(
                                        initiative.id
                                    )
                                )
                        }
                    }

                    Picker(
                        "Outcome",
                        selection: $outcomeID
                    ) {

                        Text("None")
                            .tag(UUID?.none)

                        ForEach(
                            availableOutcomes
                        ) { outcome in

                            Text(outcome.name)
                                .tag(
                                    Optional(
                                        outcome.id
                                    )
                                )
                        }
                    }
                }

                Section("Work schedule") {
                    Toggle("Plan work dates", isOn: $hasWorkSchedule)

                    if hasWorkSchedule {
                        DatePicker(
                            "From",
                            selection: $scheduledStart,
                            displayedComponents: .date
                        )

                        Toggle("Multi-day period", isOn: $hasScheduleEnd)

                        if hasScheduleEnd {
                            DatePicker(
                                "Through",
                                selection: $scheduledEnd,
                                in: scheduledStart...,
                                displayedComponents: .date
                            )
                        }
                    }
                }

                Section("Deadline") {

                    Toggle(
                        "Due Date",
                        isOn: $hasDueDate
                    )

                    if hasDueDate {

                        DatePicker(
                            "Date",
                            selection: $dueDate,
                            displayedComponents: .date
                        )
                    }
                }
            }
            .navigationTitle(taskID == nil ? "New Task" : "Edit Task")
            .onAppear(perform: load)
            .onChange(of: areaID) {

                if let initiativeID,
                   !availableInitiatives.contains(
                    where: {
                        $0.id == initiativeID
                    }
                   ) {

                    self.initiativeID = nil
                    outcomeID = nil
                }
            }
            .onChange(of: initiativeID) {

                if let initiativeID,
                   let initiative =
                    store.initiative(
                        for: initiativeID
                    ) {

                    areaID = initiative.areaID
                }

                if let outcomeID,
                   !availableOutcomes.contains(
                    where: {
                        $0.id == outcomeID
                    }
                   ) {

                    self.outcomeID = nil
                }
            }
            .onChange(of: outcomeID) {

                guard
                    let outcome =
                        store.outcome(
                            for: outcomeID
                        )
                else {
                    return
                }

                initiativeID =
                outcome.initiativeID

                if let initiative =
                    store.initiative(
                        for: outcome.initiativeID
                    ) {

                    areaID = initiative.areaID
                }
            }
            .toolbar {

                ToolbarItem(
                    placement: .cancellationAction
                ) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(
                    placement: .confirmationAction
                ) {
                    Button(taskID == nil ? "Create" : "Save") {
                        save()
                        dismiss()
                    }
                    .disabled(
                        name.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty
                    )
                }
            }
        }
    }

    private func load() {
        guard let taskID, let task = store.tasks.first(where: { $0.id == taskID }) else { return }
        name = task.name
        areaID = task.areaID
        initiativeID = task.initiativeID
        outcomeID = task.outcomeID
        priority = task.priority
        if let start = task.scheduledStart {
            hasWorkSchedule = true
            scheduledStart = start
            if let end = task.scheduledEnd, !Calendar.current.isDate(start, inSameDayAs: end) {
                hasScheduleEnd = true
                scheduledEnd = end
            }
        }
        if let due = task.dueDate {
            hasDueDate = true
            dueDate = due
        }
    }

    private func save() {
        if let taskID {
            store.updateTask(
                id: taskID,
                name: name,
                areaID: areaID,
                initiativeID: initiativeID,
                outcomeID: outcomeID,
                priority: priority,
                scheduledStart: hasWorkSchedule ? scheduledStart : nil,
                scheduledEnd: hasWorkSchedule && hasScheduleEnd ? scheduledEnd : nil,
                dueDate: hasDueDate ? dueDate : nil
            )
        } else {
            store.addTask(
                name: name,
                areaID: areaID,
                initiativeID: initiativeID,
                outcomeID: outcomeID,
                priority: priority,
                scheduledStart: hasWorkSchedule ? scheduledStart : nil,
                scheduledEnd: hasWorkSchedule && hasScheduleEnd ? scheduledEnd : nil,
                dueDate: hasDueDate ? dueDate : nil
            )
        }
    }
}
