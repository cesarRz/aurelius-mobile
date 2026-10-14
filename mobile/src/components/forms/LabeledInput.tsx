import { Typography } from "heroui-native";
import type { JSX } from "react";
import { TextInput, type TextInputProps } from "react-native";

export function LabeledInput({
  label,
  ...props
}: TextInputProps & { label: string }): JSX.Element {
  return (
    <>
      <Typography.Paragraph className="text-sm text-default-500 mb-1">{label}</Typography.Paragraph>
      <TextInput
        className="border border-default-200 rounded-xl px-3 py-2 text-foreground"
        placeholderTextColor="#9ca3af"
        {...props}
      />
    </>
  );
}
