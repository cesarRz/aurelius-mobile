import SwiftUI

struct DocsListView: View {
    @Environment(WorkspaceStore.self) private var store
    @Binding var selection: WorkspaceSelection?
    var path: Binding<NavigationPath>? = nil

    var body: some View {
        List(store.docs) { doc in
            WorkspaceSelectionLink(
                value: .document(doc.id),
                selection: $selection
            ) {
                HStack {
                    Label(
                        doc.name.isEmpty ? "Untitled" : doc.name,
                        systemImage: "doc.text"
                    )
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Docs")
        .fabDefault(.hidden)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    open(.document(store.addDocument()))
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("New Document")
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
