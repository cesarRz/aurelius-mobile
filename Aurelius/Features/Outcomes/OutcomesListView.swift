import SwiftUI

struct OutcomesListView: View {

    @Environment(WorkspaceStore.self)
    private var store
    @Environment(EntityEditor.self) private var editor
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @Binding var selection: WorkspaceSelection?
    @Binding var showingForm: Bool

    var body: some View {

        List {

            ForEach(store.outcomes) { outcome in

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
        .navigationTitle("Outcomes")
        .fabDefault(.capture(.outcome))
        .toolbar {
            if horizontalSizeClass != .compact {
                Button {
                    showingForm = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}
