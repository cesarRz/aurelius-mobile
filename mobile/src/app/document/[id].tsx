import { useLocalSearchParams } from "expo-router";
import type { JSX } from "react";
import { View } from "react-native";

import { BlockDocumentEditor } from "@/components/editor/BlockDocumentEditor";

export default function DocumentScreen(): JSX.Element {
  const { id } = useLocalSearchParams<{ id: string }>();

  return (
    <View className="flex-1 bg-background">
      {id ? <BlockDocumentEditor documentID={id} /> : null}
    </View>
  );
}
