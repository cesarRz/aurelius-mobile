import SwiftUI

struct NoteEditorView: View {

    @Environment(WorkspaceStore.self)
    private var store

    let noteID: UUID

    @FocusState
    private var focusedBlockID: UUID?

    private var noteIndex: Int? {
        store.notes.firstIndex {
            $0.id == noteID
        }
    }

    var body: some View {

        if let noteIndex {

            @Bindable var store = store

            ScrollView {

                VStack(
                    alignment: .leading,
                    spacing: 6
                ) {

                    TextField(
                        "Untitled",
                        text: $store.notes[noteIndex].name
                    )
                    .font(.largeTitle.bold())
                    .textFieldStyle(.plain)
                    .padding(.bottom, 16)

                    ForEach(
                        $store.notes[noteIndex].blocks
                    ) { $block in

                        BlockEditorRow(
                            block: $block,
                            focusedBlockID: $focusedBlockID,
                            onChange: {
                                store.interpretNoteSyntax(
                                    noteID: noteID,
                                    blockID: block.id
                                )
                            },
                            onSubmit: { remainder in
                                let newID = store.addBlock(
                                    toNote: noteID,
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
                                    toNote: noteID,
                                    after: block.id,
                                    type: type
                                )

                                DispatchQueue.main.async {
                                    focusedBlockID = newID
                                }
                            }
                        )
                    }

                    Button {

                        let newID = store.addBlock(
                            toNote: noteID,
                            after: nil
                        )

                        focusedBlockID = newID

                    } label: {

                        Label(
                            "Add block",
                            systemImage: "plus"
                        )
                        .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 10)
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 28)
                .frame(
                    maxWidth: 850,
                    alignment: .leading
                )
            }
            .navigationTitle(
                store.notes[noteIndex].name
            )
            .inlineNavigationTitle()

        } else {

            ContentUnavailableView(
                "Note not found",
                systemImage: "note.text"
            )
        }
    }
}
