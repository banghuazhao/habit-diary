//
// Created by Banghua Zhao on 17/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//
  
import Observation
import SQLiteData
import SwiftUI
import SwiftUINavigation
import Dependencies
import Sharing

@Observable
@MainActor
class HabitPageViewModel {
    var habit: Habit
    
    @ObservationIgnored
    @FetchAll(DiaryEntry.all, animation: .default) var allCheckIns: [DiaryEntry]

    @ObservationIgnored
    @FetchAll(Reminder.all, animation: .default) var allReminders

    @ObservationIgnored
    @FetchAll(Badge.all, animation: .default) var allAchievements

    @ObservationIgnored
    @Dependency(\.defaultDatabase) var database

    @ObservationIgnored
    @Dependency(\.calendar) var calendar
    
    @ObservationIgnored
    @Dependency(\.reminderNotificationCenter) var reminderNotificationCenter
    
    @ObservationIgnored
    @Dependency(\.badgeService) var badgeService
    
    @ObservationIgnored
    @Dependency(\.appReviewPromptService) var appReviewPromptService

    @ObservationIgnored
    @Shared(.appStorage("startWeekOnMonday")) private var startWeekOnMonday: Bool = true
    
    @ObservationIgnored
    @Dependency(\.soundPlayer) var soundPlayer

    var selectedMonth: Date = Date()
    var selectedYear: Int = Calendar.current.component(.year, from: Date())

    enum CalendarMode: String, CaseIterable, Identifiable {
        case monthly = "Monthly"
        case yearly = "Yearly"
        var id: String { rawValue }
        
        var displayName: String {
            switch self {
            case .monthly: String(localized: "Monthly")
            case .yearly: String(localized: "Yearly")
            }
        }
    }

    var calendarMode: CalendarMode = .monthly

    @CasePathable
    enum Route {
        case editHabit(HabitEditorViewModel)
        case deleteAlert
        case editReminder(ReminderEditorViewModel)
        case showAchievement(Badge)
    }

    var route: Route?

    var userCalendar: Calendar {
        var cal = Calendar.current
        cal.firstWeekday = startWeekOnMonday ? 2 : 1 // 2 = Monday, 1 = Sunday
        return cal
    }

    var checkIns: [DiaryEntry] {
        allCheckIns.filter { $0.habitID == habit.id }
    }

    var todayHabit: JournalHabit {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let streak = calculateCurrentStreak(checkIns: checkIns, calendar: calendar, today: today)
        let streakDescription = streak > 0 ? String(localized: "🔥 \(streak)d streak") : nil
        return habit.toTodayHabit(
            isCompleted: true,
            streakDescription: streakDescription,
            frequencyDescription: habit.frequencyDescription
        )
    }

    private func calculateCurrentStreak(checkIns: [DiaryEntry], calendar: Calendar, today: Date) -> Int {
        let sortedDates = checkIns.map { calendar.startOfDay(for: $0.date) }.sorted(by: >)
        var streak = 0
        var currentDate = today
        let dateSet = Set(sortedDates)
        while dateSet.contains(currentDate) {
            streak += 1
            guard let previousDate = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
            currentDate = previousDate
        }
        return streak
    }

    var reminders: [Reminder.Draft] {
        allReminders.filter { $0.habitID == habit.id }.map(Reminder.Draft.init)
    }

    var habitAchievements: [Badge] {
        allAchievements.filter { achievement in
            achievement.habitID == habit.id
        }.sorted { $0.unlockedDate ?? Date() > $1.unlockedDate ?? Date() }
    }

