import { Typography } from "heroui-native";
import { Ionicons } from "@expo/vector-icons";
import { Link, Stack } from "expo-router";
import type { JSX } from "react";
import { Pressable, ScrollView } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";

const LINKS = [
  { href: "/inbox", title: "Inbox", icon: "file-tray-outline" as const },
  { href: "/more/tasks", title: "Tasks", icon: "checkmark-circle-outline" as const },
  { href: "/more/threads", title: "Active Threads", icon: "chatbubbles-outline" as const },
  { href: "/more/notes", title: "Notes", icon: "document-text-outline" as const },
];

export default function MoreHubScreen(): JSX.Element {
  return (
    <SafeAreaView className="flex-1 bg-background" edges={["bottom"]}>
      <Stack.Screen options={{ headerShown: true, title: "More" }} />
      <ScrollView contentContainerClassName="p-2">
        {LINKS.map((item) => (
          <Link key={item.href} href={item.href as never} asChild>
            <Pressable className="flex-row items-center gap-3 px-4 py-4 border-b border-default-100">
              <Ionicons name={item.icon} size={22} color="#6b7280" />
              <Typography.Paragraph className="flex-1">{item.title}</Typography.Paragraph>
              <Ionicons name="chevron-forward" size={18} color="#9ca3af" />
            </Pressable>
          </Link>
        ))}
      </ScrollView>
    </SafeAreaView>
  );
}
