//
// Created by Banghua Zhao on 01/01/2025
// Copyright Apps Bay Limited. All rights reserved.
//

import Dependencies
import Sharing
import SQLiteData
import SwiftUI

struct RatingBreakdownView: View {
    @Environment(\.dismiss) private var dismiss
    @Dependency(\.themeManager) private var themeManager
    @State var viewModel: RatingBreakdownViewModel

    private var theme: AppTheme { themeManager.current }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.large) {
                    headerCard
                    progressSection
                    statisticsSection
                    tipsSection
                }
                .padding(.horizontal)
                .padding(.vertical, AppSpacing.small)
            }
            .appBackground()
            .navigationTitle(viewModel.category.localizedTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text(String(localized: "Done"))
                            .appRectButtonStyle()
                    }
                }
            }
            .task {
                await viewModel.loadData()
            }
        }
    }

    private var headerCard: some View {
        let c = viewModel.category.color
        return JournalAccentPanel(theme: theme, accent: c) {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                Text(String(localized: "Category detail"))
                    .font(AppFont.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(theme.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.6)

                HStack(alignment: .center, spacing: AppSpacing.smallMedium) {
                    Image(systemName: viewModel.category.icon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(c)
                        .frame(width: 48, height: 48)
                        .background(c.opacity(0.12))
                        .clipShape(.rect(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.category.localizedTitle)
                            .font(.system(.title3, design: .serif))
                            .fontWeight(.semibold)
                            .foregroundStyle(theme.textPrimary)

                        Text(
                            String(
                                localized: "Score \(viewModel.currentScore) of \(viewModel.category.maxScore)"
                            )
                        )
                        .font(AppFont.subheadline)
                        .foregroundStyle(theme.textSecondary)
                    }
                    Spacer(minLength: 0)
                }

                VStack(spacing: 8) {
                    HStack {
                        Text(String(localized: "Progress"))
                            .font(AppFont.subheadline)
                            .foregroundStyle(theme.textSecondary)
                        Spacer()
                        Text("\(Int(viewModel.percentage * 100))%")
                            .font(AppFont.subheadline.weight(.semibold))
                            .foregroundStyle(c)
                    }

                    ProgressView(value: viewModel.percentage)
                        .tint(c)
                        .scaleEffect(x: 1, y: 1.8, anchor: .center)
                }
                .padding(AppSpacing.smallMedium)
                .background(theme.surface.opacity(0.65))
                .clipShape(.rect(cornerRadius: AppCornerRadius.info))
            }
        }
    }

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.smallMedium) {
            Text(String(localized: "How it’s calculated"))
                .font(.system(.headline, design: .serif))
                .foregroundStyle(theme.textPrimary)

            Text(viewModel.category.calculationExplanation)
                .font(AppFont.body)
                .foregroundStyle(theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(AppSpacing.smallMedium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(theme.surface.opacity(0.5))
                .clipShape(.rect(cornerRadius: AppCornerRadius.info))
        }
    }

    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.smallMedium) {
            Text(String(localized: "Numbers"))
                .font(.system(.headline, design: .serif))
                .foregroundStyle(theme.textPrimary)

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                spacing: 12
            ) {
                ForEach(viewModel.statistics, id: \.title) { stat in
                    InsightStatTile(
                        title: stat.title,
                        value: stat.value,
                        subtitle: stat.subtitle,
                        accent: viewModel.category.color,
                        theme: theme
                    )
                }
            }
        }
    }

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.smallMedium) {
            Text(String(localized: "Ideas to try"))
                .font(.system(.headline, design: .serif))
                .foregroundStyle(theme.textPrimary)

            VStack(spacing: AppSpacing.small) {
                ForEach(viewModel.tips, id: \.self) { tip in
                    HStack(alignment: .top, spacing: AppSpacing.smallMedium) {
                        Image(systemName: "leaf.fill")
                            .foregroundStyle(viewModel.category.color)
                            .font(.body)

                        Text(tip)
                            .font(AppFont.body)
                            .foregroundStyle(theme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer(minLength: 0)
                    }
                    .padding(AppSpacing.smallMedium)
                    .background(theme.surface.opacity(0.45))
                    .clipShape(.rect(cornerRadius: AppCornerRadius.info))
                }
            }
        }
    }
}

/// Compact stat cell — matches Insights “shelf” tiles (replaces plain `StatCard`).
private struct InsightStatTile: View {
    let title: String
    let value: String
    let subtitle: String
    let accent: Color
    let theme: AppTheme

    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(AppFont.caption)
                .foregroundStyle(theme.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.85)

            Text(value)
                .font(.system(.title2, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(accent)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(subtitle)
                .font(AppFont.footnote)
                .foregroundStyle(theme.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(AppSpacing.smallMedium)
        .frame(maxWidth: .infinity)
        .background {
            if #available(iOS 26, *) {
                Color.clear
                    .glassEffect(in: .rect(cornerRadius: AppCornerRadius.info))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: AppCornerRadius.info)
                        .fill(theme.card)
                    RoundedRectangle(cornerRadius: AppCornerRadius.info)
                        .strokeBorder(accent.opacity(0.2), lineWidth: 1)
                }
            }
        }
    }
}

