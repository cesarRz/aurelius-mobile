import { Button, Typography } from "heroui-native";
import { Ionicons } from "@expo/vector-icons";
import { router, Stack, useLocalSearchParams } from "expo-router";
import type { JSX } from "react";
import { Pressable, ScrollView, View } from "react-native";

import { OutcomeListRow } from "@/components/OutcomeListRow";
import { SectionCard } from "@/components/SectionCard";
import { StatusBadge } from "@/components/StatusBadge";
import { TaskRow } from "@/components/TaskRow";
import { useWorkspaceStore } from "@/store/workspaceStore";
import { areaIoniconName } from "@/utils/areaIcons";

export default function InitiativeDetailScreen(): JSX.Element {
  const { id } = useLocalSearchParams<{ id: string }>();
  const initiative = useWorkspaceStore((s) => s.initiative(id));
  const linkedArea = useWorkspaceStore((s) => s.area(initiative?.areaID));
  const outcomes = useWorkspaceStore((s) => (id ? s.outcomesForInitiative(id) : []));
  const tasks = useWorkspaceStore((s) => (id ? s.tasksForInitiative(id) : []));

  if (!initiative) {
    return (
      <View className="flex-1 items-center justify-center p-6">
        <Typography.Paragraph>Initiative not found.</Typography.Paragraph>
      </View>
    );
  }

  return (
    <>
      <Stack.Screen
        options={{
          title: initiative.name,
          headerRight: () => (
            <View className="flex-row gap-1">
              <Button
                size="sm"
                variant="ghost"
                onPress={() =>
                  router.push({ pathname: "/forms/initiative", params: { id: initiative.id } })
                }
              >
                Edit
              </Button>
              <Button
                size="sm"
                variant="ghost"
                onPress={() =>
                  router.push({ pathname: "/forms/outcome", params: { initiativeId: initiative.id } })
                }
              >
                +
              </Button>
            </View>
          ),
        }}
      />
      <ScrollView contentContainerClassName="p-4 gap-6">
        <View className="gap-2">
          <Typography.Paragraph className="text-xs font-bold text-default-500">INITIATIVE</Typography.Paragraph>
          <Typography.Heading>{initiative.name}</Typography.Heading>
          <View className="flex-row flex-wrap gap-2 items-center">
            <StatusBadge status={initiative.status} />
            {linkedArea ? (
              <View className="flex-row items-center gap-1">
                <Ionicons name={areaIoniconName(linkedArea.icon)} size={16} color="#6b7280" />
                <Typography.Paragraph className="text-sm text-default-500">
                  {linkedArea.name}
                </Typography.Paragraph>
              </View>
            ) : null}
          </View>
        </View>

        <SectionCard title="Outcomes">
          {outcomes.length === 0 ? (
            <Typography.Paragraph className="text-default-500">No outcomes yet.</Typography.Paragraph>
          ) : (
            outcomes.map((outcome) => (
              <Pressable
                key={outcome.id}
                onPress={() => router.push(`/planning/outcomes/${outcome.id}`)}
              >
                <OutcomeListRow outcome={outcome} />
              </Pressable>
            ))
          )}
        </SectionCard>

        <SectionCard title="Tasks">
          {tasks.length === 0 ? (
            <Typography.Paragraph className="text-default-500">No tasks yet.</Typography.Paragraph>
          ) : (
            tasks.map((task) => <TaskRow key={task.id} taskID={task.id} />)
          )}
          <Button
            variant="ghost"
            onPress={() =>
              router.push({ pathname: "/forms/task", params: { initiativeId: initiative.id } })
            }
          >
            + Add Task
          </Button>
        </SectionCard>
      </ScrollView>
    </>
  );
}
