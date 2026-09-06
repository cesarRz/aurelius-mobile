import SwiftUI

struct PhoneRootView: View {
    @Environment(WorkspaceStore.self) private var store
    @Environment(EntityEditor.self) private var editor

    @State private var tab: PhoneTab = .agenda
    @State private var selection: WorkspaceSelection?
    @State private var quickCapture = QuickCaptureController()

    @State private var showingAreaForm = false
    @State private var showingInitiativeForm = false
    @State private var showingOutcomeForm = false
    @State private var showingMilestoneForm = false
    @State private var showingTaskForm = false
    @State private var docsPath = NavigationPath()
    @State private var morePath = NavigationPath()

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $tab) {
                phoneTab(.agenda) {
                    AgendaView()
                }

                phoneTab(.planning) {
                    PlanningHubView(
                        selection: $selection,
                        showingAreaForm: $showingAreaForm,
                        showingInitiativeForm: $showingInitiativeForm,
                        showingOutcomeForm: $showingOutcomeForm
                    )
                }

                phoneTab(.docs, path: $docsPath) {
                    DocsListView(selection: $selection, path: $docsPath)
                }

                phoneTab(.more, path: $morePath) {
                    MoreHubView(selection: $selection, path: $morePath)
                }
            }

            if !quickCapture.isPresented, quickCapture.defaultAction != .hidden {
                CreateActionFAB(
                    onCreateTask: { showingTaskForm = true },
                    onCreateMilestone: { showingMilestoneForm = true }
                )
                .padding(.trailing, 20)
                .padding(.bottom, 72)
            }
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

    @ViewBuilder
    private func phoneTab<Content: View>(
        _ phoneTab: PhoneTab,
        path: Binding<NavigationPath>? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        Group {
            if let path {
                NavigationStack(path: path) {
                    tabRoot(content)
                }
            } else {
                NavigationStack {
                    tabRoot(content)
                }
            }
        }
        .tabItem {
            Label(phoneTab.title, systemImage: phoneTab.icon)
        }
        .tag(phoneTab)
    }

    private func tabRoot<Content: View>(_ content: () -> Content) -> some View {
        content()
            .environment(editor)
            .workspaceNavigation(
                selection: $selection,
                showingInitiativeForm: $showingInitiativeForm,
                showingOutcomeForm: $showingOutcomeForm,
                showingTaskForm: $showingTaskForm
            )
    }
}
