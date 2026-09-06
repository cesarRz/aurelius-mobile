import Foundation
import Testing
@testable import Aurelius

@MainActor
struct AureliusTests {
    @Test func taskCompletionUpdatesOnlyItsOutcomeProgress() throws {
        let store = WorkspaceStore()
        let outcome = Outcome(name: "Launch")
        let other = Outcome(name: "Other")
        store.outcomes = [outcome, other]
        #expect(store.progress(for: outcome.id) == 0)
        store.addTask(name: "First", areaID: nil, initiativeID: nil,
                      outcomeID: outcome.id, priority: .high, dueDate: nil)
        store.addTask(name: "Second", areaID: nil, initiativeID: nil,
                      outcomeID: outcome.id, priority: .medium, dueDate: nil)
        store.addTask(name: "Unrelated", areaID: nil, initiativeID: nil,
                      outcomeID: other.id, priority: .low, dueDate: nil)
        let task = try #require(store.tasks.first)
        store.toggleTask(task.id)
        #expect(store.progress(for: outcome.id) == 0.5)
        #expect(store.progress(for: other.id) == 0)
        store.toggleTask(task.id)
        #expect(store.progress(for: outcome.id) == 0)
    }

    @Test func documentInsertionAndSyntaxPreserveAdjacentBlocks() throws {
        let store = WorkspaceStore()
        let first = DocumentBlock(text: "## Heading")
        let last = DocumentBlock(text: "Keep me")
        let document = WorkspaceDocument(name: "Plan", blocks: [first, last])
        store.docs = [document]
        let inserted = try #require(store.addBlock(toDocument: document.id,
                                                   after: first.id, type: .checklist))
        store.interpretDocumentSyntax(documentID: document.id, blockID: first.id)
        #expect(store.docs[0].blocks.map(\.id) == [first.id, inserted, last.id])
        #expect(store.docs[0].blocks[0].type == .heading2)
        #expect(store.docs[0].blocks[0].text == "Heading")
        #expect(store.docs[0].blocks[2].text == "Keep me")
        #expect(store.addBlock(toDocument: UUID(), after: nil) == nil)
    }

    @Test func addDocumentCreatesBlankDocumentReadyToEdit() {
        let store = WorkspaceStore()
        let id = store.addDocument()
        #expect(store.docs.count == 1)
        #expect(store.docs[0].id == id)
        #expect(store.docs[0].name.isEmpty)
        #expect(store.docs[0].blocks.count == 1)
        #expect(store.docs[0].blocks[0].text.isEmpty)
    }

    @Test func addNoteCreatesBlankNoteReadyToEdit() {
        let store = WorkspaceStore()
        let id = store.addNote()
        #expect(store.notes.count == 1)
        #expect(store.notes[0].id == id)
        #expect(store.notes[0].name.isEmpty)
        #expect(store.notes[0].blocks.count == 1)
        #expect(store.notes[0].blocks[0].text.isEmpty)
    }

    @Test func returnSplitsBlockTextInsteadOfKeepingANewline() {
        let midLine = DocumentBlock.splitOnReturn("Hello\nWorld")
        #expect(midLine?.kept == "Hello")
        #expect(midLine?.remainder == "World")
        #expect(DocumentBlock.splitOnReturn("Hello\n")?.remainder == "")
        #expect(DocumentBlock.splitOnReturn("Hello") == nil)
        #expect(DocumentBlock.splitOnReturn("A\nB\nC")?.remainder == "BC")
        #expect(DocumentBlock(type: .heading1).typeAfterReturn == .paragraph)
        #expect(DocumentBlock(type: .bullet).typeAfterReturn == .bullet)
        #expect(DocumentBlock(type: .checklist).typeAfterReturn == .checklist)
    }

    @Test func addBlockCanCarryRemainderTextIntoTheNewRow() throws {
        let store = WorkspaceStore()
        let first = DocumentBlock(text: "Hello")
        let document = WorkspaceDocument(name: "Plan", blocks: [first])
        store.docs = [document]
        let inserted = try #require(store.addBlock(
            toDocument: document.id,
            after: first.id,
            text: "World"
        ))
        #expect(store.docs[0].blocks.map(\.id) == [first.id, inserted])
        #expect(store.docs[0].blocks[1].text == "World")
    }

    @Test func noteEditingDoesNotChangeDocuments() throws {
        let store = WorkspaceStore()
        let block = DocumentBlock(text: "- [ ] Todo")
        let note = WorkspaceNote(name: "Note", blocks: [block])
        store.notes = [note]
        store.docs = [WorkspaceDocument(name: "Doc", blocks: [block])]
        store.interpretNoteSyntax(noteID: note.id, blockID: block.id)
        let inserted = try #require(store.addBlock(toNote: note.id, after: block.id))
        #expect(store.notes[0].blocks[0].type == .checklist)
        #expect(store.notes[0].blocks[0].text == "Todo")
        #expect(store.notes[0].blocks[1].id == inserted)
        #expect(store.docs[0].blocks[0].text == "- [ ] Todo")
    }

    @Test func updatingEntitiesChangesStoredFields() throws {
        let store = WorkspaceStore()
        store.addArea(name: "Work", icon: "briefcase")
        let area = try #require(store.areas.first)
        store.updateArea(id: area.id, name: "Life", icon: "heart")
        #expect(store.areas[0].name == "Life")
        #expect(store.areas[0].icon == "heart")

        store.addInitiative(name: "Ship", areaID: area.id, status: .notStarted)
        let initiative = try #require(store.initiatives.first)
        store.updateInitiative(id: initiative.id, name: "Launch", areaID: nil, status: .inProgress)
        #expect(store.initiatives[0].name == "Launch")
        #expect(store.initiatives[0].status == .inProgress)

        store.addOutcome(name: "Beta", initiativeID: initiative.id, status: .notStarted, targetDate: nil)
        let outcome = try #require(store.outcomes.first)
        store.updateOutcome(id: outcome.id, name: "GA", initiativeID: nil, status: .inProgress, targetDate: nil)
        #expect(store.outcomes[0].name == "GA")

        store.addTask(name: "Draft", areaID: nil, initiativeID: nil, outcomeID: outcome.id,
                      priority: .low, dueDate: nil)
        let task = try #require(store.tasks.first)
        store.updateTask(id: task.id, name: "Publish", areaID: area.id, initiativeID: initiative.id,
                         outcomeID: outcome.id, priority: .high, scheduledStart: nil,
                         scheduledEnd: nil, dueDate: nil)
        #expect(store.tasks[0].name == "Publish")
        #expect(store.tasks[0].priority == .high)
        #expect(store.tasks[0].areaID == area.id)
    }
}
