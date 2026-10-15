import { Button, Typography } from "heroui-native";
import { Link, router, Stack } from "expo-router";
import type { JSX } from "react";
import { Pressable, ScrollView } from "react-native";
import { Ionicons } from "@expo/vector-icons";

import { useWorkspaceStore } from "@/store/workspaceStore";

export default function NotesListScreen(): JSX.Element {
  const notes = useWorkspaceStore((s) => s.notes);
  const addNote = useWorkspaceStore((s) => s.addNote);

  return (
    <>
      <Stack.Screen
        options={{
          title: "Notes",
          headerRight: () => (
            <Button
              size="sm"
              variant="ghost"
              onPress={() => {
                const id = addNote();
                router.push(`/note/${id}`);
              }}
            >
              +
            </Button>
          ),
        }}
      />
      <ScrollView contentContainerClassName="p-4">
        {notes.map((note) => (
          <Link key={note.id} href={`/note/${note.id}` as never} asChild>
            <Pressable className="flex-row items-center justify-between py-3 border-b border-default-100">
              <Typography.Paragraph>{note.name || "Untitled"}</Typography.Paragraph>
              <Ionicons name="chevron-forward" size={16} color="#9ca3af" />
            </Pressable>
          </Link>
        ))}
      </ScrollView>
    </>
  );
}
