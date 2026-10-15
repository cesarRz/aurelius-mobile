import { Chip, Typography } from "heroui-native";
import type { JSX } from "react";
import { useMemo, useState } from "react";
import { Pressable, ScrollView, View } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";

import { AgendaTaskOptions } from "@/components/AgendaTaskOptions";
import { TaskRow } from "@/components/TaskRow";
import { agendaGroups, type AgendaTaskGroupingMode } from "@/domain/agendaGrouping";
import type { EntityId } from "@/domain/entities";
import { defaultCalendar } from "@/domain/taskScheduling";
import { useWorkspaceStore } from "@/store/workspaceStore";

function taskSummaryText(
  grouping: AgendaTaskGroupingMode,
  initiativeName: string | null,
  outcomeName: string | null,
): string {
  const parts = [`By ${grouping}`];
  if (initiativeName) {
    parts.push(initiativeName);
  }
  if (outcomeName) {
    parts.push(outcomeName);
  }
  return parts.join(" · ");
}

export default function AgendaTab(): JSX.Element {
  const areas = useWorkspaceStore((s) => s.areas);
  const initiatives = useWorkspaceStore((s) => s.initiatives);
  const outcomes = useWorkspaceStore((s) => s.outcomes);
  const tasksForAgendaOn = useWorkspaceStore((s) => s.tasksForAgendaOn);
  const store = useWorkspaceStore();

  const [selectedDate, setSelectedDate] = useState(() => defaultCalendar.startOfDay(new Date()));
  const [areaID, setAreaID] = useState<EntityId | null>(null);
  const [grouping, setGrouping] = useState<AgendaTaskGroupingMode>("initiative");
  const [initiativeID, setInitiativeID] = useState<EntityId | null>(null);
  const [outcomeID, setOutcomeID] = useState<EntityId | null>(null);

  const scheduledTasks = useMemo(
    () => tasksForAgendaOn(selectedDate, { areaID, initiativeID, outcomeID }),
    [tasksForAgendaOn, selectedDate, areaID, initiativeID, outcomeID],
  );

  const groups = useMemo(
    () => agendaGroups(grouping, scheduledTasks, store),
    [grouping, scheduledTasks, store],
  );

  const initiativeName =
    initiativeID === null
      ? null
      : (initiatives.find((i) => i.id === initiativeID)?.name ?? null);
  const outcomeName =
    outcomeID === null ? null : (outcomes.find((o) => o.id === outcomeID)?.name ?? null);

  const shiftDay = (delta: number) => {
    setSelectedDate((d) => defaultCalendar.addDays(d, delta));
  };

  return (
    <SafeAreaView className="flex-1 bg-background" edges={["top"]}>
      <ScrollView contentContainerClassName="p-4 gap-5">
        <Typography.Heading>Agenda</Typography.Heading>

        <View className="flex-row items-center justify-between">
          <Pressable onPress={() => shiftDay(-1)}>
            <Typography.Paragraph className="text-accent">Previous</Typography.Paragraph>
          </Pressable>
          <Typography.Paragraph className="font-semibold">
            {selectedDate.toLocaleDateString(undefined, {
              weekday: "short",
              month: "short",
              day: "numeric",
            })}
          </Typography.Paragraph>
          <Pressable onPress={() => shiftDay(1)}>
            <Typography.Paragraph className="text-accent">Next</Typography.Paragraph>
          </Pressable>
        </View>

        <ScrollView horizontal showsHorizontalScrollIndicator={false} className="flex-row gap-2">
          <Chip variant={areaID === null ? "primary" : "soft"} onPress={() => setAreaID(null)}>
            All areas
          </Chip>
          {areas.map((area) => (
            <Chip
              key={area.id}
              variant={areaID === area.id ? "primary" : "soft"}
              onPress={() => setAreaID(area.id)}
            >
              {area.name}
            </Chip>
          ))}
        </ScrollView>

        <View className="flex-row items-start justify-between gap-2">
          <View className="flex-1 gap-1">
            <Typography.Heading className="text-base">Tasks</Typography.Heading>
            <Typography.Paragraph className="text-xs text-default-500">
              {taskSummaryText(grouping, initiativeName, outcomeName)}
            </Typography.Paragraph>
          </View>
          <AgendaTaskOptions
            grouping={grouping}
            onGroupingChange={setGrouping}
            initiativeID={initiativeID}
            onInitiativeIDChange={setInitiativeID}
            outcomeID={outcomeID}
            onOutcomeIDChange={setOutcomeID}
          />
        </View>

        {groups.length === 0 ? (
          <Typography.Paragraph className="text-default-500">
            No tasks for this day and filters.
          </Typography.Paragraph>
        ) : (
          groups.map((group) => (
            <View key={group.id ?? group.title} className="gap-2">
              <View className="flex-row justify-between items-center">
                <Typography.Heading className="text-base">{group.title}</Typography.Heading>
                <Typography.Paragraph className="text-sm text-default-500">
                  {group.tasks.length}
                </Typography.Paragraph>
              </View>
              {group.tasks.map((task) => (
                <TaskRow
                  key={task.id}
                  taskID={task.id}
                  style="agenda"
                  contextDate={selectedDate}
                />
              ))}
            </View>
          ))
        )}
      </ScrollView>
    </SafeAreaView>
  );
}
