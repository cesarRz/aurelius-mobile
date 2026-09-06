import SwiftUI

struct OutcomeListRow: View {

    @Environment(WorkspaceStore.self)
    private var store

    let outcome: Outcome

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            HStack {

                Text(outcome.name)
                    .font(.headline)

                Spacer()

                StatusBadge(
                    status: outcome.status
                )
            }

            if let initiative =
                store.initiative(for: outcome.initiativeID) {

                Label(
                    initiative.name,
                    systemImage: "flag"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            ProgressView(
                value: store.progress(
                    for: outcome.id
                )
            )
        }
        .padding(.vertical, 4)
    }
}
