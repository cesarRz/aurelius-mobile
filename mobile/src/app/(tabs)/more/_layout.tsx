import { Stack } from "expo-router";
import type { JSX } from "react";

export default function MoreStackLayout(): JSX.Element {
  return (
    <Stack>
      <Stack.Screen name="index" options={{ title: "More" }} />
      <Stack.Screen name="tasks" options={{ title: "Tasks" }} />
      <Stack.Screen name="threads" options={{ title: "Active Threads" }} />
      <Stack.Screen name="notes/index" options={{ title: "Notes" }} />
    </Stack>
  );
}
