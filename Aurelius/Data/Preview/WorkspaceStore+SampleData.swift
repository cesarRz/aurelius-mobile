import Foundation

extension WorkspaceStore {
    /// Sample workspace for the prototype and SwiftUI previews.
    static func sample() -> WorkspaceStore {
        let store = WorkspaceStore()
        store.loadMockData()
        store.inboxEntries = [
            InboxEntry(text: "Think about referral program"),
            InboxEntry(text: "Research launch campaign"),
            InboxEntry(text: "Review onboarding copy")
        ]
        return store
    }


    private func loadMockData() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let dayAfterTomorrow = calendar.date(byAdding: .day, value: 2, to: today)!

        let business = Area(
            name: "Business",
            icon: "briefcase"
        )

        let personal = Area(
            name: "Personal",
            icon: "person"
        )

        let health = Area(
            name: "Health",
            icon: "heart"
        )

        areas = [
            business,
            personal,
            health
        ]

        let bilanz = Initiative(
            name: "Bilanz",
            areaID: business.id,
            status: .inProgress
        )

        let personalBrand = Initiative(
            name: "Personal Brand",
            areaID: business.id,
            status: .inProgress
        )

        let homeRenovation = Initiative(
            name: "Home Renovation",
            areaID: personal.id,
            status: .inProgress
        )

        let halfMarathon = Initiative(
            name: "Half Marathon",
            areaID: health.id,
            status: .inProgress
        )

        initiatives = [
            bilanz,
            personalBrand,
            homeRenovation,
            halfMarathon
        ]

        let launch = Outcome(
            name: "Launch Bilanz publicly",
            initiativeID: bilanz.id,
            status: .inProgress,
            targetDate: Calendar.current.date(
                byAdding: .day,
                value: 45,
                to: .now
            )
        )

        let firstUsers = Outcome(
            name: "Reach first 100 paying users",
            initiativeID: bilanz.id,
            status: .notStarted,
            targetDate: Calendar.current.date(
                byAdding: .month,
                value: 3,
                to: .now
            )
        )

        let content = Outcome(
            name: "Publish consistently for 30 days",
            initiativeID: personalBrand.id,
            status: .inProgress,
            targetDate: calendar.date(
                byAdding: .day,
                value: 30,
                to: .now
            )
        )

        let kitchenRefresh = Outcome(
            name: "Refresh kitchen before holidays",
            initiativeID: homeRenovation.id,
            status: .inProgress,
            targetDate: calendar.date(
                byAdding: .day,
                value: 60,
                to: .now
            )
        )

        let raceDay = Outcome(
            name: "Run the city half marathon",
            initiativeID: halfMarathon.id,
            status: .inProgress,
            targetDate: calendar.date(
                byAdding: .month,
                value: 2,
                to: .now
            )
        )

        let referralProgram = Outcome(
            name: "Launch referral program",
            initiativeID: bilanz.id,
            status: .notStarted,
            targetDate: calendar.date(
                byAdding: .day,
                value: 21,
                to: .now
            )
        )

        outcomes = [
            launch,
            firstUsers,
            content,
            kitchenRefresh,
            raceDay,
            referralProgram
        ]

        milestones = [
            Milestone(
                name: "Beta completed",
                outcomeID: launch.id,
                isCompleted: true
            ),
            Milestone(
                name: "Onboarding complete",
                outcomeID: launch.id
            ),
            Milestone(
                name: "App Store submission",
                outcomeID: launch.id
            ),
            Milestone(
                name: "Public launch",
                outcomeID: launch.id
            )
        ]

