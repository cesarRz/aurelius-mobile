import SwiftUI

struct WorkspaceHomeView: View {

    var body: some View {

        ContentUnavailableView {

            Label(
                "Workspace",
                systemImage: "circle.grid.2x2"
            )

        } description: {

            Text(
                "Select an area, initiative, outcome, document or note."
            )
        }
    }
}
