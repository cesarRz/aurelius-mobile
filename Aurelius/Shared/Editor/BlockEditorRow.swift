import SwiftUI

struct BlockEditorRow: View {

    @Binding var block: DocumentBlock

    var focusedBlockID: FocusState<UUID?>.Binding

    let onChange: () -> Void
    let onSubmit: (String) -> Void
    let onAddBlock: (BlockType) -> Void

    /// Acciones opcionales de gestión de bloque (las notas no las usan todavía).
    var isSelected = false
    var onSelect: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    var onDuplicate: (() -> Void)? = nil
    var onMove: ((Int) -> Void)? = nil
    /// Backspace en un bloque vacío: borra el bloque y devuelve el cursor al anterior.
    var onBackspaceEmpty: (() -> Void)? = nil
    /// Navegación entre bloques: `direction` -1/+1 y `column` = carácter dentro de
    /// la línea actual (`Int.max` = final, `0` = inicio).
    var onNavigate: ((_ direction: Int, _ column: Int) -> Void)? = nil
    /// Selección controlada desde fuera para poder colocar el cursor al cambiar de bloque.
    var externalSelection: Binding<TextSelection?>? = nil

    @State private var ownSelection: TextSelection?
    @State private var slashIndex = 0

    private var selectionBinding: Binding<TextSelection?> {
        externalSelection ?? $ownSelection
    }

    private var caretOffset: Int {
        let text = block.text
        guard case .selection(let range)? = selectionBinding.wrappedValue?.indices,
              range.isEmpty
        else { return text.count }
        return text.distance(from: text.startIndex, to: range.lowerBound)
    }

    private func column(at offset: Int) -> Int {
        let chars = Array(block.text)
        let clamped = min(max(offset, 0), chars.count)
        var start = clamped
        while start > 0, chars[start - 1] != "\n" { start -= 1 }
        return clamped - start
    }

