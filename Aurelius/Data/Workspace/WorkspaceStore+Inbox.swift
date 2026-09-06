import Foundation

extension WorkspaceStore {
    @discardableResult
    func captureInbox(_ text: String, source: InboxEntry.Source = .text) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        inboxEntries.insert(InboxEntry(text: trimmed, source: source), at: 0)
        return true
    }
}