    var checkInsWithNotes: [DiaryEntry] {
        checkIns
            .filter { !$0.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .sorted { $0.date > $1.date }
    }

    var showFavoriteInfo: Bool = false
    var showArchivedInfo: Bool = false

    init(habit: Habit) {
        self.habit = habit
    }

    var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: selectedMonth)
    }

    var weekdaySymbols: [String] {
        let symbols = userCalendar.shortWeekdaySymbols
        // Start from Monday
        let idx = userCalendar.firstWeekday - 1
        return Array(symbols[idx...] + symbols[..<idx])
    }

    var calendarDays: [Date?] {
        let now = Date()
        let currentHour = userCalendar.component(.hour, from: now)
        let currentMinute = userCalendar.component(.minute, from: now)
        let startOfMonth = selectedMonth.startOfMonth(for: userCalendar)
        let range = userCalendar.range(of: .day, in: .month, for: startOfMonth)!
        let numDays = range.count
        let firstWeekday = userCalendar.component(.weekday, from: startOfMonth)
        let firstWeekdayIdx = (firstWeekday - userCalendar.firstWeekday + 7) % 7
        var days: [Date?] = Array(repeating: nil, count: firstWeekdayIdx)
        for day in 1 ... numDays {
            if let date = userCalendar.date(bySetting: .day, value: day, of: startOfMonth),
               let dateWithTime = userCalendar.date(bySettingHour: currentHour, minute: currentMinute, second: 0, of: date) {
                days.append(dateWithTime)
            }
        }
        // Fill to complete the last week
        while days.count % 7 != 0 {
            days.append(nil)
        }
        return days
    }

    func isToday(day: Date?) -> Bool {
        guard let day = day else { return false }
        return userCalendar.isDateInToday(day)
    }

    func isChecked(day: Date?) -> Bool {
        guard let day = day else { return false }
        return checkIns.contains { userCalendar.isDate($0.date, inSameDayAs: day) }
    }

    func isCurrentMonth(day: Date?) -> Bool {
        guard let day = day else { return false }
        return userCalendar.isDate(day, equalTo: selectedMonth, toGranularity: .month)
    }

    func previousMonth() {
        if let prev = userCalendar.date(byAdding: .month, value: -1, to: selectedMonth) {
            selectedMonth = prev
        }
    }

    func nextMonth() {
        if let next = userCalendar.date(byAdding: .month, value: 1, to: selectedMonth) {
            selectedMonth = next
        }
    }

    func toggleCheckIn(for day: Date?) {
        guard let day, isCurrentMonth(day: day) else { return }
        let startOfDay = day.startOfDay(for: userCalendar)
        let endOfDay = day.endOfDay(for: userCalendar)
        if let checkIn = checkIns.first(
            where: {
                $0.date >= startOfDay &&
                    $0.date <= endOfDay &&
                    $0.habitID == habit.id
            }) {
            // Remove check-in
            withErrorReporting {
                try database.write { db in
                    try DiaryEntry.delete(checkIn).execute(db)
                }
            }
            Task {
                await soundPlayer.playCancelCheckinSound()
            }
        } else {
            // Add check-in
            withErrorReporting {
                try database.write { db in
                    let draft = DiaryEntry.Draft(date: day, habitID: habit.id)
                    let savedCheckIn = try DiaryEntry
                        .upsert { draft }
                        .returning(\.self)
                        .fetchOne(db)
                    
                    // Check for achievements after adding check-in
                    if let savedCheckIn {
                        Task {
                            await badgeService.checkAchievementsAndShow(for: savedCheckIn)
                        }
                    }
                }
                Task {
                    await soundPlayer.playCheckinSound()
                }
            }
        }
        print("Toggle check-in called")
        Haptics.shared.vibrateIfEnabled()
    }

    func onTapEditHabit() {
        route = .editHabit(
            HabitEditorViewModel(
                habit: Habit.Draft(habit)
            ) { [weak self] updatedHabit in
                guard let self else { return }
                habit = updatedHabit
                // Increment habit modification count for rating prompts
                appReviewPromptService.incrementHabitModificationCount()
            }
        )
    }

    func onTapDeleteHabit() {
        route = .deleteAlert
    }

    func deleteHabit() {
        withErrorReporting {
            reminderNotificationCenter.removeRemindersForHabit(habit.id)
            try database.write { db in
                try Habit.delete(habit).execute(db)
            }
        }
    }

    // For yearly view: get all check-ins for a year, grouped by month and day
    func yearlyCheckIns(for year: Int) -> [Int: Set<Int>] {
        // [month: Set<day>]
        var result: [Int: Set<Int>] = [:]
        for checkIn in checkIns {
            let comps = userCalendar.dateComponents([.year, .month, .day], from: checkIn.date)
            if comps.year == year, let month = comps.month, let day = comps.day {
                result[month, default: []].insert(day)
            }
        }
        return result
    }

    func previousYear() {
        selectedYear -= 1
    }

    func nextYear() {
        selectedYear += 1
    }

    func onTapEditReminder(_ reminder: Reminder.Draft) {
        route = .editReminder(
            ReminderEditorViewModel(
                reminder: reminder,
                onSave: { [weak self] reminderDraft in
                    guard let self else { return }
                    onUpdateReminder(reminderDraft)
                    route = nil
                }
            )
        )
    }

    func onTapDeleteReminder(_ reminder: Reminder.Draft) {
        onDeleteReminder(reminder)
    }
    
    private func onUpdateReminder(_ reminder: Reminder.Draft) {
        Task {
            await withErrorReporting {
                let updatedReminder = try await database.write { db in
                    try Reminder
                        .upsert { reminder }
                        .returning(\.self)
                        .fetchOne(db)
                }
                if let updatedReminder {
                    await reminderNotificationCenter.scheduleReminder(updatedReminder)
                }
            }
        }
    }
    
    private func onDeleteReminder(_ reminder: Reminder.Draft) {
        Task {
            await withErrorReporting {
                guard let reminderID = reminder.id else { return }
                let reminderToDelete = try await database.read { db in
                    try Reminder.find(reminderID).fetchOne(db)
                }
                if let reminderToDelete {
                    reminderNotificationCenter.removeReminder(reminderToDelete)
                    try await database.write { db in
                        try Reminder.delete(reminderToDelete).execute(db)
                    }
                }
            }
        }
    }
    
    func onTapAchievement(_ achievement: Badge) {
        route = .showAchievement(achievement)
    }
}
