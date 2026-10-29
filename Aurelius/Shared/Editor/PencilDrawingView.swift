import SwiftUI

#if os(iOS)
import PencilKit

struct PencilDrawingView: UIViewRepresentable {

    @Binding var drawingData: Data

    func makeCoordinator() -> Coordinator {
        Coordinator(drawingData: $drawingData)
    }

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.delegate = context.coordinator
        canvas.backgroundColor = .systemBackground
        canvas.drawingPolicy = .anyInput

        if !drawingData.isEmpty,
           let drawing = try? PKDrawing(data: drawingData) {
            canvas.drawing = drawing
        }

        context.coordinator.toolPicker
            .setVisible(true, forFirstResponder: canvas)
        context.coordinator.toolPicker.addObserver(canvas)

        DispatchQueue.main.async {
            canvas.becomeFirstResponder()
        }

        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        if !drawingData.isEmpty,
           uiView.drawing.dataRepresentation() != drawingData,
           let drawing = try? PKDrawing(data: drawingData) {
            uiView.drawing = drawing
        }
    }

    final class Coordinator: NSObject, PKCanvasViewDelegate {

        let toolPicker = PKToolPicker()

        @Binding var drawingData: Data

        init(drawingData: Binding<Data>) {
            _drawingData = drawingData
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            drawingData = canvasView.drawing.dataRepresentation()
        }
    }
}
#else
/// PencilKit no existe en macOS nativo: muestra un aviso en lugar del lienzo.
struct PencilDrawingView: View {

    @Binding var drawingData: Data

    var body: some View {
        ContentUnavailableView(
            "Drawing is available on iPad and iPhone",
            systemImage: "pencil.tip.crop.circle.badge.minus"
        )
    }
}
#endif
