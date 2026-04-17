//
// Created by Banghua Zhao on 17/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//
  
import SwiftUI
import SQLiteData
import Dependencies
import Sharing

@MainActor
@Observable
class JournalStatsViewModel {
    @ObservationIgnored
    @FetchAll(Habit.all, animation: .default) var allHabits
    @ObservationIgnored
    @FetchAll(DiaryEntry.all, animation: .default) var allCheckIns
    @ObservationIgnored
    @FetchAll(Badge.all, animation: .default) var allAchievements
    @ObservationIgnored
    @Dependency(\.defaultDatabase) var database
    @ObservationIgnored
    @Dependency(\.themeManager) var themeManager
    @ObservationIgnored
    @Dependency(\.insightsService) var insightsService
    
    @ObservationIgnored
    @Shared(.appStorage("userName")) var userName: String = String(localized: "Your Name")
    @ObservationIgnored
    @Shared(.appStorage("userAvatar")) var userAvatar: String = "😀"
    
    var totalHabits: Int { allHabits.filter { !$0.isArchived }.count }
    var totalCheckIns: Int { allCheckIns.count }
    var totalAchievements: Int { allAchievements.filter { $0.isUnlocked }.count }
    var totalDaysActive: Int { calculateTotalDaysActive() }
    var longestStreak: Int { calculateLongestStreak() }
    var currentStreak: Int { calculateCurrentStreak() }
    var bestHabit: Habit? { findBestHabit() }
    var earliestCheckIn: DiaryEntry? { findEarliestCheckIn() }
    var earliestCheckInString: String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        if let date = earliestCheckIn?.date {
            return dateFormatter.string(from: date)
        } else {
            return nil
        }
    }
    var mostFrequentHabit: Habit? { findMostFrequentHabit() }
    
    // Habit Rating
    var habitScore: HabitScoreBreakdown { insightsService.calculateHabitScore() }
    var habitRating: HabitRating { habitScore.rating }
    var totalScore: Int { habitScore.totalScore }
    var scoreToNextRating: Int { habitScore.scoreToNextRating }
    var nextRating: HabitRating? { habitScore.nextRating }
    
    private func calculateTotalDaysActive() -> Int {
        let uniqueDates = Set(allCheckIns.map { Calendar.current.startOfDay(for: $0.date) })
        return uniqueDates.count
    }
    
    private func calculateLongestStreak() -> Int {
        let sortedDates = allCheckIns.map { $0.date }.sorted()
        var longestStreak = 0
        var currentStreak = 0
        var lastDate: Date?
        
        for date in sortedDates {
            let startOfDay = Calendar.current.startOfDay(for: date)
            
            if let last = lastDate {
                let daysBetween = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: last), to: startOfDay).day ?? 0
                
                if daysBetween == 1 {
                    currentStreak += 1
                } else if daysBetween > 1 {
                    longestStreak = max(longestStreak, currentStreak)
                    currentStreak = 1
                }
            } else {
                currentStreak = 1
            }
            
            lastDate = startOfDay
        }
        
        return max(longestStreak, currentStreak)
    }
    
    private func calculateCurrentStreak() -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        let sortedDates = allCheckIns.map { $0.date }.sorted()
        var currentStreak = 0
        var checkDate = today
        
        while true {
            let hasCheckIn = sortedDates.contains { Calendar.current.isDate($0, inSameDayAs: checkDate) }
            if hasCheckIn {
                currentStreak += 1
                checkDate = Calendar.current.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else {
                break
            }
        }
        
        return currentStreak
    }
    
    private func findBestHabit() -> Habit? {
        let habitCheckInCounts = Dictionary(grouping: allCheckIns, by: { $0.habitID })
            .mapValues { $0.count }
        
        return habitCheckInCounts.max(by: { $0.value < $1.value })
            .flatMap { habitID in
                allHabits.first { $0.id == habitID.key }
            }
    }
    
    private func findEarliestCheckIn() -> DiaryEntry? {
        return allCheckIns.min(by: { $0.date < $1.date })
    }
    
    private func findMostFrequentHabit() -> Habit? {
        let habitCheckInCounts = Dictionary(grouping: allCheckIns, by: { $0.habitID })
            .mapValues { $0.count }
        
        return habitCheckInCounts.max(by: { $0.value < $1.value })
            .flatMap { habitID in
                allHabits.first { $0.id == habitID.key }
            }
    }
    
    func generateShareText() -> String {
        let bestHabitName = bestHabit?.name ?? "No habits yet"
        let earliestDate = earliestCheckIn?.date ?? Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        return """
        📊 My Habit Diary Stats
        
        🏆 Habit Diary Rating: \(habitRating.displayName) (\(habitRating.description))
        📈 Total Score: \(totalScore) points
        🎯 Total Habits: \(totalHabits)
        ✅ Total Check-ins: \(totalCheckIns)
        🏆 Achievements Unlocked: \(totalAchievements)
        📅 Days Active: \(totalDaysActive)
        🔥 Longest Streak: \(longestStreak) days
        ⚡ Current Streak: \(currentStreak) days
        🌟 Best Habit: \(bestHabitName)
        🕐 Started: \(dateFormatter.string(from: earliestDate))
        
        #HabitDiary #HealthyHabits #Wellness
        """
    }
}
