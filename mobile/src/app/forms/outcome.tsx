import { Switch, Typography } from "heroui-native";
import { router, useLocalSearchParams } from "expo-router";
import type { JSX } from "react";
import { useMemo, useState } from "react";
import { View } from "react-native";

import { DateField } from "@/components/forms/DateField";
import { FormScreen } from "@/components/forms/FormScreen";
import { FormSection } from "@/components/forms/FormSection";
import { LabeledInput } from "@/components/forms/LabeledInput";
import { OptionPicker } from "@/components/forms/OptionPicker";
import type { WorkStatus } from "@/domain/entities";
import { WORK_STATUSES, WORK_STATUS_LABELS } from "@/domain/labels";
import { defaultCalendar } from "@/domain/taskScheduling";
import { useWorkspaceStore } from "@/store/workspaceStore";

function OutcomeFormContent({
  outcomeId,
  presetInitiativeId,
}: {
  outcomeId?: string;
  presetInitiativeId?: string;
}): JSX.Element {
  const outcome = useWorkspaceStore((s) =>
    outcomeId ? s.outcomes.find((o) => o.id === outcomeId) : undefined,
  );
  const initiatives = useWorkspaceStore((s) => s.initiatives);
  const addOutcome = useWorkspaceStore((s) => s.addOutcome);
  const updateOutcome = useWorkspaceStore((s) => s.updateOutcome);

  const [name, setName] = useState(outcome?.name ?? "");
  const [selectedInitiativeID, setSelectedInitiativeID] = useState<string | null>(
    outcome?.initiativeID ?? presetInitiativeId ?? null,
  );
  const [status, setStatus] = useState<WorkStatus>(outcome?.status ?? "notStarted");
  const [hasTargetDate, setHasTargetDate] = useState(outcome ? outcome.targetDate != null : true);
  const [targetDate, setTargetDate] = useState(
    () => outcome?.targetDate ?? defaultCalendar.addDays(new Date(), 30),
  );

  const initiativeOptions = useMemo(
    () => initiatives.map((i) => ({ value: i.id, label: i.name })),
    [initiatives],
  );

  const trimmed = name.trim();
  const isEdit = Boolean(outcomeId);

  return (
    <FormScreen
      title={isEdit ? "Edit Outcome" : "New Outcome"}
      saveLabel={isEdit ? "Save" : "Create"}
      saveDisabled={!trimmed}
      onSave={() => {
        if (!trimmed) {
          return;
        }
        const date = hasTargetDate ? targetDate : null;
        if (outcomeId) {
          updateOutcome(outcomeId, trimmed, selectedInitiativeID, status, date);
        } else {
          addOutcome(trimmed, selectedInitiativeID, status, date);
        }
        router.back();
      }}
    >
      <FormSection title="Outcome">
        <LabeledInput
          label="What do you want to achieve?"
          value={name}
          onChangeText={setName}
          placeholder="Outcome name"
        />
        <View className="gap-2">
          <Typography.Paragraph className="text-sm text-default-500">Initiative</Typography.Paragraph>
          <OptionPicker
            options={initiativeOptions}
            value={selectedInitiativeID}
            onChange={setSelectedInitiativeID}
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
      <FormSection title="Target">
        <View className="flex-row items-center justify-between">
          <Typography.Paragraph>Target date</Typography.Paragraph>
          <Switch isSelected={hasTargetDate} onSelectedChange={setHasTargetDate} />
        </View>
        {hasTargetDate ? <DateField label="Date" value={targetDate} onChange={setTargetDate} /> : null}
      </FormSection>
    </FormScreen>
  );
}

export default function OutcomeFormScreen(): JSX.Element {
  const { id, initiativeId } = useLocalSearchParams<{ id?: string; initiativeId?: string }>();
  return (
    <OutcomeFormContent
      key={`${id ?? "new"}-${initiativeId ?? ""}`}
      outcomeId={id}
      presetInitiativeId={initiativeId}
    />
  );
}
