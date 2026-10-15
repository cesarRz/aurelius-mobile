import { Card, Typography } from "heroui-native";
import type { JSX, ReactNode } from "react";
import { View } from "react-native";

interface SectionCardProps {
  title: string;
  children: ReactNode;
}

export function SectionCard({ title, children }: SectionCardProps): JSX.Element {
  return (
    <Card className="p-4 gap-3">
      <Typography.Heading className="text-base">{title}</Typography.Heading>
      <View className="gap-2">{children}</View>
    </Card>
  );
}
