import { Typography } from "heroui-native";
import { Link } from "expo-router";
import type { JSX } from "react";
import { ScrollView, View } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";

import { useWorkspaceStore } from "@/store/workspaceStore";

export default function PlanningTab(): JSX.Element {
  const areas = useWorkspaceStore((s) => s.areas);
  const initiatives = useWorkspaceStore((s) => s.initiatives);
  const outcomes = useWorkspaceStore((s) => s.outcomes);

  return (
    <SafeAreaView className="flex-1 bg-background" edges={["top"]}>
      <ScrollView contentContainerClassName="p-4 gap-6">
        <Typography.Heading>Planning</Typography.Heading>

        <Section title="Areas" href="/planning/areas">
          {areas.map((a) => (
            <Row key={a.id} label={a.name} />
          ))}
        </Section>

        <Section title="Initiatives" href="/planning/initiatives">
          {initiatives.map((i) => (
            <Row key={i.id} label={i.name} />
          ))}
        </Section>

        <Section title="Outcomes" href="/planning/outcomes">
          {outcomes.map((o) => (
            <Row key={o.id} label={o.name} />
          ))}
        </Section>
      </ScrollView>
    </SafeAreaView>
  );
}

function Section({
  title,
  href,
  children,
}: {
  title: string;
  href: string;
  children: React.ReactNode;
}): JSX.Element {
  return (
    <View className="gap-2">
      <Link href={href as never}>
        <Typography.Heading className="text-base text-accent">
          {title}
        </Typography.Heading>
      </Link>
      {children}
    </View>
  );
}

function Row({ label }: { label: string }): JSX.Element {
  return (
    <View className="py-2 border-b border-default-100">
      <Typography.Paragraph>{label}</Typography.Paragraph>
    </View>
  );
}
