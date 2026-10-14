import { Button, Typography } from "heroui-native";
import { Link, useRouter } from "expo-router";
import type { JSX } from "react";
import { Pressable, ScrollView, View } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";

import { useWorkspaceStore } from "@/store/workspaceStore";

export default function DocsTab(): JSX.Element {
  const docs = useWorkspaceStore((s) => s.docs);
  const addDocument = useWorkspaceStore((s) => s.addDocument);
  const router = useRouter();

  return (
    <SafeAreaView className="flex-1 bg-background" edges={["top"]}>
      <ScrollView contentContainerClassName="p-4 gap-4">
        <View className="flex-row items-center justify-between">
          <Typography.Heading>Docs</Typography.Heading>
          <Button
            size="sm"
            onPress={() => {
              const id = addDocument();
              router.push(`/document/${id}`);
            }}
          >
            New
          </Button>
        </View>

        {docs.map((doc) => (
          <Link key={doc.id} href={`/document/${doc.id}` as never} asChild>
            <Pressable className="py-3 border-b border-default-100 flex-row justify-between">
              <Typography.Paragraph>{doc.name || "Untitled"}</Typography.Paragraph>
              <Typography.Paragraph className="text-default-400">›</Typography.Paragraph>
            </Pressable>
          </Link>
        ))}
      </ScrollView>
    </SafeAreaView>
  );
}
