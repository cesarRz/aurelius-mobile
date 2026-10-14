import { createBlock } from "../domain/entities";
import type {
  ActiveThread,
  Area,
  Initiative,
  Milestone,
  Outcome,
  TaskItem,
  TaskWorkLog,
  WorkspaceDocument,
  WorkspaceNote,
} from "../domain/entities";
import { defaultCalendar } from "../domain/taskScheduling";

export interface SampleWorkspaceSlice {
  areas: Area[];
  initiatives: Initiative[];
  outcomes: Outcome[];
  milestones: Milestone[];
  tasks: TaskItem[];
  taskWorkLogs: TaskWorkLog[];
  threads: ActiveThread[];
  docs: WorkspaceDocument[];
  notes: WorkspaceNote[];
}

export function buildSampleWorkspace(): SampleWorkspaceSlice {
  const calendar = defaultCalendar;
  const today = calendar.startOfDay(new Date());
  const tomorrow = calendar.addDays(today, 1);
  const yesterday = calendar.addDays(today, -1);
  const dayAfterTomorrow = calendar.addDays(today, 2);

  const business: Area = { id: crypto.randomUUID(), name: "Business", icon: "briefcase" };
  const personal: Area = { id: crypto.randomUUID(), name: "Personal", icon: "person" };
  const health: Area = { id: crypto.randomUUID(), name: "Health", icon: "heart" };
  const areas = [business, personal, health];

  const bilanz: Initiative = {
    id: crypto.randomUUID(),
    name: "Bilanz",
    areaID: business.id,
    status: "inProgress",
  };
  const personalBrand: Initiative = {
    id: crypto.randomUUID(),
    name: "Personal Brand",
    areaID: business.id,
    status: "inProgress",
  };
  const homeRenovation: Initiative = {
    id: crypto.randomUUID(),
    name: "Home Renovation",
    areaID: personal.id,
    status: "inProgress",
  };
  const halfMarathon: Initiative = {
    id: crypto.randomUUID(),
    name: "Half Marathon",
    areaID: health.id,
    status: "inProgress",
  };
  const initiatives = [bilanz, personalBrand, homeRenovation, halfMarathon];

  const launch: Outcome = {
    id: crypto.randomUUID(),
    name: "Launch Bilanz publicly",
    initiativeID: bilanz.id,
    status: "inProgress",
    targetDate: calendar.addDays(today, 45),
  };
  const firstUsers: Outcome = {
    id: crypto.randomUUID(),
    name: "Reach first 100 paying users",
    initiativeID: bilanz.id,
    status: "notStarted",
    targetDate: calendar.addDays(today, 90),
  };
  const content: Outcome = {
    id: crypto.randomUUID(),
    name: "Publish consistently for 30 days",
    initiativeID: personalBrand.id,
    status: "inProgress",
    targetDate: calendar.addDays(today, 30),
  };
  const kitchenRefresh: Outcome = {
    id: crypto.randomUUID(),
    name: "Refresh kitchen before holidays",
    initiativeID: homeRenovation.id,
    status: "inProgress",
    targetDate: calendar.addDays(today, 60),
  };
  const raceDay: Outcome = {
    id: crypto.randomUUID(),
    name: "Run the city half marathon",
    initiativeID: halfMarathon.id,
    status: "inProgress",
    targetDate: calendar.addDays(today, 60),
  };
  const referralProgram: Outcome = {
    id: crypto.randomUUID(),
    name: "Launch referral program",
    initiativeID: bilanz.id,
    status: "notStarted",
    targetDate: calendar.addDays(today, 21),
  };
  const outcomes = [launch, firstUsers, content, kitchenRefresh, raceDay, referralProgram];

  const milestones: Milestone[] = [
    { id: crypto.randomUUID(), name: "Beta completed", outcomeID: launch.id, isCompleted: true },
    { id: crypto.randomUUID(), name: "Onboarding complete", outcomeID: launch.id },
    { id: crypto.randomUUID(), name: "App Store submission", outcomeID: launch.id },
    { id: crypto.randomUUID(), name: "Public launch", outcomeID: launch.id },
  ];

  const tasks: TaskItem[] = [
    {
      id: crypto.randomUUID(),
      name: "Finish onboarding flow",
      areaID: business.id,
      initiativeID: bilanz.id,
      outcomeID: launch.id,
      milestoneID: null,
      status: "inProgress",
      priority: "high",
      scheduledStart: today,
      scheduledEnd: tomorrow,
      dueDate: calendar.addDays(today, 3),
    },
    {
      id: crypto.randomUUID(),
      name: "Record launch video",
      areaID: business.id,
      initiativeID: bilanz.id,
      outcomeID: launch.id,
      milestoneID: null,
      status: "notStarted",
      priority: "medium",
      scheduledStart: today,
      scheduledEnd: today,
      dueDate: null,
    },
    {
      id: crypto.randomUUID(),
      name: "Rewrite pricing page",
      areaID: business.id,
      initiativeID: bilanz.id,
      outcomeID: launch.id,
      milestoneID: null,
      status: "inProgress",
      priority: "high",
      scheduledStart: tomorrow,
      scheduledEnd: dayAfterTomorrow,
      dueDate: calendar.addDays(today, 5),
    },
    {
      id: crypto.randomUUID(),
      name: "Outline 4 LinkedIn posts",
      areaID: business.id,
      initiativeID: personalBrand.id,
      outcomeID: content.id,
      milestoneID: null,
      status: "notStarted",
      priority: "medium",
      scheduledStart: today,
      scheduledEnd: tomorrow,
      dueDate: null,
    },
    {
      id: crypto.randomUUID(),
      name: "Compare countertop quotes",
      areaID: personal.id,
      initiativeID: homeRenovation.id,
      outcomeID: kitchenRefresh.id,
      milestoneID: null,
      status: "notStarted",
      priority: "medium",
      scheduledStart: today,
      scheduledEnd: today,
      dueDate: null,
    },
    {
      id: crypto.randomUUID(),
      name: "Map referral reward flow",
      areaID: business.id,
      initiativeID: bilanz.id,
      outcomeID: referralProgram.id,
      milestoneID: null,
      status: "inProgress",
      priority: "medium",
      scheduledStart: yesterday,
      scheduledEnd: today,
      dueDate: null,
    },
  ];

  const taskWorkLogs: TaskWorkLog[] = [
    { id: crypto.randomUUID(), taskID: tasks[0].id, workDate: today },
    { id: crypto.randomUUID(), taskID: tasks[2].id, workDate: yesterday },
    { id: crypto.randomUUID(), taskID: tasks[5].id, workDate: yesterday },
  ];

  const threads: ActiveThread[] = [
    {
      id: crypto.randomUUID(),
      name: "Onboarding UX",
      outcomeID: launch.id,
      detail: "Working through onboarding flow, copy and interaction details.",
    },
    {
      id: crypto.randomUUID(),
      name: "Subscription strategy",
      outcomeID: launch.id,
      detail: "Deciding how the freemium limits and premium conversion should work.",
    },
  ];

  const docs: WorkspaceDocument[] = [
    {
      id: crypto.randomUUID(),
      name: "Launch Strategy",
      initiativeID: bilanz.id,
      outcomeID: launch.id,
      blocks: [
        createBlock({ type: "heading1", text: "Bilanz Launch Strategy" }),
        createBlock({
          type: "paragraph",
          text: "The goal is to launch Bilanz with a focused first version.",
        }),
        createBlock({ type: "heading2", text: "Priorities" }),
        createBlock({ type: "bullet", text: "Finish onboarding" }),
        createBlock({ type: "bullet", text: "Stabilize subscriptions" }),
        createBlock({ type: "checklist", text: "Record first launch video" }),
        createBlock({ type: "quote", text: "Ship the smallest version that provides real value." }),
      ],
    },
  ];

  const notes: WorkspaceNote[] = [
    {
      id: crypto.randomUUID(),
      name: "Launch Notes",
      outcomeID: launch.id,
      blocks: [
        createBlock({ type: "heading1", text: "Launch Notes" }),
        createBlock({
          type: "paragraph",
          text: "Focus on getting people into the core transaction flow quickly.",
        }),
        createBlock({ type: "checklist", text: "Is onboarding clear?" }),
      ],
    },
  ];

  return {
    areas,
    initiatives,
    outcomes,
    milestones,
    tasks,
    taskWorkLogs,
    threads,
    docs,
    notes,
  };
}
