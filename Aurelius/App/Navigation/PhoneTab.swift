import SwiftUI

enum PhoneTab: String, CaseIterable, Identifiable {
    case agenda
    case planning
    case docs
    case more

    var id: String { rawValue }

    var title: String {
        switch self {
        case .agenda: "Agenda"
        case .planning: "Planning"
        case .docs: "Docs"
        case .more: "More"
        }
    }

    var icon: String {
        switch self {
        case .agenda: "calendar"
        case .planning: "square.grid.2x2"
        case .docs: "doc.text"
        case .more: "ellipsis.circle"
        }
    }
}
