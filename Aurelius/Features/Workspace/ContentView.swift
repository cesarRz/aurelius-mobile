import SwiftUI

struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(EntityEditor.self) private var editor

    var body: some View {
        Group {
            if horizontalSizeClass == .compact {
                PhoneRootView()
            } else {
                TabletRootView()
            }
        }
        .environment(editor)
    }
}

private struct TabletRootView: View {
    @Environment(WorkspaceStore.self) private var store
    @Environment(EntityEditor.self) private var editor

    @State private var tab: PhoneTab = .agenda
    @State private var selection: WorkspaceSelection?
    @State private var path = NavigationPath()
    @State private var quickCapture = QuickCaptureController()

    @State private var showingAreaForm = false
    @State private var showingInitiativeForm = false
    @State private var showingOutcomeForm = false
    @State private var showingMilestoneForm = false
    @State private var showingTaskForm = false

    var body: some View {
        NavigationSplitView {
            SidebarView(tab: $tab)
                .environment(editor)
        } detail: {
            NavigationStack(path: $path) {
                detailRoot
                    .environment(editor)
                    .workspaceNavigation(
                        selection: $selection,
                        showingInitiativeForm: $showingInitiativeForm,
                        showingOutcomeForm: $showingOutcomeForm,
                        showingTaskForm: $showingTaskForm
                    )
                    .toolbar {
                        if tab == .agenda {
                            ToolbarItem(placement: .primaryAction) {
                                createActionButton
                            }
                        }
                    }
            }
            .environment(editor)
        }
        .onChange(of: tab) {
            path = NavigationPath()
            selection = nil
        }
        .modifier(QuickCapturePresentation())
        .environment(store)
        .environment(editor)
        .environment(quickCapture)
        .sheet(isPresented: $showingAreaForm) {
            AddAreaForm().environment(store)
        }
        .sheet(isPresented: $showingInitiativeForm) {
            AddInitiativeForm().environment(store)
        }
        .sheet(isPresented: $showingOutcomeForm) {
            AddOutcomeForm().environment(store)
        }
        .sheet(isPresented: $showingMilestoneForm) {
            AddMilestoneForm().environment(store)
        }
        .sheet(isPresented: $showingTaskForm) {
            AddTaskForm().environment(store)
        }
    }

    private var createActionButton: CreateActionFAB {
        CreateActionFAB(
            placement: .toolbar,
            onCreateTask: { showingTaskForm = true },
            onCreateMilestone: { showingMilestoneForm = true }
        )
    }

    @ViewBuilder
    private var detailRoot: some View {
        switch tab {
        case .agenda:
            AgendaView()

        case .planning:
            PlanningHubView(
                selection: $selection,
                showingAreaForm: $showingAreaForm,
                showingInitiativeForm: $showingInitiativeForm,
                showingOutcomeForm: $showingOutcomeForm
            )

        case .docs:
            DocsListView(selection: $selection, path: $path)

        case .more:
            MoreHubView(selection: $selection, path: $path)
        }
    }
}

#Preview {
    ContentView()
        .environment(WorkspaceStore.sample())
        .environment(EntityEditor())
}