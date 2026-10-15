import { Ionicons } from "@expo/vector-icons";
import { Chip, Typography } from "heroui-native";
import { router } from "expo-router";
import type { JSX } from "react";
import { Alert, Pressable, View } from "react-native";

import type { EntityId, TaskItem } from "../domain/entities";
import { agendaDueSubtitle, scheduleLabel } from "../domain/taskPresentation";
import { defaultCalendar } from "../domain/taskScheduling";
import { useWorkspaceStore } from "../store/workspaceStore";

export type TaskRowStyle = "standard" | "agenda";

interface TaskRowProps {
  taskID: EntityId;
  style?: TaskRowStyle;
  contextDate?: Date;
}

export function TaskRow({
  taskID,
  style = "standard",
  contextDate,
}: TaskRowProps): JSX.Element | null {
  const task = useWorkspaceStore((s) => s.tasks.find((t) => t.id === taskID));
  const toggleTask = useWorkspaceStore((s) => s.toggleTask);
  const outcome = useWorkspaceStore((s) => s.outcome);
  const hasWorkLog = useWorkspaceStore((s) => s.hasWorkLog);
  const logWork = useWorkspaceStore((s) => s.logWork);
  const removeWorkLog = useWorkspaceStore((s) => s.removeWorkLog);
  const scheduleWork = useWorkspaceStore((s) => s.scheduleWork);
  const pushScheduledWork = useWorkspaceStore((s) => s.pushScheduledWork);
  const clearSchedule = useWorkspaceStore((s) => s.clearSchedule);

  if (!task) {
    return null;
  }

  const referenceDate = contextDate ?? new Date();
  const verticalPad = style === "agenda" ? "py-0.5" : "py-3";

  const openContextMenu = () => {
    showTaskContextMenu({
      task,
      referenceDate,
      hasWorkLog: hasWorkLog(taskID, referenceDate),
      logWork: () => logWork(taskID, referenceDate),
      removeWorkLog: () => removeWorkLog(taskID, referenceDate),
      scheduleForDay: () => scheduleWork(taskID, referenceDate),
      scheduleTodayTomorrow: () => {
        const tomorrow = defaultCalendar.addDays(referenceDate, 1);
        scheduleWork(taskID, referenceDate, tomorrow);
      },
      pushSchedule: () => pushScheduledWork(taskID),
      clearSchedule: () => clearSchedule(taskID),
    });
  };

  return (
    <Pressable
      onLongPress={openContextMenu}
      delayLongPress={400}
      className={`flex-row items-center gap-3 border-b border-default-100 ${verticalPad}`}
    >
      <Pressable
        onPress={() => toggleTask(taskID)}
        hitSlop={8}
        accessibilityRole="button"
        accessibilityLabel="Toggle task completion"
      >
        <Ionicons
          name={task.status === "done" ? "checkmark-circle" : "ellipse-outline"}
          size={22}
          color={task.status === "done" ? "#22c55e" : "#a1a1aa"}
        />
      </Pressable>
      <Pressable
        className="flex-1 gap-1"
        onPress={() => router.push({ pathname: "/forms/task", params: { id: taskID } })}
      >
        <Typography.Paragraph
          className={task.status === "done" ? "line-through text-default-400" : ""}
          numberOfLines={2}
        >
          {task.name}
        </Typography.Paragraph>
        {style === "standard" ? (
          <StandardMetadata task={task} outcomeName={outcome(task.outcomeID)?.name ?? null} />
        ) : (
          <AgendaSubtitle task={task} referenceDate={referenceDate} />
        )}
      </Pressable>
      {style === "agenda" ? (
        <AgendaTrailing
          task={task}
          taskID={taskID}
          referenceDate={referenceDate}
          hasWorkLog={hasWorkLog(taskID, referenceDate)}
        />
      ) : null}
    </Pressable>
  );
}

function StandardMetadata({
  task,
  outcomeName,
}: {
  task: TaskItem;
  outcomeName: string | null;
}): JSX.Element {
  const sched = scheduleLabel(task);
  const dueText = task.dueDate
    ? task.dueDate.toLocaleDateString(undefined, { month: "short", day: "numeric" })
    : null;

  return (
    <View className="flex-row flex-wrap items-center gap-2">
      {task.priority === "high" ? (
        <Chip size="sm" variant="soft" color="warning">
          high
        </Chip>
      ) : null}
      {outcomeName ? (
        <Typography.Paragraph className="text-xs text-default-500" numberOfLines={1}>
          {outcomeName}
        </Typography.Paragraph>
      ) : null}
      {sched ? (
        <Typography.Paragraph className="text-xs text-default-500" numberOfLines={1}>
          {sched}
        </Typography.Paragraph>
      ) : null}
      {dueText ? (
        <Typography.Paragraph className="text-xs text-default-500" numberOfLines={1}>
          {dueText}
        </Typography.Paragraph>
      ) : null}
    </View>
  );
}

function AgendaSubtitle({
  task,
  referenceDate,
}: {
  task: TaskItem;
  referenceDate: Date;
}): JSX.Element | null {
  const subtitle = agendaDueSubtitle(task, referenceDate);
  if (!subtitle) {
    return null;
  }
  return (
    <Typography.Paragraph className="text-xs text-default-400" numberOfLines={1}>
      {subtitle}
    </Typography.Paragraph>
  );
}

function AgendaTrailing({
  task,
  hasWorkLog,
}: {
  task: TaskItem;
  taskID: EntityId;
  referenceDate: Date;
  hasWorkLog: boolean;
}): JSX.Element | null {
  if (!hasWorkLog && task.priority !== "high") {
    return null;
  }
  return (
    <View className="flex-row items-center gap-1.5">
      {hasWorkLog ? (
        <View
          className="h-1.5 w-1.5 rounded-full bg-default-400"
          accessibilityLabel="Work logged"
        />
      ) : null}
      {task.priority === "high" ? (
        <Ionicons name="flag" size={14} color="#f97316" accessibilityLabel="High priority" />
      ) : null}
    </View>
  );
}

function showTaskContextMenu(options: {
  task: TaskItem;
  referenceDate: Date;
  hasWorkLog: boolean;
  logWork: () => void;
  removeWorkLog: () => void;
  scheduleForDay: () => void;
  scheduleTodayTomorrow: () => void;
  pushSchedule: () => void;
  clearSchedule: () => void;
}): void {
  const buttons: { text: string; onPress?: () => void; style?: "cancel" | "destructive" | "default" }[] =
    [];

  if (options.hasWorkLog) {
    buttons.push({
      text: "Remove work log for this day",
      onPress: options.removeWorkLog,
    });
  } else {
    buttons.push({
      text: "Log work for this day",
      onPress: options.logWork,
    });
  }

  buttons.push({ text: "Schedule for this day", onPress: options.scheduleForDay });
  buttons.push({
    text: "Schedule today through tomorrow",
    onPress: options.scheduleTodayTomorrow,
  });

  if (options.task.scheduledStart) {
    buttons.push({ text: "Push schedule 1 day", onPress: options.pushSchedule });
    buttons.push({
      text: "Clear schedule",
      style: "destructive",
      onPress: options.clearSchedule,
    });
  }

  buttons.push({ text: "Cancel", style: "cancel" });

  Alert.alert("Task actions", undefined, buttons);
}
