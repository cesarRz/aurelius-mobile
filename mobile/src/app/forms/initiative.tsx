import { Typography } from "heroui-native";
import { router, useLocalSearchParams } from "expo-router";
import type { JSX } from "react";
import { useMemo, useState } from "react";
import { View } from "react-native";

import { FormScreen } from "@/components/forms/FormScreen";
import { FormSection } from "@/components/forms/FormSection";
import { LabeledInput } from "@/components/forms/LabeledInput";
import { OptionPicker } from "@/components/forms/OptionPicker";
import type { WorkStatus } from "@/domain/entities";
import { WORK_STATUSES, WORK_STATUS_LABELS } from "@/domain/labels";
import { useWorkspaceStore } from "@/store/workspaceStore";

function InitiativeFormContent({
  initiativeId,
  presetAreaId,
}: {
  initiativeId?: string;
  presetAreaId?: string;
}): JSX.Element {
  const initiative = useWorkspaceStore((s) =>
    initiativeId ? s.initiatives.find((i) => i.id === initiativeId) : undefined,
  );
  const areas = useWorkspaceStore((s) => s.areas);
  const addInitiative = useWorkspaceStore((s) => s.addInitiative);
  const updateInitiative = useWorkspaceStore((s) => s.updateInitiative);

  const [name, setName] = useState(initiative?.name ?? "");
  const [selectedAreaID, setSelectedAreaID] = useState<string | null>(
    initiative?.areaID ?? presetAreaId ?? null,
  );
  const [status, setStatus] = useState<WorkStatus>(initiative?.status ?? "notStarted");

  const areaOptions = useMemo(
    () => areas.map((a) => ({ value: a.id, label: a.name })),
    [areas],
  );

  const trimmed = name.trim();
  const isEdit = Boolean(initiativeId);

  return (
    <FormScreen
      title={isEdit ? "Edit Initiative" : "New Initiative"}
      saveLabel={isEdit ? "Save" : "Create"}
      saveDisabled={!trimmed}
      onSave={() => {
        if (!trimmed) {
          return;
        }
        if (initiativeId) {
          updateInitiative(initiativeId, trimmed, selectedAreaID, status);
        } else {
          addInitiative(trimmed, selectedAreaID, status);
        }
        router.back();
      }}
    >
      <FormSection title="Initiative">
        <LabeledInput label="Name" value={name} onChangeText={setName} placeholder="Name" />
        <View className="gap-2">
          <Typography.Paragraph className="text-sm text-default-500">Area</Typography.Paragraph>
          <OptionPicker
            options={areaOptions}
            value={selectedAreaID}
            onChange={setSelectedAreaID}
            allowNone
          />
        </View>
        <View className="gap-2">
          <Typography.Paragraph className="text-sm text-default-500">Status</Typography.Paragraph>
          <OptionPicker
            options={WORK_STATUSES.map((s) => ({ value: s, label: WORK_STATUS_LABELS[s] }))}
            value={status}
            onChange={(value) => value && setStatus(value)}
          />
        </View>
      </FormSection>
    </FormScreen>
  );
}

export default function InitiativeFormScreen(): JSX.Element {
  const { id, areaId } = useLocalSearchParams<{ id?: string; areaId?: string }>();
  return (
    <InitiativeFormContent
      key={`${id ?? "new"}-${areaId ?? ""}`}
      initiativeId={id}
      presetAreaId={areaId}
    />
  );
}
