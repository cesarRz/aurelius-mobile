import { Typography } from "heroui-native";
import type { JSX } from "react";
import { View } from "react-native";

import type { Outcome } from "../domain/entities";
import { useWorkspaceStore } from "../store/workspaceStore";
import { StatusBadge } from "./StatusBadge";

export function OutcomeListRow({ outcome }: { outcome: Outcome }): JSX.Element {
  const initiative = useWorkspaceStore((s) => s.initiative(outcome.initiativeID));
  const progress = useWorkspaceStore((s) => s.progressForOutcome(outcome.id));

  return (
    <View className="gap-2 py-2">
      <View className="flex-row items-center justify-between gap-2">
        <Typography.Paragraph className="font-semibold flex-1">{outcome.name}</Typography.Paragraph>
        <StatusBadge status={outcome.status} />
      </View>
      {initiative ? (
        <Typography.Paragraph className="text-sm text-default-500">{initiative.name}</Typography.Paragraph>
      ) : null}
      <View className="h-2 rounded-full bg-default-200 overflow-hidden">
        <View className="h-full bg-accent rounded-full" style={{ width: `${Math.round(progress * 100)}%` }} />
      </View>
    </View>
  );
}
