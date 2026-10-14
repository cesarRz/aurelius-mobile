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
import type { Priority } from "@/domain/entities";
import { PRIORITIES, PRIORITY_LABELS } from "@/domain/labels";
import { defaultCalendar } from "@/domain/taskScheduling";
import { useWorkspaceStore } from "@/store/workspaceStore";

function loadScheduleFromTask(task: ReturnType<typeof useWorkspaceStore.getState>["tasks"][0]) {
  let hasWorkSchedule = false;
  let scheduledStart = defaultCalendar.startOfDay(new Date());
  let hasScheduleEnd = false;
  let scheduledEnd = defaultCalendar.startOfDay(new Date());
  if (task.scheduledStart) {
    hasWorkSchedule = true;
    scheduledStart = task.scheduledStart;
    if (task.scheduledEnd && !defaultCalendar.isSameDay(task.scheduledStart, task.scheduledEnd)) {
      hasScheduleEnd = true;
      scheduledEnd = task.scheduledEnd;
    }
  }
  return { hasWorkSchedule, scheduledStart, hasScheduleEnd, scheduledEnd };
}

function TaskFormContent({
  taskId,
  presetOutcomeId,
  presetInitiativeId,
}: {
  taskId?: string;
  presetOutcomeId?: string;
  presetInitiativeId?: string;
}): JSX.Element {
  const task = useWorkspaceStore((s) => (taskId ? s.tasks.find((t) => t.id === taskId) : undefined));
  const areas = useWorkspaceStore((s) => s.areas);
  const initiatives = useWorkspaceStore((s) => s.initiatives);
  const outcomes = useWorkspaceStore((s) => s.outcomes);
  const addTask = useWorkspaceStore((s) => s.addTask);
  const updateTask = useWorkspaceStore((s) => s.updateTask);
  const initiative = useWorkspaceStore((s) => s.initiative);

  const scheduleDefaults = task
    ? loadScheduleFromTask(task)
    : {
        hasWorkSchedule: false,
        scheduledStart: defaultCalendar.startOfDay(new Date()),
        hasScheduleEnd: false,
        scheduledEnd: defaultCalendar.startOfDay(new Date()),
      };

  const [name, setName] = useState(task?.name ?? "");
  const [areaID, setAreaID] = useState<string | null>(task?.areaID ?? null);
  const [selectedInitiativeID, setSelectedInitiativeID] = useState<string | null>(
    task?.initiativeID ?? presetInitiativeId ?? null,
  );
  const [selectedOutcomeID, setSelectedOutcomeID] = useState<string | null>(
    task?.outcomeID ?? presetOutcomeId ?? null,
  );
  const [priority, setPriority] = useState<Priority>(task?.priority ?? "medium");
  const [hasWorkSchedule, setHasWorkSchedule] = useState(scheduleDefaults.hasWorkSchedule);
  const [scheduledStart, setScheduledStart] = useState(scheduleDefaults.scheduledStart);
  const [hasScheduleEnd, setHasScheduleEnd] = useState(scheduleDefaults.hasScheduleEnd);
  const [scheduledEnd, setScheduledEnd] = useState(scheduleDefaults.scheduledEnd);
  const [hasDueDate, setHasDueDate] = useState(Boolean(task?.dueDate));
  const [dueDate, setDueDate] = useState(() => task?.dueDate ?? new Date());

  const availableInitiatives = useMemo(() => {
    if (!areaID) {
      return initiatives;
    }
    return initiatives.filter((i) => i.areaID === areaID);
  }, [areaID, initiatives]);

  const availableOutcomes = useMemo(() => {
    if (!selectedInitiativeID) {
      return outcomes;
    }
    return outcomes.filter((o) => o.initiativeID === selectedInitiativeID);
  }, [selectedInitiativeID, outcomes]);

  const trimmed = name.trim();
  const isEdit = Boolean(taskId);

  const persist = () => {
    if (!trimmed) {
      return;
    }
    const payload = {
      name: trimmed,
      areaID,
      initiativeID: selectedInitiativeID,
      outcomeID: selectedOutcomeID,
      priority,
      scheduledStart: hasWorkSchedule ? scheduledStart : null,
      scheduledEnd:
        hasWorkSchedule && hasScheduleEnd ? scheduledEnd : hasWorkSchedule ? scheduledStart : null,
      dueDate: hasDueDate ? dueDate : null,
    };
    if (taskId) {
      updateTask({ id: taskId, ...payload });
    } else {
      addTask(payload);
    }
    router.back();
  };

  return (
    <FormScreen
      title={isEdit ? "Edit Task" : "New Task"}
      saveLabel={isEdit ? "Save" : "Create"}
      saveDisabled={!trimmed}
      onSave={persist}
    >
      <FormSection title="Task">
        <LabeledInput
          label="What needs to be done?"
          value={name}
          onChangeText={setName}
          placeholder="Task name"
        />
        <View className="gap-2">
          <Typography.Paragraph className="text-sm text-default-500">Priority</Typography.Paragraph>
          <OptionPicker
            options={PRIORITIES.map((p) => ({ value: p, label: PRIORITY_LABELS[p] }))}
            value={priority}
            onChange={(value) => value && setPriority(value)}
          />
        </View>
      </FormSection>

      <FormSection title="Context">
        <View className="gap-2">
          <Typography.Paragraph className="text-sm text-default-500">Area</Typography.Paragraph>
          <OptionPicker
            options={areas.map((a) => ({ value: a.id, label: a.name }))}
            value={areaID}
            onChange={(next) => {
              setAreaID(next);
              if (next && selectedInitiativeID) {
                const stillValid = initiatives.some(
                  (i) => i.id === selectedInitiativeID && i.areaID === next,
                );
                if (!stillValid) {
                  setSelectedInitiativeID(null);
                  setSelectedOutcomeID(null);
                }
              }
            }}
            allowNone
          />
        </View>
        <View className="gap-2">
          <Typography.Paragraph className="text-sm text-default-500">Initiative</Typography.Paragraph>
          <OptionPicker
            options={availableInitiatives.map((i) => ({ value: i.id, label: i.name }))}
            value={selectedInitiativeID}
            onChange={(next) => {
              setSelectedInitiativeID(next);
              if (next) {
                const init = initiative(next);
                if (init?.areaID) {
                  setAreaID(init.areaID);
                }
              }
              if (next && selectedOutcomeID) {
                const ok = outcomes.some(
                  (o) => o.id === selectedOutcomeID && o.initiativeID === next,
                );
                if (!ok) {
                  setSelectedOutcomeID(null);
                }
              }
            }}
            allowNone
          />
        </View>
        <View className="gap-2">
          <Typography.Paragraph className="text-sm text-default-500">Outcome</Typography.Paragraph>
          <OptionPicker
            options={availableOutcomes.map((o) => ({ value: o.id, label: o.name }))}
            value={selectedOutcomeID}
            onChange={(next) => {
              setSelectedOutcomeID(next);
              if (next) {
                const out = outcomes.find((o) => o.id === next);
                if (out?.initiativeID) {
                  setSelectedInitiativeID(out.initiativeID);
                  const init = initiative(out.initiativeID);
                  if (init?.areaID) {
                    setAreaID(init.areaID);
                  }
                }
              }
            }}
            allowNone
          />
        </View>
      </FormSection>

      <FormSection title="Work schedule">
        <View className="flex-row items-center justify-between">
          <Typography.Paragraph>Plan work dates</Typography.Paragraph>
          <Switch isSelected={hasWorkSchedule} onSelectedChange={setHasWorkSchedule} />
        </View>
        {hasWorkSchedule ? (
          <>
            <DateField label="From" value={scheduledStart} onChange={setScheduledStart} />
            <View className="flex-row items-center justify-between">
              <Typography.Paragraph>Multi-day period</Typography.Paragraph>
              <Switch isSelected={hasScheduleEnd} onSelectedChange={setHasScheduleEnd} />
            </View>
            {hasScheduleEnd ? (
              <DateField label="Through" value={scheduledEnd} onChange={setScheduledEnd} />
            ) : null}
          </>
        ) : null}
      </FormSection>

      <FormSection title="Deadline">
        <View className="flex-row items-center justify-between">
          <Typography.Paragraph>Due date</Typography.Paragraph>
          <Switch isSelected={hasDueDate} onSelectedChange={setHasDueDate} />
        </View>
        {hasDueDate ? <DateField label="Date" value={dueDate} onChange={setDueDate} /> : null}
      </FormSection>
    </FormScreen>
  );
}

export default function TaskFormScreen(): JSX.Element {
  const { id, outcomeId, initiativeId } = useLocalSearchParams<{
    id?: string;
    outcomeId?: string;
    initiativeId?: string;
  }>();
  return (
    <TaskFormContent
      key={`${id ?? "new"}-${outcomeId ?? ""}-${initiativeId ?? ""}`}
      taskId={id}
      presetOutcomeId={outcomeId}
      presetInitiativeId={initiativeId}
    />
  );
}
