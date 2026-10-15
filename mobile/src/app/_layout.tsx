import type { JSX } from "react";
import { Stack } from "expo-router";
import { StatusBar } from "expo-status-bar";
import { HeroUINativeProvider } from "heroui-native";
import { GestureHandlerRootView } from "react-native-gesture-handler";

import "../global.css";

const modalOptions = { presentation: "modal" as const };

export default function RootLayout(): JSX.Element {
  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <HeroUINativeProvider>
        <Stack>
          <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
          <Stack.Screen name="document/[id]" options={{ title: "Document" }} />
          <Stack.Screen name="note/[id]" options={{ title: "Note" }} />
          <Stack.Screen name="inbox" options={{ title: "Inbox" }} />
          <Stack.Screen name="forms/area" options={{ ...modalOptions, title: "Area" }} />
          <Stack.Screen name="forms/initiative" options={{ ...modalOptions, title: "Initiative" }} />
          <Stack.Screen name="forms/outcome" options={{ ...modalOptions, title: "Outcome" }} />
          <Stack.Screen name="forms/task" options={{ ...modalOptions, title: "Task" }} />
          <Stack.Screen name="forms/milestone" options={{ ...modalOptions, title: "Milestone" }} />
        </Stack>
        <StatusBar style="auto" />
      </HeroUINativeProvider>
    </GestureHandlerRootView>
  );
}
