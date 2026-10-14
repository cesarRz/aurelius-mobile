import { Typography } from "heroui-native";
import type { JSX } from "react";
import { useCallback, useRef, useState } from "react";
import { ScrollView, TextInput, View, type TextInput as TextInputType } from "react-native";

import { typeAfterReturn, type EntityId } from "../../domain/entities";
import { useWorkspaceStore } from "../../store/workspaceStore";
import { BlockEditorRow } from "./BlockEditorRow";

interface BlockDocumentEditorProps {
  documentID: EntityId;
}

export function BlockDocumentEditor({ documentID }: BlockDocumentEditorProps): JSX.Element | null {
  const doc = useWorkspaceStore((s) => s.docs.find((d) => d.id === documentID));
  const updateDocumentName = useWorkspaceStore((s) => s.updateDocumentName);
  const updateDocumentBlock = useWorkspaceStore((s) => s.updateDocumentBlock);
  const addDocumentBlock = useWorkspaceStore((s) => s.addDocumentBlock);
  const interpretDocumentSyntax = useWorkspaceStore((s) => s.interpretDocumentSyntax);

  const inputRefs = useRef<Map<string, TextInputType>>(new Map());
  const [focusBlockID, setFocusBlockID] = useState<EntityId | null>(null);

  const focusBlock = useCallback((blockID: EntityId) => {
    setFocusBlockID(blockID);
    requestAnimationFrame(() => {
      inputRefs.current.get(blockID)?.focus();
    });
  }, []);

  if (!doc) {
    return (
      <View className="flex-1 items-center justify-center p-6">
        <Typography.Paragraph>Document not found.</Typography.Paragraph>
      </View>
    );
  }

  return (
    <ScrollView className="flex-1 bg-background" contentContainerClassName="px-4 pb-24 pt-4 gap-2">
      <TextInput
        value={doc.name}
        onChangeText={(name) => updateDocumentName(documentID, name)}
        placeholder="Untitled"
        className="text-3xl font-bold text-foreground mb-4"
        placeholderTextColor="#9ca3af"
      />

      {doc.blocks.map((block) => (
        <BlockEditorRow
          key={block.id}
          block={block}
          autoFocus={focusBlockID === block.id}
          inputRef={(ref) => {
            if (ref) {
              inputRefs.current.set(block.id, ref);
            } else {
              inputRefs.current.delete(block.id);
            }
          }}
          onBlockChange={(patch) => updateDocumentBlock(documentID, block.id, patch)}
          onSyntax={() => interpretDocumentSyntax(documentID, block.id)}
          onSubmitNewBlock={(remainder, currentType) => {
            const newID = addDocumentBlock(
              documentID,
              block.id,
              typeAfterReturn(currentType),
              remainder,
            );
            if (newID) {
              focusBlock(newID);
            }
          }}
          onInsertBlock={(type) => {
            const newID = addDocumentBlock(documentID, block.id, type);
            if (newID) {
              focusBlock(newID);
            }
          }}
        />
      ))}

      <View className="pt-4">
        <Typography.Paragraph className="text-sm text-default-400">
          Tap + on a block to change type or insert drawing / divider.
        </Typography.Paragraph>
      </View>
    </ScrollView>
  );
}