@Observable
class RatingBreakdownViewModel: HashableObject {
    @ObservationIgnored
    @Dependency(\.defaultDatabase) var database
    
    @ObservationIgnored
    @FetchAll(Habit.all, animation: .default) var allHabits
    
    @ObservationIgnored
    @FetchAll(Badge.all, animation: .default) var allAchievements
    
    @ObservationIgnored
    @FetchAll(DiaryEntry.all, animation: .default) var allCheckIns
    
    @ObservationIgnored
    @Shared(.appStorage("startWeekOnMonday")) private var startWeekOnMonday: Bool = true
    
    let category: ScoreCategory
    var currentScore: Int = 0
    var percentage: Double = 0.0
    var statistics: [Statistic] = []
    var tips: [String] = []
    
    var userCalendar: Calendar {
        var cal = Calendar.current
        cal.firstWeekday = startWeekOnMonday ? 2 : 1
        return cal
    }
    
    init(category: ScoreCategory) {
        self.category = category
    }
    
    func loadData() async {
        switch category {
        case .activeHabits:
            await loadActiveHabitsData()
        case .achievements:
            await loadAchievementsData()
        case .totalCheckIns:
            await loadCheckInsData()
        case .longestStreak:
            await loadStreakData()
        }
    }
    
    private func loadActiveHabitsData() async {
        let activeHabits = allHabits.filter { !$0.isArchived }
        currentScore = min(activeHabits.count * 10, ScoreCategory.activeHabits.maxScore)
        percentage = Double(currentScore) / Double(ScoreCategory.activeHabits.maxScore)
        
        statistics = [
            Statistic(title: String(localized: "Active Habits"), value: "\(activeHabits.count)", subtitle: String(localized: "out of 30")),
            Statistic(title: String(localized: "Archived Habits"), value: "\(allHabits.filter { $0.isArchived }.count)", subtitle: String(localized: "not counted")),
            Statistic(title: String(localized: "Favorites"), value: "\(activeHabits.filter { $0.isFavorite }.count)", subtitle: String(localized: "starred"))
        ]
        
        tips = [
            String(localized: "Create new habits to increase your score"),
            String(localized: "Archive unused habits to keep your list clean"),
            String(localized: "Try habits from different categories for variety"),
            String(localized: "Mark your most important habits as favorites")
        ]
    }
        
    private func loadAchievementsData() async {
        let unlockedAchievements = allAchievements.filter { $0.isUnlocked }
        currentScore = min(unlockedAchievements.count * 10, ScoreCategory.achievements.maxScore)
        percentage = Double(currentScore) / Double(ScoreCategory.achievements.maxScore)
        
        let recentUnlocks = unlockedAchievements.filter { 
            guard let unlockDate = $0.unlockedDate else { return false }
            return userCalendar.isDate(unlockDate, inSameDayAs: Date()) || 
                   userCalendar.isDate(unlockDate, inSameDayAs: userCalendar.date(byAdding: .day, value: -1, to: Date()) ?? Date())
        }
        
        statistics = [
            Statistic(title: String(localized: "Unlocked"), value: "\(unlockedAchievements.count)", subtitle: String(localized: "achievements")),
            Statistic(title: String(localized: "Available"), value: "\(allAchievements.count)", subtitle: String(localized: "total")),
            Statistic(title: String(localized: "Recent"), value: "\(recentUnlocks.count)", subtitle: String(localized: "last 2 days")),
            Statistic(title: String(localized: "Progress"), value: "\(Int(percentage * 100))%", subtitle: String(localized: "complete"))
        ]
        
        tips = [
            String(localized: "Complete daily habits to unlock streak achievements"),
            String(localized: "Try different habit categories for variety achievements"),
            String(localized: "Check in consistently to reach milestone achievements"),
            String(localized: "Complete habits early or late for time-based achievements")
        ]
    }
    
