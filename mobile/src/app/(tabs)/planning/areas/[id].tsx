import { Button, Typography } from "heroui-native";
import { Ionicons } from "@expo/vector-icons";
import { router, Stack, useLocalSearchParams } from "expo-router";
import type { JSX } from "react";
import { Pressable, ScrollView, View } from "react-native";

import { SectionCard } from "@/components/SectionCard";
import { StatusBadge } from "@/components/StatusBadge";
import { useWorkspaceStore } from "@/store/workspaceStore";
import { areaIoniconName } from "@/utils/areaIcons";

export default function AreaDetailScreen(): JSX.Element {
  const { id } = useLocalSearchParams<{ id: string }>();
  const area = useWorkspaceStore((s) => s.areas.find((a) => a.id === id));
  const initiatives = useWorkspaceStore((s) => (id ? s.initiativesForArea(id) : []));

  if (!area) {
    return (
      <View className="flex-1 items-center justify-center p-6">
        <Typography.Paragraph>Area not found.</Typography.Paragraph>
      </View>
    );
  }

  return (
    <>
      <Stack.Screen
        options={{
          title: area.name,
          headerRight: () => (
            <View className="flex-row gap-1">
              <Button
                size="sm"
                variant="ghost"
                onPress={() => router.push({ pathname: "/forms/area", params: { id: area.id } })}
              >
                Edit
              </Button>
              <Button
                size="sm"
                variant="ghost"
                onPress={() =>
                  router.push({ pathname: "/forms/initiative", params: { areaId: area.id } })
                }
              >
                +
              </Button>
            </View>
          ),
        }}
      />
      <ScrollView contentContainerClassName="p-4 gap-6">
        <View className="flex-row items-center gap-4">
          <Ionicons name={areaIoniconName(area.icon)} size={36} color="#111827" />
          <View>
            <Typography.Paragraph className="text-xs font-bold text-default-500">AREA</Typography.Paragraph>
            <Typography.Heading>{area.name}</Typography.Heading>
          </View>
        </View>

        <SectionCard title="Initiatives">
          {initiatives.length === 0 ? (
            <Typography.Paragraph className="text-default-500">No initiatives yet.</Typography.Paragraph>
          ) : (
            initiatives.map((initiative) => (
              <Pressable
                key={initiative.id}
                onPress={() => router.push(`/planning/initiatives/${initiative.id}`)}
                className="py-2"
              >
                <Typography.Paragraph className="font-semibold">{initiative.name}</Typography.Paragraph>
                <StatusBadge status={initiative.status} />
              </Pressable>
            ))
          )}
        </SectionCard>
      </ScrollView>
    </>
  );
}
