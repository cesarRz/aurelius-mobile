import { Button, Typography } from "heroui-native";
import { Ionicons } from "@expo/vector-icons";
import { router, Stack } from "expo-router";
import type { JSX } from "react";
import { Pressable, ScrollView, View } from "react-native";

import { useWorkspaceStore } from "@/store/workspaceStore";
import { areaIoniconName } from "@/utils/areaIcons";

export default function AreasListScreen(): JSX.Element {
  const areas = useWorkspaceStore((s) => s.areas);
  const initiativesForArea = useWorkspaceStore((s) => s.initiativesForArea);

  return (
    <>
      <Stack.Screen
        options={{
          title: "Areas",
          headerRight: () => (
            <Button size="sm" variant="ghost" onPress={() => router.push("/forms/area")}>
              +
            </Button>
          ),
        }}
      />
      <ScrollView contentContainerClassName="p-4 gap-2">
        {areas.map((area) => (
          <Pressable
            key={area.id}
            onPress={() => router.push(`/planning/areas/${area.id}`)}
            className="flex-row items-center gap-3 py-3 border-b border-default-100"
          >
            <Ionicons name={areaIoniconName(area.icon)} size={24} color="#374151" />
            <View className="flex-1">
              <Typography.Paragraph className="font-semibold">{area.name}</Typography.Paragraph>
              <Typography.Paragraph className="text-sm text-default-500">
                {initiativesForArea(area.id).length} initiatives
              </Typography.Paragraph>
            </View>
            <Pressable
              onPress={() => router.push({ pathname: "/forms/area", params: { id: area.id } })}
              hitSlop={8}
            >
              <Typography.Paragraph className="text-sm text-accent">Edit</Typography.Paragraph>
            </Pressable>
          </Pressable>
        ))}
      </ScrollView>
    </>
  );
}
