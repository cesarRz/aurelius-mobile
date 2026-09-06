import AVFoundation

/// Normalized RMS energy: silence below -55 dBFS is zero; -5 dBFS is full scale.
enum MicrophoneLevel {
    nonisolated static func normalized(rms: Float) -> Double {
        guard rms.isFinite, rms > 0 else { return 0 }
        let decibels = 20 * log10(Double(rms))
        return min(1, max(0, (decibels + 55) / 50))
    }

    nonisolated static func measure(_ buffer: AVAudioPCMBuffer) -> Double {
        guard let channels = buffer.floatChannelData, buffer.frameLength > 0 else { return 0 }
        let frames = Int(buffer.frameLength)
        var energy: Float = 0
        let samples = channels[0]
        for index in 0..<frames {
            let sample = samples[index * buffer.stride]
            energy += sample * sample
        }
        return normalized(rms: sqrt(energy / Float(frames)))
    }
}
