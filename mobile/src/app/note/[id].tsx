import { useLocalSearchParams } from "expo-router";
import type { JSX } from "react";
import { View } from "react-native";

import { BlockNoteEditor } from "@/components/editor/BlockNoteEditor";

export default function NoteScreen(): JSX.Element {
  const { id } = useLocalSearchParams<{ id: string }>();

  return (
    <View className="flex-1 bg-background">
      {id ? <BlockNoteEditor noteID={id} /> : null}
    </View>
  );
}
