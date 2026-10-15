import { Button } from "heroui-native";
import { router } from "expo-router";
import type { JSX } from "react";
import { View } from "react-native";

export function CreateActionFAB(): JSX.Element {
  return (
    <View className="absolute bottom-24 right-5 gap-2 items-end">
      <Button size="sm" variant="secondary" onPress={() => router.push("/forms/milestone")}>
        Milestone
      </Button>
      <Button size="md" variant="primary" onPress={() => router.push("/forms/task")}>
        + Task
      </Button>
    </View>
  );
}
