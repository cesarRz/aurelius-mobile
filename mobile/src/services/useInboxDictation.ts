/**
 * Voice capture for Inbox — replaces Swift Speech + AVAudioEngine.
 * Uses expo-speech-recognition (Apple Speech / Android SpeechRecognizer).
 */
import {
  ExpoSpeechRecognitionModule,
  useSpeechRecognitionEvent,
} from "expo-speech-recognition";
import { useCallback, useRef, useState } from "react";

const LEVEL_SLOTS = 7;

export function useInboxDictation() {
  const [isRecording, setIsRecording] = useState(false);
  const [isStarting, setIsStarting] = useState(false);
  const [transcript, setTranscript] = useState("");
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [audioLevels, setAudioLevels] = useState<number[]>(() =>
    Array.from({ length: LEVEL_SLOTS }, () => 0),
  );
  const sessionRef = useRef(0);

  useSpeechRecognitionEvent("result", (event) => {
    const text = event.results[0]?.transcript;
    if (text) {
      setTranscript(text);
    }
    if (event.isFinal) {
      setIsRecording(false);
      setIsStarting(false);
    }
  });

  useSpeechRecognitionEvent("error", () => {
    setErrorMessage("Dictation ended. Review the captured text or try again.");
    setIsRecording(false);
    setIsStarting(false);
  });

  useSpeechRecognitionEvent("volumechange", (event) => {
    const normalized = Math.min(1, Math.max(0, ((event.value ?? 0) + 2) / 12));
    setAudioLevels((prev) => [...prev.slice(1), normalized]);
  });

  const stop = useCallback(() => {
    sessionRef.current += 1;
    ExpoSpeechRecognitionModule.stop();
    setIsRecording(false);
    setIsStarting(false);
    setAudioLevels(Array.from({ length: LEVEL_SLOTS }, () => 0));
  }, []);

  const start = useCallback(async () => {
    if (isRecording || isStarting) {
      return;
    }
    const session = sessionRef.current + 1;
    sessionRef.current = session;
    stop();
    sessionRef.current = session;
    setIsStarting(true);
    setTranscript("");
    setErrorMessage(null);

    const permission = await ExpoSpeechRecognitionModule.requestPermissionsAsync();
    if (sessionRef.current !== session) {
      return;
    }
    if (!permission.granted) {
      setErrorMessage("Allow speech recognition in Settings to use voice capture.");
      setIsStarting(false);
      return;
    }

    try {
      ExpoSpeechRecognitionModule.start({
        lang: undefined,
        interimResults: true,
        continuous: true,
        volumeChangeEventOptions: { enabled: true, intervalMillis: 50 },
      });
      if (sessionRef.current !== session) {
        return;
      }
      setIsStarting(false);
      setIsRecording(true);
    } catch {
      setErrorMessage("Could not start dictation. Try again or type your idea.");
      setIsStarting(false);
    }
  }, [isRecording, isStarting, stop]);

  return {
    isRecording,
    isStarting,
    transcript,
    errorMessage,
    audioLevels,
    start,
    stop,
  };
}
