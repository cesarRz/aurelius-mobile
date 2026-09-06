import SwiftUI

struct AgendaView: View {
    @Environment(WorkspaceStore.self) private var store
    @State private var selectedDate = Date.now
    @State private var selectedAreaID: UUID?
    @State private var grouping: AgendaTaskGrouping = .initiative
    @State private var selectedInitiativeID: UUID?
    @State private var selectedOutcomeID: UUID?

    private var scheduledTasks: [TaskItem] {
        store.tasks(forAgendaOn: selectedDate, areaID: selectedAreaID,
                    initiativeID: selectedInitiativeID, outcomeID: selectedOutcomeID)
    }

    private var taskSummary: String {
        var parts = ["By \(grouping.rawValue.lowercased())"]
        if let initiative = store.initiative(for: selectedInitiativeID) { parts.append(initiative.name) }
        if let outcome = store.outcome(for: selectedOutcomeID) { parts.append(outcome.name) }
        return parts.joined(separator: " · ")
    }

    var body: some View {
        List {
            Section {
                AgendaDateNavigator(selectedDate: $selectedDate)
                    .listRowSeparator(.hidden)
            }

            Section {
                AgendaAreaFilter(areas: store.areas, selectedAreaID: $selectedAreaID)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }

            Section {
                if scheduledTasks.isEmpty {
                    ContentUnavailableView(
                        "No tasks for this day",
                        systemImage: "calendar",
                        description: Text("No tasks match this date and the selected filters.")
                    )
                } else {
                    ForEach(grouping.groups(for: scheduledTasks, in: store)) { group in
                        Section {
                            ForEach(group.tasks) { task in
                                TaskRow(taskID: task.id, contextDate: selectedDate, style: .agenda)
                                    .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                            }
                        } header: {
                            HStack {
                                Text(group.title)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("\(group.tasks.count)")
                                    .font(.caption.monospacedDigit())
                                    .foregroundStyle(.tertiary)
                            }
                            .textCase(nil)
                        }
                    }
                }
            } header: {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Tasks")
                        Text(taskSummary)
                            .font(.caption2)
                            .textCase(nil)
                    }
                    Spacer()
                    AgendaTaskOptions(grouping: $grouping,
                                      initiativeID: $selectedInitiativeID,
                                      outcomeID: $selectedOutcomeID)
                        .textCase(nil)
                }
            }
        }
        .listSectionSpacing(20)
        .navigationTitle("Agenda")
        .fabDefault(.capture(.inbox))
        .onChange(of: store.areas.map(\.id)) { _, ids in
            if let selectedAreaID, !ids.contains(selectedAreaID) { self.selectedAreaID = nil }
        }
        .onChange(of: store.initiatives.map(\.id)) { _, ids in
            if let selectedInitiativeID, !ids.contains(selectedInitiativeID) { self.selectedInitiativeID = nil }
        }
        .onChange(of: store.outcomes.map(\.id)) { _, ids in
            if let selectedOutcomeID, !ids.contains(selectedOutcomeID) { self.selectedOutcomeID = nil }
        }
    }
}

#Preview {
    NavigationStack {
        AgendaView()
            .environment(WorkspaceStore.sample())
            .environment(EntityEditor())
            .environment(QuickCaptureController())
    }
}
