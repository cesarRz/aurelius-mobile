import type { TaskItem } from "./entities";
import type { CalendarLike } from "./taskScheduling";
import { defaultCalendar } from "./taskScheduling";

export function scheduleLabel(
  task: TaskItem,
  calendar: CalendarLike = defaultCalendar,
): string | null {
  const start = task.scheduledStart;
  if (!start) {
    return null;
  }
  const end = task.scheduledEnd ?? start;
  if (calendar.isSameDay(start, end)) {
    return start.toLocaleDateString(undefined, { month: "short", day: "numeric" });
  }
  const startText = start.toLocaleDateString(undefined, { month: "short", day: "numeric" });
  const endText = end.toLocaleDateString(undefined, { month: "short", day: "numeric" });
  return `${startText} – ${endText}`;
}

export function agendaDueSubtitle(
  task: TaskItem,
  referenceDate: Date,
  calendar: CalendarLike = defaultCalendar,
): string | null {
  const dueDate = task.dueDate;
  if (!dueDate) {
    return null;
  }
  if (calendar.isSameDay(dueDate, referenceDate)) {
    return "Due today";
  }
  return `Due ${dueDate.toLocaleDateString(undefined, { month: "short", day: "numeric" })}`;
}
