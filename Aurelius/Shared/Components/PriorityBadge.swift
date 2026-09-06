import SwiftUI

struct PriorityBadge: View {

    let priority: Priority

    var body: some View {

        HStack(spacing: 4) {

            Image(systemName: "flag.fill")

            Text(priority.rawValue)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
}
