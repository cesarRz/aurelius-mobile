import { Typography } from "heroui-native";
import { Link } from "expo-router";
import type { JSX } from "react";
import { ScrollView, View } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";

import { InboxCapturePanel } from "@/components/inbox/InboxCapturePanel";
import { useWorkspaceStore } from "@/store/workspaceStore";

export default function MoreTab(): JSX.Element {
  const notes = useWorkspaceStore((s) => s.notes);
  const threads = useWorkspaceStore((s) => s.threads);

  return (
    <SafeAreaView className="flex-1 bg-background" edges={["top"]}>
      <ScrollView contentContainerClassName="p-4 gap-6">
        <Typography.Heading>More</Typography.Heading>

        <Link href="/inbox" asChild>
          <Typography.Paragraph className="text-accent">Full inbox screen</Typography.Paragraph>
        </Link>

        <InboxCapturePanel />

        <View className="gap-2">
          <Typography.Heading className="text-base">Notes</Typography.Heading>
          {notes.map((note) => (
            <Typography.Paragraph key={note.id}>{note.name || "Untitled note"}</Typography.Paragraph>
          ))}
        </View>

        <View className="gap-2">
          <Typography.Heading className="text-base">Threads</Typography.Heading>
          {threads.map((thread) => (
            <View key={thread.id} className="gap-1 py-2 border-b border-default-100">
              <Typography.Paragraph className="font-medium">{thread.name}</Typography.Paragraph>
              <Typography.Paragraph className="text-sm text-default-500">
                {thread.detail}
              </Typography.Paragraph>
            </View>
          ))}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}
