import SwiftUI

struct MoreHubView: View {
    @Binding var selection: WorkspaceSelection?
    var path: Binding<NavigationPath>? = nil

    var body: some View {
        List {
            NavigationLink {
                InboxView()
            } label: {
                Label("Inbox", systemImage: "tray")
            }

            NavigationLink {
                TasksListView(showingForm: .constant(false))
            } label: {
                Label("Tasks", systemImage: "checkmark.circle")
            }

            NavigationLink {
                ThreadsListView()
            } label: {
                Label("Active Threads", systemImage: "bubble.left.and.bubble.right")
            }

            NavigationLink {
                NotesListView(selection: $selection, path: path)
            } label: {
                Label("Notes", systemImage: "note.text")
            }
        }
        .navigationTitle("More")
        .fabDefault(.capture(.inbox))
    }
}
