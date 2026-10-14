import { taskScheduling, type CalendarLike, defaultCalendar } from "./taskScheduling";

export type WorkStatus = "notStarted" | "inProgress" | "done";

export type Priority = "low" | "medium" | "high";

export type BlockType =
  | "paragraph"
  | "heading1"
  | "heading2"
  | "heading3"
  | "bullet"
  | "checklist"
  | "quote"
  | "code"
  | "divider"
  | "drawing";

export type EntityId = string;

export interface Area {
  id: EntityId;
  name: string;
  icon: string;
}

export interface Initiative {
  id: EntityId;
  name: string;
  areaID: EntityId | null;
  status: WorkStatus;
}

export interface Outcome {
  id: EntityId;
  name: string;
  initiativeID: EntityId | null;
  status: WorkStatus;
  targetDate: Date | null;
}

export interface Milestone {
  id: EntityId;
  name: string;
  outcomeID: EntityId;
  isCompleted?: boolean;
}

export interface TaskItem {
  id: EntityId;
  name: string;
  areaID: EntityId | null;
  initiativeID: EntityId | null;
  outcomeID: EntityId | null;
  milestoneID: EntityId | null;
  status: WorkStatus;
  priority: Priority;
  scheduledStart: Date | null;
  scheduledEnd: Date | null;
  dueDate: Date | null;
}

export interface TaskWorkLog {
  id: EntityId;
  taskID: EntityId;
  workDate: Date;
}

export interface ActiveThread {
  id: EntityId;
  name: string;
  outcomeID: EntityId | null;
  detail: string;
}

/** JSON stroke payload for @shopify/react-native-skia (replaces PencilKit PKDrawing). */
export interface DocumentBlock {
  id: EntityId;
  type: BlockType;
  text: string;
  isChecked: boolean;
  /** UTF-8 JSON: {@link DrawingDocument} */
  drawingData: string;
}

export interface WorkspaceDocument {
  id: EntityId;
  name: string;
  initiativeID: EntityId | null;
  outcomeID: EntityId | null;
  blocks: DocumentBlock[];
}

export interface WorkspaceNote {
  id: EntityId;
  name: string;
  outcomeID: EntityId | null;
  blocks: DocumentBlock[];
}

export interface InboxEntry {
  id: EntityId;
  text: string;
  createdAt: Date;
}

export interface DrawingPoint {
  x: number;
  y: number;
}

export interface DrawingStroke {
  color: string;
  width: number;
  points: DrawingPoint[];
}

export interface DrawingDocument {
  version: 1;
  strokes: DrawingStroke[];
}

export const BLOCK_TYPES: BlockType[] = [
  "paragraph",
  "heading1",
  "heading2",
  "heading3",
  "bullet",
  "checklist",
  "quote",
  "code",
  "divider",
  "drawing",
];

export function typeAfterReturn(type: BlockType): BlockType {
  if (type === "bullet" || type === "checklist") {
    return type;
  }
  return "paragraph";
}

export function splitOnReturn(text: string): { kept: string; remainder: string } | null {
  const newline = text.indexOf("\n");
  if (newline === -1) {
    return null;
  }
  const kept = text.slice(0, newline);
  const remainder = text
    .slice(newline + 1)
    .split("\n")
    .join("");
  return { kept, remainder };
}

export function createBlock(partial?: Partial<DocumentBlock>): DocumentBlock {
  return {
    id: crypto.randomUUID(),
    type: partial?.type ?? "paragraph",
    text: partial?.text ?? "",
    isChecked: partial?.isChecked ?? false,
    drawingData: partial?.drawingData ?? "",
  };
}

export function isScheduledOn(
  task: TaskItem,
  date: Date,
  calendar: CalendarLike = defaultCalendar,
): boolean {
  return taskScheduling.rangeContains(date, task.scheduledStart, task.scheduledEnd, calendar);
}
