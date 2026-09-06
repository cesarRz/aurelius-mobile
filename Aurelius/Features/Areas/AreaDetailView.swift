import SwiftUI

struct AreaDetailView: View {

    @Environment(WorkspaceStore.self)
    private var store
    @Environment(EntityEditor.self) private var editor

    let areaID: UUID

    @Binding var selection: WorkspaceSelection?
    @Binding var showingInitiativeForm: Bool

    private var area: Area? {
        store.areas.first {
            $0.id == areaID
        }
    }

    private var initiatives: [Initiative] {
        store.initiatives(forArea: areaID)
    }

    var body: some View {

        if let area {

            ScrollView {

                VStack(
                    alignment: .leading,
                    spacing: 28
                ) {

                    HStack(spacing: 16) {

                        Image(systemName: area.icon)
                            .font(.largeTitle)

                        VStack(
                            alignment: .leading,
                            spacing: 4
                        ) {

                            Text("AREA")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)

                            Text(area.name)
                                .font(.largeTitle.bold())
                        }
                    }

                    SectionCard(
                        title: "Initiatives",
                        icon: "flag"
                    ) {

                        if initiatives.isEmpty {

                            Text("No initiatives yet.")
                                .foregroundStyle(.secondary)

                        } else {

                            ForEach(initiatives) { initiative in

                                Button {
                                    editor.target = .initiative(initiative.id)
                                } label: {

                                    HStack {

                                        VStack(
                                            alignment: .leading
                                        ) {
                                            Text(initiative.name)
                                                .font(.headline)

                                            StatusBadge(
                                                status: initiative.status
                                            )
                                        }

                                        Spacer()
                                    }
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(28)
                .frame(
                    maxWidth: 900,
                    alignment: .leading
                )
            }
            .navigationTitle(area.name)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") {
                        editor.target = .area(areaID)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingInitiativeForm = true
                    } label: {
                        Label(
                            "New Initiative",
                            systemImage: "plus"
                        )
                    }
                }
            }

        } else {

            ContentUnavailableView(
                "Area not found",
                systemImage: "square.grid.2x2"
            )
        }
    }
}
