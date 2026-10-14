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
  initiativesForArea: (areaID: EntityId) => Initiative[];
  outcomesForInitiative: (initiativeID: EntityId) => Outcome[];
  tasksForInitiative: (initiativeID: EntityId) => TaskItem[];
  tasksForOutcome: (outcomeID: EntityId) => TaskItem[];
  docsForOutcome: (outcomeID: EntityId) => WorkspaceDocument[];
  notesForOutcome: (outcomeID: EntityId) => WorkspaceNote[];
  progressForOutcome: (outcomeID: EntityId) => number;
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
  updateArea: (id: EntityId, name: string, icon: string) => void;
  logWork: (taskID: EntityId, date?: Date, calendar?: CalendarLike) => void;
  addMilestone: (name: string, outcomeID: EntityId) => void;
  updateInitiative: (
    id: EntityId,
    name: string,
    areaID: EntityId | null,
    status: WorkStatus,
  ) => void;
  updateOutcome: (
    id: EntityId,
    name: string,
    initiativeID: EntityId | null,
    status: WorkStatus,
    targetDate: Date | null,
  ) => void;
  updateTask: (input: {
    id: EntityId;
    name: string;
    areaID: EntityId | null;
    initiativeID: EntityId | null;
    outcomeID: EntityId | null;
    priority: Priority;
    scheduledStart: Date | null;
    scheduledEnd: Date | null;
    dueDate: Date | null;
  }) => void;
  updateNoteBlock: (noteID: EntityId, blockID: EntityId, patch: Partial<DocumentBlock>) => void;
  addNoteBlock: (
    noteID: EntityId,
    afterBlockID: EntityId | null,
    type?: DocumentBlock["type"],
    text?: string,
  ) => EntityId | null;
  interpretNoteSyntax: (noteID: EntityId, blockID: EntityId) => void;
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
