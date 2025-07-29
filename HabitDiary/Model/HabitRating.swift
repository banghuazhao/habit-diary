//
// Created by Banghua Zhao on 01/01/2025
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation
import SwiftUI

enum HabitRating: String, CaseIterable {
    case f = "F"
    case dMinus = "D-"
    case d = "D"
    case cMinus = "C-"
    case c = "C"
    case bMinus = "B-"
    case b = "B"
    case aMinus = "A-"
    case a = "A"
    case s = "S"
    case ss = "SS"
    case sss = "SSS"
    
    var displayName: String {
        return self.rawValue
    }
    
    var color: Color {
        switch self {
        case .f: return .gray
        case .dMinus: return .brown
        case .d: return .orange
        case .cMinus: return .yellow
        case .c: return .mint
        case .bMinus: return .green
        case .b: return .blue
        case .aMinus: return .indigo
        case .a: return .purple
        case .s: return .pink
        case .ss: return .red
        case .sss: return .primary
        }
    }
    
    var description: String {
        switch self {
        case .f: return String(localized: "Beginner")
        case .dMinus: return String(localized: "Novice")
        case .d: return String(localized: "Novice+")
        case .cMinus: return String(localized: "Apprentice")
        case .c: return String(localized: "Apprentice+")
        case .bMinus: return String(localized: "Intermediate")
        case .b: return String(localized: "Intermediate+")
        case .aMinus: return String(localized: "Advanced")
        case .a: return String(localized: "Advanced+")
        case .s: return String(localized: "Expert")
        case .ss: return String(localized: "Master")
        case .sss: return String(localized: "Legend")
        }
    }
    
    var motivationalMessage: String {
        switch self {
        case .f: return String(localized: "Every expert was once a beginner. You've got this! 🌱")
        case .dMinus: return String(localized: "You're making great progress! Keep building those habits! 🚀")
        case .d: return String(localized: "Consistency is key! You're developing a great routine! 📈")
        case .cMinus: return String(localized: "You're getting into the rhythm! Great momentum! ⚡")
        case .c: return String(localized: "Halfway there! Your dedication is paying off! 💪")
        case .bMinus: return String(localized: "You're becoming a habit master! Keep pushing! 🔥")
        case .b: return String(localized: "Impressive consistency! You're an inspiration! ⭐")
        case .aMinus: return String(localized: "Advanced level achieved! You're crushing it! 🏆")
        case .a: return String(localized: "Elite habit builder! Your discipline is incredible! 💎")
        case .s: return String(localized: "Expert status unlocked! You're in the top tier! 👑")
        case .ss: return String(localized: "Master of habits! Your consistency is legendary! 🌟")
        case .sss: return String(localized: "LEGEND! You've achieved the ultimate level! 🚀✨")
        }
    }
    
    static func fromScore(_ score: Int) -> HabitRating {
        switch score {
        case 0..<50: return .f
        case 50..<120: return .dMinus
        case 120..<200: return .d
        case 200..<300: return .cMinus
        case 300..<420: return .c
        case 420..<560: return .bMinus
        case 560..<720: return .b
        case 720..<900: return .aMinus
        case 900..<1100: return .a
        case 1100..<1320: return .s
        case 1320..<1560: return .ss
        default: return .sss
        }
    }
    
    var scoreRange: ClosedRange<Int> {
        switch self {
        case .f: return 0...49
        case .dMinus: return 50...119
        case .d: return 120...199
        case .cMinus: return 200...299
        case .c: return 300...419
        case .bMinus: return 420...559
        case .b: return 560...719
        case .aMinus: return 720...899
        case .a: return 900...1099
        case .s: return 1100...1319
        case .ss: return 1320...1559
        case .sss: return 1560...Int.max
        }
    }
}

enum ScoreCategory: String, CaseIterable {
    case activeHabits = "Active Habits"
    case achievements = "Achievements"
    case totalCheckIns = "Total Check-ins"
    case longestStreak = "Longest Streak"
    
    var localizedTitle: String {
        switch self {
        case .activeHabits: return String(localized: "Active Habits")
        case .achievements: return String(localized: "Achievements")
        case .totalCheckIns: return String(localized: "Total Check-ins")
        case .longestStreak: return String(localized: "Longest Streak")
        }
    }
    
