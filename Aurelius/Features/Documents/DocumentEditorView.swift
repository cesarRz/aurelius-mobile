import SwiftUI

struct DocumentEditorView: View {

    @Environment(WorkspaceStore.self)
    private var store

    let documentID: UUID

    @FocusState
    private var focusedBlockID: UUID?

    @FocusState
    private var listFocused: Bool

    @State
    private var selectedBlockID: UUID?

    /// Borra un bloque y deja el cursor en el anterior.
    private func deleteBlock(_ id: UUID) {
        let previous = store.deleteBlock(fromDocument: documentID, blockID: id)
        selectedBlockID = nil
        DispatchQueue.main.async {
            focusedBlockID = previous
        }
    }

    @State
    private var selections: [UUID: TextSelection] = [:]

    private func selectionBinding(for id: UUID) -> Binding<TextSelection?> {
        Binding(
            get: { selections[id] },
            set: { selections[id] = $0 }
        )
    }

    /// Mueve el cursor al bloque vecino conservando la columna, como en un editor de texto.
    /// `column`: `Int.max` = final de la línea de destino, `0` = inicio.
    private func navigate(from id: UUID, direction: Int, column: Int) {
        guard let documentIndex,
              let current = store.docs[documentIndex].blocks.firstIndex(where: { $0.id == id })
        else { return }
        let blocks = store.docs[documentIndex].blocks
        var target = current + direction
        while blocks.indices.contains(target),
              blocks[target].type == .divider || blocks[target].type == .drawing {
            target += direction
        }
        guard blocks.indices.contains(target) else { return }

        let block = blocks[target]
        let lines = block.text.split(separator: "\n", omittingEmptySubsequences: false)
        let characters = Array(block.text)
        let offset: Int
        if direction < 0 {
            let lastLine = lines.last.map(String.init) ?? ""
            let lineStart = characters.count - lastLine.count
            offset = lineStart + min(column, lastLine.count)
        } else {
            let firstLine = lines.first.map(String.init) ?? ""
            offset = min(column, firstLine.count)
        }
        focus(block.id, offset: offset)
    }

    private func focus(_ id: UUID, offset: Int) {
        guard let documentIndex,
              let block = store.docs[documentIndex].blocks.first(where: { $0.id == id })
        else { return }

        let text = block.text
        let clamped = min(max(offset, 0), text.count)
        let index = text.index(text.startIndex, offsetBy: clamped)
        let caret = TextSelection(insertionPoint: index)

        // La selección se fija antes de dar foco para que el cursor nazca en su sitio;
        // se repite en el siguiente ciclo por si el foco la reinicia.
        selectedBlockID = nil
        selections[id] = caret
        focusedBlockID = id
        DispatchQueue.main.async {
            if selections[id] != caret { selections[id] = caret }
        }
    }

    /// Posición actual del cursor en el bloque enfocado (para los botones del teclado en iPhone).
    private func currentColumn(of id: UUID) -> Int {
        guard let documentIndex,
              let block = store.docs[documentIndex].blocks.first(where: { $0.id == id }),
              case .selection(let range)? = selections[id]?.indices
        else { return 0 }
        let before = block.text[..<range.lowerBound]
        let lineStart = before.lastIndex(of: "\n").map { before.index(after: $0) } ?? before.startIndex
        return before.distance(from: lineStart, to: before.endIndex)
    }

    private func select(_ id: UUID) {
        focusedBlockID = nil
        selectedBlockID = id
        listFocused = true
    }

    private var documentIndex: Int? {
        store.docs.firstIndex {
            $0.id == documentID
        }
    }

    var body: some View {

        if let documentIndex {

            @Bindable var store = store

            ScrollView {

                VStack(
                    alignment: .leading,
                    spacing: 6
                ) {

                    TextField(
                        "Untitled",
                        text: $store.docs[documentIndex].name
                    )
                    .font(.largeTitle.bold())
                    .textFieldStyle(.plain)
                    .padding(.bottom, 16)

                    ForEach(
                        $store.docs[documentIndex].blocks
                    ) { $block in

                        BlockEditorRow(
                            block: $block,
                            focusedBlockID: $focusedBlockID,
                            onChange: {
                                store.interpretDocumentSyntax(
                                    documentID: documentID,
                                    blockID: block.id
                                )
                            },
                            onSubmit: { remainder in
                                let newID = store.addBlock(
                                    toDocument: documentID,
                                    after: block.id,
                                    type: block.typeAfterReturn,
                                    text: remainder
                                )

                                DispatchQueue.main.async {
                                    focusedBlockID = newID
                                }
                            },
                            onAddBlock: { type in

                                let newID =
                                store.addBlock(
                                    toDocument: documentID,
                                    after: block.id,
                                    type: type
                                )

                                DispatchQueue.main.async {
                                    focusedBlockID = newID
                                }
                            },
                            isSelected: selectedBlockID == block.id,
                            onSelect: { select(block.id) },
                            onDelete: { deleteBlock(block.id) },
                            onDuplicate: {
                                let newID = store.duplicateBlock(
                                    inDocument: documentID,
                                    blockID: block.id
                                )
                                DispatchQueue.main.async {
                                    focusedBlockID = newID
                                }
                            },
                            onMove: { offset in
                                store.moveBlock(
                                    inDocument: documentID,
                                    blockID: block.id,
                                    by: offset
                                )
                            },
                            onBackspaceEmpty: { deleteBlock(block.id) },
                            onNavigate: { direction, column in
                                navigate(from: block.id, direction: direction, column: column)
                            },
                            externalSelection: selectionBinding(for: block.id)
                        )
                    }
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 28)
                .frame(
                    maxWidth: 850,
                    alignment: .leading
                )
            }
            .focusable()
            .focused($listFocused)
            .focusEffectDisabled()
            .onKeyPress(.delete) {
                guard let id = selectedBlockID else { return .ignored }
                deleteBlock(id)
                return .handled
            }
            .onKeyPress(.deleteForward) {
                guard let id = selectedBlockID else { return .ignored }
                deleteBlock(id)
                return .handled
            }
            .onKeyPress(.escape) {
                guard selectedBlockID != nil else { return .ignored }
                selectedBlockID = nil
                return .handled
            }
            #if os(iOS)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button {
                        if let id = focusedBlockID {
                            navigate(from: id, direction: -1, column: currentColumn(of: id))
                        }
                    } label: {
                        Image(systemName: "chevron.up")
                    }
                    Button {
                        if let id = focusedBlockID {
                            navigate(from: id, direction: 1, column: currentColumn(of: id))
                        }
                    } label: {
                        Image(systemName: "chevron.down")
                    }
                    Button(role: .destructive) {
                        if let id = focusedBlockID { deleteBlock(id) }
                    } label: {
                        Image(systemName: "trash")
                    }
                    Spacer()
                    Button("Done") { focusedBlockID = nil }
                }
            }
            #endif
            .onChange(of: focusedBlockID) { _, id in
                if id != nil { selectedBlockID = nil }
            }
            .navigationTitle(
                store.docs[documentIndex].name
            )
            .inlineNavigationTitle()

        } else {

            ContentUnavailableView(
                "Document not found",
                systemImage: "doc.text"
            )
        }
    }
}
