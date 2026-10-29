import Foundation

struct WorkspaceDocument: Identifiable {
    let id: UUID
    var name: String
    var initiativeID: UUID?
    var outcomeID: UUID?
    var blocks: [DocumentBlock]

    init(
        id: UUID = UUID(),
        name: String,
        initiativeID: UUID? = nil,
        outcomeID: UUID? = nil,
        blocks: [DocumentBlock] = []
    ) {
        self.id = id
        self.name = name
        self.initiativeID = initiativeID
        self.outcomeID = outcomeID
        self.blocks = blocks
    }
}

extension WorkspaceDocument {
    var displayName: String { name.isEmpty ? "Untitled" : name }

    /// Primer texto no vacío, para la vista previa en la lista.
    var preview: String {
        blocks
            .first { !$0.text.isEmpty && $0.type != .divider && $0.type != .drawing }?
            .text ?? "No content"
    }

    func matches(_ query: String) -> Bool {
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return true }
        return name.localizedCaseInsensitiveContains(q)
            || blocks.contains { $0.text.localizedCaseInsensitiveContains(q) }
    }
}
