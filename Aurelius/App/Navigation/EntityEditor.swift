import SwiftUI

enum EditingEntity: Identifiable, Hashable {
    case task(UUID)
    case area(UUID)
    case initiative(UUID)
    case outcome(UUID)

    var id: String {
        switch self {
        case .task(let id): "task-\(id)"
        case .area(let id): "area-\(id)"
        case .initiative(let id): "initiative-\(id)"
        case .outcome(let id): "outcome-\(id)"
        }
    }
}

@Observable
final class EntityEditor {
    var target: EditingEntity?
}

struct EntityEditorPresentation: ViewModifier {
    var editor: EntityEditor

    func body(content: Content) -> some View {
        @Bindable var editor = editor
        content.sheet(item: $editor.target) { target in
            Group {
                switch target {
                case .task(let id):
                    AddTaskForm(taskID: id)
                case .area(let id):
                    AddAreaForm(areaID: id)
                case .initiative(let id):
                    AddInitiativeForm(initiativeID: id)
                case .outcome(let id):
                    AddOutcomeForm(outcomeID: id)
                }
            }
            .environment(editor)
        }
    }
}