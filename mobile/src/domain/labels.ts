import type { Priority, WorkStatus } from "./entities";

export const WORK_STATUS_LABELS: Record<WorkStatus, string> = {
  notStarted: "Not Started",
  inProgress: "In Progress",
  done: "Done",
};

export const PRIORITY_LABELS: Record<Priority, string> = {
  low: "Low",
  medium: "Medium",
  high: "High",
};

export const WORK_STATUSES: WorkStatus[] = ["notStarted", "inProgress", "done"];
export const PRIORITIES: Priority[] = ["low", "medium", "high"];
