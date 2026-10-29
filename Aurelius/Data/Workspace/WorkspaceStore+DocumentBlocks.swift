import Foundation

extension WorkspaceStore {

    /// Elimina un bloque y devuelve el id del bloque al que debe volver el cursor
    /// (el anterior, o el siguiente si era el primero).
    @discardableResult
    func deleteBlock(fromDocument documentID: UUID, blockID: UUID) -> UUID? {
        guard let d = docs.firstIndex(where: { $0.id == documentID }),
              let b = docs[d].blocks.firstIndex(where: { $0.id == blockID })
        else { return nil }

        docs[d].blocks.remove(at: b)

        if docs[d].blocks.isEmpty {
            let fresh = DocumentBlock()
            docs[d].blocks = [fresh]
            return fresh.id
        }

        let target = b > 0 ? b - 1 : 0
        return docs[d].blocks[target].id
    }

    /// Mueve un bloque `offset` posiciones (-1 sube, +1 baja).
    func moveBlock(inDocument documentID: UUID, blockID: UUID, by offset: Int) {
        guard let d = docs.firstIndex(where: { $0.id == documentID }),
              let b = docs[d].blocks.firstIndex(where: { $0.id == blockID })
        else { return }
        let target = b + offset
        guard docs[d].blocks.indices.contains(target) else { return }
        docs[d].blocks.swapAt(b, target)
    }

    @discardableResult
    func duplicateBlock(inDocument documentID: UUID, blockID: UUID) -> UUID? {
        guard let d = docs.firstIndex(where: { $0.id == documentID }),
              let b = docs[d].blocks.firstIndex(where: { $0.id == blockID })
        else { return nil }
        let source = docs[d].blocks[b]
        let copy = DocumentBlock(
            type: source.type,
            text: source.text,
            isChecked: source.isChecked,
            drawingData: source.drawingData
        )
        docs[d].blocks.insert(copy, at: b + 1)
        return copy.id
    }

    @discardableResult
    func duplicateDocument(_ documentID: UUID) -> UUID? {
        guard let d = docs.firstIndex(where: { $0.id == documentID }) else { return nil }
        let source = docs[d]
        let copy = WorkspaceDocument(
            name: source.name.isEmpty ? "" : "\(source.name) copy",
            initiativeID: source.initiativeID,
            outcomeID: source.outcomeID,
            blocks: source.blocks.map {
                DocumentBlock(
                    type: $0.type,
                    text: $0.text,
                    isChecked: $0.isChecked,
                    drawingData: $0.drawingData
                )
            }
        )
        docs.insert(copy, at: d + 1)
        return copy.id
    }

    func deleteDocument(_ documentID: UUID) {
        docs.removeAll { $0.id == documentID }
    }
}
