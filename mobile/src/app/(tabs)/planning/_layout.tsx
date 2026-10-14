import { Stack } from "expo-router";
import type { JSX } from "react";

export default function PlanningStackLayout(): JSX.Element {
  return (
    <Stack>
      <Stack.Screen name="index" options={{ title: "Planning" }} />
      <Stack.Screen name="areas/index" options={{ title: "Areas" }} />
      <Stack.Screen name="areas/[id]" options={{ title: "Area" }} />
      <Stack.Screen name="initiatives/index" options={{ title: "Initiatives" }} />
      <Stack.Screen name="initiatives/[id]" options={{ title: "Initiative" }} />
      <Stack.Screen name="outcomes/index" options={{ title: "Outcomes" }} />
      <Stack.Screen name="outcomes/[id]" options={{ title: "Outcome" }} />
    </Stack>
  );
}
