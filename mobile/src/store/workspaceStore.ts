import { create } from "zustand";

import { interpretBlockSyntax } from "../domain/blockSyntax";
import {
  createBlock,
  isScheduledOn,
  type EntityId,
  type InboxEntry,
  type TaskItem,
  type WorkspaceDocument,
  type WorkspaceNote,
} from "../domain/entities";
import { taskScheduling, defaultCalendar } from "../domain/taskScheduling";
import { newEntityId } from "../lib/newEntityId";
import { buildSampleWorkspace } from "./sampleData";
import type { WorkspaceStoreState } from "./workspaceStoreTypes";

function matchesAgendaFilters(
  task: TaskItem,
  store: WorkspaceStoreState,
  areaID?: EntityId | null,
  initiativeID?: EntityId | null,
  outcomeID?: EntityId | null,
): boolean {
  return (
    (areaID == null || store.resolvedAreaID(task) === areaID) &&
    (initiativeID == null || store.resolvedInitiativeID(task) === initiativeID) &&
    (outcomeID == null || store.resolvedOutcomeID(task) === outcomeID)
  );
}

export const useWorkspaceStore = create<WorkspaceStoreState>((set, get) => {
  const sample = buildSampleWorkspace();

  const resolveHelpers = {
    area: (id: EntityId | null | undefined) =>
      id ? get().areas.find((a) => a.id === id) : undefined,
    initiative: (id: EntityId | null | undefined) =>
      id ? get().initiatives.find((i) => i.id === id) : undefined,
    outcome: (id: EntityId | null | undefined) =>
      id ? get().outcomes.find((o) => o.id === id) : undefined,
    resolvedAreaID: (task: TaskItem): EntityId | null => {
      if (task.areaID) {
        return task.areaID;
      }
      const fromInitiative = get().initiative(task.initiativeID)?.areaID ?? null;
      if (fromInitiative) {
        return fromInitiative;
      }
      const resolvedInit = get().resolvedInitiativeID(task);
      return get().initiative(resolvedInit)?.areaID ?? null;
    },
    resolvedOutcomeID: (task: TaskItem): EntityId | null =>
      task.outcomeID ??
      get().milestones.find((m) => m.id === task.milestoneID)?.outcomeID ??
      null,
    resolvedInitiativeID: (task: TaskItem): EntityId | null =>
      task.initiativeID ?? get().outcome(get().resolvedOutcomeID(task))?.initiativeID ?? null,
  };

  return {
    inboxEntries: [
      { id: newEntityId(), text: "Think about referral program", createdAt: new Date() },
      { id: newEntityId(), text: "Research launch campaign", createdAt: new Date() },
      { id: newEntityId(), text: "Review onboarding copy", createdAt: new Date() },
    ],
    ...sample,

    ...resolveHelpers,

    initiativesForArea(areaID) {
      return get().initiatives.filter((i) => i.areaID === areaID);
    },

    outcomesForInitiative(initiativeID) {
      return get().outcomes.filter((o) => o.initiativeID === initiativeID);
    },

    tasksForInitiative(initiativeID) {
      return get().tasks.filter((t) => get().resolvedInitiativeID(t) === initiativeID);
    },

    tasksForOutcome(outcomeID) {
      return get().tasks.filter((t) => get().resolvedOutcomeID(t) === outcomeID);
    },

    docsForOutcome(outcomeID) {
      return get().docs.filter((d) => d.outcomeID === outcomeID);
    },

    notesForOutcome(outcomeID) {
      return get().notes.filter((n) => n.outcomeID === outcomeID);
    },

    progressForOutcome(outcomeID) {
      const relevant = get().tasksForOutcome(outcomeID);
      if (relevant.length === 0) {
        return 0;
      }
      const completed = relevant.filter((t) => t.status === "done").length;
      return completed / relevant.length;
    },

    tasksForAgendaOn(date, filters, calendar = defaultCalendar) {
      const state = get();
      return state.tasks.filter((task) => {
        const hasWork = state.taskWorkLogs.some(
          (log) => log.taskID === task.id && calendar.isSameDay(log.workDate, date),
        );
        return (
          matchesAgendaFilters(
            task,
            state,
            filters?.areaID,
            filters?.initiativeID,
            filters?.outcomeID,
          ) &&
          (isScheduledOn(task, date, calendar) || hasWork)
        );
      });
    },

    toggleTask(taskID) {
      set((state) => ({
        tasks: state.tasks.map((t) =>
          t.id === taskID
            ? { ...t, status: t.status === "done" ? "notStarted" : "done" }
            : t,
        ),
      }));
    },

    addDocument(name = "") {
      const doc: WorkspaceDocument = {
        id: newEntityId(),
        name,
        initiativeID: null,
        outcomeID: null,
        blocks: [createBlock()],
      };
      set((state) => ({ docs: [doc, ...state.docs] }));
      return doc.id;
    },

    addNote(name = "") {
      const note: WorkspaceNote = {
        id: newEntityId(),
        name,
        outcomeID: null,
        blocks: [createBlock()],
      };
      set((state) => ({ notes: [note, ...state.notes] }));
      return note.id;
    },

    updateDocumentName(documentID, name) {
      set((state) => ({
        docs: state.docs.map((d) => (d.id === documentID ? { ...d, name } : d)),
      }));
    },

    updateNoteName(noteID, name) {
      set((state) => ({
        notes: state.notes.map((n) => (n.id === noteID ? { ...n, name } : n)),
      }));
    },

    updateDocumentBlock(documentID, blockID, patch) {
      set((state) => ({
        docs: state.docs.map((doc) => {
          if (doc.id !== documentID) {
            return doc;
          }
          return {
            ...doc,
            blocks: doc.blocks.map((b) => (b.id === blockID ? { ...b, ...patch } : b)),
          };
        }),
      }));
    },

    addDocumentBlock(documentID, afterBlockID, type = "paragraph", text = "") {
      const block = createBlock({ type, text });
      let inserted: EntityId | null = block.id;
      set((state) => ({
        docs: state.docs.map((doc) => {
          if (doc.id !== documentID) {
            return doc;
          }
          const blocks = [...doc.blocks];
          if (afterBlockID) {
            const idx = blocks.findIndex((b) => b.id === afterBlockID);
            if (idx >= 0) {
              blocks.splice(idx + 1, 0, block);
            } else {
              blocks.push(block);
            }
          } else {
            blocks.push(block);
          }
          return { ...doc, blocks };
        }),
      }));
      return inserted;
    },

    interpretDocumentSyntax(documentID, blockID) {
      set((state) => ({
        docs: state.docs.map((doc) => {
          if (doc.id !== documentID) {
            return doc;
          }
          return {
            ...doc,
            blocks: doc.blocks.map((b) =>
              b.id === blockID ? interpretBlockSyntax(b) : b,
            ),
          };
        }),
      }));
    },

    addInboxEntry(text) {
      const entry: InboxEntry = { id: newEntityId(), text, createdAt: new Date() };
      set((state) => ({ inboxEntries: [entry, ...state.inboxEntries] }));
    },

    addArea(name, icon) {
      set((state) => ({
        areas: [...state.areas, { id: newEntityId(), name, icon }],
      }));
    },

    updateArea(id, name, icon) {
      set((state) => ({
        areas: state.areas.map((a) => (a.id === id ? { ...a, name, icon } : a)),
      }));
    },

    hasWorkLog(taskID, date, calendar = defaultCalendar) {
      const day = taskScheduling.normalizedDay(date, calendar);
      return get().taskWorkLogs.some(
        (log) => log.taskID === taskID && calendar.isSameDay(log.workDate, day),
      );
    },

    logWork(taskID, date = new Date(), calendar = defaultCalendar) {
      const day = taskScheduling.normalizedDay(date, calendar);
      if (get().hasWorkLog(taskID, day, calendar)) {
        return;
      }
      set((s) => ({
        taskWorkLogs: [
          ...s.taskWorkLogs,
          { id: newEntityId(), taskID, workDate: day },
        ],
        tasks: s.tasks.map((t) =>
          t.id === taskID && t.status === "notStarted" ? { ...t, status: "inProgress" } : t,
        ),
      }));
    },

    removeWorkLog(taskID, date, calendar = defaultCalendar) {
      const day = taskScheduling.normalizedDay(date, calendar);
      set((s) => ({
        taskWorkLogs: s.taskWorkLogs.filter(
          (log) => !(log.taskID === taskID && calendar.isSameDay(log.workDate, day)),
        ),
      }));
    },

    scheduleWork(taskID, from, to, calendar = defaultCalendar) {
      const period = taskScheduling.normalizedPeriod(from, to ?? from, calendar);
      set((s) => ({
        tasks: s.tasks.map((t) =>
          t.id === taskID
            ? { ...t, scheduledStart: period.start, scheduledEnd: period.end }
            : t,
        ),
      }));
    },

    pushScheduledWork(taskID, days = 1, calendar = defaultCalendar) {
      const task = get().tasks.find((t) => t.id === taskID);
      if (!task?.scheduledStart) {
        return;
      }
      const start = task.scheduledStart;
      const end = task.scheduledEnd ?? start;
      const shiftedStart = calendar.addDays(start, days);
      const shiftedEnd = calendar.addDays(end, days);
      const period = taskScheduling.normalizedPeriod(shiftedStart, shiftedEnd, calendar);
      set((s) => ({
        tasks: s.tasks.map((t) =>
          t.id === taskID
            ? { ...t, scheduledStart: period.start, scheduledEnd: period.end }
            : t,
        ),
      }));
    },

    clearSchedule(taskID) {
      set((s) => ({
        tasks: s.tasks.map((t) =>
          t.id === taskID ? { ...t, scheduledStart: null, scheduledEnd: null } : t,
        ),
      }));
    },

    addMilestone(name, outcomeID) {
      set((state) => ({
        milestones: [
          ...state.milestones,
          { id: newEntityId(), name, outcomeID, isCompleted: false },
        ],
      }));
    },

    addInitiative(name, areaID, status) {
      set((state) => ({
        initiatives: [
          ...state.initiatives,
          { id: newEntityId(), name, areaID, status },
        ],
      }));
    },

    updateInitiative(id, name, areaID, status) {
      set((state) => ({
        initiatives: state.initiatives.map((i) =>
          i.id === id ? { ...i, name, areaID, status } : i,
        ),
      }));
    },

    addOutcome(name, initiativeID, status, targetDate) {
      set((state) => ({
        outcomes: [
          ...state.outcomes,
          { id: newEntityId(), name, initiativeID, status, targetDate },
        ],
      }));
    },

    updateOutcome(id, name, initiativeID, status, targetDate) {
      set((state) => ({
        outcomes: state.outcomes.map((o) =>
          o.id === id ? { ...o, name, initiativeID, status, targetDate } : o,
        ),
      }));
    },

    updateTask(input) {
      const period = input.scheduledStart
        ? taskScheduling.normalizedPeriod(
            input.scheduledStart,
            input.scheduledEnd,
            defaultCalendar,
          )
        : null;
      set((state) => ({
        tasks: state.tasks.map((t) =>
          t.id === input.id
            ? {
                ...t,
                name: input.name,
                areaID: input.areaID,
                initiativeID: input.initiativeID,
                outcomeID: input.outcomeID,
                priority: input.priority,
                scheduledStart: period?.start ?? null,
                scheduledEnd: period?.end ?? null,
                dueDate: input.dueDate,
              }
            : t,
        ),
      }));
    },

    updateNoteBlock(noteID, blockID, patch) {
      set((state) => ({
        notes: state.notes.map((note) => {
          if (note.id !== noteID) {
            return note;
          }
          return {
            ...note,
            blocks: note.blocks.map((b) => (b.id === blockID ? { ...b, ...patch } : b)),
          };
        }),
      }));
    },

    addNoteBlock(noteID, afterBlockID, type = "paragraph", text = "") {
      const block = createBlock({ type, text });
      set((state) => ({
        notes: state.notes.map((note) => {
          if (note.id !== noteID) {
            return note;
          }
          const blocks = [...note.blocks];
          if (afterBlockID) {
            const idx = blocks.findIndex((b) => b.id === afterBlockID);
            if (idx >= 0) {
              blocks.splice(idx + 1, 0, block);
            } else {
              blocks.push(block);
            }
          } else {
            blocks.push(block);
          }
          return { ...note, blocks };
        }),
      }));
      return block.id;
    },

    interpretNoteSyntax(noteID, blockID) {
      set((state) => ({
        notes: state.notes.map((note) => {
          if (note.id !== noteID) {
            return note;
          }
          return {
            ...note,
            blocks: note.blocks.map((b) =>
              b.id === blockID ? interpretBlockSyntax(b) : b,
            ),
          };
        }),
      }));
    },

    addTask(input) {
      const period = input.scheduledStart
        ? taskScheduling.normalizedPeriod(
            input.scheduledStart,
            input.scheduledEnd,
            defaultCalendar,
          )
        : null;
      set((state) => ({
        tasks: [
          ...state.tasks,
          {
            id: newEntityId(),
            name: input.name,
            areaID: input.areaID,
            initiativeID: input.initiativeID,
            outcomeID: input.outcomeID,
            milestoneID: null,
            status: "notStarted",
            priority: input.priority,
            scheduledStart: period?.start ?? null,
            scheduledEnd: period?.end ?? null,
            dueDate: input.dueDate ?? null,
          },
        ],
      }));
    },
  };
});
