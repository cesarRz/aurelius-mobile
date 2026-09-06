import SwiftUI

struct WorkspaceSelectionLink<Label: View>: View {
    let value: WorkspaceSelection
    @Binding var selection: WorkspaceSelection?
    @ViewBuilder let label: () -> Label

    var body: some View {
        NavigationLink(value: value) {
            label()
        }
        .simultaneousGesture(
            TapGesture().onEnded {
                selection = value
            }
        )
    }
}