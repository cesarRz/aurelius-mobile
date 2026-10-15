import { Typography } from "heroui-native";
import type { JSX } from "react";
import { useCallback, useRef, useState } from "react";
import { ScrollView, TextInput, View, type TextInput as TextInputType } from "react-native";

import { typeAfterReturn, type EntityId } from "../../domain/entities";
import { useWorkspaceStore } from "../../store/workspaceStore";
import { BlockEditorRow } from "./BlockEditorRow";

interface BlockNoteEditorProps {
  noteID: EntityId;
}

export function BlockNoteEditor({ noteID }: BlockNoteEditorProps): JSX.Element | null {
  const note = useWorkspaceStore((s) => s.notes.find((n) => n.id === noteID));
  const updateNoteName = useWorkspaceStore((s) => s.updateNoteName);
  const updateNoteBlock = useWorkspaceStore((s) => s.updateNoteBlock);
  const addNoteBlock = useWorkspaceStore((s) => s.addNoteBlock);
  const interpretNoteSyntax = useWorkspaceStore((s) => s.interpretNoteSyntax);

  const inputRefs = useRef<Map<string, TextInputType>>(new Map());
  const [focusBlockID, setFocusBlockID] = useState<EntityId | null>(null);

  const focusBlock = useCallback((blockID: EntityId) => {
    setFocusBlockID(blockID);
    requestAnimationFrame(() => {
      inputRefs.current.get(blockID)?.focus();
    });
  }, []);

  if (!note) {
    return (
      <View className="flex-1 items-center justify-center p-6">
        <Typography.Paragraph>Note not found.</Typography.Paragraph>
      </View>
    );
  }

  return (
    <ScrollView className="flex-1 bg-background" contentContainerClassName="px-4 pb-24 pt-4 gap-2">
      <TextInput
        value={note.name}
        onChangeText={(name) => updateNoteName(noteID, name)}
        placeholder="Untitled"
        className="text-3xl font-bold text-foreground mb-4"
        placeholderTextColor="#9ca3af"
      />

      {note.blocks.map((block) => (
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
          onBlockChange={(patch) => updateNoteBlock(noteID, block.id, patch)}
          onSyntax={() => interpretNoteSyntax(noteID, block.id)}
          onSubmitNewBlock={(remainder, currentType) => {
            const newID = addNoteBlock(noteID, block.id, typeAfterReturn(currentType), remainder);
            if (newID) {
              focusBlock(newID);
            }
          }}
          onInsertBlock={(type) => {
            const newID = addNoteBlock(noteID, block.id, type);
            if (newID) {
              focusBlock(newID);
            }
          }}
        />
      ))}
    </ScrollView>
  );
}
