import SwiftUI

struct CreateActionFAB: View {
    enum Placement {
        case floating
        case toolbar
    }

    @Environment(QuickCaptureController.self) private var capture
    var placement: Placement = .floating
    var onCreateTask: () -> Void
    var onCreateMilestone: () -> Void

    var body: some View {
        Menu {
            Button {
                capture.open(.area)
            } label: {
                Label("New Area", systemImage: "square.grid.2x2")
            }

            Button {
                capture.open(.initiative)
            } label: {
                Label("New Initiative", systemImage: "flag")
            }

            Button {
                capture.open(.outcome)
            } label: {
                Label("New Outcome", systemImage: "target")
            }

            Button {
                onCreateTask()
            } label: {
                Label("New Task", systemImage: "checkmark.circle")
            }

            Button {
                onCreateMilestone()
            } label: {
                Label("New Milestone", systemImage: "flag.checkered")
            }
        } label: {
            buttonLabel
        } primaryAction: {
            performDefault()
        }
        .accessibilityLabel(capture.defaultAction.accessibilityLabel)
        .accessibilityHint("Long press for other capture types")
    }

    @ViewBuilder
    private var buttonLabel: some View {
        switch placement {
        case .floating:
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Color.accentColor, in: Circle())
                .shadow(color: .black.opacity(0.16), radius: 10, y: 4)
        case .toolbar:
            Image(systemName: "plus")
        }
    }

    private func performDefault() {
        switch capture.defaultAction {
        case .capture(let kind):
            capture.open(kind)
        case .task:
            onCreateTask()
        case .milestone:
            onCreateMilestone()
        case .hidden:
            break
        }
    }
}
