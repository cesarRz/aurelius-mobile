import SwiftUI

struct BlockEditorRow: View {

    @Binding var block: DocumentBlock

    var focusedBlockID: FocusState<UUID?>.Binding

    let onChange: () -> Void
    let onSubmit: (String) -> Void
    let onAddBlock: (BlockType) -> Void

    @State private var showBlockMenu = false

    var body: some View {

        HStack(
            alignment: .top,
            spacing: 8
        ) {

            Menu {

                ForEach(BlockType.allCases) { type in

                    Button {

                        if type == .drawing ||
                            type == .divider {

                            onAddBlock(type)

                        } else {

                            block.type = type
                        }

                    } label: {

                        Label(
                            type.displayName,
                            systemImage: type.icon
                        )
                    }
                }

            } label: {

                Image(systemName: "plus")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .frame(
                        width: 22,
                        height: 28
                    )
            }
            .buttonStyle(.plain)

            blockContent
        }
        .padding(.vertical, blockPadding)
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
            axis: .vertical
        )
        .font(font)
        .textFieldStyle(.plain)
        .focused(
            focusedBlockID,
            equals: block.id
        )
        .onSubmit {
            onSubmit("")
        }
        .onChange(of: block.text) { _, text in
            if let split = DocumentBlock.splitOnReturn(text) {
                block.text = split.kept
                onSubmit(split.remainder)
                return
            }

            if text == "/" {
                block.text = ""
                showBlockMenu = true
            }

            onChange()
        }
        .confirmationDialog(
            "Insert Block",
            isPresented: $showBlockMenu,
            titleVisibility: .visible
        ) {

            Button("Heading 1") {
                block.type = .heading1
            }

            Button("Heading 2") {
                block.type = .heading2
            }

            Button("Heading 3") {
                block.type = .heading3
            }

            Button("Checklist") {
                block.type = .checklist
            }

            Button("Bullet List") {
                block.type = .bullet
            }

            Button("Quote") {
                block.type = .quote
            }

            Button("Code") {
                block.type = .code
            }

            Button("Drawing") {
                onAddBlock(.drawing)
            }

            Button("Divider") {
                onAddBlock(.divider)
            }

            Button("Cancel", role: .cancel) {}
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
