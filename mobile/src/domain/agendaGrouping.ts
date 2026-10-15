import type { TaskItem } from "./entities";
import type { WorkspaceStoreState } from "../store/workspaceStoreTypes";

export type AgendaTaskGroupingMode = "initiative" | "outcome";

export interface AgendaTaskGroup {
  id: string | null;
  title: string;
  tasks: TaskItem[];
}

export function agendaGroups(
  mode: AgendaTaskGroupingMode,
  tasks: TaskItem[],
  store: WorkspaceStoreState,
): AgendaTaskGroup[] {
  const grouped = new Map<string | null, TaskItem[]>();

  for (const task of tasks) {
    const key =
      mode === "initiative"
        ? store.resolvedInitiativeID(task)
        : store.resolvedOutcomeID(task);
    const list = grouped.get(key) ?? [];
    list.push(task);
    grouped.set(key, list);
  }

  const groups: AgendaTaskGroup[] = [];
  for (const [id, groupTasks] of grouped) {
    const title =
      mode === "initiative"
        ? (store.initiative(id)?.name ?? "No initiative")
        : (store.outcome(id)?.name ?? "No outcome");
    groups.push({ id, title, tasks: groupTasks });
  }

  return groups.sort((lhs, rhs) => {
    if (lhs.id === null && rhs.id !== null) {
      return 1;
    }
    if (rhs.id === null && lhs.id !== null) {
      return -1;
    }
    if (lhs.title === rhs.title) {
      return (lhs.id ?? "").localeCompare(rhs.id ?? "");
    }
    return lhs.title.localeCompare(rhs.title, undefined, { sensitivity: "base" });
  });
}
