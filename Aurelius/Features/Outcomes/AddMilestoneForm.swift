import SwiftUI

struct AddMilestoneForm: View {
    @Environment(WorkspaceStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var outcomeID: UUID?

    var body: some View {
        NavigationStack {
            Form {
                Section("Milestone") {
                    TextField("What marks progress?", text: $name)

                    Picker("Outcome", selection: $outcomeID) {
                        Text("Select outcome").tag(UUID?.none)
                        ForEach(store.outcomes) { outcome in
                            Text(outcome.name).tag(Optional(outcome.id))
                        }
                    }
                }
            }
            .navigationTitle("New Milestone")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        guard let outcomeID else { return }
                        store.addMilestone(name: name, outcomeID: outcomeID)
                        dismiss()
                    }
                    .disabled(
                        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        || outcomeID == nil
                    )
                }
            }
        }
    }
}
