import { Ionicons } from "@expo/vector-icons";
import { Typography } from "heroui-native";
import type { JSX } from "react";
import { useEffect, useMemo, useState } from "react";
import { Modal, Pressable, ScrollView, View } from "react-native";

import type { AgendaTaskGroupingMode } from "@/domain/agendaGrouping";
import type { EntityId } from "@/domain/entities";
import { useWorkspaceStore } from "@/store/workspaceStore";

interface AgendaTaskOptionsProps {
  grouping: AgendaTaskGroupingMode;
  onGroupingChange: (mode: AgendaTaskGroupingMode) => void;
  initiativeID: EntityId | null;
  onInitiativeIDChange: (id: EntityId | null) => void;
  outcomeID: EntityId | null;
  onOutcomeIDChange: (id: EntityId | null) => void;
}

export function AgendaTaskOptions({
  grouping,
  onGroupingChange,
  initiativeID,
  onInitiativeIDChange,
  outcomeID,
  onOutcomeIDChange,
}: AgendaTaskOptionsProps): JSX.Element {
  const initiatives = useWorkspaceStore((s) => s.initiatives);
  const outcomes = useWorkspaceStore((s) => s.outcomes);
  const outcome = useWorkspaceStore((s) => s.outcome);

  const [open, setOpen] = useState(false);

  const availableOutcomes = useMemo(
    () => outcomes.filter((o) => initiativeID === null || o.initiativeID === initiativeID),
    [outcomes, initiativeID],
  );

  useEffect(() => {
    if (initiativeID && outcomeID) {
      const selectedOutcome = outcome(outcomeID);
      if (selectedOutcome && selectedOutcome.initiativeID !== initiativeID) {
        onOutcomeIDChange(null);
      }
    }
  }, [initiativeID, outcomeID, outcome, onOutcomeIDChange]);

  const filtersActive = initiativeID !== null || outcomeID !== null;

  return (
    <>
      <Pressable
        onPress={() => setOpen(true)}
        hitSlop={8}
        accessibilityRole="button"
        accessibilityLabel="Task grouping and filters"
        className="h-11 w-11 items-center justify-center"
      >
        <Ionicons
          name={filtersActive ? "funnel" : "options-outline"}
          size={22}
          color="#71717a"
        />
      </Pressable>

      <Modal visible={open} animationType="slide" transparent onRequestClose={() => setOpen(false)}>
        <Pressable className="flex-1 bg-black/40 justify-end" onPress={() => setOpen(false)}>
          <Pressable className="bg-background rounded-t-2xl max-h-[80%]" onPress={() => {}}>
            <ScrollView contentContainerClassName="p-4 gap-6">
              <View className="flex-row justify-between items-center">
                <Typography.Heading className="text-lg">Tasks</Typography.Heading>
                <Pressable onPress={() => setOpen(false)}>
                  <Typography.Paragraph className="text-accent">Done</Typography.Paragraph>
                </Pressable>
              </View>

              <View className="gap-2">
                <Typography.Paragraph className="text-default-500 text-sm">Group by</Typography.Paragraph>
                {(["initiative", "outcome"] as const).map((mode) => (
                  <Pressable
                    key={mode}
                    className="py-2"
                    onPress={() => onGroupingChange(mode)}
                  >
                    <Typography.Paragraph
                      className={grouping === mode ? "font-semibold text-accent" : ""}
                    >
                      {mode.charAt(0).toUpperCase() + mode.slice(1)}
                    </Typography.Paragraph>
                  </Pressable>
                ))}
              </View>

              <View className="gap-2">
                <Typography.Paragraph className="text-default-500 text-sm">
                  Filter by initiative
                </Typography.Paragraph>
                <Pressable className="py-2" onPress={() => onInitiativeIDChange(null)}>
                  <Typography.Paragraph
                    className={initiativeID === null ? "font-semibold text-accent" : ""}
                  >
                    All initiatives
                  </Typography.Paragraph>
                </Pressable>
                {initiatives.map((initiative) => (
                  <Pressable
                    key={initiative.id}
                    className="py-2"
                    onPress={() => onInitiativeIDChange(initiative.id)}
                  >
                    <Typography.Paragraph
                      className={initiativeID === initiative.id ? "font-semibold text-accent" : ""}
                    >
                      {initiative.name}
                    </Typography.Paragraph>
                  </Pressable>
                ))}
              </View>

              <View className="gap-2">
                <Typography.Paragraph className="text-default-500 text-sm">
                  Filter by outcome
                </Typography.Paragraph>
                <Pressable className="py-2" onPress={() => onOutcomeIDChange(null)}>
                  <Typography.Paragraph
                    className={outcomeID === null ? "font-semibold text-accent" : ""}
                  >
                    All outcomes
                  </Typography.Paragraph>
                </Pressable>
                {availableOutcomes.map((outcome) => (
                  <Pressable
                    key={outcome.id}
                    className="py-2"
                    onPress={() => onOutcomeIDChange(outcome.id)}
                  >
                    <Typography.Paragraph
                      className={outcomeID === outcome.id ? "font-semibold text-accent" : ""}
                    >
                      {outcome.name}
                    </Typography.Paragraph>
                  </Pressable>
                ))}
              </View>

              {filtersActive ? (
                <Pressable
                  onPress={() => {
                    onInitiativeIDChange(null);
                    onOutcomeIDChange(null);
                  }}
                >
                  <Typography.Paragraph className="text-danger">Clear task filters</Typography.Paragraph>
                </Pressable>
              ) : null}
            </ScrollView>
          </Pressable>
        </Pressable>
      </Modal>
    </>
  );
}
