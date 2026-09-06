import SwiftUI

struct AreasListView: View {

    @Environment(WorkspaceStore.self)
    private var store
    @Environment(EntityEditor.self) private var editor
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @Binding var selection: WorkspaceSelection?
    @Binding var showingForm: Bool

    var body: some View {

        List {

            ForEach(store.areas) { area in

                Button {
                    editor.target = .area(area.id)
                } label: {

                    HStack(spacing: 14) {

                        Image(systemName: area.icon)
                            .font(.title3)
                            .frame(width: 30)

                        VStack(
                            alignment: .leading,
                            spacing: 3
                        ) {

                            Text(area.name)
                                .font(.headline)

                            Text(
                                "\(store.initiatives(forArea: area.id).count) initiatives"
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Areas")
        .fabDefault(.capture(.area))
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
