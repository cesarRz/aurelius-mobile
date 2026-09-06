import Foundation

struct DocumentBlock: Identifiable {
    let id: UUID
    var type: BlockType
    var text: String
    var isChecked: Bool
    var drawingData: Data

    init(
        id: UUID = UUID(),
        type: BlockType = .paragraph,
        text: String = "",
        isChecked: Bool = false,
        drawingData: Data = Data()
    ) {
        self.id = id
        self.type = type
        self.text = text
        self.isChecked = isChecked
        self.drawingData = drawingData
    }

    var typeAfterReturn: BlockType {
        switch type {
        case .bullet, .checklist: type
        default: .paragraph
        }
    }

    static func splitOnReturn(_ text: String) -> (kept: String, remainder: String)? {
        guard let newline = text.firstIndex(of: "\n") else { return nil }
        let kept = String(text[..<newline])
        let remainder = text[text.index(after: newline)...].filter { $0 != "\n" }
        return (kept, String(remainder))
    }
}
