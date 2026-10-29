import SwiftUI

struct DocsListView: View {
    @Environment(WorkspaceStore.self) private var store
    @Binding var selection: WorkspaceSelection?
    var path: Binding<NavigationPath>? = nil

    @State private var query = ""

    private var filteredDocs: [WorkspaceDocument] {
        store.docs.filter { $0.matches(query) }
    }

    var body: some View {
        List(filteredDocs) { doc in
            WorkspaceSelectionLink(
                value: .document(doc.id),
                selection: $selection
            ) {
                row(for: doc)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    store.deleteDocument(doc.id)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
            .swipeActions(edge: .leading) {
                Button {
                    store.duplicateDocument(doc.id)
                } label: {
                    Label("Duplicate", systemImage: "plus.square.on.square")
                }
                .tint(.indigo)
            }
            .contextMenu {
                Button {
                    store.duplicateDocument(doc.id)
                } label: {
                    Label("Duplicate", systemImage: "plus.square.on.square")
                }
                Button(role: .destructive) {
                    store.deleteDocument(doc.id)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .overlay {
            if store.docs.isEmpty {
                ContentUnavailableView {
                    Label("No documents", systemImage: "doc.text")
                } description: {
                    Text("Create your first document.")
                } actions: {
                    Button("New Document") { open(.document(store.addDocument())) }
                        .buttonStyle(.borderedProminent)
                }
            } else if filteredDocs.isEmpty {
                ContentUnavailableView.search(text: query)
            }
        }
        .searchable(text: $query, prompt: "Search documents")
        .navigationTitle("Docs")
        .fabDefault(.hidden)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    open(.document(store.addDocument()))
                } label: {
                    Image(systemName: "square.and.pencil")
                }
                .accessibilityLabel("New Document")
            }
        }
    }

    private func row(for doc: WorkspaceDocument) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.text")
                .font(.title3)
                .foregroundStyle(.secondary)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(doc.displayName)
                    .font(.headline)
                    .lineLimit(1)
                Text(doc.preview)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                if let context = contextName(for: doc) {
                    Text(context)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 2)
    }

    private func contextName(for doc: WorkspaceDocument) -> String? {
        if let id = doc.outcomeID, let o = store.outcomes.first(where: { $0.id == id }) { return o.name }
        if let id = doc.initiativeID, let i = store.initiatives.first(where: { $0.id == id }) { return i.name }
        return nil
    }

    private func open(_ item: WorkspaceSelection) {
        if let path {
            path.wrappedValue.append(item)
        } else {
            selection = item
        }
    }
}