    /// Comportamiento tipo editor: la flecha mueve el cursor dentro del bloque y,
    /// si ya estaba en la primera/última línea, salta al bloque vecino conservando la columna.
    private func handleVertical(_ direction: Int) -> KeyPress.Result {
        if slashQuery != nil {
            let count = slashMatches.count
            guard count > 0 else { return .handled }
            slashIndex = (min(slashIndex, count - 1) + direction + count) % count
            return .handled
        }
        guard let onNavigate else { return .ignored }
        let text = block.text
        let before = caretOffset
        let chars = Array(text)

        if direction < 0 {
            if !chars[..<min(before, chars.count)].contains("\n"), before == 0 {
                onNavigate(-1, 0)
                return .handled
            }
        } else if before >= chars.count, !chars[min(before, chars.count)...].contains("\n") {
            onNavigate(1, column(at: before))
            return .handled
        }

        let column = column(at: before)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
            let after = caretOffset
            let all = Array(block.text)
            if direction < 0 {
                let onFirstLine = !all[..<min(before, all.count)].contains("\n")
                if onFirstLine, after == 0 || after == before {
                    onNavigate(-1, column)
                }
            } else {
                let onLastLine = !all[min(before, all.count)...].contains("\n")
                if onLastLine, after >= all.count || after == before {
                    onNavigate(1, column)
                }
            }
        }
        return .ignored
    }

    private func handleHorizontal(_ direction: Int) -> KeyPress.Result {
        guard slashQuery == nil, let onNavigate else { return .ignored }
        guard case .selection(let range)? = selectionBinding.wrappedValue?.indices ?? .selection(block.text.endIndex..<block.text.endIndex),
              range.isEmpty
        else { return .ignored }
        let offset = block.text.distance(from: block.text.startIndex, to: range.lowerBound)
        if direction < 0, offset == 0 {
            onNavigate(-1, Int.max)
            return .handled
        }
        if direction > 0, offset >= block.text.count {
            onNavigate(1, 0)
            return .handled
        }
        return .ignored
    }

    /// Texto tras "/" cuando el menú de comandos está abierto.
    private var slashQuery: String? {
        guard block.type == .paragraph, block.text.hasPrefix("/") else { return nil }
        let rest = block.text.dropFirst()
        return rest.contains(" ") ? nil : String(rest)
    }

    private var slashMatches: [BlockType] {
        guard let query = slashQuery else { return [] }
        let all = BlockType.allCases
        guard !query.isEmpty else { return all }
        return all.filter { type in
            let words = type.displayName.split(separator: " ").map(String.init) + [type.rawValue]
            return words.contains { $0.range(of: query, options: [.anchored, .caseInsensitive]) != nil }
        }
    }

    private var selectedSlashType: BlockType? {
        let matches = slashMatches
        guard !matches.isEmpty else { return nil }
        return matches[min(slashIndex, matches.count - 1)]
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 4) {

            HStack(
                alignment: .top,
                spacing: 8
            ) {

                blockMenu

                blockContent
            }
            .padding(.vertical, blockPadding)
            .padding(.horizontal, isSelected ? 6 : 0)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.accentColor.opacity(isSelected ? 0.15 : 0))
            )

            if slashQuery != nil {
                slashPanel
                    .padding(.leading, 30)
            }
        }
    }

    // MARK: - Menú del bloque

    private var blockMenu: some View {
        Menu {
            Menu {
                ForEach(BlockType.allCases) { type in
                    Button {
                        apply(type)
                    } label: {
                        Label(type.displayName, systemImage: type.icon)
                    }
                }
            } label: {
                Label("Turn into", systemImage: "arrow.triangle.2.circlepath")
            }

            Menu {
                ForEach(BlockType.allCases) { type in
                    Button {
                        onAddBlock(type)
                    } label: {
                        Label(type.displayName, systemImage: type.icon)
                    }
                }
            } label: {
                Label("Insert below", systemImage: "plus.rectangle.on.rectangle")
            }

            if let onSelect {
                Button {
                    onSelect()
                } label: {
                    Label("Select", systemImage: "checkmark.circle")
                }
            }

            if let onMove {
                Button { onMove(-1) } label: {
                    Label("Move up", systemImage: "arrow.up")
                }
                Button { onMove(1) } label: {
                    Label("Move down", systemImage: "arrow.down")
                }
            }

            if let onDuplicate {
                Button { onDuplicate() } label: {
                    Label("Duplicate", systemImage: "plus.square.on.square")
                }
            }

            if let onDelete {
                Divider()
                Button(role: .destructive) { onDelete() } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        } label: {
            Image(systemName: onDelete == nil ? "plus" : "ellipsis")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .frame(width: 22, height: 28)
                .contentShape(Rectangle())
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .fixedSize()
    }

    /// Cambia el tipo del bloque; dibujo y separador no tienen texto,
    /// así que se convierten y se deja un párrafo debajo para seguir escribiendo.
    private func apply(_ type: BlockType) {
        let hadSlash = slashQuery != nil
        if hadSlash { block.text = "" }
        block.type = type
        if type == .drawing || type == .divider {
            block.text = ""
            onAddBlock(.paragraph)
        }
    }

    // MARK: - Menú "/"

    private var slashPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            if slashMatches.isEmpty {
                Text("No results")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(12)
            } else {
                ForEach(Array(slashMatches.enumerated()), id: \.element.id) { index, type in
                    Button {
                        apply(type)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: type.icon)
                                .frame(width: 22)
                                .foregroundStyle(.secondary)
                            Text(type.displayName)
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(type == selectedSlashType ? Color.accentColor.opacity(0.15) : .clear)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: 260, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.2))
        )
        .shadow(color: .black.opacity(0.08), radius: 8, y: 3)
    }

    @ViewBuilder
    private var blockContent: some View {

        switch block.type {

        case .paragraph:

            textField(
                placeholder: "Type '/' for commands",
                font: .body
            )

        case .heading1:

            textField(
                placeholder: "Heading 1",
                font: .largeTitle.bold()
            )

        case .heading2:

            textField(
                placeholder: "Heading 2",
                font: .title.bold()
            )

        case .heading3:

            textField(
                placeholder: "Heading 3",
                font: .title2.bold()
            )

        case .bullet:

            HStack(
                alignment: .firstTextBaseline,
                spacing: 10
            ) {

                Text("•")
                    .font(.title3)

                textField(
                    placeholder: "List item",
                    font: .body
                )
            }

        case .checklist:

            HStack(
                alignment: .firstTextBaseline,
                spacing: 10
            ) {

                Button {
                    block.isChecked.toggle()
                } label: {

                    Image(
                        systemName:
                            block.isChecked
                        ? "checkmark.square.fill"
                        : "square"
                    )
                }
                .buttonStyle(.plain)

                textField(
                    placeholder: "To-do",
                    font: .body
                )
                .strikethrough(
                    block.isChecked
                )
            }

        case .quote:

            HStack(
                alignment: .top,
                spacing: 12
            ) {

                RoundedRectangle(
                    cornerRadius: 1
                )
                .frame(
                    width: 3
                )

                textField(
                    placeholder: "Quote",
                    font: .body.italic()
                )
            }

        case .code:

            textField(
                placeholder: "Code",
                font: .system(
                    .body,
                    design: .monospaced
                )
            )
            .padding(10)
            .background(
                Color.secondary.opacity(0.08)
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 8
                )
            )

        case .divider:

            Divider()
                .padding(.vertical, 10)

        case .drawing:

            VStack(
                alignment: .leading,
                spacing: 8
            ) {

                HStack {

                    Label(
                        "Drawing",
                        systemImage: "pencil.tip"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    Spacer()
                }

                PencilDrawingView(
                    drawingData: $block.drawingData
                )
                .frame(minHeight: 320)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 12
                    )
                )
                .overlay {

                    RoundedRectangle(
                        cornerRadius: 12
                    )
                    .stroke(
                        Color.secondary.opacity(0.2)
                    )
                }
            }
        }
    }

    private func textField(
        placeholder: String,
        font: Font
    ) -> some View {

        TextField(
            placeholder,
            text: $block.text,
            selection: selectionBinding,
            axis: .vertical
        )
        .font(font)
        .textFieldStyle(.plain)
        .focused(
            focusedBlockID,
            equals: block.id
        )
        .onSubmit {
            if let chosen = selectedSlashType {
                apply(chosen)
            } else {
                onSubmit("")
            }
        }
        .onChange(of: block.text) { _, text in
            if let split = DocumentBlock.splitOnReturn(text) {
                block.text = split.kept
                if let chosen = selectedSlashType {
                    apply(chosen)
                } else {
                    onSubmit(split.remainder)
                }
                return
            }

            onChange()
        }
        .onChange(of: slashQuery) { slashIndex = 0 }
        .onKeyPress(.delete) {
            guard block.text.isEmpty, let onBackspaceEmpty else { return .ignored }
            onBackspaceEmpty()
            return .handled
        }
        .onKeyPress(.upArrow) { handleVertical(-1) }
        .onKeyPress(.downArrow) { handleVertical(1) }
        .onKeyPress(.leftArrow) { handleHorizontal(-1) }
        .onKeyPress(.rightArrow) { handleHorizontal(1) }
        .onKeyPress(.escape) {
            guard slashQuery != nil else { return .ignored }
            block.text = ""
            return .handled
        }
    }

    private var blockPadding: CGFloat {

        switch block.type {
        case .heading1: 8
        case .heading2: 6
        case .heading3: 5
        case .drawing: 10
        default: 2
        }
    }
}
