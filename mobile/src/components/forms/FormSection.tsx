import { Typography } from "heroui-native";
import type { JSX, ReactNode } from "react";
import { View } from "react-native";

export function FormSection({
  title,
  children,
}: {
  title: string;
  children: ReactNode;
}): JSX.Element {
  return (
    <View className="gap-3">
      <Typography.Heading className="text-sm text-default-500">{title}</Typography.Heading>
      <View className="gap-3">{children}</View>
    </View>
  );
}
