//
//  JournalStatsView.swift
//  Habit Diary
//
//  Created by Banghua Zhao on 2025/1/1
//  Copyright Apps Bay Limited. All rights reserved.
//

import Dependencies
import SwiftUI

struct JournalStatsView: View {
    @State private var viewModel = JournalStatsViewModel()
    @Dependency(\.themeManager) private var themeManager

    private var theme: AppTheme { themeManager.current }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.large) {
                headerSection
                habitRatingSection
                keyStatsSection
                streakSection
                habitInsightsSection
                shareSection
            }
            .padding(.horizontal)
            .padding(.vertical, AppSpacing.small)
            .padding(.bottom, 24)
        }
        .background(theme.background.ignoresSafeArea())
        .navigationTitle(String(localized: "My Stats"))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var headerSection: some View {
        JournalAccentPanel(theme: theme, accent: theme.primaryColor) {
            VStack(alignment: .leading, spacing: AppSpacing.smallMedium) {
                JournalSectionHeader(
                    title: String(localized: "Your diary"),
                    subtitle: String(localized: "Name and avatar from Settings"),
                    systemImage: "person.crop.circle.fill",
                    theme: theme
                )

                HStack(spacing: AppSpacing.medium) {
                    Text(viewModel.userAvatar)
                        .font(.system(size: 52))
                        .frame(width: 72, height: 72)
                        .background(theme.surface.opacity(0.85))
                        .clipShape(Circle())
                        .overlay {
                            Circle()
                                .strokeBorder(theme.textSecondary.opacity(0.12), lineWidth: 1)
                        }

                    Text(viewModel.userName)
                        .font(.system(.title2, design: .serif))
                        .fontWeight(.semibold)
                        .foregroundStyle(theme.textPrimary)
                        .lineLimit(3)
                }
            }
        }
    }

    // MARK: - Rating

    private var habitRatingSection: some View {
        let rating = viewModel.habitRating
        return JournalAccentPanel(theme: theme, accent: rating.color) {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                JournalSectionHeader(
                    title: String(localized: "Habit rating"),
                    subtitle: String(localized: "Based on your journal activity"),
                    systemImage: "gauge.with.dots.needle.67percent",
                    theme: theme
                )

                HStack(alignment: .center, spacing: AppSpacing.medium) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(rating.displayName)
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(rating.color)
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)

                        Text(rating.description)
                            .font(.system(.subheadline, design: .serif))
                            .foregroundStyle(theme.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(viewModel.totalScore)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(theme.primaryColor)
                        Text(String(localized: "points"))
                            .font(AppFont.caption)
                            .foregroundStyle(theme.textSecondary)
                    }
                }

                if let next = viewModel.nextRating, viewModel.scoreToNextRating > 0 {
                    Label {
                        Text(
                            String(
                                localized: "\(viewModel.scoreToNextRating) points to \(next.displayName) (\(next.description))"
                            )
                        )
                        .font(AppFont.caption)
                        .foregroundStyle(theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    } icon: {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundStyle(theme.primaryColor.opacity(0.9))
                    }
                    .padding(AppSpacing.smallMedium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(theme.surface.opacity(0.55))
                    .clipShape(.rect(cornerRadius: 10))
                }
            }
        }
    }

    // MARK: - Key stats

    private var keyStatsSection: some View {
        JournalAccentPanel(theme: theme, accent: theme.primaryColor) {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                JournalSectionHeader(
                    title: String(localized: "Key statistics"),
                    subtitle: String(localized: "Totals across your journal"),
                    systemImage: "chart.bar.fill",
                    theme: theme
                )

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: AppSpacing.small), count: 2), spacing: AppSpacing.small) {
                    statTile(
                        icon: "list.bullet",
                        title: String(localized: "Total habits"),
                        value: "\(viewModel.totalHabits)",
                        iconTint: theme.primaryColor
                    )
                    statTile(
                        icon: "checkmark.circle.fill",
                        title: String(localized: "Total entries"),
                        value: "\(viewModel.totalCheckIns)",
                        iconTint: theme.success
                    )
                    statTile(
                        icon: "trophy.fill",
                        title: String(localized: "Achievements"),
                        value: "\(viewModel.totalAchievements)",
                        iconTint: theme.warning
                    )
                    statTile(
                        icon: "calendar",
                        title: String(localized: "Days active"),
                        value: "\(viewModel.totalDaysActive)",
                        iconTint: theme.primaryColor.opacity(0.75)
                    )
                }
            }
        }
    }

    // MARK: - Streaks

    private var streakSection: some View {
        JournalAccentPanel(theme: theme, accent: theme.primaryColor) {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                JournalSectionHeader(
                    title: String(localized: "Streaks"),
                    subtitle: String(localized: "Consecutive days with at least one entry"),
                    systemImage: "flame.fill",
                    theme: theme
                )

                HStack(spacing: AppSpacing.medium) {
                    streakMiniCard(
                        symbol: "🔥",
                        value: viewModel.longestStreak,
                        label: String(localized: "Longest streak")
                    )
                    streakMiniCard(
                        symbol: "⚡",
                        value: viewModel.currentStreak,
                        label: String(localized: "Current streak")
                    )
                }
            }
        }
    }

    private func streakMiniCard(symbol: String, value: Int, label: String) -> some View {
        VStack(spacing: AppSpacing.small) {
            Text(symbol)
                .font(.system(size: 36))
            Text("\(value)")
                .font(.system(.title, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(theme.primaryColor)
            Text(label)
                .font(AppFont.caption)
                .foregroundStyle(theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.smallMedium)
        .background(theme.surface.opacity(0.55))
        .clipShape(.rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(theme.textSecondary.opacity(0.1), lineWidth: 1)
        }
    }

    // MARK: - Insights

    @ViewBuilder
    private var habitInsightsSection: some View {
        JournalAccentPanel(theme: theme, accent: theme.primaryColor) {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                JournalSectionHeader(
                    title: String(localized: "Habit insights"),
                    subtitle: String(localized: "Highlights from your data"),
                    systemImage: "sparkles",
                    theme: theme
                )

                VStack(spacing: AppSpacing.smallMedium) {
                    if let bestHabit = viewModel.bestHabit {
                        insightRow(
                            systemImage: "star.fill",
                            title: String(localized: "Top habit"),
                            subtitle: bestHabit.name,
                            detail: entryCountPhrase(allCheckInsForHabit(bestHabit.id).count)
                        )
                    }

                    if let earliestCheckInString = viewModel.earliestCheckInString {
                        insightRow(
                            systemImage: "clock.fill",
                            title: String(localized: "Journey began"),
                            subtitle: earliestCheckInString,
                            detail: String(localized: "First journal entry")
                        )
                    }

                    if let mostFrequent = viewModel.mostFrequentHabit {
                        insightRow(
                            systemImage: "chart.line.uptrend.xyaxis",
                            title: String(localized: "Most logged"),
                            subtitle: mostFrequent.name,
                            detail: entryCountPhrase(allCheckInsForHabit(mostFrequent.id).count)
                        )
                    }
                }
            }
        }
    }

    private func entryCountPhrase(_ count: Int) -> String {
        String(localized: "\(count) entries")
    }

    // MARK: - Share

    private var shareSection: some View {
        JournalAccentPanel(theme: theme, accent: theme.primaryColor) {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                JournalSectionHeader(
                    title: String(localized: "Share"),
                    subtitle: String(localized: "Send a text summary of your stats"),
                    systemImage: "square.and.arrow.up",
                    theme: theme
                )

                ShareLink(
                    item: viewModel.generateShareText(),
                    subject: Text(String(localized: "My habit stats")),
                    message: Text(String(localized: "From Habit Diary"))
                ) {
                    Label(String(localized: "Share my stats"), systemImage: "square.and.arrow.up")
                        .font(AppFont.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.small)
                }
                .buttonStyle(.borderedProminent)
                .tint(theme.primaryColor)
            }
        }
    }

    // MARK: - Tiles & rows

    private func statTile(icon: String, title: String, value: String, iconTint: Color) -> some View {
        VStack(spacing: AppSpacing.small) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(iconTint)

            Text(value)
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(theme.textPrimary)

            Text(title)
                .font(AppFont.caption)
                .foregroundStyle(theme.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.smallMedium)
        .background(theme.surface.opacity(0.55))
        .clipShape(.rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(theme.textSecondary.opacity(0.1), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(value)")
    }

    private func insightRow(systemImage: String, title: String, subtitle: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.smallMedium) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(theme.primaryColor)
                .frame(width: 36, height: 36)
                .background(theme.primaryColor.opacity(0.12))
                .clipShape(.rect(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppFont.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(theme.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.4)

                Text(subtitle)
                    .font(.system(.body, design: .serif))
                    .fontWeight(.semibold)
                    .foregroundStyle(theme.textPrimary)

                Text(detail)
                    .font(AppFont.caption)
                    .foregroundStyle(theme.textSecondary)
            }

            Spacer(minLength: 0)
        }
        .padding(AppSpacing.smallMedium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.surface.opacity(0.45))
        .clipShape(.rect(cornerRadius: AppCornerRadius.info))
        .overlay {
            RoundedRectangle(cornerRadius: AppCornerRadius.info)
                .strokeBorder(theme.textSecondary.opacity(0.08), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }

    private func allCheckInsForHabit(_ habitId: Int) -> [DiaryEntry] {
        viewModel.allCheckIns.filter { $0.habitID == habitId }
    }
}

#Preview {
    NavigationStack {
        JournalStatsView()
    }
}
