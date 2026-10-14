import { Button, Typography } from "heroui-native";
import DateTimePicker from "@react-native-community/datetimepicker";
import type { JSX } from "react";
import { useState } from "react";
import { Platform, View } from "react-native";

interface DateFieldProps {
  label: string;
  value: Date;
  onChange: (date: Date) => void;
}

export function DateField({ label, value, onChange }: DateFieldProps): JSX.Element {
  const [open, setOpen] = useState(false);

  return (
    <View className="gap-2">
      <Typography.Paragraph className="text-sm text-default-500">{label}</Typography.Paragraph>
      <Button variant="secondary" onPress={() => setOpen(true)}>
        {value.toLocaleDateString()}
      </Button>
      {open ? (
        <DateTimePicker
          value={value}
          mode="date"
          display={Platform.OS === "ios" ? "spinner" : "default"}
          onChange={(_, date) => {
            setOpen(Platform.OS === "ios");
            if (date) {
              onChange(date);
            }
          }}
        />
      ) : null}
    </View>
  );
}
