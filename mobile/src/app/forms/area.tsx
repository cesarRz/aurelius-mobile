import { router, useLocalSearchParams } from "expo-router";
import type { JSX } from "react";
import { useState } from "react";
import { TextInput, View } from "react-native";

import { FormScreen } from "@/components/forms/FormScreen";
import { FormSection } from "@/components/forms/FormSection";
import { OptionPicker } from "@/components/forms/OptionPicker";
import { useWorkspaceStore } from "@/store/workspaceStore";
import { AREA_ICON_OPTIONS } from "@/utils/areaIcons";

function AreaFormContent({ areaId }: { areaId?: string }): JSX.Element {
  const area = useWorkspaceStore((s) => (areaId ? s.areas.find((a) => a.id === areaId) : undefined));
  const addArea = useWorkspaceStore((s) => s.addArea);
  const updateArea = useWorkspaceStore((s) => s.updateArea);

  const [name, setName] = useState(area?.name ?? "");
  const [icon, setIcon] = useState(area?.icon ?? AREA_ICON_OPTIONS[0] ?? "briefcase");

  const trimmed = name.trim();
  const isEdit = Boolean(areaId);

  return (
    <FormScreen
      title={isEdit ? "Edit Area" : "New Area"}
      saveLabel={isEdit ? "Save" : "Create"}
      saveDisabled={!trimmed}
      onSave={() => {
        if (!trimmed) {
          return;
        }
        if (areaId) {
          updateArea(areaId, trimmed, icon);
        } else {
          addArea(trimmed, icon);
        }
        router.back();
      }}
    >
      <FormSection title="Area">
        <TextInput
          value={name}
          onChangeText={setName}
          placeholder="Name"
          className="border border-default-200 rounded-xl px-3 py-2 text-foreground"
          placeholderTextColor="#9ca3af"
        />
        <View className="gap-2">
          <OptionPicker
            options={AREA_ICON_OPTIONS.map((value) => ({ value, label: value }))}
            value={icon}
            onChange={(value) => value && setIcon(value)}
          />
        </View>
      </FormSection>
    </FormScreen>
  );
}

export default function AreaFormScreen(): JSX.Element {
  const { id } = useLocalSearchParams<{ id?: string }>();
  return <AreaFormContent key={id ?? "new"} areaId={id} />;
}