        tasks = [
            // Today + tomorrow, already logged today — multi-day carry-over
            TaskItem(
                name: "Finish onboarding flow",
                areaID: business.id,
                initiativeID: bilanz.id,
                outcomeID: launch.id,
                status: .inProgress,
                priority: .high,
                scheduledStart: today,
                scheduledEnd: tomorrow,
                dueDate: calendar.date(byAdding: .day, value: 3, to: .now)
            ),

            // Scheduled today only
            TaskItem(
                name: "Record launch video",
                areaID: business.id,
                initiativeID: bilanz.id,
                outcomeID: launch.id,
                priority: .medium,
                scheduledStart: today
            ),

            // Worked yesterday, schedule pushed to tomorrow — log stays on yesterday
            TaskItem(
                name: "Rewrite pricing page",
                areaID: business.id,
                initiativeID: bilanz.id,
                outcomeID: launch.id,
                status: .inProgress,
                priority: .high,
                scheduledStart: tomorrow,
                scheduledEnd: dayAfterTomorrow,
                dueDate: calendar.date(byAdding: .day, value: 5, to: .now)
            ),

            // Personal brand: planned today through tomorrow, not started yet
            TaskItem(
                name: "Outline 4 LinkedIn posts",
                areaID: business.id,
                initiativeID: personalBrand.id,
                outcomeID: content.id,
                priority: .medium,
                scheduledStart: today,
                scheduledEnd: tomorrow
            ),

            TaskItem(
                name: "Draft newsletter intro",
                areaID: business.id,
                initiativeID: personalBrand.id,
                outcomeID: content.id,
                priority: .low,
                scheduledStart: tomorrow
            ),

            // Home renovation — scheduled for today
            TaskItem(
                name: "Compare countertop quotes",
                areaID: personal.id,
                initiativeID: homeRenovation.id,
                outcomeID: kitchenRefresh.id,
                priority: .medium,
                scheduledStart: today
            ),

            TaskItem(
                name: "Buy paint samples",
                areaID: personal.id,
                initiativeID: homeRenovation.id,
                outcomeID: kitchenRefresh.id,
                priority: .low,
                dueDate: calendar.date(byAdding: .day, value: 7, to: .now)
            ),

            // Health — tomorrow's training block
            TaskItem(
                name: "Long run 8 km",
                areaID: health.id,
                initiativeID: halfMarathon.id,
                outcomeID: raceDay.id,
                priority: .high,
                scheduledStart: tomorrow
            ),

            TaskItem(
                name: "Stretching routine",
                areaID: health.id,
                initiativeID: halfMarathon.id,
                outcomeID: raceDay.id,
                status: .done,
                priority: .medium,
                scheduledStart: yesterday
            ),

            // Referral work started yesterday, extended through today
            TaskItem(
                name: "Map referral reward flow",
                areaID: business.id,
                initiativeID: bilanz.id,
                outcomeID: referralProgram.id,
                status: .inProgress,
                priority: .medium,
                scheduledStart: yesterday,
                scheduledEnd: today
            ),

            // No schedule — backlog item, won't appear in Agenda until scheduled
            TaskItem(
                name: "Review translations",
                areaID: business.id,
                initiativeID: bilanz.id,
                outcomeID: launch.id,
                priority: .medium
            ),

            TaskItem(
                name: "Prepare App Store screenshots",
                areaID: business.id,
                initiativeID: bilanz.id,
                outcomeID: launch.id,
                priority: .high
            )
        ]

        taskWorkLogs = [
            TaskWorkLog(taskID: tasks[0].id, workDate: today),
            TaskWorkLog(taskID: tasks[2].id, workDate: yesterday),
            TaskWorkLog(taskID: tasks[8].id, workDate: yesterday),
            TaskWorkLog(taskID: tasks[9].id, workDate: yesterday)
        ]

        threads = [
            ActiveThread(
                id: UUID(),
                name: "Onboarding UX",
                outcomeID: launch.id,
                detail: "Working through onboarding flow, copy and interaction details."
            ),

            ActiveThread(
                id: UUID(),
                name: "Subscription strategy",
                outcomeID: launch.id,
                detail: "Deciding how the freemium limits and premium conversion should work."
            )
        ]

        docs = [
            WorkspaceDocument(
                name: "Launch Strategy",
                initiativeID: bilanz.id,
                outcomeID: launch.id,
                blocks: [
                    DocumentBlock(
                        type: .heading1,
                        text: "Bilanz Launch Strategy"
                    ),
                    DocumentBlock(
                        type: .paragraph,
                        text: "The goal is to launch Bilanz with a focused first version."
                    ),
                    DocumentBlock(
                        type: .heading2,
                        text: "Priorities"
                    ),
                    DocumentBlock(
                        type: .bullet,
                        text: "Finish onboarding"
                    ),
                    DocumentBlock(
                        type: .bullet,
                        text: "Stabilize subscriptions"
                    ),
                    DocumentBlock(
                        type: .bullet,
                        text: "Prepare App Store assets"
                    ),
                    DocumentBlock(
                        type: .checklist,
                        text: "Record first launch video"
                    ),
                    DocumentBlock(
                        type: .quote,
                        text: "Ship the smallest version that provides real value."
                    )
                ]
            )
        ]

        notes = [
            WorkspaceNote(
                name: "Launch Notes",
                outcomeID: launch.id,
                blocks: [
                    DocumentBlock(
                        type: .heading1,
                        text: "Launch Notes"
                    ),
                    DocumentBlock(
                        type: .paragraph,
                        text: "Focus on getting people into the core transaction flow quickly."
                    ),
                    DocumentBlock(
                        type: .heading2,
                        text: "Questions"
                    ),
                    DocumentBlock(
                        type: .checklist,
                        text: "Is onboarding clear?"
                    ),
                    DocumentBlock(
                        type: .checklist,
                        text: "Does the free limit make sense?"
                    ),
                    DocumentBlock(
                        type: .paragraph,
                        text: ""
                    )
                ]
            )
        ]
    }
}
