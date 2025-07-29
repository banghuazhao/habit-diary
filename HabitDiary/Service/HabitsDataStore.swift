//
// Created by Banghua Zhao on 03/06/2025
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation

struct HabitsDataStore {
    // MARK: - Health & Fitness
    static let morningWalk = Habit.Draft(
        name: String(localized: "Morning walk"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "7",
        icon: "🚶‍♂️",
        color: 0x4CAF5099,
        note: String(localized: "Start your day with a 20-30 minute walk to boost energy and mood.")
    )
    
    static let workout = Habit.Draft(
        name: String(localized: "Workout"),
        frequency: .fixedDaysInWeek,
        frequencyDetail: "1,3,5",
        icon: "💪",
        color: 0xFF572299,
        note: String(localized: "Strength training or cardio exercise for at least 30 minutes.")
    )
    
    static let yoga = Habit.Draft(
        name: String(localized: "Yoga practice"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "4",
        icon: "🧘‍♀️",
        color: 0x9C27B099,
        note: String(localized: "Practice yoga for flexibility, strength, and mental clarity.")
    )
    
    static let swimming = Habit.Draft(
        name: String(localized: "Swimming"),
        frequency: .fixedDaysInWeek,
        frequencyDetail: "2,4,6",
        icon: "🏊‍♂️",
        color: 0x2196F399,
        note: String(localized: "Swimming improves cardiovascular health and builds full-body strength.")
    )
    
    static let running = Habit.Draft(
        name: String(localized: "Running"),
        frequency: .fixedDaysInWeek,
        frequencyDetail: "1,3,5,7",
        icon: "🏃‍♂️",
        color: 0xFF980099,
        note: String(localized: "Go for a run to improve cardiovascular health and endurance.")
    )
    
    // MARK: - Nutrition & Hydration
    static let drinkWater = Habit.Draft(
        name: String(localized: "Drink 8 glasses of water"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "7",
        icon: "💧",
        color: 0x03A9F499,
        note: String(localized: "Stay hydrated by drinking at least 8 glasses of water daily.")
    )
    
    static let eatFruits = Habit.Draft(
        name: String(localized: "Eat fruits"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "7",
        icon: "🍎",
        color: 0x8BC34A99,
        note: String(localized: "Include at least 2 servings of fresh fruits in your daily diet.")
    )
    
    static let eatVegetables = Habit.Draft(
        name: String(localized: "Eat vegetables"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "7",
        icon: "🥬",
        color: 0x4CAF5099,
        note: String(localized: "Consume at least 3 servings of vegetables for essential nutrients.")
    )
    
    static let noSugar = Habit.Draft(
        name: String(localized: "Avoid added sugar"),
        frequency: .fixedDaysInWeek,
        frequencyDetail: "1,2,3,4,5",
        icon: "🚫",
        color: 0xF4433699,
        note: String(localized: "Limit processed foods and drinks with added sugars.")
    )
    
    static let cookHealthy = Habit.Draft(
        name: String(localized: "Cook healthy meal"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "5",
        icon: "👨‍🍳",
        color: 0xFF572299,
        note: String(localized: "Prepare nutritious homemade meals instead of ordering takeout.")
    )
    
    // MARK: - Sleep & Rest
    static let sleep = Habit.Draft(
        name: String(localized: "Sleep 7-9 hours"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "7",
        icon: "😴",
        color: 0x67419799,
        note: String(localized: "Maintain consistent sleep schedule with 7-9 hours of quality rest.")
    )
    
    static let noScreenBeforeBed = Habit.Draft(
        name: String(localized: "No screens 1 hour before bed"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "7",
        icon: "📱",
        color: 0x795548CC,
        note: String(localized: "Avoid electronic devices before bedtime for better sleep quality.")
    )
    
    static let earlyBedtime = Habit.Draft(
        name: String(localized: "Sleep by 10 PM"),
        frequency: .fixedDaysInWeek,
        frequencyDetail: "1,2,3,4,5",
        icon: "🌙",
        color: 0x3F51B599,
        note: String(localized: "Go to bed early on weekdays to ensure adequate rest.")
    )
    
    // MARK: - Mental Health & Mindfulness
    static let meditation = Habit.Draft(
        name: String(localized: "Meditation"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "7",
        icon: "🧘",
        color: 0x9C27B099,
        note: String(localized: "Practice mindfulness meditation for 10-20 minutes daily.")
    )
    
    static let gratitudeJournal = Habit.Draft(
        name: String(localized: "Write gratitude journal"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "7",
        icon: "📝",
        color: 0xFFC10799,
        note: String(localized: "Write down 3 things you're grateful for each day.")
    )
    
    static let deepBreathing = Habit.Draft(
        name: String(localized: "Deep breathing exercise"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "5",
        icon: "🫁",
        color: 0x00BCD499,
        note: String(localized: "Practice deep breathing for stress relief and relaxation.")
    )
    
    static let noSocialMedia = Habit.Draft(
        name: String(localized: "Limit social media"),
        frequency: .fixedDaysInWeek,
        frequencyDetail: "1,2,3,4,5,6,7",
        icon: "📵",
        color: 0x60707399,
        note: String(localized: "Limit social media usage to reduce stress and increase focus.")
    )
    
    // MARK: - Learning & Growth
    static let reading = Habit.Draft(
        name: String(localized: "Read for 30 minutes"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "7",
        icon: "📚",
        color: 0x79554899,
        note: String(localized: "Read books, articles, or educational content for personal growth.")
    )
    
    static let learnLanguage = Habit.Draft(
        name: String(localized: "Learn new language"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "5",
        icon: "🗣️",
        color: 0x3F51B599,
        note: String(localized: "Practice a new language for 15-30 minutes daily.")
    )
    
    static let podcast = Habit.Draft(
        name: String(localized: "Listen to educational podcast"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "3",
        icon: "🎧",
        color: 0xFF980099,
        note: String(localized: "Listen to educational or inspiring podcasts during commute or exercise.")
    )
    
    static let skillPractice = Habit.Draft(
        name: String(localized: "Practice a skill"),
        frequency: .fixedDaysInWeek,
        frequencyDetail: "1,3,5,7",
        icon: "🎯",
        color: 0x4CAF5099,
        note: String(localized: "Dedicate time to practice a hobby or professional skill.")
    )
    
    // MARK: - Productivity & Organization
    static let planDay = Habit.Draft(
        name: String(localized: "Plan the day"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "7",
        icon: "📅",
        color: 0x2196F399,
        note: String(localized: "Spend 10 minutes each morning planning your day and priorities.")
    )
    
    static let cleanDesk = Habit.Draft(
        name: String(localized: "Organize workspace"),
        frequency: .fixedDaysInWeek,
        frequencyDetail: "1,3,5",
        icon: "🗂️",
        color: 0x60707399,
        note: String(localized: "Keep your workspace clean and organized for better productivity.")
    )
    
    static let reviewWeek = Habit.Draft(
        name: String(localized: "Weekly review"),
        frequency: .fixedDaysInWeek,
        frequencyDetail: "7",
        icon: "📊",
        color: 0x795548CC,
        note: String(localized: "Reflect on the week's achievements and plan for the next week.")
    )
    
    static let timeBlocking = Habit.Draft(
        name: String(localized: "Use time blocking"),
        frequency: .fixedDaysInWeek,
        frequencyDetail: "1,2,3,4,5",
        icon: "⏰",
        color: 0xFF572299,
        note: String(localized: "Schedule focused work blocks for important tasks.")
    )
    
    // MARK: - Social & Relationships
    static let callFamily = Habit.Draft(
        name: String(localized: "Call family/friends"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "2",
        icon: "📞",
        color: 0x4CAF5099,
        note: String(localized: "Stay connected with loved ones through regular phone calls.")
    )
    
    static let socialActivity = Habit.Draft(
        name: String(localized: "Social activity"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "1",
        icon: "👥",
        color: 0x9C27B099,
        note: String(localized: "Engage in social activities to maintain relationships and well-being.")
    )
    
    static let kindnessAct = Habit.Draft(
        name: String(localized: "Do a kind act"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "3",
        icon: "❤️",
        color: 0xE91E6399,
        note: String(localized: "Perform small acts of kindness to spread positivity.")
    )
    
    // MARK: - Self-Care & Wellness
    static let skincare = Habit.Draft(
        name: String(localized: "Skincare routine"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "7",
        icon: "🧴",
        color: 0xF8BBD999,
        note: String(localized: "Follow a consistent skincare routine for healthy skin.")
    )
    
    static let stretchingX = Habit.Draft(
        name: String(localized: "Stretching"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "7",
        icon: "🤸‍♀️",
        color: 0xFF572299,
        note: String(localized: "Do stretching exercises to improve flexibility and prevent injury.")
    )
    
    static let vitamins = Habit.Draft(
        name: String(localized: "Take vitamins"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "7",
        icon: "💊",
        color: 0xFFC10799,
        note: String(localized: "Take essential vitamins and supplements as recommended.")
    )
    
    static let sunlight = Habit.Draft(
        name: String(localized: "Get morning sunlight"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "7",
        icon: "☀️",
        color: 0xFFEB3B99,
        note: String(localized: "Spend 10-15 minutes in morning sunlight to regulate circadian rhythm.")
    )
    
    // MARK: - Environment & Lifestyle
    static let makeBeauty = Habit.Draft(
        name: String(localized: "Make bed"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "7",
        icon: "🛏️",
        color: 0x79554899,
        note: String(localized: "Start the day by making your bed for a sense of accomplishment.")
    )
    
    static let declutter = Habit.Draft(
        name: String(localized: "Declutter 15 minutes"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "3",
        icon: "🧹",
        color: 0x607D8B99,
        note: String(localized: "Spend 15 minutes decluttering and organizing your living space.")
    )
    
    static let outdoorTime = Habit.Draft(
        name: String(localized: "Spend time outdoors"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "5",
        icon: "🌳",
        color: 0x4CAF5099,
        note: String(localized: "Spend time in nature for mental health and vitamin D.")
    )
    
    // MARK: - Creative & Hobbies
    static let creative = Habit.Draft(
        name: String(localized: "Creative activity"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "3",
        icon: "🎨",
        color: 0x9C27B099,
        note: String(localized: "Engage in creative activities like drawing, writing, or crafting.")
    )
    
    static let music = Habit.Draft(
        name: String(localized: "Play musical instrument"),
        frequency: .fixedDaysInWeek,
        frequencyDetail: "2,4,6",
        icon: "🎸",
        color: 0xFF572299,
        note: String(localized: "Practice playing a musical instrument for cognitive benefits.")
    )
    
    static let photography = Habit.Draft(
        name: String(localized: "Take photos"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "2",
        icon: "📸",
        color: 0x607D8B99,
        note: String(localized: "Practice photography to capture memories and improve creativity.")
    )
    
    static let all = [
        // Health & Fitness
        morningWalk,
        workout,
        yoga,
        swimming,
        running,
        stretchingX,
        
        // Nutrition & Hydration
        drinkWater,
        eatFruits,
        eatVegetables,
        noSugar,
        cookHealthy,
        vitamins,
        
        // Sleep & Rest
        sleep,
        noScreenBeforeBed,
        earlyBedtime,
        
        // Mental Health & Mindfulness
        meditation,
        gratitudeJournal,
        deepBreathing,
        noSocialMedia,
        
        // Learning & Growth
        reading,
        learnLanguage,
        podcast,
        skillPractice,
        
        // Productivity & Organization
        planDay,
        cleanDesk,
        reviewWeek,
        timeBlocking,
        
        // Social & Relationships
        callFamily,
        socialActivity,
        kindnessAct,
        
        // Self-Care & Wellness
        skincare,
        sunlight,
        
        // Environment & Lifestyle
        makeBeauty,
        declutter,
        outdoorTime,
        
        // Creative & Hobbies
        creative,
        music,
        photography
    ]
}
