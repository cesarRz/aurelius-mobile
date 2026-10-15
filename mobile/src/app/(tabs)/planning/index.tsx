import { Typography } from "heroui-native";
import { Link, Stack } from "expo-router";
import type { JSX } from "react";
import { Pressable, ScrollView } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { Ionicons } from "@expo/vector-icons";

const LINKS = [
  { href: "/planning/areas", title: "Areas", icon: "grid-outline" as const },
  { href: "/planning/initiatives", title: "Initiatives", icon: "flag-outline" as const },
  { href: "/planning/outcomes", title: "Outcomes", icon: "locate-outline" as const },
];

export default function PlanningHubScreen(): JSX.Element {
  return (
    <SafeAreaView className="flex-1 bg-background" edges={["bottom"]}>
      <Stack.Screen options={{ headerShown: true, title: "Planning" }} />
      <ScrollView contentContainerClassName="p-2">
        {LINKS.map((item) => (
          <Link key={item.href} href={item.href as never} asChild>
            <Pressable className="flex-row items-center gap-3 px-4 py-4 border-b border-default-100">
              <Ionicons name={item.icon} size={22} color="#6b7280" />
              <Typography.Paragraph className="flex-1 text-base">{item.title}</Typography.Paragraph>
              <Ionicons name="chevron-forward" size={18} color="#9ca3af" />
            </Pressable>
          </Link>
        ))}
      </ScrollView>
    </SafeAreaView>
  );
}
