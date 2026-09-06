import SwiftUI

struct TasksListView: View {

    @Environment(WorkspaceStore.self)
    private var store
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @Binding var showingForm: Bool

    private var activeTasks: [TaskItem] {
        store.tasks.filter {
            $0.status != .done
        }
    }

    private var completedTasks: [TaskItem] {
        store.tasks.filter {
            $0.status == .done
        }
    }

    var body: some View {

        List {

            Section("Active") {

                ForEach(activeTasks) { task in
                    TaskRow(taskID: task.id)
                }
            }

            Section("Completed") {

                ForEach(completedTasks) { task in
                    TaskRow(taskID: task.id)
                }
            }
        }
        .navigationTitle("Tasks")
        .fabDefault(.task)
        .toolbar {
            if horizontalSizeClass != .compact {
                Button {
                    showingForm = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}
