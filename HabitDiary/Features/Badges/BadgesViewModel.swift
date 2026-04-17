//
// Created by Banghua Zhao on 17/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//


import SwiftUI
import SQLiteData
import Sharing

@Observable
@MainActor
class BadgesViewModel {
    @ObservationIgnored
    @FetchAll(Badge.all, animation: .default) var allAchievements
    
    @ObservationIgnored
    @FetchAll(DiaryEntry.all, animation: .default) var allCheckIns
    
    @ObservationIgnored
    @FetchAll(Habit.all, animation: .default) var allHabits
    
    var unlockedAchievements: [Badge] {
        allAchievements.filter { $0.isUnlocked }.sorted { $0.unlockedDate ?? Date() > $1.unlockedDate ?? Date() }
    }
    
    var lockedAchievements: [Badge] {
        allAchievements.filter { !$0.isUnlocked }
    }
    
    var totalAchievements: Int {
        allAchievements.count
    }
    
    var unlockedCount: Int {
        unlockedAchievements.count
    }
    
    var progressPercentage: Double {
        guard totalAchievements > 0 else { return 0 }
        return Double(unlockedCount) / Double(totalAchievements) * 100
    }
    
    @ObservationIgnored
    @Shared(.appStorage("startWeekOnMonday")) private var startWeekOnMonday: Bool = true
    
    var userCalendar: Calendar {
        var cal = Calendar.current
        cal.firstWeekday = startWeekOnMonday ? 2 : 1 // 2 = Monday, 1 = Sunday
        return cal
    }
    
    func getProgress(for achievement: Badge) -> Double {
        switch achievement.type {
        case .streak:
            return getStreakProgress(for: achievement)
        case .totalCheckIns:
            return getTotalCheckInsProgress(for: achievement)
        case .perfectWeek, .perfectMonth:
            return 0 // These are binary achievements
        case .earlyBird, .nightOwl:
            return 0 // These are binary achievements
        case .consistency:
            return getConsistencyProgress(for: achievement)
        case .milestone:
            return getMilestoneProgress(for: achievement)
        }
    }
    
    private func getStreakProgress(for achievement: Badge) -> Double {
        let targetStreak = achievement.criteria.targetValue
        let habitID = achievement.habitID
        
        let checkIns = allCheckIns.filter { habitID == nil || $0.habitID == habitID }
        let sortedCheckIns = checkIns.sorted { $0.date > $1.date }
        
        guard let latestCheckIn = sortedCheckIns.first else { return 0 }
        
        var currentStreak = 0
        var currentDate = latestCheckIn.date
        
        for _ in 0..<targetStreak {
            let startOfDay = currentDate.startOfDay(for: userCalendar)
            let endOfDay = currentDate.endOfDay(for: userCalendar)
            
            let hasCheckIn = checkIns.contains { checkIn in
                checkIn.date >= startOfDay && checkIn.date <= endOfDay
            }
            
            if hasCheckIn {
                currentStreak += 1
                currentDate = userCalendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return min(Double(currentStreak) / Double(targetStreak), 1.0)
    }
    
    private func getTotalCheckInsProgress(for achievement: Badge) -> Double {
        let targetCount = achievement.criteria.targetValue
        let habitID = achievement.habitID
        
        let totalCheckIns = allCheckIns.filter { habitID == nil || $0.habitID == habitID }.count
        
        return min(Double(totalCheckIns) / Double(targetCount), 1.0)
    }
    
    private func getConsistencyProgress(for achievement: Badge) -> Double {
        let targetDays = achievement.criteria.targetValue
        var currentDate = Date()
        var consecutiveDays = 0
        
        for _ in 0..<targetDays {
            let startOfDay = currentDate.startOfDay(for: userCalendar)
            let endOfDay = currentDate.endOfDay(for: userCalendar)
            
            let hasAnyCheckIn = allCheckIns.contains { checkIn in
                checkIn.date >= startOfDay && checkIn.date <= endOfDay
            }
            
            if hasAnyCheckIn {
                consecutiveDays += 1
                currentDate = userCalendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return min(Double(consecutiveDays) / Double(targetDays), 1.0)
    }
    
    private func getMilestoneProgress(for achievement: Badge) -> Double {
        let targetCount = achievement.criteria.targetValue
        let totalCheckIns = allCheckIns.count
        
        return min(Double(totalCheckIns) / Double(targetCount), 1.0)
    }
    
    func createAchievementShareText(_ achievement: Badge) -> String {
        let appName = "Habit Diary"
        let appStoreURL = "https://apps.apple.com/app/id\(Constants.AppID.appID)"
        
        var shareText = "🎉 Badge Unlocked! 🎉\n\n"
        shareText += "🏆 \(achievement.title)\n"
        shareText += "📝 \(achievement.description)\n\n"
        
        if let unlockDate = achievement.unlockedDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            shareText += "📅 Unlocked on \(formatter.string(from: unlockDate))\n\n"
        }
        
        shareText += "💪 Keep building healthy habits with \(appName)!\n"
        shareText += "📱 Download: \(appStoreURL)"
        
        return shareText
    }
}
