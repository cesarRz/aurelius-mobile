import Foundation

extension WorkspaceStore {

    @discardableResult
    func addDocument(name: String = "") -> UUID {
        let document = WorkspaceDocument(
            name: name,
            blocks: [DocumentBlock()]
        )
        docs.insert(document, at: 0)
        return document.id
    }

    @discardableResult
    func addNote(name: String = "") -> UUID {
        let note = WorkspaceNote(
            name: name,
            blocks: [DocumentBlock()]
        )
        notes.insert(note, at: 0)
        return note.id
    }

    func addBlock(
        toDocument documentID: UUID,
        after blockID: UUID?,
        type: BlockType = .paragraph,
        text: String = ""
    ) -> UUID? {

        guard let documentIndex = docs.firstIndex(where: {
            $0.id == documentID
        }) else {
            return nil
        }

        let block = DocumentBlock(type: type, text: text)

        if let blockID,
           let currentIndex = docs[documentIndex]
            .blocks
            .firstIndex(where: { $0.id == blockID }) {

            docs[documentIndex].blocks.insert(
                block,
                at: currentIndex + 1
            )

        } else {
            docs[documentIndex].blocks.append(block)
        }

        return block.id
    }

    func addBlock(
        toNote noteID: UUID,
        after blockID: UUID?,
        type: BlockType = .paragraph,
        text: String = ""
    ) -> UUID? {

        guard let noteIndex = notes.firstIndex(where: {
            $0.id == noteID
        }) else {
            return nil
        }

        let block = DocumentBlock(type: type, text: text)

        if let blockID,
           let currentIndex = notes[noteIndex]
            .blocks
            .firstIndex(where: { $0.id == blockID }) {

            notes[noteIndex].blocks.insert(
                block,
                at: currentIndex + 1
            )
        } else {
            notes[noteIndex].blocks.append(block)
        }

        return block.id
    }

    func interpretDocumentSyntax(
        documentID: UUID,
        blockID: UUID
    ) {
        guard
            let documentIndex = docs.firstIndex(where: {
                $0.id == documentID
            }),
            let blockIndex = docs[documentIndex]
                .blocks
                .firstIndex(where: {
                    $0.id == blockID
                })
        else {
            return
        }

        interpret(
            block: &docs[documentIndex].blocks[blockIndex]
        )
    }

    func interpretNoteSyntax(
        noteID: UUID,
        blockID: UUID
    ) {
        guard
            let noteIndex = notes.firstIndex(where: {
                $0.id == noteID
            }),
            let blockIndex = notes[noteIndex]
                .blocks
                .firstIndex(where: {
                    $0.id == blockID
                })
        else {
            return
        }

        interpret(
            block: &notes[noteIndex].blocks[blockIndex]
        )
    }

    private func interpret(
        block: inout DocumentBlock
    ) {
        let text = block.text

        if text.hasPrefix("### ") {
            block.type = .heading3
            block.text.removeFirst(4)

        } else if text.hasPrefix("## ") {
            block.type = .heading2
            block.text.removeFirst(3)

        } else if text.hasPrefix("# ") {
            block.type = .heading1
            block.text.removeFirst(2)

        } else if text.hasPrefix("- [ ] ") {
            block.type = .checklist
            block.text.removeFirst(6)

        } else if text.hasPrefix("[] ") {
            block.type = .checklist
            block.text.removeFirst(3)

        } else if text.hasPrefix("- ") {
            block.type = .bullet
            block.text.removeFirst(2)

        } else if text.hasPrefix("> ") {
            block.type = .quote
            block.text.removeFirst(2)

        } else if text.hasPrefix("` ") {
            block.type = .code
            block.text.removeFirst(2)
        }
    }
}
