import Foundation

enum QuickCaptureKind: String, CaseIterable, Identifiable {
    case inbox
    case area
    case initiative
    case outcome

    var id: String { rawValue }

    var title: String {
        switch self {
        case .inbox: "Inbox"
        case .area: "Area"
        case .initiative: "Initiative"
        case .outcome: "Outcome"
        }
    }

    var icon: String {
        switch self {
        case .inbox: "tray"
        case .area: "square.grid.2x2"
        case .initiative: "flag"
        case .outcome: "target"
        }
    }

    var placeholder: String {
        switch self {
        case .inbox: "Capture an idea…"
        case .area: "New area"
        case .initiative: "New initiative"
        case .outcome: "What do you want to achieve?"
        }
    }
}
