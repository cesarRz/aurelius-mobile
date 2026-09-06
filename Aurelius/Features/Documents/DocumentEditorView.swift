import SwiftUI

struct DocumentEditorView: View {

    @Environment(WorkspaceStore.self)
    private var store

    let documentID: UUID

    @FocusState
    private var focusedBlockID: UUID?

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
                            }
                        )
                    }

                    Button {

                        let newID = store.addBlock(
                            toDocument: documentID,
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
                store.docs[documentIndex].name
            )
            .navigationBarTitleDisplayMode(.inline)

        } else {

            ContentUnavailableView(
                "Document not found",
                systemImage: "doc.text"
            )
        }
    }
}
