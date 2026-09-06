import SwiftUI

struct AddInitiativeForm: View {

    @Environment(WorkspaceStore.self)
    private var store

    @Environment(\.dismiss)
    private var dismiss

    var initiativeID: UUID? = nil

    @State private var name = ""
    @State private var areaID: UUID?
    @State private var status: WorkStatus = .notStarted

    var body: some View {

        NavigationStack {

            Form {

                Section("Initiative") {

                    TextField(
                        "Name",
                        text: $name
                    )

                    Picker(
                        "Area",
                        selection: $areaID
                    ) {

                        Text("None")
                            .tag(UUID?.none)

                        ForEach(store.areas) { area in

                            Text(area.name)
                                .tag(
                                    Optional(area.id)
                                )
                        }
                    }

                    Picker(
                        "Status",
                        selection: $status
                    ) {

                        ForEach(
                            WorkStatus.allCases
                        ) { status in

                            Text(status.rawValue)
                                .tag(status)
                        }
                    }
                }
            }
            .navigationTitle(initiativeID == nil ? "New Initiative" : "Edit Initiative")
            .onAppear(perform: load)
            .toolbar {

                ToolbarItem(
                    placement: .cancellationAction
                ) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(
                    placement: .confirmationAction
                ) {
                    Button(initiativeID == nil ? "Create" : "Save") {
                        save()
                        dismiss()
                    }
                    .disabled(
                        name.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty
                    )
                }
            }
        }
    }

    private func load() {
        guard let initiativeID, let initiative = store.initiative(for: initiativeID) else { return }
        name = initiative.name
        areaID = initiative.areaID
        status = initiative.status
    }

    private func save() {
        if let initiativeID {
            store.updateInitiative(id: initiativeID, name: name, areaID: areaID, status: status)
        } else {
            store.addInitiative(name: name, areaID: areaID, status: status)
        }
    }
}
