import SwiftUI

struct SectionCard<Content: View>: View {

    let title: String
    let icon: String
    let content: Content

    init(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            Label(
                title,
                systemImage: icon
            )
            .font(.headline)

            content
        }
        .padding(18)
        .background(
            Color.secondary.opacity(0.07)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
        )
    }
}
