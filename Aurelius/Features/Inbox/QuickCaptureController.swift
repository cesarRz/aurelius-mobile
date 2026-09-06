import Foundation
import Observation
import SwiftUI

enum FABPrimaryAction: Equatable {
    case capture(QuickCaptureKind)
    case task
    case milestone
    case hidden

    var accessibilityLabel: String {
        switch self {
        case .capture(let kind): "Capture to \(kind.title)"
        case .task: "New Task"
        case .milestone: "New Milestone"
        case .hidden: "Create"
        }
    }

    static func `default`(for selection: WorkspaceSelection) -> FABPrimaryAction {
        switch selection {
        case .area: .capture(.area)
        case .initiative: .capture(.initiative)
        case .outcome: .capture(.outcome)
        case .document, .note: .hidden
        }
    }
}

@Observable
final class QuickCaptureController {
    var isPresented = false
    var kind: QuickCaptureKind = .inbox
    var defaultAction: FABPrimaryAction = .capture(.inbox)
    var wantsFocus = false
    private(set) var isDismissing = false

    func open(_ kind: QuickCaptureKind = .inbox) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            self.kind = kind
            isDismissing = false
            isPresented = true
            wantsFocus = true
        }
    }

    func close() {
        guard isPresented else { return }
        if wantsFocus {
            isDismissing = true
            wantsFocus = false
        } else {
            finishClose()
        }
    }

    func finishClose() {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            isPresented = false
            isDismissing = false
            wantsFocus = false
        }
    }

    func handleKeyboardDidHide() {
        guard isPresented, isDismissing else { return }
        finishClose()
    }
}

private struct FABDefaultSetter: ViewModifier {
    @Environment(QuickCaptureController.self) private var capture
    let action: FABPrimaryAction

    func body(content: Content) -> some View {
        content.onAppear { capture.defaultAction = action }
    }
}

extension View {
    func fabDefault(_ action: FABPrimaryAction) -> some View {
        modifier(FABDefaultSetter(action: action))
    }
}
