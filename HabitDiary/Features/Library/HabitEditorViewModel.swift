//
// Created by Banghua Zhao on 17/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//
  

import Dependencies
import SQLiteData
import SwiftNavigation
import SwiftUI

@Observable
@MainActor
class HabitEditorViewModel: HashableObject {
    var habit: Habit.Draft
    
    var draftReminders: [Reminder.Draft] = []
    private var originalReminderIDs: Set<Int> = []

    var todayHabit: JournalDraftHabit {
        let frequencyDescription: String? = switch habit.frequency {
        case .nDaysEachWeek: String(localized: "1/\(habit.nDaysPerWeek) this week")
        case .nDaysEachMonth: String(localized: "1/\(habit.nDaysPerMonth) this month")
        default: nil
        }
        return habit.toTodayDraftHabit(
            streakDescription: String(localized: "🔥 1d streak"),
            frequencyDescription: frequencyDescription
        )
    }

    @CasePathable
    enum Route: Equatable {
        case editHabitIcon
        case habitsGallery
        case addReminder(ReminderEditorViewModel)
        case editReminder(ReminderEditorViewModel)
    }

    var route: Route?

    @ObservationIgnored
    @Dependency(\.defaultDatabase) var database
    
    @ObservationIgnored
    @Dependency(\.reminderNotificationCenter) var reminderNotificationCenter
    
    @ObservationIgnored
    @Dependency(\.appReviewPromptService) var appReviewPromptService

    var showTitleEmptyToast = false
    let isEdit: Bool
    let onSaveHabit: ((Habit) -> Void)?

    init(
        habit: Habit.Draft,
        onSaveHabit: ((Habit) -> Void)? = nil
    ) {
        self.habit = habit
        self.onSaveHabit = onSaveHabit
        isEdit = habit.id != nil
        if let habitID = habit.id, isEdit {
            if let reminders = try? appDatabase().read({ db in
                try Reminder
                    .where { $0.habitID.eq(habitID) }
                    .fetchAll(db)
            }) {
                self.draftReminders = reminders.map { Reminder.Draft($0) }
                self.originalReminderIDs = Set(reminders.map { $0.id })
            }
        } else {
            self.draftReminders = []
            self.originalReminderIDs = []
        }
    }

    func toggleWeekDay(_ weekDay: WeekDays) {
        guard habit.frequency == .fixedDaysInWeek else { return }
        var daysOfWeek = habit.daysOfWeek
        if hasSelectedWeekDay(weekDay) {
            daysOfWeek.remove(weekDay.rawValue)
        } else {
            daysOfWeek.insert(weekDay.rawValue)
        }
        habit.frequencyDetail = daysOfWeek.sorted().map(String.init).joined(separator: ",")
    }

    func toggleMonthDay(_ monthDay: Int) {
        guard habit.frequency == .fixedDaysInMonth else { return }
        var daysOfMonth = habit.daysOfMonth
        if hasSelectedMonthDay(monthDay) {
            daysOfMonth.remove(monthDay)
        } else {
            daysOfMonth.insert(monthDay)
        }
        habit.frequencyDetail = daysOfMonth.sorted().map(String.init).joined(separator: ",")
    }

    func hasSelectedWeekDay(_ weekDay: WeekDays) -> Bool {
        guard habit.frequency == .fixedDaysInWeek else { return false }
        return habit.daysOfWeek.contains(weekDay.rawValue)
    }

    func hasSelectedMonthDay(_ monthDay: Int) -> Bool {
        guard habit.frequency == .fixedDaysInMonth else { return false }
        return habit.daysOfMonth.contains(monthDay)
    }

    func onSelectNDays(_ nDays: Int) {
        habit.frequencyDetail = "\(nDays)"
    }

    func onChangeOfHabitFrequency() {
        switch habit.frequency {
        case .fixedDaysInWeek:
            habit.frequencyDetail = "1,2,3,4,5,6,7"
        case .fixedDaysInMonth:
            habit.frequencyDetail = "1"
        case .nDaysEachWeek:
            habit.frequencyDetail = "1"
        case .nDaysEachMonth:
            habit.frequencyDetail = "1"
        }
    }

    func onTapTodayHabit() {
        route = .editHabitIcon
    }

    func onTapSaveHabit() async -> Bool {
        guard !habit.name.isEmpty else {
            showTitleEmptyToast = true
            return false
        }
        await withErrorReporting {
            let updatedHabit = try await database.write { [habit] db in
                try Habit
                    .upsert { habit }
                    .returning { $0 }
                    .fetchOne(db)
            }
            
            guard let updatedHabit else { return }
            
            for var draftReminder in draftReminders {
                draftReminder.habitID = updatedHabit.id
                draftReminder.title = "\(updatedHabit.icon) \(updatedHabit.name)"
                let reminder = try await database.write { [draftReminder] db in
                    try Reminder
                        .upsert { draftReminder }
                        .returning { $0 }
                        .fetchOne(db)
                }
                
                if let reminder {
                    await reminderNotificationCenter.scheduleReminder(reminder)
                }
            }
            
            let currentIDs = Set(draftReminders.compactMap { $0.id })
            let toDelete = originalReminderIDs.subtracting(currentIDs)
            for id in toDelete {
                let reminderToDelete = try await database.read { db in
                    try Reminder
                        .where { $0.id.eq(id) }
                        .fetchOne(db)
                }
                if let reminderToDelete {
                    try await database.write { db in
                        try Reminder
                            .delete(reminderToDelete)
                            .execute(db)
                    }
                    reminderNotificationCenter.removeReminder(reminderToDelete)
                }
            }
            onSaveHabit?(updatedHabit)
            
            // Increment habit modification count for rating prompts
            appReviewPromptService.incrementHabitModificationCount()
        }
        return true
    }

    func onTapGallery() {
        route = .habitsGallery
    }
    
    func onTapAddReminder() {
        route = .addReminder(
            ReminderEditorViewModel(
                reminder: Reminder.Draft(),
                onSave: { [weak self] draft in
                    guard let self else { return }
                    draftReminders.append(draft)
                    route = nil
                }
            )
        )
    }
    
    func onTapEditReminder(_ reminder: Reminder.Draft) {
        route = .editReminder(
            ReminderEditorViewModel(
                reminder: reminder,
                onSave: { [weak self] updatedDraft in
                    guard let self else { return }
                    if let idx = draftReminders.firstIndex(where: { $0.id == updatedDraft.id }) {
                        draftReminders[idx] = updatedDraft
                    }
                    route = nil
                }
            )
        )
    }
    
    func onTapDeleteReminder(_ reminder: Reminder.Draft) {
        if let idx = draftReminders.firstIndex(where: { $0.id == reminder.id }) {
            draftReminders.remove(at: idx)
        }
    }
}

enum WeekDays: Int, CaseIterable {
    case mon = 2
    case tue = 3
    case wed = 4
    case thu = 5
    case fri = 6
    case sat = 7
    case sun = 1

    var title: String {
        switch self {
        case .mon:
            "Mon"
        case .tue:
            "Tue"
        case .wed:
            "Wed"
        case .thu:
            "Thu"
        case .fri:
            "Fri"
        case .sat:
            "Sat"
        case .sun:
            "Sun"
        }
    }
}
