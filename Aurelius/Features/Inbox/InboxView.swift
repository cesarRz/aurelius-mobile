import SwiftUI

struct InboxView: View {
    @Environment(WorkspaceStore.self) private var store
    @Environment(QuickCaptureController.self) private var quickCapture

    var body: some View {
        List {
            Section("Unsorted") {
                if store.inboxEntries.isEmpty {
                    ContentUnavailableView("Inbox is empty", systemImage: "tray",
                                           description: Text("Tap + to capture an idea, area, or outcome."))
                }
                ForEach(store.inboxEntries) { entry in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(entry.text)
                        Label(entry.createdAt.formatted(date: .abbreviated, time: .shortened),
                              systemImage: entry.source == .voice ? "mic" : "text.alignleft")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
                .onDelete { store.inboxEntries.remove(atOffsets: $0) }
            }
        }
        .navigationTitle("Inbox")
        .fabDefault(.capture(.inbox))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    quickCapture.open(.inbox)
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Capture to Inbox")
            }
        }
    }
}

#Preview {
    NavigationStack {
        InboxView()
            .environment(WorkspaceStore.sample())
            .environment(QuickCaptureController())
    }
}
