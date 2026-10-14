import type {
  ActiveThread,
  Area,
  DocumentBlock,
  EntityId,
  InboxEntry,
  Initiative,
  Milestone,
  Outcome,
  Priority,
  TaskItem,
  TaskWorkLog,
  WorkStatus,
  WorkspaceDocument,
  WorkspaceNote,
} from "../domain/entities";
import type { CalendarLike } from "../domain/taskScheduling";

export interface WorkspaceStoreState {
  inboxEntries: InboxEntry[];
  areas: Area[];
  initiatives: Initiative[];
  outcomes: Outcome[];
  milestones: Milestone[];
  tasks: TaskItem[];
  taskWorkLogs: TaskWorkLog[];
  threads: ActiveThread[];
  docs: WorkspaceDocument[];
  notes: WorkspaceNote[];

  area: (id: EntityId | null | undefined) => Area | undefined;
  initiative: (id: EntityId | null | undefined) => Initiative | undefined;
  outcome: (id: EntityId | null | undefined) => Outcome | undefined;
  resolvedAreaID: (task: TaskItem) => EntityId | null;
  resolvedInitiativeID: (task: TaskItem) => EntityId | null;
  resolvedOutcomeID: (task: TaskItem) => EntityId | null;
  tasksForAgendaOn: (
    date: Date,
    filters?: { areaID?: EntityId | null; initiativeID?: EntityId | null; outcomeID?: EntityId | null },
    calendar?: CalendarLike,
  ) => TaskItem[];
  toggleTask: (taskID: EntityId) => void;
  addDocument: (name?: string) => EntityId;
  addNote: (name?: string) => EntityId;
  updateDocumentName: (documentID: EntityId, name: string) => void;
  updateNoteName: (noteID: EntityId, name: string) => void;
  updateDocumentBlock: (documentID: EntityId, blockID: EntityId, patch: Partial<DocumentBlock>) => void;
  addDocumentBlock: (
    documentID: EntityId,
    afterBlockID: EntityId | null,
    type?: DocumentBlock["type"],
    text?: string,
  ) => EntityId | null;
  interpretDocumentSyntax: (documentID: EntityId, blockID: EntityId) => void;
  addInboxEntry: (text: string) => void;
  addArea: (name: string, icon: string) => void;
  logWork: (taskID: EntityId, date?: Date, calendar?: CalendarLike) => void;


  addInitiative: (name: string, areaID: EntityId | null, status: WorkStatus) => void;
  addOutcome: (
    name: string,
    initiativeID: EntityId | null,
    status: WorkStatus,
    targetDate: Date | null,
  ) => void;
  addTask: (input: {
    name: string;
    areaID: EntityId | null;
    initiativeID: EntityId | null;
    outcomeID: EntityId | null;
    priority: Priority;
    scheduledStart?: Date | null;
    scheduledEnd?: Date | null;
    dueDate?: Date | null;
  }) => void;
}
