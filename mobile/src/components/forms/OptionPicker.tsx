import { Chip } from "heroui-native";
import type { JSX } from "react";
import { View } from "react-native";

interface Option<T extends string> {
  value: T;
  label: string;
}

interface OptionPickerProps<T extends string> {
  options: Option<T>[];
  value: T | null;
  onChange: (value: T | null) => void;
  allowNone?: boolean;
  noneLabel?: string;
}

export function OptionPicker<T extends string>({
  options,
  value,
  onChange,
  allowNone,
  noneLabel = "None",
}: OptionPickerProps<T>): JSX.Element {
  return (
    <View className="flex-row flex-wrap gap-2">
      {allowNone ? (
        <Chip variant={value === null ? "primary" : "soft"} onPress={() => onChange(null)}>
          {noneLabel}
        </Chip>
      ) : null}
      {options.map((opt) => (
        <Chip
          key={opt.value}
          variant={value === opt.value ? "primary" : "soft"}
          onPress={() => onChange(opt.value)}
        >
          {opt.label}
        </Chip>
      ))}
    </View>
  );
}