    private func loadCheckInsData() async {
        currentScore = min(allCheckIns.count, ScoreCategory.totalCheckIns.maxScore)
        percentage = Double(currentScore) / Double(ScoreCategory.totalCheckIns.maxScore)
        
        let today = Date()
        let startOfWeek = today.startOfWeek(for: userCalendar)
        let startOfMonth = today.startOfMonth(for: userCalendar)
        
        let checkInsThisWeek = allCheckIns.filter { $0.date >= startOfWeek }
        let checkInsThisMonth = allCheckIns.filter { $0.date >= startOfMonth }
        
        statistics = [
            Statistic(title: String(localized: "Total Check-ins"), value: "\(allCheckIns.count)", subtitle: String(localized: "all time")),
            Statistic(title: String(localized: "This Week"), value: "\(checkInsThisWeek.count)", subtitle: String(localized: "recent activity")),
            Statistic(title: String(localized: "This Month"), value: "\(checkInsThisMonth.count)", subtitle: String(localized: "monthly progress")),
            Statistic(title: String(localized: "Average/Day"), value: String(format: "%.1f", Double(allCheckIns.count) / max(1, Double(userCalendar.dateComponents([.day], from: allCheckIns.first?.date ?? today, to: today).day ?? 1))), subtitle: String(localized: "consistency"))
        ]
        
        tips = [
            String(localized: "Check in daily to build consistency"),
            String(localized: "Don't break your streak - even one check-in counts"),
            String(localized: "Use reminders to never miss a day"),
            String(localized: "Celebrate milestones to stay motivated")
        ]
    }
    
    private func loadStreakData() async {
        let longestStreak = calculateLongestStreak()
        currentScore = min(longestStreak * 5, ScoreCategory.longestStreak.maxScore)
        percentage = Double(currentScore) / Double(ScoreCategory.longestStreak.maxScore)
        
        let currentStreak = calculateCurrentStreak()
        let averageStreak = calculateAverageStreak()
        
        statistics = [
            Statistic(title: String(localized: "Longest Streak"), value: "\(longestStreak)", subtitle: String(localized: "days")),
            Statistic(title: String(localized: "Current Streak"), value: "\(currentStreak)", subtitle: String(localized: "days")),
            Statistic(title: String(localized: "Average Streak"), value: String(format: "%.1f", averageStreak), subtitle: String(localized: "days")),
            Statistic(title: String(localized: "Streak Goal"), value: "125", subtitle: String(localized: "days max"))
        ]
        
        tips = [
            String(localized: "Never miss two days in a row"),
            String(localized: "Start with small, achievable habits"),
            String(localized: "Track your progress to stay motivated"),
            String(localized: "Build momentum with consistent daily check-ins")
        ]
    }
    
    private func calculateLongestStreak() -> Int {
        guard !allCheckIns.isEmpty else { return 0 }
        
        let uniqueDates = Set(allCheckIns.map { $0.date.startOfDay(for: userCalendar) }).sorted()
        
        var longestStreak = 0
        var currentStreak = 0
        var previousDate: Date?
        
        for date in uniqueDates {
            if let previous = previousDate {
                let daysDifference = userCalendar.dateComponents([.day], from: previous, to: date).day ?? 0
                
                if daysDifference == 1 {
                    currentStreak += 1
                } else {
                    longestStreak = max(longestStreak, currentStreak)
                    currentStreak = 1
                }
            } else {
                currentStreak = 1
            }
            
            previousDate = date
        }
        
        longestStreak = max(longestStreak, currentStreak)
        return longestStreak
    }
    
    private func calculateCurrentStreak() -> Int {
        guard !allCheckIns.isEmpty else { return 0 }
        
        let mostRecentCheckIn = allCheckIns.max { $0.date < $1.date }
        guard let mostRecentDate = mostRecentCheckIn?.date else { return 0 }
        
        var currentStreak = 0
        var currentDate = mostRecentDate
        
        while true {
            let startOfDay = currentDate.startOfDay(for: userCalendar)
            let endOfDay = currentDate.endOfDay(for: userCalendar)
            
            let hasAnyCheckIn = allCheckIns.contains { checkIn in
                checkIn.date >= startOfDay && checkIn.date <= endOfDay
            }
            
            if hasAnyCheckIn {
                currentStreak += 1
                currentDate = userCalendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return currentStreak
    }
    
    private func calculateAverageStreak() -> Double {
        guard !allCheckIns.isEmpty else { return 0 }
        
        let uniqueDates = Set(allCheckIns.map { $0.date.startOfDay(for: userCalendar) }).sorted()
        
        var streaks: [Int] = []
        var currentStreak = 0
        var previousDate: Date?
        
        for date in uniqueDates {
            if let previous = previousDate {
                let daysDifference = userCalendar.dateComponents([.day], from: previous, to: date).day ?? 0
                
                if daysDifference == 1 {
                    currentStreak += 1
                } else {
                    if currentStreak > 0 {
                        streaks.append(currentStreak)
                    }
                    currentStreak = 1
                }
            } else {
                currentStreak = 1
            }
            
            previousDate = date
        }
        
        if currentStreak > 0 {
            streaks.append(currentStreak)
        }
        
        return streaks.isEmpty ? 0 : Double(streaks.reduce(0, +)) / Double(streaks.count)
    }
}

struct Statistic {
    let title: String
    let value: String
    let subtitle: String
}

#Preview {
    let _ = prepareDependencies {
        $0.defaultDatabase = try! appDatabase()
    }
    RatingBreakdownView(
        viewModel: RatingBreakdownViewModel(
            category: .activeHabits
        )
    )
}
