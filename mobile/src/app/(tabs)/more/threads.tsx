import { Typography } from "heroui-native";
import { Stack } from "expo-router";
import type { JSX } from "react";
import { ScrollView, View } from "react-native";

import { useWorkspaceStore } from "@/store/workspaceStore";

export default function ThreadsListScreen(): JSX.Element {
  const threads = useWorkspaceStore((s) => s.threads);

  return (
    <>
      <Stack.Screen options={{ title: "Active Threads" }} />
      <ScrollView contentContainerClassName="p-4 gap-4">
        {threads.map((thread) => (
          <View key={thread.id} className="gap-1 py-2 border-b border-default-100">
            <Typography.Paragraph className="font-semibold">{thread.name}</Typography.Paragraph>
            <Typography.Paragraph className="text-sm text-default-500">{thread.detail}</Typography.Paragraph>
          </View>
        ))}
      </ScrollView>
    </>
  );
}
