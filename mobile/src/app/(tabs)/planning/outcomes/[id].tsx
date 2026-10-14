import { Button, Typography } from "heroui-native";
import { Ionicons } from "@expo/vector-icons";
import { Link, router, Stack, useLocalSearchParams } from "expo-router";
import type { JSX } from "react";
import { Pressable, ScrollView, View } from "react-native";

import { SectionCard } from "@/components/SectionCard";
import { StatusBadge } from "@/components/StatusBadge";
import { TaskRow } from "@/components/TaskRow";
import { useWorkspaceStore } from "@/store/workspaceStore";

export default function OutcomeWorkspaceScreen(): JSX.Element {
  const { id } = useLocalSearchParams<{ id: string }>();
  const outcome = useWorkspaceStore((s) => s.outcome(id));
  const initiative = useWorkspaceStore((s) => s.initiative(outcome?.initiativeID));
  const progress = useWorkspaceStore((s) => (id ? s.progressForOutcome(id) : 0));
  const milestones = useWorkspaceStore((s) => s.milestones.filter((m) => m.outcomeID === id));
  const tasks = useWorkspaceStore((s) => (id ? s.tasksForOutcome(id) : []));
  const threads = useWorkspaceStore((s) => s.threads.filter((t) => t.outcomeID === id));
  const docs = useWorkspaceStore((s) => (id ? s.docsForOutcome(id) : []));
  const notes = useWorkspaceStore((s) => (id ? s.notesForOutcome(id) : []));

  if (!outcome || !id) {
    return (
      <View className="flex-1 items-center justify-center p-6">
        <Typography.Paragraph>Outcome not found.</Typography.Paragraph>
      </View>
    );
  }

  return (
    <>
      <Stack.Screen
        options={{
          title: outcome.name,
          headerRight: () => (
            <View className="flex-row gap-1">
              <Button
                size="sm"
                variant="ghost"
                onPress={() =>
                  router.push({ pathname: "/forms/outcome", params: { id: outcome.id } })
                }
              >
                Edit
              </Button>
              <Button
                size="sm"
                variant="ghost"
                onPress={() =>
                  router.push({ pathname: "/forms/task", params: { outcomeId: outcome.id } })
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
          <Typography.Paragraph className="text-xs font-bold text-default-500">OUTCOME</Typography.Paragraph>
          <Typography.Heading>{outcome.name}</Typography.Heading>
          <View className="flex-row flex-wrap gap-2 items-center">
            <StatusBadge status={outcome.status} />
            {initiative ? (
              <Typography.Paragraph className="text-sm text-default-500">{initiative.name}</Typography.Paragraph>
            ) : null}
            {outcome.targetDate ? (
              <Typography.Paragraph className="text-sm text-default-500">
                {outcome.targetDate.toLocaleDateString()}
              </Typography.Paragraph>
            ) : null}
          </View>
        </View>

        <View className="gap-2">
          <View className="flex-row justify-between">
            <Typography.Paragraph className="font-semibold">Progress</Typography.Paragraph>
            <Typography.Paragraph className="text-default-500">{Math.round(progress * 100)}%</Typography.Paragraph>
          </View>
          <View className="h-2 rounded-full bg-default-200 overflow-hidden">
            <View className="h-full bg-accent" style={{ width: `${Math.round(progress * 100)}%` }} />
          </View>
        </View>

        <SectionCard title="Milestones">
          {milestones.map((m) => (
            <View key={m.id} className="flex-row items-center gap-2 py-1">
              <Ionicons
                name={m.isCompleted ? "checkmark-circle" : "ellipse-outline"}
                size={18}
                color={m.isCompleted ? "#22c55e" : "#9ca3af"}
              />
              <Typography.Paragraph>{m.name}</Typography.Paragraph>
            </View>
          ))}
        </SectionCard>

        <SectionCard title="Tasks">
          {tasks.map((t) => (
            <TaskRow key={t.id} taskID={t.id} />
          ))}
          <Button
            variant="ghost"
            onPress={() =>
              router.push({ pathname: "/forms/task", params: { outcomeId: outcome.id } })
            }
          >
            + Add Task
          </Button>
        </SectionCard>

        <SectionCard title="Active Threads">
          {threads.map((thread) => (
            <View key={thread.id} className="py-1 gap-1">
              <Typography.Paragraph className="font-semibold">{thread.name}</Typography.Paragraph>
              <Typography.Paragraph className="text-sm text-default-500">{thread.detail}</Typography.Paragraph>
            </View>
          ))}
        </SectionCard>

        <SectionCard title="Docs">
          {docs.map((doc) => (
            <Link key={doc.id} href={`/document/${doc.id}` as never} asChild>
              <Pressable className="flex-row justify-between py-2">
                <Typography.Paragraph>{doc.name || "Untitled"}</Typography.Paragraph>
                <Ionicons name="chevron-forward" size={16} color="#9ca3af" />
              </Pressable>
            </Link>
          ))}
        </SectionCard>

        <SectionCard title="Notes">
          {notes.map((note) => (
            <Link key={note.id} href={`/note/${note.id}` as never} asChild>
              <Pressable className="flex-row justify-between py-2">
                <Typography.Paragraph>{note.name || "Untitled"}</Typography.Paragraph>
                <Ionicons name="chevron-forward" size={16} color="#9ca3af" />
              </Pressable>
            </Link>
          ))}
        </SectionCard>
      </ScrollView>
    </>
  );
}
