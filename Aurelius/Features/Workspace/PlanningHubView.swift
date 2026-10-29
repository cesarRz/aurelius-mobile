import SwiftUI

struct PlanningHubView: View {
    @Binding var selection: WorkspaceSelection?
    @Binding var showingAreaForm: Bool
    @Binding var showingInitiativeForm: Bool
    @Binding var showingOutcomeForm: Bool
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var section: PlanningSection = .areas

    var body: some View {
        Group {
            if horizontalSizeClass == .compact {
                phoneNavigation
            } else {
                tabletNavigation
            }
        }
        .fabDefault(.capture(.inbox))
    }

    private var phoneNavigation: some View {
        List {
            NavigationLink {
                AreasListView(selection: $selection, showingForm: $showingAreaForm)
            } label: {
                Label("Areas", systemImage: "square.grid.2x2")
            }

            NavigationLink {
                InitiativesListView(selection: $selection, showingForm: $showingInitiativeForm)
            } label: {
                Label("Initiatives", systemImage: "flag")
            }

            NavigationLink {
                OutcomesListView(selection: $selection, showingForm: $showingOutcomeForm)
            } label: {
                Label("Outcomes", systemImage: "target")
            }
        }
        .navigationTitle("Planning")
    }

    private var tabletNavigation: some View {
        NavigationSplitView {
            List(PlanningSection.allCases, selection: Binding<PlanningSection?>(get: { section }, set: { if let newValue = $0 { section = newValue } })) { item in
                Label(item.title, systemImage: item.icon)
                    .tag(item)
            }
            .listStyle(.sidebar)
            .navigationTitle("Planning")
        } detail: {
            NavigationStack {
                planningList
            }
        }
        .navigationSplitViewStyle(.balanced)
    }

    @ViewBuilder
    private var planningList: some View {
        switch section {
        case .areas:
            AreasListView(selection: $selection, showingForm: $showingAreaForm)
        case .initiatives:
            InitiativesListView(selection: $selection, showingForm: $showingInitiativeForm)
        case .outcomes:
            OutcomesListView(selection: $selection, showingForm: $showingOutcomeForm)
        }
    }
}

private enum PlanningSection: String, CaseIterable, Identifiable {
    case areas
    case initiatives
    case outcomes

    var id: String { rawValue }

    var title: String {
        switch self {
        case .areas: "Areas"
        case .initiatives: "Initiatives"
        case .outcomes: "Outcomes"
        }
    }

    var icon: String {
        switch self {
        case .areas: "square.grid.2x2"
        case .initiatives: "flag"
        case .outcomes: "target"
        }
    }
}
