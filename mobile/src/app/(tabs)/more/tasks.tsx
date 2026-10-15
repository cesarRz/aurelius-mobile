import { Button, Typography } from "heroui-native";
import { router, Stack } from "expo-router";
import type { JSX } from "react";
import { ScrollView, View } from "react-native";

import { TaskRow } from "@/components/TaskRow";
import { useWorkspaceStore } from "@/store/workspaceStore";

export default function TasksListScreen(): JSX.Element {
  const tasks = useWorkspaceStore((s) => s.tasks);
  const active = tasks.filter((t) => t.status !== "done");
  const completed = tasks.filter((t) => t.status === "done");

  return (
    <>
      <Stack.Screen
        options={{
          title: "Tasks",
          headerRight: () => (
            <Button size="sm" variant="ghost" onPress={() => router.push("/forms/task")}>
              +
            </Button>
          ),
        }}
      />
      <ScrollView contentContainerClassName="p-4 gap-6">
        <View className="gap-2">
          <Typography.Heading className="text-base">Active</Typography.Heading>
          {active.map((t) => (
            <TaskRow key={t.id} taskID={t.id} />
          ))}
        </View>
        <View className="gap-2">
          <Typography.Heading className="text-base">Completed</Typography.Heading>
          {completed.map((t) => (
            <TaskRow key={t.id} taskID={t.id} />
          ))}
        </View>
      </ScrollView>
    </>
  );
}
