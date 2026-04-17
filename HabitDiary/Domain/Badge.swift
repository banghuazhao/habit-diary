//
// Created by Banghua Zhao on 01/01/2025
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation
import SQLiteData

@Table
struct Badge: Identifiable {
    let id: Int
    var title: String
    var description: String
    var icon: String
    var type: BadgeType
    @Column(as: BadgeCriteria.JSONRepresentation.self)
    var criteria: BadgeCriteria
    var isUnlocked: Bool
    var unlockedDate: Date?
    var habitID: Int? // nil for global achievements
}

extension Badge.Draft: Identifiable {}

enum BadgeType: Int, Codable, QueryBindable {
    case streak
    case totalCheckIns
    case perfectWeek
    case perfectMonth
    case earlyBird
    case nightOwl
    case consistency
    case milestone
    
    var title: String {
        switch self {
        case .streak: return String(localized: "Daily Scribe")
        case .totalCheckIns: return String(localized: "Prolific Journaler")
        case .perfectWeek: return String(localized: "Full-Page Week")
        case .perfectMonth: return String(localized: "Complete Volume")
        case .earlyBird: return String(localized: "Early Bird")
        case .nightOwl: return String(localized: "Night Owl")
        case .consistency: return String(localized: "Journal Keeper")
        case .milestone: return String(localized: "First Entry")
        }
    }
    
    var icon: String {
        switch self {
        case .streak: return "🔥"
        case .totalCheckIns: return "✅"
        case .perfectWeek: return "⭐"
        case .perfectMonth: return "🏆"
        case .earlyBird: return "🌅"
        case .nightOwl: return "🦉"
        case .consistency: return "📈"
        case .milestone: return "🎯"
        }
    }
}

struct BadgeCriteria: Codable {
    var targetValue: Int
    var timeFrame: TimeFrame?
    
    enum TimeFrame: String, Codable {
        case day = "day"
        case week = "week"
        case month = "month"
        case year = "year"
        case allTime = "allTime"
    }
    
    // Custom encoding/decoding for JSON storage in database
    func encode() -> String {
        let data = try? JSONEncoder().encode(self)
        return String(data: data ?? Data(), encoding: .utf8) ?? "{}"
    }
    
    static func decode(from string: String) -> BadgeCriteria? {
        guard let data = string.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(BadgeCriteria.self, from: data)
    }
}

