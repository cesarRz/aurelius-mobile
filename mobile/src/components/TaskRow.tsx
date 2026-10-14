import { Chip, Typography } from "heroui-native";
import { router } from "expo-router";
import type { JSX } from "react";
import { Pressable, View } from "react-native";

import type { EntityId } from "../domain/entities";
import { useWorkspaceStore } from "../store/workspaceStore";

interface TaskRowProps {
  taskID: EntityId;
}

export function TaskRow({ taskID }: TaskRowProps): JSX.Element | null {
  const task = useWorkspaceStore((s) => s.tasks.find((t) => t.id === taskID));
  const toggleTask = useWorkspaceStore((s) => s.toggleTask);

  if (!task) {
    return null;
  }

  return (
    <View className="flex-row items-center gap-3 py-3 border-b border-default-100">
      <Pressable
        onPress={() => toggleTask(taskID)}
        hitSlop={8}
        accessibilityRole="button"
        accessibilityLabel="Toggle task completion"
      >
        <View
          className={`h-5 w-5 rounded-full border-2 ${
            task.status === "done" ? "bg-success border-success" : "border-default-400"
          }`}
        />
      </Pressable>
      <Pressable
        className="flex-1 gap-1"
        onPress={() => router.push({ pathname: "/forms/task", params: { id: taskID } })}
      >
        <Typography.Paragraph
          className={task.status === "done" ? "line-through text-default-400" : ""}
        >
          {task.name}
        </Typography.Paragraph>
        <Chip size="sm" variant="soft">
          {task.priority}
        </Chip>
      </Pressable>
    </View>
  );
}
