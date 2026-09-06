import Foundation
import Testing
@testable import Aurelius

@MainActor
struct InboxTests {
    @Test func captureRejectsWhitespaceAndKeepsDuplicateIdeasDistinct() {
        let store = WorkspaceStore()
        #expect(!store.captureInbox(" \n "))
        #expect(store.inboxEntries.isEmpty)
        #expect(store.captureInbox("  An idea\n"))
        #expect(store.captureInbox("An idea", source: .voice))
        #expect(store.inboxEntries.count == 2)
        #expect(store.inboxEntries[0].text == "An idea")
        #expect(store.inboxEntries[0].source == .voice)
        #expect(store.inboxEntries[1].source == .text)
        #expect(store.inboxEntries[0].id != store.inboxEntries[1].id)
        #expect(store.tasks.isEmpty && store.areas.isEmpty && store.notes.isEmpty && store.docs.isEmpty)
    }

    @Test func quickCaptureRoutesToInboxAreaAndOutcome() {
        let store = WorkspaceStore()
        #expect(!store.submitQuickCapture(" \n", kind: .inbox))
        #expect(store.submitQuickCapture("  An idea\n", kind: .inbox, source: .voice))
        #expect(store.inboxEntries.map(\.text) == ["An idea"])
        #expect(store.inboxEntries[0].source == .voice)

        #expect(store.submitQuickCapture("Health", kind: .area))
        #expect(store.areas.map(\.name) == ["Health"])
        #expect(store.areas[0].icon == "square.grid.2x2")

        #expect(store.submitQuickCapture("Ship it", kind: .outcome))
        #expect(store.outcomes.map(\.name) == ["Ship it"])
        #expect(store.outcomes[0].initiativeID == nil)

        #expect(store.submitQuickCapture("Launch", kind: .initiative))
        #expect(store.initiatives.map(\.name) == ["Launch"])
        #expect(store.initiatives[0].areaID == nil)
        #expect(store.tasks.isEmpty)
    }

    @Test func fabDefaultFollowsWorkspaceSelection() {
        #expect(FABPrimaryAction.default(for: .area(UUID())) == .capture(.area))
        #expect(FABPrimaryAction.default(for: .initiative(UUID())) == .capture(.initiative))
        #expect(FABPrimaryAction.default(for: .outcome(UUID())) == .capture(.outcome))
        #expect(FABPrimaryAction.default(for: .document(UUID())) == .hidden)
        #expect(FABPrimaryAction.default(for: .note(UUID())) == .hidden)
    }
}
