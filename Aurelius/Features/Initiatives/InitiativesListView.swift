import SwiftUI

struct InitiativesListView: View {

    @Environment(WorkspaceStore.self)
    private var store
    @Environment(EntityEditor.self) private var editor
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @Binding var selection: WorkspaceSelection?
    @Binding var showingForm: Bool

    var body: some View {

        List {

            ForEach(store.initiatives) { initiative in

                Button {
                    editor.target = .initiative(initiative.id)
                } label: {

                    VStack(
                        alignment: .leading,
                        spacing: 7
                    ) {

                        HStack {

                            Text(initiative.name)
                                .font(.headline)

                            Spacer()

                            StatusBadge(
                                status: initiative.status
                            )
                        }

                        if let area =
                            store.area(for: initiative.areaID) {

                            Label(
                                area.name,
                                systemImage: area.icon
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Initiatives")
        .fabDefault(.capture(.initiative))
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
