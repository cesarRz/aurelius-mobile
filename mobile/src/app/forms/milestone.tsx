import { Typography } from "heroui-native";
import { router, useLocalSearchParams } from "expo-router";
import type { JSX } from "react";
import { useMemo, useState } from "react";
import { View } from "react-native";

import { FormScreen } from "@/components/forms/FormScreen";
import { FormSection } from "@/components/forms/FormSection";
import { LabeledInput } from "@/components/forms/LabeledInput";
import { OptionPicker } from "@/components/forms/OptionPicker";
import { useWorkspaceStore } from "@/store/workspaceStore";

export default function MilestoneFormScreen(): JSX.Element {
  const { outcomeId } = useLocalSearchParams<{ outcomeId?: string }>();
  const outcomes = useWorkspaceStore((s) => s.outcomes);
  const addMilestone = useWorkspaceStore((s) => s.addMilestone);

  const [name, setName] = useState("");
  const [selectedOutcomeID, setSelectedOutcomeID] = useState<string | null>(outcomeId ?? null);

  const outcomeOptions = useMemo(
    () => outcomes.map((o) => ({ value: o.id, label: o.name })),
    [outcomes],
  );

  const trimmed = name.trim();

  return (
    <FormScreen
      title="New Milestone"
      saveLabel="Create"
      saveDisabled={!trimmed || !selectedOutcomeID}
      onSave={() => {
        if (!trimmed || !selectedOutcomeID) {
          return;
        }
        addMilestone(trimmed, selectedOutcomeID);
        router.back();
      }}
    >
      <FormSection title="Milestone">
        <LabeledInput
          label="What marks progress?"
          value={name}
          onChangeText={setName}
          placeholder="Milestone name"
        />
        <View className="gap-2">
          <Typography.Paragraph className="text-sm text-default-500">Outcome</Typography.Paragraph>
          <OptionPicker
            options={outcomeOptions}
            value={selectedOutcomeID}
            onChange={setSelectedOutcomeID}
            noneLabel="Select outcome"
          />
        </View>
      </FormSection>
    </FormScreen>
  );
}
