import SwiftUI

struct NotesListView: View {
    @Environment(WorkspaceStore.self) private var store
    @Binding var selection: WorkspaceSelection?
    var path: Binding<NavigationPath>? = nil

    var body: some View {
        List(store.notes) { note in
            WorkspaceSelectionLink(
                value: .note(note.id),
                selection: $selection
            ) {
                HStack {
                    Label(
                        note.name.isEmpty ? "Untitled" : note.name,
                        systemImage: "note.text"
                    )
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Notes")
        .fabDefault(.hidden)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    open(.note(store.addNote()))
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("New Note")
            }
        }
    }

    private func open(_ item: WorkspaceSelection) {
        if let path {
            path.wrappedValue.append(item)
        } else {
            selection = item
        }
    }
}
