//
//  JournalStatsView.swift
//  Habit Diary
//
//  Created by Banghua Zhao on 2025/1/1
//  Copyright Apps Bay Limited. All rights reserved.
//

import SwiftUI
import Dependencies
import Sharing

struct JournalStatsView: View {
    @State private var viewModel = JournalStatsViewModel()
    @Environment(\.openURL) private var openURL
    @State private var showShareSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.large) {
                // Header Section
                headerSection
                
                // Habit Rating Section
                habitRatingSection
                
                // Key Stats Section
                keyStatsSection
                
                // Streak Section
                streakSection
                
                // Habit Insights Section
                habitInsightsSection
                                
                // Share Section
                shareSection
            }
            .padding(.horizontal)
        }
        .background(viewModel.themeManager.current.background)
        .navigationTitle("My Stats")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [viewModel.generateShareText()])
        }
    }
    
    private var headerSection: some View {
        HStack(spacing: AppSpacing.medium) {
            Text(viewModel.userAvatar)
                .font(.system(size: 60))
                .frame(width: 80, height: 80)
                .background(viewModel.themeManager.current.card)
                .clipShape(Circle())
                .shadow(color: AppShadow.card.color, radius: 8, x: 0, y: 4)
            
            Text(viewModel.userName)
                .font(AppFont.title)
                .fontWeight(.bold)
                .foregroundStyle(viewModel.themeManager.current.textPrimary)
        }
        .appCardStyle()
    }
    
    private var habitRatingSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Text(String(localized: "Habit Rating"))
                .appSectionHeader(theme: viewModel.themeManager.current)
            
            VStack(spacing: AppSpacing.medium) {
                // Rating Display
                HStack(spacing: AppSpacing.large) {
                    VStack(spacing: AppSpacing.small) {
                        Text(viewModel.habitRating.displayName)
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(viewModel.habitRating.color)
                        
                        Text(viewModel.habitRating.description)
                            .font(AppFont.subheadline)
                            .foregroundStyle(viewModel.themeManager.current.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(spacing: AppSpacing.small) {
                        Text("\(viewModel.totalScore)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(viewModel.themeManager.current.primaryColor)
                        
                        Text(String(localized: "points"))
                            .font(AppFont.caption)
                            .foregroundStyle(viewModel.themeManager.current.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .appCardStyle()
    }
    
    private var keyStatsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Text(String(localized: "Key Statistics"))
                .appSectionHeader(theme: viewModel.themeManager.current)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: AppSpacing.medium) {
                statCard(
                    icon: "list.bullet",
                    title: String(localized: "Total Habits"),
                    value: "\(viewModel.totalHabits)",
                    color: .blue
                )
                
                statCard(
                    icon: "checkmark.circle.fill",
                    title: String(localized: "Total Check-ins"),
                    value: "\(viewModel.totalCheckIns)",
                    color: .green
                )
                
                statCard(
                    icon: "trophy.fill",
                    title: String(localized: "Achievements"),
                    value: "\(viewModel.totalAchievements)",
                    color: .orange
                )
                
                statCard(
                    icon: "calendar",
                    title: String(localized: "Days Active"),
                    value: "\(viewModel.totalDaysActive)",
                    color: .purple
                )
            }
        }
        .appCardStyle()
    }
    
    private var streakSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Text(String(localized: "Streak Information"))
                .appSectionHeader(theme: viewModel.themeManager.current)
            
            HStack(spacing: AppSpacing.large) {
                VStack(spacing: AppSpacing.small) {
                    Text("🔥")
                        .font(.system(size: 40))
                    Text("\(viewModel.longestStreak)")
                        .font(AppFont.title)
                        .fontWeight(.bold)
                        .foregroundStyle(viewModel.themeManager.current.primaryColor)
                    Text(String(localized: "Longest Streak"))
                        .font(AppFont.caption)
                        .foregroundStyle(viewModel.themeManager.current.textSecondary)
                }
                .frame(maxWidth: .infinity)
                
                VStack(spacing: AppSpacing.small) {
                    Text("⚡")
                        .font(.system(size: 40))
                    Text("\(viewModel.currentStreak)")
                        .font(AppFont.title)
                        .fontWeight(.bold)
                        .foregroundStyle(viewModel.themeManager.current.primaryColor)
                    Text(String(localized: "Current Streak"))
                        .font(AppFont.caption)
                        .foregroundStyle(viewModel.themeManager.current.textSecondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .appCardStyle()
    }
    
    @ViewBuilder
    private var habitInsightsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Text(String(localized: "Habit Insights"))
                .appSectionHeader(theme: viewModel.themeManager.current)
            
            VStack(spacing: AppSpacing.medium) {
                if let bestHabit = viewModel.bestHabit {
                    insightRow(
                        icon: "🌟",
                        title: String(localized: "Best Habit"),
                        subtitle: bestHabit.name,
                        detail: "\(allCheckInsForHabit(bestHabit.id).count) check-ins"
                    )
                }
                
                if let earliestCheckInString = viewModel.earliestCheckInString {
                    insightRow(
                        icon: "🕐",
                        title: String(localized: "Started Journey"),
                        subtitle: earliestCheckInString,
                        detail: "First check-in"
                    )
                }
                
                if let mostFrequent = viewModel.mostFrequentHabit {
                    insightRow(
                        icon: "📈",
                        title: String(localized: "Most Consistent"),
                        subtitle: mostFrequent.name,
                        detail: "\(allCheckInsForHabit(mostFrequent.id).count) times"
                    )
                }
            }
        }
        .appCardStyle()
    }
        
    private var shareSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Text(String(localized: "Share Your Progress"))
                .appSectionHeader(theme: viewModel.themeManager.current)
            
            Button(action: {
                showShareSheet = true
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title2)
                    Text(String(localized: "Share My Stats"))
                        .font(AppFont.body)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .foregroundStyle(.white)
                .padding()
                .background(viewModel.themeManager.current.primaryColor)
                .clipShape(.rect(cornerRadius: AppCornerRadius.button))
            }
        }
        .appCardStyle()
    }
    
    private func statCard(icon: String, title: String, value: String, color: Color) -> some View {
        VStack(spacing: AppSpacing.small) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(AppFont.headline)
                .fontWeight(.bold)
                .foregroundStyle(viewModel.themeManager.current.textPrimary)
            
            Text(title)
                .font(AppFont.caption)
                .foregroundStyle(viewModel.themeManager.current.textSecondary)
                .multilineTextAlignment(.center)
        }
        .appCardStyle()
    }
    
    private func insightRow(icon: String, title: String, subtitle: String, detail: String) -> some View {
        HStack(spacing: AppSpacing.medium) {
            Text(icon)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppFont.caption)
                    .foregroundStyle(viewModel.themeManager.current.textSecondary)
                
                Text(subtitle)
                    .font(AppFont.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(viewModel.themeManager.current.textPrimary)
                
                Text(detail)
                    .font(AppFont.caption)
                    .foregroundStyle(viewModel.themeManager.current.textSecondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private func allCheckInsForHabit(_ habitId: Int) -> [DiaryEntry] {
        return viewModel.allCheckIns.filter { $0.habitID == habitId }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        JournalStatsView()
    }
} 
