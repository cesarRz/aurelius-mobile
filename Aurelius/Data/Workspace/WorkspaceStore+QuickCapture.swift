import Foundation

extension WorkspaceStore {
    @discardableResult
    func submitQuickCapture(
        _ text: String,
        kind: QuickCaptureKind,
        source: InboxEntry.Source = .text
    ) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        switch kind {
        case .inbox:
            return captureInbox(trimmed, source: source)
        case .area:
            addArea(name: trimmed, icon: "square.grid.2x2")
            return true
        case .initiative:
            addInitiative(name: trimmed, areaID: nil, status: .notStarted)
            return true
        case .outcome:
            addOutcome(name: trimmed, initiativeID: nil, status: .notStarted, targetDate: nil)
            return true
        }
    }
}
