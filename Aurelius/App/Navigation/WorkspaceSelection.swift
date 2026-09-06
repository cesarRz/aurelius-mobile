import SwiftUI

enum WorkspaceSelection: Hashable {
    case area(UUID)
    case initiative(UUID)
    case outcome(UUID)
    case document(UUID)
    case note(UUID)
}
