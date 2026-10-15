import { Stack } from "expo-router";
import type { JSX } from "react";
import { ScrollView } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";

import { InboxCapturePanel } from "@/components/inbox/InboxCapturePanel";

export default function InboxScreen(): JSX.Element {
  return (
    <SafeAreaView className="flex-1 bg-background">
      <Stack.Screen options={{ title: "Inbox", headerShown: true }} />
      <ScrollView contentContainerClassName="p-4">
        <InboxCapturePanel />
      </ScrollView>
    </SafeAreaView>
  );
}
