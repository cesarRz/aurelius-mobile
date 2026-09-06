import Foundation

enum Priority: String, CaseIterable, Identifiable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"

    var id: String { rawValue }
}
