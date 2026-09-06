import SwiftUI

struct AgendaTaskOptions: View {
    @Environment(WorkspaceStore.self) private var store
    @Binding var grouping: AgendaTaskGrouping
    @Binding var initiativeID: UUID?
    @Binding var outcomeID: UUID?

    private var availableOutcomes: [Outcome] {
        store.outcomes.filter { initiativeID == nil || $0.initiativeID == initiativeID }
    }

    var body: some View {
        Menu {
            Picker("Group by", selection: $grouping) {
                ForEach(AgendaTaskGrouping.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            Menu("Filter by initiative") {
                Picker("Initiative", selection: $initiativeID) {
                    Text("All initiatives").tag(nil as UUID?)
                    ForEach(store.initiatives) { initiative in
                        Text(initiative.name).tag(Optional(initiative.id))
                    }
                }
            }
            Menu("Filter by outcome") {
                Picker("Outcome", selection: $outcomeID) {
                    Text("All outcomes").tag(nil as UUID?)
                    ForEach(availableOutcomes) { outcome in
                        Text(outcome.name).tag(Optional(outcome.id))
                    }
                }
            }
            if initiativeID != nil || outcomeID != nil {
                Button("Clear task filters") {
                    initiativeID = nil
                    outcomeID = nil
                }
            }
        } label: {
            Image(systemName: initiativeID == nil && outcomeID == nil
                  ? "slider.horizontal.3" : "line.3.horizontal.decrease.circle.fill")
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Task grouping and filters")
        .onChange(of: initiativeID) { _, initiativeID in
            if let outcomeID, let initiativeID,
               store.outcome(for: outcomeID)?.initiativeID != initiativeID {
                self.outcomeID = nil
            }
        }
    }
}
