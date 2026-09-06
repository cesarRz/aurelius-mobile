import SwiftUI

struct QuickCaptureComposer: View {
    @Environment(WorkspaceStore.self) private var store
    @Environment(QuickCaptureController.self) private var capture
    @Environment(\.scenePhase) private var scenePhase

    @State private var text = ""
    @State private var dictation = InboxDictation()
    @State private var textBeforeDictation = ""
    @State private var source: InboxEntry.Source = .text
    @FocusState private var isFocused: Bool

    private var isDictating: Bool { dictation.isRecording || dictation.isStarting }

    private var canSubmit: Bool {
        !isDictating && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if dictation.isRecording {
                InboxVoiceActivity(levels: dictation.audioLevels)
            } else if dictation.isStarting {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Preparing…")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            TextField(capture.kind.placeholder, text: $text, axis: .vertical)
                .font(.title3.weight(.medium))
                .focused($isFocused)
                .lineLimit(1...4)
                .submitLabel(.send)
                .disabled(isDictating)
                .accessibilityLabel(capture.kind.placeholder)
                .onSubmit(submit)

            if let error = dictation.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            HStack(spacing: 12) {
                destinationMenu

                Spacer(minLength: 0)

                Button(action: canSubmit ? submit : toggleDictation) {
                    Image(systemName: trailingIcon)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(trailingForeground)
                        .frame(width: 44, height: 44)
                        .background(trailingBackground, in: Circle())
                }
                .accessibilityLabel(trailingAccessibilityLabel)
                .disabled(isDictating && dictation.isStarting)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .background(alignment: .top) {
            GeometryReader { geo in
                VStack(spacing: 0) {
                    UnevenRoundedRectangle(
                        topLeadingRadius: 22,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 22,
                        style: .continuous
                    )
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
                    .frame(height: geo.size.height)
                    Color(uiColor: .secondarySystemGroupedBackground)
                        .frame(height: 500)
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .onAppear { isFocused = capture.wantsFocus }
        .onChange(of: capture.wantsFocus) { _, wants in
            let wasFocused = isFocused
            isFocused = wants
            if !wants, capture.isDismissing, !wasFocused {
                capture.finishClose()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)) { _ in
            guard !isDictating else { return }
            capture.handleKeyboardDidHide()
        }
        .onChange(of: dictation.transcript) { _, transcript in
            guard !transcript.isEmpty else { return }
            text = [textBeforeDictation, transcript].filter { !$0.isEmpty }.joined(separator: " ")
            source = .voice
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background { dictation.stop() }
        }
        .onDisappear { dictation.stop() }
    }

    private var destinationMenu: some View {
        Menu {
            ForEach(QuickCaptureKind.allCases) { kind in
                Button {
                    capture.kind = kind
                } label: {
                    Label(kind.title, systemImage: kind.icon)
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: capture.kind.icon)
                Text(capture.kind.title)
                    .fontWeight(.semibold)
                Image(systemName: "chevron.down")
                    .font(.caption2.weight(.semibold))
            }
            .font(.subheadline)
            .foregroundStyle(.primary)
            .padding(.horizontal, 12)
            .frame(minHeight: 44)
            .background(Color.primary.opacity(0.06), in: Capsule())
        }
        .accessibilityLabel("Capture as \(capture.kind.title)")
        .accessibilityHint("Choose Inbox, Area, Initiative, or Outcome")
    }

    private var trailingIcon: String {
        if isDictating { return dictation.isRecording ? "stop.fill" : "mic" }
        if canSubmit { return "arrow.up" }
        return "mic"
    }

    private var trailingForeground: Color {
        if dictation.isRecording { return .white }
        if canSubmit { return Color(uiColor: .systemBackground) }
        return .primary
    }

    private var trailingBackground: Color {
        if dictation.isRecording { return .red }
        if canSubmit { return Color.accentColor }
        return Color.primary.opacity(0.08)
    }

    private var trailingAccessibilityLabel: String {
        if dictation.isRecording { return "Stop dictation" }
        if dictation.isStarting { return "Starting dictation" }
        if canSubmit { return "Save \(capture.kind.title.lowercased())" }
        return "Capture by voice"
    }

    private func toggleDictation() {
        isFocused = false
        if isDictating {
            dictation.stop()
            isFocused = true
        } else {
            textBeforeDictation = text
            Task { await dictation.start() }
        }
    }

    private func submit() {
        guard store.submitQuickCapture(text, kind: capture.kind, source: source) else { return }
        dictation.stop()
        capture.close()
    }
}

struct QuickCapturePresentation: ViewModifier {
    @Environment(QuickCaptureController.self) private var capture

    func body(content: Content) -> some View {
        content
            .overlay {
                if capture.isPresented {
                    Color.black.opacity(0.28)
                        .ignoresSafeArea()
                        .onTapGesture { capture.close() }
                }
            }
            .overlay(alignment: .bottom) {
                if capture.isPresented {
                    QuickCaptureComposer()
                }
            }
    }
}
