//
// Created by Banghua Zhao on 03/06/2025
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation

struct HabitsDataStore {
    // MARK: - Movement & Activity
    static let morningWalk = Habit.Draft(
        name: String(localized: "Morning walk"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "7",
        icon: "🚶‍♂️",
        color: 0x4CAF5099,
        note: String(localized: "Log in your diary how a morning walk sets the tone for your whole day.")
    )
    
    static let workout = Habit.Draft(
        name: String(localized: "Workout"),
        frequency: .fixedDaysInWeek,
        frequencyDetail: "1,3,5",
        icon: "💪",
        color: 0xFF572299,
        note: String(localized: "Track your sessions and jot down what felt strong or challenging.")
    )
    
    static let yoga = Habit.Draft(
        name: String(localized: "Yoga practice"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "4",
        icon: "🧘‍♀️",
        color: 0x9C27B099,
        note: String(localized: "Write a quick note after each session — notice how your practice evolves over time.")
    )
    
    static let swimming = Habit.Draft(
        name: String(localized: "Swimming"),
        frequency: .fixedDaysInWeek,
        frequencyDetail: "2,4,6",
        icon: "🏊‍♂️",
        color: 0x2196F399,
        note: String(localized: "A great habit to track in your diary — watch your stamina build page by page.")
    )
    
    static let running = Habit.Draft(
        name: String(localized: "Running"),
        frequency: .fixedDaysInWeek,
        frequencyDetail: "1,3,5,7",
        icon: "🏃‍♂️",
        color: 0xFF980099,
        note: String(localized: "Use your diary notes to spot patterns in your pace, weather, and energy.")
    )
    
    // MARK: - Nourishment
    static let drinkWater = Habit.Draft(
        name: String(localized: "Drink 8 glasses of water"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "7",
        icon: "💧",
        color: 0x03A9F499,
        note: String(localized: "A simple daily entry — keep the streak going and notice how you feel.")
    )
    
    static let eatFruits = Habit.Draft(
        name: String(localized: "Eat fruits"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "7",
        icon: "🍎",
        color: 0x8BC34A99,
        note: String(localized: "Log your daily fruit choices and notice which ones you enjoy most.")
    )
    
    static let eatVegetables = Habit.Draft(
        name: String(localized: "Eat vegetables"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "7",
        icon: "🥬",
        color: 0x4CAF5099,
        note: String(localized: "Record what you're eating — building a colorful journal of good choices.")
    )
    
    static let noSugar = Habit.Draft(
        name: String(localized: "Avoid added sugar"),
        frequency: .fixedDaysInWeek,
        frequencyDetail: "1,2,3,4,5",
        icon: "🚫",
        color: 0xF4433699,
        note: String(localized: "Checking this off is proof of your commitment. Write how it went in your note.")
    )
    
    static let cookHealthy = Habit.Draft(
        name: String(localized: "Cook a homemade meal"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "5",
        icon: "👨‍🍳",
        color: 0xFF572299,
        note: String(localized: "Jot down what you cooked — your diary becomes your personal recipe journal.")
    )
    
    // MARK: - Rest & Renewal
    static let sleep = Habit.Draft(
        name: String(localized: "Sleep 7-9 hours"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "7",
        icon: "😴",
        color: 0x67419799,
        note: String(localized: "Track your sleep entries and see how rest shapes your next-day mood.")
    )
    
    static let noScreenBeforeBed = Habit.Draft(
        name: String(localized: "No screens 1 hour before bed"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "7",
        icon: "📱",
        color: 0x795548CC,
        note: String(localized: "Use that screen-free hour to write tonight's diary entry instead.")
    )
    
    static let earlyBedtime = Habit.Draft(
        name: String(localized: "Sleep by 10 PM"),
        frequency: .fixedDaysInWeek,
        frequencyDetail: "1,2,3,4,5",
        icon: "🌙",
        color: 0x3F51B599,
        note: String(localized: "Log it and notice how early nights change the texture of your mornings.")
    )
    
    // MARK: - Mind & Reflection
    static let meditation = Habit.Draft(
        name: String(localized: "Meditation"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "7",
        icon: "🧘",
        color: 0x9C27B099,
        note: String(localized: "After each sit, write one thing that surfaced — a thought, feeling, or insight.")
    )
    
    static let gratitudeJournal = Habit.Draft(
        name: String(localized: "Write gratitude journal"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "7",
        icon: "📝",
        color: 0xFFC10799,
        note: String(localized: "Three things you're grateful for — the simplest diary entry with the biggest impact.")
    )
    
    static let deepBreathing = Habit.Draft(
        name: String(localized: "Deep breathing exercise"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "5",
        icon: "🫁",
        color: 0x00BCD499,
        note: String(localized: "Write a word or two about how you felt before and after — see the shift.")
    )
    
    static let noSocialMedia = Habit.Draft(
        name: String(localized: "Limit social media"),
        frequency: .fixedDaysInWeek,
        frequencyDetail: "1,2,3,4,5,6,7",
        icon: "📵",
        color: 0x60707399,
        note: String(localized: "Reclaim that time for your diary — trade scrolling for reflecting.")
    )
    
    // MARK: - Learning & Curiosity
    static let reading = Habit.Draft(
        name: String(localized: "Read for 30 minutes"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "7",
        icon: "📚",
        color: 0x79554899,
        note: String(localized: "Add a note about what you read today — your diary becomes a reading log.")
    )
    
    static let learnLanguage = Habit.Draft(
        name: String(localized: "Learn new language"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "5",
        icon: "🗣️",
        color: 0x3F51B599,
        note: String(localized: "Record new words or phrases you learned — a unique entry every day.")
    )
    
    static let podcast = Habit.Draft(
        name: String(localized: "Listen to educational podcast"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "3",
        icon: "🎧",
        color: 0xFF980099,
        note: String(localized: "Write the one idea from today's episode worth remembering.")
    )
    
    static let skillPractice = Habit.Draft(
        name: String(localized: "Practice a skill"),
        frequency: .fixedDaysInWeek,
        frequencyDetail: "1,3,5,7",
        icon: "🎯",
        color: 0x4CAF5099,
        note: String(localized: "Log your practice time and note what clicked — watch your story of mastery unfold.")
    )
    
    // MARK: - Focus & Flow
    static let planDay = Habit.Draft(
        name: String(localized: "Plan the day"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "7",
        icon: "📅",
        color: 0x2196F399,
        note: String(localized: "Write your top three intentions for the day — a mini diary entry every morning.")
    )
    
    static let cleanDesk = Habit.Draft(
        name: String(localized: "Organize workspace"),
        frequency: .fixedDaysInWeek,
        frequencyDetail: "1,3,5",
        icon: "🗂️",
        color: 0x60707399,
        note: String(localized: "A tidy desk is a good backdrop for journaling. Log it and feel the difference.")
    )
    
    static let reviewWeek = Habit.Draft(
        name: String(localized: "Weekly review"),
        frequency: .fixedDaysInWeek,
        frequencyDetail: "7",
        icon: "📊",
        color: 0x795548CC,
        note: String(localized: "Your richest diary entry of the week — wins, struggles, and what comes next.")
    )
    
    static let timeBlocking = Habit.Draft(
        name: String(localized: "Use time blocking"),
        frequency: .fixedDaysInWeek,
        frequencyDetail: "1,2,3,4,5",
        icon: "⏰",
        color: 0xFF572299,
        note: String(localized: "Note which blocks you protected today — your diary shows you where time really goes.")
    )
    
    // MARK: - Connection
    static let callFamily = Habit.Draft(
        name: String(localized: "Call family/friends"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "2",
        icon: "📞",
        color: 0x4CAF5099,
        note: String(localized: "Write a line about who you spoke with and what you shared — moments worth keeping.")
    )
    
    static let socialActivity = Habit.Draft(
        name: String(localized: "Social activity"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "1",
        icon: "👥",
        color: 0x9C27B099,
        note: String(localized: "A diary entry about time with others is always worth reading later.")
    )
    
    static let kindnessAct = Habit.Draft(
        name: String(localized: "Do a kind act"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "3",
        icon: "❤️",
        color: 0xE91E6399,
        note: String(localized: "Note what you did and for whom — small kindnesses deserve a page in your story.")
    )
    
    // MARK: - Self-Care
    static let skincare = Habit.Draft(
        name: String(localized: "Skincare routine"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "7",
        icon: "🧴",
        color: 0xF8BBD999,
        note: String(localized: "A daily ritual worth logging — notice the difference consistency makes.")
    )
    
    static let stretchingX = Habit.Draft(
        name: String(localized: "Stretching"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "7",
        icon: "🤸‍♀️",
        color: 0xFF572299,
        note: String(localized: "Write how your body felt before and after — these notes become your progress story.")
    )
    
    static let vitamins = Habit.Draft(
        name: String(localized: "Take vitamins"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "7",
        icon: "💊",
        color: 0xFFC10799,
        note: String(localized: "A quick daily log — tick it off and keep the streak alive.")
    )
    
    static let sunlight = Habit.Draft(
        name: String(localized: "Get morning sunlight"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "7",
        icon: "☀️",
        color: 0xFFEB3B99,
        note: String(localized: "Step outside and breathe. Write one observation about the morning sky.")
    )
    
    // MARK: - Space & Environment
    static let makeBeauty = Habit.Draft(
        name: String(localized: "Make bed"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "7",
        icon: "🛏️",
        color: 0x79554899,
        note: String(localized: "A small first win every morning — log it and start the page on a good note.")
    )
    
    static let declutter = Habit.Draft(
        name: String(localized: "Declutter 15 minutes"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "3",
        icon: "🧹",
        color: 0x607D8B99,
        note: String(localized: "Note what you cleared out — both your space and your thoughts become lighter.")
    )
    
    static let outdoorTime = Habit.Draft(
        name: String(localized: "Spend time outdoors"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "5",
        icon: "🌳",
        color: 0x4CAF5099,
        note: String(localized: "Write one thing you noticed outside today — your diary becomes a nature log.")
    )
    
    // MARK: - Creative Expression
    static let creative = Habit.Draft(
        name: String(localized: "Creative activity"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "3",
        icon: "🎨",
        color: 0x9C27B099,
        note: String(localized: "Jot down what you made or explored — your diary tracks your creative journey.")
    )
    
    static let music = Habit.Draft(
        name: String(localized: "Play musical instrument"),
        frequency: .fixedDaysInWeek,
        frequencyDetail: "2,4,6",
        icon: "🎸",
        color: 0xFF572299,
        note: String(localized: "Note what you practiced and what it felt like — a musical diary unfolds over time.")
    )
    
    static let photography = Habit.Draft(
        name: String(localized: "Take photos"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "2",
        icon: "📸",
        color: 0x607D8B99,
        note: String(localized: "Capture the day. Add a note about the story behind your favorite shot.")
    )
    
    // MARK: - Diary & Journaling
    static let eveningDiary = Habit.Draft(
        name: String(localized: "Evening diary entry"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "7",
        icon: "📔",
        color: 0x5D4E3799,
        note: String(localized: "End the day by writing — even a few sentences. Over time, these pages become your story.")
    )
    
    static let morningPages = Habit.Draft(
        name: String(localized: "Morning pages"),
        frequency: .nDaysEachWeek,
        frequencyDetail: "5",
        icon: "✍️",
        color: 0x79554899,
        note: String(localized: "Fill three pages first thing — stream-of-consciousness writing that clears the mind.")
    )
    
    static let reflectOnGoals = Habit.Draft(
        name: String(localized: "Reflect on your goals"),
        frequency: .fixedDaysInWeek,
        frequencyDetail: "1,4",
        icon: "🔭",
        color: 0x3F51B599,
        note: String(localized: "Write where you are vs. where you want to be. Your diary holds you accountable.")
    )
    
    static let all = [
        // Movement & Activity
        morningWalk,
        workout,
        yoga,
        swimming,
        running,
        stretchingX,
        
        // Nourishment
        drinkWater,
        eatFruits,
        eatVegetables,
        noSugar,
        cookHealthy,
        vitamins,
        
        // Rest & Renewal
        sleep,
        noScreenBeforeBed,
        earlyBedtime,
        
        // Mind & Reflection
        meditation,
        gratitudeJournal,
        deepBreathing,
        noSocialMedia,
        
        // Learning & Curiosity
        reading,
        learnLanguage,
        podcast,
        skillPractice,
        
        // Focus & Flow
        planDay,
        cleanDesk,
        reviewWeek,
        timeBlocking,
        
        // Connection
        callFamily,
        socialActivity,
        kindnessAct,
        
        // Self-Care
        skincare,
        sunlight,
        
        // Space & Environment
        makeBeauty,
        declutter,
        outdoorTime,
        
        // Creative Expression
        creative,
        music,
        photography,
        
        // Diary & Journaling
        eveningDiary,
        morningPages,
        reflectOnGoals
    ]
}
