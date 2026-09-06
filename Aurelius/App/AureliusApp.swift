import SwiftUI

@main
struct AureliusApp: App {
    @State private var store = WorkspaceStore.sample()
    @State private var editor = EntityEditor()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .environment(editor)
                .modifier(EntityEditorPresentation(editor: editor))
        }
    }
}