// Badge definitions
struct BadgeDefinitions {
    static let all: [Badge.Draft] = [
        // Streak achievements
        Badge.Draft(
            title: String(localized: "Ink Is Flowing"),
            description: String(localized: "Write diary entries 3 days running"),
            icon: "🔥",
            type: .streak,
            criteria: BadgeCriteria(targetValue: 3),
            isUnlocked: false,
            unlockedDate: nil,
            habitID: nil
        ),
        Badge.Draft(
            title: String(localized: "Seven Pages"),
            description: String(localized: "Keep a 7-day journaling streak"),
            icon: "🔥",
            type: .streak,
            criteria: BadgeCriteria(targetValue: 7),
            isUnlocked: false,
            unlockedDate: nil,
            habitID: nil
        ),
        Badge.Draft(
            title: String(localized: "A Month of Pages"),
            description: String(localized: "Fill your diary 30 days in a row"),
            icon: "🔥",
            type: .streak,
            criteria: BadgeCriteria(targetValue: 30),
            isUnlocked: false,
            unlockedDate: nil,
            habitID: nil
        ),
        
        // Total check-ins
        Badge.Draft(
            title: String(localized: "Opening Chapter"),
            description: String(localized: "Log 10 diary entries"),
            icon: "📖",
            type: .totalCheckIns,
            criteria: BadgeCriteria(targetValue: 10),
            isUnlocked: false,
            unlockedDate: nil,
            habitID: nil
        ),
        Badge.Draft(
            title: String(localized: "Page Turner"),
            description: String(localized: "Log 50 diary entries"),
            icon: "📖",
            type: .totalCheckIns,
            criteria: BadgeCriteria(targetValue: 50),
            isUnlocked: false,
            unlockedDate: nil,
            habitID: nil
        ),
        Badge.Draft(
            title: String(localized: "Full Volume"),
            description: String(localized: "Log 100 diary entries"),
            icon: "📖",
            type: .totalCheckIns,
            criteria: BadgeCriteria(targetValue: 100),
            isUnlocked: false,
            unlockedDate: nil,
            habitID: nil
        ),
        
        // Perfect week/month
        Badge.Draft(
            title: String(localized: "Full-Page Week"),
            description: String(localized: "Fill every diary page for a whole week"),
            icon: "⭐",
            type: .perfectWeek,
            criteria: BadgeCriteria(targetValue: 1),
            isUnlocked: false,
            unlockedDate: nil,
            habitID: nil
        ),
        Badge.Draft(
            title: String(localized: "Complete Volume"),
            description: String(localized: "Fill every diary page for a whole month"),
            icon: "🏆",
            type: .perfectMonth,
            criteria: BadgeCriteria(targetValue: 1),
            isUnlocked: false,
            unlockedDate: nil,
            habitID: nil
        ),
        
        // Time-based achievements
        Badge.Draft(
            title: String(localized: "Early Bird"),
            description: String(localized: "Write your first diary entry before 8 AM"),
            icon: "🌅",
            type: .earlyBird,
            criteria: BadgeCriteria(targetValue: 1),
            isUnlocked: false,
            unlockedDate: nil,
            habitID: nil
        ),
        Badge.Draft(
            title: String(localized: "Night Owl"),
            description: String(localized: "Write a diary entry after 10 PM"),
            icon: "🦉",
            type: .nightOwl,
            criteria: BadgeCriteria(targetValue: 1),
            isUnlocked: false,
            unlockedDate: nil,
            habitID: nil
        ),
        
        // Consistency achievements
        Badge.Draft(
            title: String(localized: "Steady Hand"),
            description: String(localized: "Log diary entries 5 days in a row"),
            icon: "✍️",
            type: .consistency,
            criteria: BadgeCriteria(targetValue: 5),
            isUnlocked: false,
            unlockedDate: nil,
            habitID: nil
        ),
        
        // Milestone achievements
        Badge.Draft(
            title: String(localized: "First Entry"),
            description: String(localized: "Write your very first diary entry"),
            icon: "📔",
            type: .milestone,
            criteria: BadgeCriteria(targetValue: 1),
            isUnlocked: false,
            unlockedDate: nil,
            habitID: nil
        ),
        
        // Additional streak achievements
        Badge.Draft(
            title: String(localized: "Century Journal"),
            description: String(localized: "Keep a 100-day diary streak"),
            icon: "🔥",
            type: .streak,
            criteria: BadgeCriteria(targetValue: 100),
            isUnlocked: false,
            unlockedDate: nil,
            habitID: nil
        ),
        
        // Additional total check-ins
        Badge.Draft(
            title: String(localized: "Collector of Days"),
            description: String(localized: "Log 500 diary entries"),
            icon: "📖",
            type: .totalCheckIns,
            criteria: BadgeCriteria(targetValue: 500),
            isUnlocked: false,
            unlockedDate: nil,
            habitID: nil
        ),
        Badge.Draft(
            title: String(localized: "Life in Pages"),
            description: String(localized: "Log 1000 diary entries"),
            icon: "📖",
            type: .totalCheckIns,
            criteria: BadgeCriteria(targetValue: 1000),
            isUnlocked: false,
            unlockedDate: nil,
            habitID: nil
        ),
        
        // Additional consistency achievements
        Badge.Draft(
            title: String(localized: "Devoted Diarist"),
            description: String(localized: "Log diary entries 10 days in a row"),
            icon: "✍️",
            type: .consistency,
            criteria: BadgeCriteria(targetValue: 10),
            isUnlocked: false,
            unlockedDate: nil,
            habitID: nil
        ),
        Badge.Draft(
            title: String(localized: "Unbroken Thread"),
            description: String(localized: "Log diary entries 20 days in a row"),
            icon: "✍️",
            type: .consistency,
            criteria: BadgeCriteria(targetValue: 20),
            isUnlocked: false,
            unlockedDate: nil,
            habitID: nil
        )
    ]
} 
