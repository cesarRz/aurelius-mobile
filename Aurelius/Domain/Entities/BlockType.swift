import Foundation

enum BlockType: String, CaseIterable, Identifiable {
    case paragraph
    case heading1
    case heading2
    case heading3
    case bullet
    case checklist
    case quote
    case code
    case divider
    case drawing

    var id: String { rawValue }
}
