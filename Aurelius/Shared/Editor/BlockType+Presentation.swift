extension BlockType {
    var displayName: String {
        switch self {
        case .paragraph: "Text"
        case .heading1: "Heading 1"
        case .heading2: "Heading 2"
        case .heading3: "Heading 3"
        case .bullet: "Bullet List"
        case .checklist: "Checklist"
        case .quote: "Quote"
        case .code: "Code"
        case .divider: "Divider"
        case .drawing: "Drawing"
        }
    }

    var icon: String {
        switch self {
        case .paragraph: "text.alignleft"
        case .heading1: "textformat.size.larger"
        case .heading2: "textformat.size"
        case .heading3: "textformat"
        case .bullet: "list.bullet"
        case .checklist: "checkmark.square"
        case .quote: "quote.opening"
        case .code: "chevron.left.forwardslash.chevron.right"
        case .divider: "minus"
        case .drawing: "pencil.tip.crop.circle"
        }
    }
}
