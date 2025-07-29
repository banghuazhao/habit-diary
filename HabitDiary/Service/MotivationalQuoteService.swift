//
//  MotivationalQuoteService.swift
//  Habit Diary
//
//  Created by Banghua Zhao on 2025/07/17.
//  Copyright Apps Bay Limited. All rights reserved.
//

import Foundation
import Dependencies
import Sharing

struct MotivationalQuote {
    let text: String
    let author: String
}

struct MotivationalQuoteService {
    @Shared(.appStorage("motivationalQuotesEnabled")) var motivationalQuotesEnabled = true
    @Shared(.appStorage("lastQuoteDismissedDate")) var lastQuoteDismissedDate: Date? = nil

    private var quotes: [MotivationalQuote] {
        [
            // Habit Formation & Consistency
            MotivationalQuote(
                text: String(localized: "We are what we repeatedly do. Excellence, then, is not an act, but a habit."),
                author: "Aristotle"
            ),
            MotivationalQuote(
                text: String(localized: "Success is the sum of small efforts repeated day in and day out."),
                author: "Robert Collier"
            ),
            MotivationalQuote(
                text: String(localized: "The secret of getting ahead is getting started."),
                author: "Mark Twain"
            ),
            MotivationalQuote(
                text: String(localized: "You don't have to be great to get started, but you have to get started to be great."),
                author: "Les Brown"
            ),
            MotivationalQuote(
                text: String(localized: "Small daily improvements over time lead to stunning results."),
                author: "Robin Sharma"
            ),
            MotivationalQuote(
                text: String(localized: "Every master was once a beginner. Every pro was once an amateur."),
                author: "Robin Sharma"
            ),
            
            // Progress & Growth
            MotivationalQuote(
                text: String(localized: "Progress, not perfection, is the goal."),
                author: String(localized: "Unknown")
            ),
            MotivationalQuote(
                text: String(localized: "The journey of a thousand miles begins with one step."),
                author: "Lao Tzu"
            ),
            MotivationalQuote(
                text: String(localized: "Don't compare your chapter 1 to someone else's chapter 20."),
                author: String(localized: "Unknown")
            ),
            MotivationalQuote(
                text: String(localized: "The only impossible journey is the one you never begin."),
                author: "Tony Robbins"
            ),
            MotivationalQuote(
                text: String(localized: "Be yourself, but always your better self."),
                author: "Karl G. Maeser"
            ),
            MotivationalQuote(
                text: String(localized: "The expert in anything was once a beginner."),
                author: "Helen Hayes"
            ),
            
            // Discipline & Consistency
            MotivationalQuote(
                text: String(localized: "Discipline is the bridge between goals and accomplishment."),
                author: "Jim Rohn"
            ),
            MotivationalQuote(
                text: String(localized: "It's not what we do once in a while that shapes our lives. It's what we do consistently."),
                author: "Tony Robbins"
            ),
            MotivationalQuote(
                text: String(localized: "The successful person has the habit of doing the things failures don't like to do."),
                author: "Earl Nightingale"
            ),
            MotivationalQuote(
                text: String(localized: "Champions are made in the offseason."),
                author: String(localized: "Unknown")
            ),
            MotivationalQuote(
                text: String(localized: "Consistency is the mother of mastery."),
                author: "Robin Sharma"
            ),
            MotivationalQuote(
                text: String(localized: "Don't break the chain. Every day counts."),
                author: "Jerry Seinfeld"
            ),
            
            // Motivation & Persistence  
            MotivationalQuote(
                text: String(localized: "Fall seven times, rise eight."),
                author: String(localized: "Japanese Proverb")
            ),
            MotivationalQuote(
                text: String(localized: "The difference between ordinary and extraordinary is that little extra."),
                author: "Jimmy Johnson"
            ),
            MotivationalQuote(
                text: String(localized: "Your only limit is your mind."),
                author: String(localized: "Unknown")
            ),
            MotivationalQuote(
                text: String(localized: "Great things never come from comfort zones."),
                author: String(localized: "Unknown")
            ),
            MotivationalQuote(
                text: String(localized: "Today's actions become tomorrow's habits."),
                author: String(localized: "Unknown")
            ),
            MotivationalQuote(
                text: String(localized: "The best time to plant a tree was 20 years ago. The second best time is now."),
                author: String(localized: "Chinese Proverb")
            ),
            
            // Achievement & Success
            MotivationalQuote(
                text: String(localized: "Success is not final, failure is not fatal: it is the courage to continue that counts."),
                author: "Winston Churchill"
            ),
            MotivationalQuote(
                text: String(localized: "Don't count the days, make the days count."),
                author: "Muhammad Ali"
            ),
            MotivationalQuote(
                text: String(localized: "The way to get started is to quit talking and begin doing."),
                author: "Walt Disney"
            ),
            MotivationalQuote(
                text: String(localized: "What seems impossible today will one day become your warm-up."),
                author: String(localized: "Unknown")
            ),
            MotivationalQuote(
                text: String(localized: "Excellence is a continuous process and not an accident."),
                author: "A. P. J. Abdul Kalam"
            ),
            MotivationalQuote(
                text: String(localized: "The only way to do great work is to love what you do."),
                author: "Steve Jobs"
            ),
            
            // Daily Improvement
            MotivationalQuote(
                text: String(localized: "If you get 1% better each day for one year, you'll end up 37 times better."),
                author: "James Clear"
            ),
            MotivationalQuote(
                text: String(localized: "Every day is a new opportunity to improve yourself."),
                author: String(localized: "Unknown")
            ),
            MotivationalQuote(
                text: String(localized: "The compound effect of small daily actions is extraordinary."),
                author: "Darren Hardy"
            ),
            MotivationalQuote(
                text: String(localized: "Today is the perfect day to start living your dreams."),
                author: String(localized: "Unknown")
            ),
            MotivationalQuote(
                text: String(localized: "Every moment is a fresh beginning."),
                author: "T.S. Eliot"
            ),
            MotivationalQuote(
                text: String(localized: "Your future is created by what you do today, not tomorrow."),
                author: "Robert Kiyosaki"
            ),
            
            // Mindset & Growth
            MotivationalQuote(
                text: String(localized: "The greatest investment you can make is in yourself."),
                author: "Warren Buffet"
            ),
            MotivationalQuote(
                text: String(localized: "Change is inevitable. Growth is optional."),
                author: "John C. Maxwell"
            ),
            MotivationalQuote(
                text: String(localized: "The only person you are destined to become is the person you decide to be."),
                author: "Ralph Waldo Emerson"
            ),
            MotivationalQuote(
                text: String(localized: "Believe you can and you're halfway there."),
                author: "Theodore Roosevelt"
            ),
            MotivationalQuote(
                text: String(localized: "Your habits shape your identity, and your identity shapes your habits."),
                author: "James Clear"
            ),
            MotivationalQuote(
                text: String(localized: "Be the person your dog thinks you are."),
                author: String(localized: "Unknown")
            )
        ]
    }
    
    func getRandomQuote() -> MotivationalQuote {
        quotes.randomElement() ?? quotes[0]
    }
    
    func shouldShowQuote() -> Bool {
        if !motivationalQuotesEnabled {
            return false
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastDismissed = lastQuoteDismissedDate {
            let lastDismissedDay = Calendar.current.startOfDay(for: lastDismissed)
            return lastDismissedDay < today
        }
        
        return true
    }
    
    func dismissQuoteForToday() {
        $lastQuoteDismissedDate.withLock { $0 = Date() }
    }
}

extension DependencyValues {
    var motivationalQuoteService: MotivationalQuoteService {
        get { self[MotivationalQuoteServiceKey.self] }
        set { self[MotivationalQuoteServiceKey.self] = newValue }
    }
}

private enum MotivationalQuoteServiceKey: DependencyKey {
    static let liveValue = MotivationalQuoteService()
} 

