import AVFoundation
import Observation
import Speech

@MainActor
@Observable
final class InboxDictation {
    private(set) var isRecording = false
    private(set) var isStarting = false
    private(set) var transcript = ""
    var errorMessage: String?
    private(set) var audioLevels = Array(repeating: 0.0, count: 7)
    @ObservationIgnored private var lastLevelUpdate = Date.distantPast

    @ObservationIgnored private let engine = AVAudioEngine()
    @ObservationIgnored private var recognitionTask: SFSpeechRecognitionTask?
    @ObservationIgnored private var request: SFSpeechAudioBufferRecognitionRequest?
    @ObservationIgnored private var hasTap = false
    @ObservationIgnored private var sessionID = UUID()

    func start() async {
        guard !isRecording && !isStarting else { return }
        stop()
        let id = UUID()
        sessionID = id
        isStarting = true
        transcript = ""
        errorMessage = nil

        let authorization = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        guard sessionID == id else { return }
        guard authorization == .authorized else {
            fail("Allow speech recognition in Settings to use voice capture.")
            return
        }
        let microphoneAllowed = await AVAudioApplication.requestRecordPermission()
        guard sessionID == id else { return }
        guard microphoneAllowed else {
            fail("Allow microphone access in Settings to use voice capture.")
            return
        }
        guard let recognizer = SFSpeechRecognizer(locale: .current), recognizer.isAvailable else {
            fail("Voice recognition is unavailable. Try again later or type your idea.")
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true)
            let input = engine.inputNode
            let format = input.outputFormat(forBus: 0)
            guard format.sampleRate > 0, format.channelCount > 0 else {
                fail("No microphone is available. You can still type your idea.")
                return
            }
            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true
            self.request = request
            input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
                request.append(buffer)
                let level = MicrophoneLevel.measure(buffer)
                Task { @MainActor [weak self] in
                    guard let self, self.sessionID == id, self.isRecording else { return }
                    let now = Date.now
                    guard now.timeIntervalSince(self.lastLevelUpdate) >= 0.05 else { return }
                    self.lastLevelUpdate = now
                    self.audioLevels.removeFirst()
                    self.audioLevels.append(level)
                }
            }
            hasTap = true
            recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
                let text = result?.bestTranscription.formattedString
                let final = result?.isFinal ?? false
                let failed = error != nil
                Task { @MainActor [weak self] in
                    guard let self, self.sessionID == id else { return }
                    if let text { self.transcript = text }
                    if final || failed {
                        if failed { self.errorMessage = "Dictation ended. Review the captured text or try again." }
                        self.stop()
                    }
                }
            }
            engine.prepare()
            try engine.start()
            isStarting = false
            isRecording = true
        } catch {
            fail("Could not start dictation. Try again or type your idea.")
        }
    }

    /// Keeps the latest visible transcription available for review.
    func stop() {
        sessionID = UUID()
        engine.stop()
        if hasTap {
            engine.inputNode.removeTap(onBus: 0)
            hasTap = false
        }
        request?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        request = nil
        isRecording = false
        isStarting = false
        audioLevels = Array(repeating: 0, count: 7)
        lastLevelUpdate = .distantPast
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func fail(_ message: String) {
        errorMessage = message
        stop()
    }
}
