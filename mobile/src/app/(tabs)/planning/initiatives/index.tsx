import { Button, Typography } from "heroui-native";
import { router, Stack } from "expo-router";
import type { JSX } from "react";
import { Pressable, ScrollView, View } from "react-native";
import { Ionicons } from "@expo/vector-icons";

import { StatusBadge } from "@/components/StatusBadge";
import { useWorkspaceStore } from "@/store/workspaceStore";
import { areaIoniconName } from "@/utils/areaIcons";

export default function InitiativesListScreen(): JSX.Element {
  const initiatives = useWorkspaceStore((s) => s.initiatives);
  const area = useWorkspaceStore((s) => s.area);

  return (
    <>
      <Stack.Screen
        options={{
          title: "Initiatives",
          headerRight: () => (
            <Button size="sm" variant="ghost" onPress={() => router.push("/forms/initiative")}>
              +
            </Button>
          ),
        }}
      />
      <ScrollView contentContainerClassName="p-4 gap-3">
        {initiatives.map((initiative) => {
          const linkedArea = area(initiative.areaID);
          return (
            <Pressable
              key={initiative.id}
              onPress={() => router.push(`/planning/initiatives/${initiative.id}`)}
              className="py-3 border-b border-default-100 gap-2"
            >
              <View className="flex-row justify-between items-start gap-2">
                <Typography.Paragraph className="font-semibold flex-1">
                  {initiative.name}
                </Typography.Paragraph>
                <StatusBadge status={initiative.status} />
              </View>
              {linkedArea ? (
                <View className="flex-row items-center gap-1">
                  <Ionicons name={areaIoniconName(linkedArea.icon)} size={14} color="#6b7280" />
                  <Typography.Paragraph className="text-sm text-default-500">
                    {linkedArea.name}
                  </Typography.Paragraph>
                </View>
              ) : null}
            </Pressable>
          );
        })}
      </ScrollView>
    </>
  );
}
