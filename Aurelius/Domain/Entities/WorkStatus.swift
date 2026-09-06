import Foundation

enum WorkStatus: String, CaseIterable, Identifiable {
    case notStarted = "Not Started"
    case inProgress = "In Progress"
    case done = "Done"

    var id: String { rawValue }
}
