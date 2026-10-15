import { Button, Switch, Typography } from "heroui-native";
import type { JSX } from "react";
import { useRef } from "react";
import { TextInput, View, type TextInput as TextInputType } from "react-native";

import {
  BLOCK_TYPES,
  splitOnReturn,
  type BlockType,
  type DocumentBlock,
} from "../../domain/entities";
import { emptyDrawingPayload } from "../../domain/drawingDocument";
import { SkiaDrawingCanvas } from "./SkiaDrawingCanvas";

const BLOCK_LABELS: Record<BlockType, string> = {
  paragraph: "Text",
  heading1: "Heading 1",
  heading2: "Heading 2",
  heading3: "Heading 3",
  bullet: "Bullet",
  checklist: "Checklist",
  quote: "Quote",
  code: "Code",
  divider: "Divider",
  drawing: "Drawing",
};

function textStyleForType(type: BlockType): { className: string; placeholder: string } {
  switch (type) {
    case "heading1":
      return { className: "text-3xl font-bold text-foreground", placeholder: "Heading 1" };
    case "heading2":
      return { className: "text-2xl font-bold text-foreground", placeholder: "Heading 2" };
    case "heading3":
      return { className: "text-xl font-semibold text-foreground", placeholder: "Heading 3" };
    case "quote":
      return {
        className: "text-base italic text-default-600 border-l-4 border-default-300 pl-3",
        placeholder: "Quote",
      };
    case "code":
      return {
        className: "text-sm font-mono text-foreground bg-default-100 px-2 py-1 rounded-lg",
        placeholder: "Code",
      };
    default:
      return { className: "text-base text-foreground", placeholder: "Type markdown shortcuts…" };
  }
}

interface BlockEditorRowProps {
  block: DocumentBlock;
  autoFocus?: boolean;
  onBlockChange: (patch: Partial<DocumentBlock>) => void;
  onSyntax: () => void;
  onSubmitNewBlock: (remainder: string, afterReturnType: BlockType) => void;
  onInsertBlock: (type: BlockType) => void;
  inputRef?: (ref: TextInputType | null) => void;
}

export function BlockEditorRow({
  block,
  autoFocus,
  onBlockChange,
  onSyntax,
  onSubmitNewBlock,
  onInsertBlock,
  inputRef,
}: BlockEditorRowProps): JSX.Element {
  const localRef = useRef<TextInputType>(null);
  const { className, placeholder } = textStyleForType(block.type);

  const setRef = (node: TextInputType | null) => {
    localRef.current = node;
    inputRef?.(node);
  };

  if (block.type === "divider") {
    return (
      <View className="py-3">
        <View className="h-px bg-default-300" />
      </View>
    );
  }

  if (block.type === "drawing") {
    return (
      <View className="py-2 gap-2">
        <SkiaDrawingCanvas
          drawingData={block.drawingData || emptyDrawingPayload()}
          onDrawingDataChange={(drawingData) => onBlockChange({ drawingData })}
        />
      </View>
    );
  }

  const textField = (
    <TextInput
      ref={setRef}
      multiline
      autoFocus={autoFocus}
      value={block.text}
      placeholder={placeholder}
      className={className}
      placeholderTextColor="#9ca3af"
      onChangeText={(text) => {
        if (text.includes("\n")) {
          const split = splitOnReturn(text);
          if (split) {
            onBlockChange({ text: split.kept });
            onSyntax();
            onSubmitNewBlock(split.remainder, block.type);
            return;
          }
        }
        onBlockChange({ text });
        onSyntax();
      }}
      blurOnSubmit={false}
      submitBehavior="newline"
    />
  );

  return (
    <View className="flex-row items-start gap-2 py-1">
      <View className="pt-1">
        <Button
          size="sm"
          variant="ghost"
          onPress={() => {
            const next = BLOCK_TYPES[(BLOCK_TYPES.indexOf(block.type) + 1) % BLOCK_TYPES.length];
            if (next === "drawing" || next === "divider") {
              onInsertBlock(next);
            } else {
              onBlockChange({ type: next });
            }
          }}
        >
          +
        </Button>
      </View>

      <View className="flex-1 gap-1">
        <Typography.Paragraph className="text-xs text-default-400">
          {BLOCK_LABELS[block.type]}
        </Typography.Paragraph>

        {block.type === "bullet" ? (
          <View className="flex-row gap-2">
            <Typography.Paragraph className="text-default-500">•</Typography.Paragraph>
            <View className="flex-1">{textField}</View>
          </View>
        ) : null}

        {block.type === "checklist" ? (
          <View className="flex-row gap-2 items-start">
            <Switch
              isSelected={block.isChecked}
              onSelectedChange={(checked) => onBlockChange({ isChecked: checked })}
            />
            <View className="flex-1">{textField}</View>
          </View>
        ) : null}

        {block.type !== "bullet" && block.type !== "checklist" ? textField : null}
      </View>
    </View>
  );
}
