import { Button, Typography } from "heroui-native";
import { router } from "expo-router";
import type { JSX, ReactNode } from "react";
import { ScrollView, View } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";

interface FormScreenProps {
  title: string;
  saveLabel: string;
  onSave: () => void;
  saveDisabled?: boolean;
  children: ReactNode;
}

export function FormScreen({
  title,
  saveLabel,
  onSave,
  saveDisabled,
  children,
}: FormScreenProps): JSX.Element {
  return (
    <SafeAreaView className="flex-1 bg-background">
      <View className="flex-row items-center justify-between px-4 py-3 border-b border-default-100">
        <Button variant="ghost" onPress={() => router.back()}>
          Cancel
        </Button>
        <Typography.Heading className="text-base">{title}</Typography.Heading>
        <Button variant="primary" size="sm" onPress={onSave} isDisabled={saveDisabled}>
          {saveLabel}
        </Button>
      </View>
      <ScrollView contentContainerClassName="p-4 gap-6">{children}</ScrollView>
    </SafeAreaView>
  );
}
