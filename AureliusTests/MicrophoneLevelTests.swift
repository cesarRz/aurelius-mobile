import AVFoundation
import Testing
@testable import Aurelius

struct MicrophoneLevelTests {
    @Test func measuresSilenceAndIncreasingAudioEnergy() throws {
        let format = try #require(AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1))
        let buffer = try #require(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 128))
        buffer.frameLength = 128
        let samples = try #require(buffer.floatChannelData)[0]
        for index in 0..<128 { samples[index] = 0 }
        #expect(MicrophoneLevel.measure(buffer) == 0)
        for index in 0..<128 { samples[index] = index.isMultiple(of: 2) ? 0.01 : -0.01 }
        let quiet = MicrophoneLevel.measure(buffer)
        for index in 0..<128 { samples[index] = index.isMultiple(of: 2) ? 0.1 : -0.1 }
        let loud = MicrophoneLevel.measure(buffer)
        #expect(quiet > 0 && loud > quiet && loud <= 1)
        #expect(MicrophoneLevel.normalized(rms: 1) == 1)
        buffer.frameLength = 0
        #expect(MicrophoneLevel.measure(buffer) == 0)
    }
}
