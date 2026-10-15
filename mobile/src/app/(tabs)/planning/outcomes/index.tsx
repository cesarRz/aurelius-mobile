import { Button } from "heroui-native";
import { router, Stack } from "expo-router";
import type { JSX } from "react";
import { Pressable, ScrollView } from "react-native";

import { OutcomeListRow } from "@/components/OutcomeListRow";
import { useWorkspaceStore } from "@/store/workspaceStore";

export default function OutcomesListScreen(): JSX.Element {
  const outcomes = useWorkspaceStore((s) => s.outcomes);

  return (
    <>
      <Stack.Screen
        options={{
          title: "Outcomes",
          headerRight: () => (
            <Button size="sm" variant="ghost" onPress={() => router.push("/forms/outcome")}>
              +
            </Button>
          ),
        }}
      />
      <ScrollView contentContainerClassName="p-4">
        {outcomes.map((outcome) => (
          <Pressable
            key={outcome.id}
            onPress={() => router.push(`/planning/outcomes/${outcome.id}`)}
          >
            <OutcomeListRow outcome={outcome} />
          </Pressable>
        ))}
      </ScrollView>
    </>
  );
}
