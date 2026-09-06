import SwiftUI

struct WorkspaceDetailView: View {
    let selection: WorkspaceSelection

    @Binding var workspaceSelection: WorkspaceSelection?
    @Binding var showingInitiativeForm: Bool
    @Binding var showingOutcomeForm: Bool
    @Binding var showingTaskForm: Bool

    var body: some View {
        detail
            .fabDefault(.default(for: selection))
    }

    @ViewBuilder
    private var detail: some View {
        switch selection {
        case .area(let id):
            AreaDetailView(
                areaID: id,
                selection: $workspaceSelection,
                showingInitiativeForm: $showingInitiativeForm
            )

        case .initiative(let id):
            InitiativeDetailView(
                initiativeID: id,
                selection: $workspaceSelection,
                showingOutcomeForm: $showingOutcomeForm,
                showingTaskForm: $showingTaskForm
            )

        case .outcome(let id):
            OutcomeWorkspaceView(
                outcomeID: id,
                selection: $workspaceSelection,
                showingTaskForm: $showingTaskForm
            )

        case .document(let id):
            DocumentEditorView(documentID: id)

        case .note(let id):
            NoteEditorView(noteID: id)
        }
    }
}

extension View {
    func workspaceNavigation(
        selection: Binding<WorkspaceSelection?>,
        showingInitiativeForm: Binding<Bool>,
        showingOutcomeForm: Binding<Bool>,
        showingTaskForm: Binding<Bool>
    ) -> some View {
        modifier(
            WorkspaceNavigationModifier(
                selection: selection,
                showingInitiativeForm: showingInitiativeForm,
                showingOutcomeForm: showingOutcomeForm,
                showingTaskForm: showingTaskForm
            )
        )
    }
}

private struct WorkspaceNavigationModifier: ViewModifier {
    @Environment(EntityEditor.self) private var editor
    @Binding var selection: WorkspaceSelection?
    @Binding var showingInitiativeForm: Bool
    @Binding var showingOutcomeForm: Bool
    @Binding var showingTaskForm: Bool

    func body(content: Content) -> some View {
        content.navigationDestination(for: WorkspaceSelection.self) { item in
            WorkspaceDetailView(
                selection: item,
                workspaceSelection: $selection,
                showingInitiativeForm: $showingInitiativeForm,
                showingOutcomeForm: $showingOutcomeForm,
                showingTaskForm: $showingTaskForm
            )
            .environment(editor)
        }
    }
}