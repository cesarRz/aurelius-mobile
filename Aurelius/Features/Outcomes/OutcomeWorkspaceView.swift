import SwiftUI

struct OutcomeWorkspaceView: View {

    @Environment(WorkspaceStore.self)
    private var store
    @Environment(EntityEditor.self) private var editor

    let outcomeID: UUID

    @Binding var selection: WorkspaceSelection?
    @Binding var showingTaskForm: Bool

    private var outcome: Outcome? {
        store.outcome(for: outcomeID)
    }

    private var tasks: [TaskItem] {
        store.tasks(forOutcome: outcomeID)
    }

    private var milestones: [Milestone] {
        store.milestones.filter {
            $0.outcomeID == outcomeID
        }
    }

    private var threads: [ActiveThread] {
        store.threads.filter {
            $0.outcomeID == outcomeID
        }
    }

    private var docs: [WorkspaceDocument] {
        store.docs(forOutcome: outcomeID)
    }

    private var notes: [WorkspaceNote] {
        store.notes(forOutcome: outcomeID)
    }

    var body: some View {

        if let outcome {

            ScrollView {

                VStack(
                    alignment: .leading,
                    spacing: 30
                ) {

                    outcomeHeader(outcome)

                    progressCard

                    SectionCard(
                        title: "Milestones",
                        icon: "flag.checkered"
                    ) {

                        ForEach(milestones) { milestone in

                            HStack {

                                Image(
                                    systemName:
                                        milestone.isCompleted
                                    ? "checkmark.circle.fill"
                                    : "circle"
                                )

                                Text(milestone.name)

                                Spacer()
                            }
                            .padding(.vertical, 4)
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

                        Button {
                            showingTaskForm = true
                        } label: {
                            Label(
                                "Add Task",
                                systemImage: "plus"
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 6)
                    }

                    SectionCard(
                        title: "Active Threads",
                        icon: "bubble.left.and.bubble.right"
                    ) {

                        ForEach(threads) { thread in

                            VStack(
                                alignment: .leading,
                                spacing: 4
                            ) {

                                Text(thread.name)
                                    .font(.headline)

                                Text(thread.detail)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 5)
                        }
                    }

                    SectionCard(
                        title: "Docs",
                        icon: "doc.text"
                    ) {

                        ForEach(docs) { doc in

                            WorkspaceSelectionLink(
                                value: .document(doc.id),
                                selection: $selection
                            ) {

                                HStack {

                                    Label(
                                        doc.name,
                                        systemImage: "doc.text"
                                    )

                                    Spacer()

                                    Image(
                                        systemName: "chevron.right"
                                    )
                                    .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    SectionCard(
                        title: "Notes",
                        icon: "note.text"
                    ) {

                        ForEach(notes) { note in

                            WorkspaceSelectionLink(
                                value: .note(note.id),
                                selection: $selection
                            ) {

                                HStack {

                                    Label(
                                        note.name,
                                        systemImage: "note.text"
                                    )

                                    Spacer()

                                    Image(
                                        systemName: "chevron.right"
                                    )
                                    .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .padding(28)
                .frame(
                    maxWidth: 900,
                    alignment: .leading
                )
            }
            .navigationTitle(outcome.name)
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") {
                        editor.target = .outcome(outcomeID)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingTaskForm = true
                    } label: {
                        Label(
                            "New Task",
                            systemImage: "plus"
                        )
                    }
                }
            }

        } else {

            ContentUnavailableView(
                "Outcome not found",
                systemImage: "target"
            )
        }
    }

    private func outcomeHeader(
        _ outcome: Outcome
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            Text("OUTCOME")
                .font(.caption.bold())
                .foregroundStyle(.secondary)

            Text(outcome.name)
                .font(.largeTitle.bold())

            HStack {

                StatusBadge(
                    status: outcome.status
                )

                if let initiative =
                    store.initiative(
                        for: outcome.initiativeID
                    ) {

                    Label(
                        initiative.name,
                        systemImage: "flag"
                    )
                    .foregroundStyle(.secondary)
                }

                if let target = outcome.targetDate {

                    Label(
                        target.formatted(
                            date: .abbreviated,
                            time: .omitted
                        ),
                        systemImage: "calendar"
                    )
                    .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var progressCard: some View {

        let progress = store.progress(
            for: outcomeID
        )

        return VStack(
            alignment: .leading,
            spacing: 10
        ) {

            HStack {

                Text("Progress")
                    .font(.headline)

                Spacer()

                Text("\(Int(progress * 100))%")
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: progress)
        }
    }
}
