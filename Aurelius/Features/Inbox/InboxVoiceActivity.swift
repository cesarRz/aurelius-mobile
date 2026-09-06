import SwiftUI

/// Recent microphone energy, from oldest (left) to newest (right).
struct InboxVoiceActivity: View {
    let levels: [Double]
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 10) {
            HStack(spacing: 3) {
                ForEach(levels.indices, id: \.self) { index in
                    Capsule()
                        .fill(Color.primary.opacity(0.65))
                        .frame(width: 3, height: 3 + 21 * levels[index])
                }
            }
            .frame(width: 39, height: 24)
            .animation(reduceMotion ? nil : .linear(duration: 0.05), value: levels)
            Text("Listening…")
                .font(.subheadline)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Listening")
    }
}
