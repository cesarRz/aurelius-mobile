import { Button, Card, Typography } from "heroui-native";
import type { JSX } from "react";
import { useState } from "react";
import { TextInput, View } from "react-native";

import { useInboxDictation } from "../../services/useInboxDictation";
import { useWorkspaceStore } from "../../store/workspaceStore";

export function InboxCapturePanel(): JSX.Element {
  const addInboxEntry = useWorkspaceStore((s) => s.addInboxEntry);
  const entries = useWorkspaceStore((s) => s.inboxEntries);
  const dictation = useInboxDictation();
  const [draft, setDraft] = useState("");

  const fieldValue = dictation.isRecording || dictation.isStarting ? dictation.transcript : draft;

  return (
    <View className="gap-4">
      <Card className="gap-3 p-4">
        <Typography.Heading className="text-base">Quick capture</Typography.Heading>
        <Typography.Paragraph className="text-sm text-default-500">
          Voice via expo-speech-recognition (replaces Apple Speech in Swift).
        </Typography.Paragraph>

        <TextInput
          value={fieldValue}
          onChangeText={setDraft}
          editable={!dictation.isRecording && !dictation.isStarting}
          placeholder="Type or dictate an idea…"
          className="border border-default-200 rounded-xl px-3 py-2 text-foreground"
          placeholderTextColor="#9ca3af"
          multiline
        />

        <View className="flex-row gap-2 flex-wrap">
          <Button
            variant={dictation.isRecording ? "danger" : "secondary"}
            onPress={() => (dictation.isRecording ? dictation.stop() : void dictation.start())}
            isDisabled={dictation.isStarting}
          >
            {dictation.isRecording ? "Stop" : "Dictate"}
          </Button>
          <Button
            variant="primary"
            onPress={() => {
              const text = (dictation.transcript || draft).trim();
              if (!text) {
                return;
              }
              addInboxEntry(text);
              setDraft("");
              dictation.stop();
            }}
          >
            Save to Inbox
          </Button>
        </View>

        {dictation.errorMessage ? (
          <Typography.Paragraph className="text-sm text-danger">
            {dictation.errorMessage}
          </Typography.Paragraph>
        ) : null}

        <View className="flex-row items-end gap-1 h-8">
          {dictation.audioLevels.map((level, index) => (
            <View
              key={`level-${index}`}
              className="flex-1 rounded-sm bg-accent"
              style={{ height: 8 + level * 24 }}
            />
          ))}
        </View>
      </Card>

      <View className="gap-2">
        <Typography.Heading className="text-base">Inbox</Typography.Heading>
        {entries.map((entry) => (
          <Card key={entry.id} className="p-3">
            <Typography.Paragraph>{entry.text}</Typography.Paragraph>
          </Card>
        ))}
      </View>
    </View>
  );
}
