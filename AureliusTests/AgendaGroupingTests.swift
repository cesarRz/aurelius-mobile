import Foundation
import Testing
@testable import Aurelius

@MainActor
struct AgendaGroupingTests {
    @Test func groupsInheritedTasksAndKeepsUnassignedTasks() {
        let store = WorkspaceStore()
        let initiative = Initiative(name: "Launch")
        let outcome = Outcome(name: "Release", initiativeID: initiative.id)
        let milestone = Milestone(name: "Beta", outcomeID: outcome.id)
        store.initiatives = [initiative]
        store.outcomes = [outcome]
        store.milestones = [milestone]
        let now = Date.now
        let direct = TaskItem(name: "Direct", initiativeID: initiative.id, dueDate: now)
        let inherited = TaskItem(name: "Inherited", milestoneID: milestone.id, dueDate: now)
        let unassigned = TaskItem(name: "Unassigned", dueDate: now)
        store.tasks = [direct, inherited, unassigned]
        let groups = AgendaTaskGrouping.initiative.groups(for: store.tasks, in: store)
        #expect(groups.count == 2)
        #expect(groups.first?.tasks.map(\.id) == [direct.id, inherited.id])
        #expect(groups.last?.title == "No initiative")
        #expect(groups.flatMap(\.tasks).count == 3)
        let outcomes = AgendaTaskGrouping.outcome.groups(for: store.tasks, in: store)
        #expect(outcomes.first?.tasks.map(\.id) == [inherited.id])
        #expect(outcomes.last?.tasks.count == 2)
        #expect(store.tasks(dueOn: now, initiativeID: initiative.id, outcomeID: outcome.id).map(\.id) == [inherited.id])
        #expect(store.tasks(dueOn: now, initiativeID: UUID(), outcomeID: outcome.id).isEmpty)
    }
}
