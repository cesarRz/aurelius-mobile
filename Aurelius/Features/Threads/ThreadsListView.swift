import SwiftUI

struct ThreadsListView: View {

    @Environment(WorkspaceStore.self)
    private var store

    var body: some View {

        List(store.threads) { thread in

            VStack(
                alignment: .leading,
                spacing: 5
            ) {

                Text(thread.name)
                    .font(.headline)

                Text(thread.detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 5)
        }
        .navigationTitle("Active Threads")
        .fabDefault(.capture(.inbox))
    }
}
