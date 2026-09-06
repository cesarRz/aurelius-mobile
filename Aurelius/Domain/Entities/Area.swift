import Foundation

struct Area: Identifiable, Hashable {
    let id: UUID
    var name: String
    var icon: String

    init(
        id: UUID = UUID(),
        name: String,
        icon: String = "square.grid.2x2"
    ) {
        self.id = id
        self.name = name
        self.icon = icon
    }
}
