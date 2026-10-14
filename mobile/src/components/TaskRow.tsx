import { Chip, Typography } from "heroui-native";
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
    <Pressable
      onPress={() => toggleTask(taskID)}
      className="py-3 border-b border-default-100"
    >
      <View className="flex-row items-center gap-3">
        <View
          className={`h-5 w-5 rounded-full border-2 ${
            task.status === "done" ? "bg-success border-success" : "border-default-400"
          }`}
        />
        <View className="flex-1 gap-1">
          <Typography.Paragraph
            className={task.status === "done" ? "line-through text-default-400" : ""}
          >
            {task.name}
          </Typography.Paragraph>
          <Chip size="sm" variant="soft">
            {task.priority}
          </Chip>
        </View>
      </View>
    </Pressable>
  );
}
