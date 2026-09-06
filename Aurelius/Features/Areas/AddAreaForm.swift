import SwiftUI

struct AddAreaForm: View {

    @Environment(WorkspaceStore.self)
    private var store

    @Environment(\.dismiss)
    private var dismiss

    var areaID: UUID? = nil

    @State private var name = ""
    @State private var icon = "square.grid.2x2"

    private let icons = [
        "square.grid.2x2",
        "briefcase",
        "person",
        "heart",
        "house",
        "dollarsign.circle",
        "figure.run",
        "book",
        "car",
        "building.2"
    ]

    var body: some View {

        NavigationStack {

            Form {

                Section("Area") {

                    TextField(
                        "Name",
                        text: $name
                    )

                    Picker(
                        "Icon",
                        selection: $icon
                    ) {

                        ForEach(
                            icons,
                            id: \.self
                        ) { icon in

                            Label(
                                icon,
                                systemImage: icon
                            )
                            .tag(icon)
                        }
                    }
                }
            }
            .navigationTitle(areaID == nil ? "New Area" : "Edit Area")
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
                    Button(areaID == nil ? "Create" : "Save") {
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
        guard let areaID, let area = store.areas.first(where: { $0.id == areaID }) else { return }
        name = area.name
        icon = area.icon
    }

    private func save() {
        if let areaID {
            store.updateArea(id: areaID, name: name, icon: icon)
        } else {
            store.addArea(name: name, icon: icon)
        }
    }
}