    var maxScore: Int {
        switch self {
        case .activeHabits: return 400 // 5 points per habit, max 80 habits
        case .achievements: return AchievementDefinitions.all.count * 12 // 12 points per achievement
        case .totalCheckIns: return 300 // 1 point per check-in, max 300 check-ins
        case .longestStreak: return 500 // 5 points per day, max 100 days
        }
    }
    
    var icon: String {
        switch self {
        case .activeHabits: return "list.bullet"
        case .achievements: return "trophy.fill"
        case .totalCheckIns: return "checkmark.circle.fill"
        case .longestStreak: return "flame.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .activeHabits: return .blue
        case .achievements: return .yellow
        case .totalCheckIns: return .green
        case .longestStreak: return .orange
        }
    }
    
    var calculationExplanation: String {
        switch self {
        case .activeHabits:
            return String(localized: "5 points per active habit. Focus on quality over quantity - having 10-20 consistent habits is better than many inactive ones.")
        case .achievements:
            return String(localized: "12 points per unlocked achievement. Complete challenges like streaks, consistency goals, and milestones to earn more points.")
        case .totalCheckIns:
            return String(localized: "1 point per check-in across all habits. Every completed habit counts toward your total score.")
        case .longestStreak:
            return String(localized: "5 points per day in your longest consecutive streak. Building long streaks shows exceptional consistency and dedication.")
        }
    }
}

struct HabitScoreBreakdown {
    let totalScore: Int
    let habitsScore: Int
    let achievementsScore: Int
    let checkInsScore: Int
    let streakScore: Int
    
    var rating: HabitRating {
        return HabitRating.fromScore(totalScore)
    }
    
    var nextRating: HabitRating? {
        let currentIndex = HabitRating.allCases.firstIndex(of: rating) ?? 0
        let nextIndex = currentIndex + 1
        return nextIndex < HabitRating.allCases.count ? HabitRating.allCases[nextIndex] : nil
    }
    
    var scoreToNextRating: Int {
        guard let nextRating = nextRating else { return 0 }
        let nextScore = nextRating.scoreRange.lowerBound
        return max(0, nextScore - totalScore)
    }
    
    var progressInCurrentRating: Double {
        let currentRange = rating.scoreRange
        let rangeSize = currentRange.upperBound - currentRange.lowerBound + 1
        let progressInRange = totalScore - currentRange.lowerBound
        return Double(max(0, progressInRange)) / Double(rangeSize)
    }
    
    var maxPossibleScore: Int {
        return ScoreCategory.allCases.reduce(0) { $0 + $1.maxScore }
    }
    
    var overallProgress: Double {
        return Double(totalScore) / Double(maxPossibleScore)
    }
}

struct ScoreBreakdownItem {
    let category: ScoreCategory
    let score: Int
    
    var maxScore: Int {
        return category.maxScore
    }
    
    var icon: String {
        return category.icon
    }
    
    var color: Color {
        return category.color
    }
    
    var title: String {
        return category.localizedTitle
    }
    
    var percentage: Double {
        return Double(score) / Double(maxScore)
    }
    
    var explanation: String {
        return category.calculationExplanation
    }
    
    var performanceLevel: PerformanceLevel {
        switch percentage {
        case 0..<0.25: return .low
        case 0.25..<0.5: return .fair
        case 0.5..<0.75: return .good
        case 0.75..<0.9: return .excellent
        default: return .outstanding
        }
    }
    
    enum PerformanceLevel {
        case low, fair, good, excellent, outstanding
        
        var description: String {
            switch self {
            case .low: return String(localized: "Getting Started")
            case .fair: return String(localized: "Making Progress")
            case .good: return String(localized: "Doing Well")
            case .excellent: return String(localized: "Excellent")
            case .outstanding: return String(localized: "Outstanding")
            }
        }
        
        var color: Color {
            switch self {
            case .low: return .gray
            case .fair: return .orange
            case .good: return .blue
            case .excellent: return .green
            case .outstanding: return .purple
            }
        }
    }
} 