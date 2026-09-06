import SwiftUI

struct StatusBadge: View {

    let status: WorkStatus

    var body: some View {

        Text(status.rawValue)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Color.secondary.opacity(0.12)
            )
            .clipShape(Capsule())
    }
}
