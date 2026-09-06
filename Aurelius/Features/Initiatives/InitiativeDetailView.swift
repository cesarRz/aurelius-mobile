import SwiftUI

struct InitiativeDetailView: View {

    @Environment(WorkspaceStore.self)
    private var store
    @Environment(EntityEditor.self) private var editor

    let initiativeID: UUID

    @Binding var selection: WorkspaceSelection?
    @Binding var showingOutcomeForm: Bool
    @Binding var showingTaskForm: Bool

    private var initiative: Initiative? {
        store.initiative(for: initiativeID)
    }

    private var outcomes: [Outcome] {
        store.outcomes(forInitiative: initiativeID)
    }

    private var tasks: [TaskItem] {
        store.tasks(forInitiative: initiativeID)
    }

    var body: some View {

        if let initiative {

            ScrollView {

                VStack(
                    alignment: .leading,
                    spacing: 28
                ) {

                    VStack(
                        alignment: .leading,
                        spacing: 10
                    ) {

                        Text("INITIATIVE")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)

                        Text(initiative.name)
                            .font(.largeTitle.bold())

                        HStack {

                            StatusBadge(
                                status: initiative.status
                            )

                            if let area =
                                store.area(for: initiative.areaID) {

                                Label(
                                    area.name,
                                    systemImage: area.icon
                                )
                                .foregroundStyle(.secondary)
                            }
                        }
                    }

                    SectionCard(
                        title: "Outcomes",
                        icon: "target"
                    ) {

                        if outcomes.isEmpty {

                            Text("No outcomes yet.")
                                .foregroundStyle(.secondary)

                        } else {

                            ForEach(outcomes) { outcome in
                                Button {
                                    editor.target = .outcome(outcome.id)
                                } label: {
                                    OutcomeListRow(outcome: outcome)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    SectionCard(
                        title: "Tasks",
                        icon: "checkmark.circle"
                    ) {

                        if tasks.isEmpty {

                            Text("No tasks yet.")
                                .foregroundStyle(.secondary)

                        } else {

                            ForEach(tasks) { task in
                                TaskRow(taskID: task.id)
                            }
                        }
                    }
                }
                .padding(28)
                .frame(
                    maxWidth: 900,
                    alignment: .leading
                )
            }
            .navigationTitle(initiative.name)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") {
                        editor.target = .initiative(initiativeID)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Menu {

                    Button {
                        showingOutcomeForm = true
                    } label: {
                        Label(
                            "New Outcome",
                            systemImage: "target"
                        )
                    }

                    Button {
                        showingTaskForm = true
                    } label: {
                        Label(
                            "New Task",
                            systemImage: "checkmark.circle"
                        )
                    }

                } label: {
                    Image(systemName: "plus")
                }
                }
            }

        } else {

            ContentUnavailableView(
                "Initiative not found",
                systemImage: "flag"
            )
        }
    }
}
