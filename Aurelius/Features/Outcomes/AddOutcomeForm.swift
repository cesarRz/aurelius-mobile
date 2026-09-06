import SwiftUI

struct AddOutcomeForm: View {

    @Environment(WorkspaceStore.self)
    private var store

    @Environment(\.dismiss)
    private var dismiss

    var outcomeID: UUID? = nil

    @State private var name = ""
    @State private var initiativeID: UUID?
    @State private var status: WorkStatus = .notStarted

    @State private var hasTargetDate = true
    @State private var targetDate =
    Calendar.current.date(
        byAdding: .month,
        value: 1,
        to: .now
    ) ?? .now

    var body: some View {

        NavigationStack {

            Form {

                Section("Outcome") {

                    TextField(
                        "What do you want to achieve?",
                        text: $name
                    )

                    Picker(
                        "Initiative",
                        selection: $initiativeID
                    ) {

                        Text("None")
                            .tag(UUID?.none)

                        ForEach(
                            store.initiatives
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
                        "Status",
                        selection: $status
                    ) {

                        ForEach(
                            WorkStatus.allCases
                        ) { status in

                            Text(status.rawValue)
                                .tag(status)
                        }
                    }
                }

                Section("Target") {

                    Toggle(
                        "Target Date",
                        isOn: $hasTargetDate
                    )

                    if hasTargetDate {

                        DatePicker(
                            "Date",
                            selection: $targetDate,
                            displayedComponents: .date
                        )
                    }
                }
            }
            .navigationTitle(outcomeID == nil ? "New Outcome" : "Edit Outcome")
            .onAppear(perform: load)
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
                    Button(outcomeID == nil ? "Create" : "Save") {
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
        guard let outcomeID, let outcome = store.outcome(for: outcomeID) else { return }
        name = outcome.name
        initiativeID = outcome.initiativeID
        status = outcome.status
        if let target = outcome.targetDate {
            hasTargetDate = true
            targetDate = target
        } else {
            hasTargetDate = false
        }
    }

    private func save() {
        if let outcomeID {
            store.updateOutcome(
                id: outcomeID,
                name: name,
                initiativeID: initiativeID,
                status: status,
                targetDate: hasTargetDate ? targetDate : nil
            )
        } else {
            store.addOutcome(
                name: name,
                initiativeID: initiativeID,
                status: status,
                targetDate: hasTargetDate ? targetDate : nil
            )
        }
    }
}
