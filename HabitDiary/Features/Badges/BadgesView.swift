//
// Created by Banghua Zhao on 01/01/2025
// Copyright Apps Bay Limited. All rights reserved.
//

import Dependencies
import SQLiteData
import SwiftUI

struct BadgesView: View {
    @State private var viewModel = BadgesViewModel()
    @State private var selectedTab = 0
    @Dependency(\.themeManager) private var themeManager

    private var theme: AppTheme { themeManager.current }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.large) {
                progressHeaderSection
                filterPicker
                badgesList
            }
            .padding(.horizontal)
            .padding(.vertical, AppSpacing.small)
            .padding(.bottom, 24)
        }
        .background(theme.background.ignoresSafeArea())
        .navigationTitle(String(localized: "Achievements"))
        .navigationBarTitleDisplayMode(.inline)
        .tint(theme.primaryColor)
    }

    // MARK: - Progress

    private var progressHeaderSection: some View {
        JournalAccentPanel(theme: theme, accent: theme.primaryColor) {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                JournalSectionHeader(
                    title: String(localized: "Progress"),
                    subtitle: String(localized: "Unlock badges by journaling and building streaks"),
                    systemImage: "rosette",
                    theme: theme
                )

                HStack(alignment: .center, spacing: AppSpacing.medium) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(unlockedCountPhrase)
                            .font(.system(.title3, design: .serif))
                            .fontWeight(.semibold)
                            .foregroundStyle(theme.textPrimary)

                        Text(String(localized: "Keep logging entries to collect the full set."))
                            .font(AppFont.subheadline)
                            .foregroundStyle(theme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    progressRing
                }

                ProgressView(value: viewModel.progressPercentage, total: 100)
                    .progressViewStyle(.linear)
                    .tint(theme.primaryColor)
                    .frame(height: 6)
                    .clipShape(.capsule)
            }
        }
    }

    private var unlockedCountPhrase: String {
        String(
            localized: "\(viewModel.unlockedCount) of \(viewModel.totalAchievements) unlocked"
        )
    }

    private var progressRing: some View {
        ZStack {
            Circle()
                .stroke(theme.secondaryGray.opacity(0.25), lineWidth: 7)
                .frame(width: 64, height: 64)

            Circle()
                .trim(from: 0, to: viewModel.progressPercentage / 100)
                .stroke(
                    AngularGradient(
                        colors: [theme.primaryColor, theme.warning, theme.primaryColor.opacity(0.75)],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 7, lineCap: .round)
                )
                .frame(width: 64, height: 64)
                .rotationEffect(.degrees(-90))

            Text("\(Int(viewModel.progressPercentage))%")
                .font(AppFont.caption)
                .fontWeight(.bold)
                .foregroundStyle(theme.textPrimary)
                .monospacedDigit()
        }
        .accessibilityLabel(
            String(
                localized: "\(Int(viewModel.progressPercentage)) percent of badges unlocked"
            )
        )
    }

    // MARK: - Filter

    private var filterPicker: some View {
        Picker(String(localized: "Filter badges"), selection: $selectedTab) {
            Text(String(localized: "All")).tag(0)
            Text(String(localized: "Unlocked")).tag(1)
            Text(String(localized: "Locked")).tag(2)
        }
        .pickerStyle(.segmented)
    }

    // MARK: - List

    private var badgesList: some View {
        LazyVStack(spacing: AppSpacing.smallMedium) {
            ForEach(achievementsToShow) { achievement in
                BadgeRowView(
                    achievement: achievement,
                    progress: viewModel.getProgress(for: achievement),
                    shareText: viewModel.createAchievementShareText(achievement),
                    theme: theme
                )
            }
        }
    }

    private var achievementsToShow: [Badge] {
        switch selectedTab {
        case 0: return viewModel.allAchievements
        case 1: return viewModel.unlockedAchievements
        case 2: return viewModel.lockedAchievements
        default: return viewModel.allAchievements
        }
    }
}

// MARK: - Row

struct BadgeRowView: View {
    let achievement: Badge
    let progress: Double
    let shareText: String
    let theme: AppTheme

    var body: some View {
        JournalAccentPanel(theme: theme, accent: theme.primaryColor) {
            HStack(alignment: .top, spacing: AppSpacing.smallMedium) {
                badgeIcon

                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(achievement.title)
                            .font(.system(.headline, design: .serif))
                            .fontWeight(.semibold)
                            .foregroundStyle(achievement.isUnlocked ? theme.textPrimary : theme.textSecondary)
                            .lineLimit(2)

                        Spacer(minLength: 8)

                        if achievement.isUnlocked {
                            HStack(spacing: 10) {
                                ShareLink(
                                    item: shareText,
                                    subject: Text(String(localized: "Badge unlocked")),
                                    message: Text(String(localized: "From Habit Diary"))
                                ) {
                                    Image(systemName: "square.and.arrow.up.circle.fill")
                                        .symbolRenderingMode(.hierarchical)
                                        .font(.title3)
                                        .foregroundStyle(theme.primaryColor)
                                }
                                .accessibilityLabel(String(localized: "Share badge"))

                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(theme.success)
                                    .accessibilityHidden(true)
                            }
                        }
                    }

                    Text(achievement.description)
                        .font(AppFont.subheadline)
                        .foregroundStyle(theme.textSecondary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)

                    if !achievement.isUnlocked, progress > 0 {
                        ProgressView(value: progress, total: 1.0)
                            .progressViewStyle(.linear)
                            .tint(theme.primaryColor)
                            .frame(height: 5)
                            .clipShape(.capsule)
                    }

                    if achievement.isUnlocked, let unlockDate = achievement.unlockedDate {
                        Text(
                            String(
                                localized: "Unlocked \(unlockDate.formatted(date: .abbreviated, time: .omitted))"
                            )
                        )
                        .font(AppFont.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(theme.primaryColor)
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var badgeIcon: some View {
        ZStack {
            Circle()
                .fill(badgeIconFill)
                .frame(width: 52, height: 52)

            Text(achievement.icon)
                .font(.title2)
                .opacity(achievement.isUnlocked ? 1 : 0.45)
        }
        .accessibilityHidden(true)
    }

    private var badgeIconFill: LinearGradient {
        if achievement.isUnlocked {
            LinearGradient(
                colors: [theme.warning.opacity(0.45), theme.primaryColor.opacity(0.35)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            LinearGradient(
                colors: [theme.secondaryGray.opacity(0.22), theme.secondaryGray.opacity(0.38)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

}

#Preview {
    let _ = prepareDependencies {
        $0.defaultDatabase = try! appDatabase()
    }
    NavigationStack {
        BadgesView()
    }
}
