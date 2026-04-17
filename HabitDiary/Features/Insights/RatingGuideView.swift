//
// Created by Banghua Zhao on 01/01/2025
// Copyright Apps Bay Limited. All rights reserved.
//

import Dependencies
import SwiftUI

struct RatingGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @Dependency(\.themeManager) private var themeManager

    private var theme: AppTheme { themeManager.current }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.large) {
                    headerSection
                    ratingLevelsSection
                    scoreCategoriesSection
                    tipsSection
                }
                .padding(.horizontal)
                .padding(.vertical, AppSpacing.small)
            }
            .appBackground()
            .navigationTitle(String(localized: "How scoring works"))
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
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            HStack(spacing: AppSpacing.smallMedium) {
                Image(systemName: "chart.line.text.clipboard.fill")
                    .font(.largeTitle)
                    .foregroundStyle(theme.primaryColor)
                    .frame(width: 52, height: 52)
                    .background(theme.primaryColor.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: "Insight score"))
                        .font(AppFont.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(theme.textSecondary)
                        .textCase(.uppercase)
                        .tracking(0.6)
                    Text(String(localized: "A single number from your habits"))
                        .font(.system(.title3, design: .serif))
                        .fontWeight(.semibold)
                        .foregroundStyle(theme.textPrimary)
                }
                Spacer(minLength: 0)
            }

            Text(
                String(
                    localized: "We combine habits, journal entries, streaks, and badges into one score — so you can see momentum at a glance."
                )
            )
            .font(AppFont.body)
            .foregroundStyle(theme.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppSpacing.medium)
        .background {
            if #available(iOS 26, *) {
                Color.clear
                    .glassEffect(in: .rect(cornerRadius: AppCornerRadius.card))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: AppCornerRadius.card)
                        .fill(theme.card)
                    RoundedRectangle(cornerRadius: AppCornerRadius.card)
                        .strokeBorder(theme.textSecondary.opacity(0.12), lineWidth: 1)
                }
            }
        }
    }

    private var ratingLevelsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.smallMedium) {
            Text(String(localized: "Tiers"))
                .font(.system(.headline, design: .serif))
                .foregroundStyle(theme.textPrimary)

            LazyVStack(spacing: AppSpacing.small) {
                ForEach(HabitRating.allCases, id: \.self) { rating in
                    RatingLevelRow(rating: rating, theme: theme)
                }
            }
        }
    }

    private var scoreCategoriesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.smallMedium) {
            Text(String(localized: "What goes in"))
                .font(.system(.headline, design: .serif))
                .foregroundStyle(theme.textPrimary)

            LazyVStack(spacing: AppSpacing.small) {
                ForEach(ScoreCategory.allCases, id: \.self) { category in
                    ScoreCategoryRow(category: category, theme: theme)
                }
            }
        }
    }

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.smallMedium) {
            Text(String(localized: "Ways to move the needle"))
                .font(.system(.headline, design: .serif))
                .foregroundStyle(theme.textPrimary)

            VStack(spacing: AppSpacing.small) {
                GuideTipRow(
                    icon: "pencil.and.list.clipboard",
                    title: String(localized: "Write small, often"),
                    description: String(localized: "Short journal entries still lift your consistency score."),
                    theme: theme
                )
                GuideTipRow(
                    icon: "calendar.badge.clock",
                    title: String(localized: "Protect the streak"),
                    description: String(localized: "One check-in on a busy day keeps momentum."),
                    theme: theme
                )
                GuideTipRow(
                    icon: "books.vertical.fill",
                    title: String(localized: "Keep habits active"),
                    description: String(localized: "Archive what you don’t use so your library matches real life."),
                    theme: theme
                )
                GuideTipRow(
                    icon: "rosette",
                    title: String(localized: "Collect badges"),
                    description: String(localized: "Badges reward patterns — explore them in the Badges tab."),
                    theme: theme
                )
            }
        }
    }
}

// MARK: - Rows

struct RatingLevelRow: View {
    let rating: HabitRating
    let theme: AppTheme

    var body: some View {
        HStack(spacing: AppSpacing.medium) {
            Text(rating.displayName)
                .font(.system(.title2, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(rating.color)
                .frame(minWidth: 44, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                Text(rating.description)
                    .font(AppFont.subheadline)
                    .foregroundStyle(theme.textPrimary)
                Text(scoreRangeText)
                    .font(AppFont.caption)
                    .foregroundStyle(theme.textSecondary)
            }

            Spacer(minLength: 0)

            Circle()
                .fill(rating.color)
                .frame(width: 10, height: 10)
        }
        .padding(AppSpacing.smallMedium)
        .background {
            if #available(iOS 26, *) {
                Color.clear
                    .glassEffect(in: .rect(cornerRadius: AppCornerRadius.info))
            } else {
                theme.surface.opacity(0.55)
            }
        }
        .clipShape(.rect(cornerRadius: AppCornerRadius.info))
    }

    private var scoreRangeText: String {
        let range = rating.scoreRange
        if range.upperBound == Int.max {
            return String(localized: "\(range.lowerBound)+ points")
        } else {
            return String(localized: "\(range.lowerBound)–\(range.upperBound) points")
        }
    }
}

struct ScoreCategoryRow: View {
    let category: ScoreCategory
    let theme: AppTheme

    var body: some View {
        HStack(alignment: .center, spacing: AppSpacing.smallMedium) {
            Image(systemName: category.icon)
                .font(.title3.weight(.semibold))
                .foregroundStyle(category.color)
                .frame(width: 40, height: 40)
                .background(category.color.opacity(0.12))
                .clipShape(.rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(category.localizedTitle)
                    .font(AppFont.subheadline.weight(.semibold))
                    .foregroundStyle(theme.textPrimary)
                Text(category.calculationExplanation)
                    .font(AppFont.caption)
                    .foregroundStyle(theme.textSecondary)
                    .lineLimit(3)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 2) {
                Text(String(localized: "Max"))
                    .font(AppFont.caption)
                    .foregroundStyle(theme.textSecondary)
                Text("\(category.maxScore)")
                    .font(AppFont.subheadline.weight(.bold))
                    .foregroundStyle(category.color)
            }
        }
        .padding(AppSpacing.smallMedium)
        .background {
            if #available(iOS 26, *) {
                Color.clear
                    .glassEffect(in: .rect(cornerRadius: AppCornerRadius.card))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: AppCornerRadius.card)
                        .fill(theme.card)
                    RoundedRectangle(cornerRadius: AppCornerRadius.card)
                        .strokeBorder(theme.textSecondary.opacity(0.1), lineWidth: 1)
                }
            }
        }
    }
}

private struct GuideTipRow: View {
    let icon: String
    let title: String
    let description: String
    let theme: AppTheme

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.smallMedium) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(theme.primaryColor)
                .frame(width: 36, height: 36)
                .background(theme.primaryColor.opacity(0.1))
                .clipShape(.rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppFont.subheadline.weight(.semibold))
                    .foregroundStyle(theme.textPrimary)
                Text(description)
                    .font(AppFont.caption)
                    .foregroundStyle(theme.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(AppSpacing.smallMedium)
        .background(theme.surface.opacity(0.45))
        .clipShape(.rect(cornerRadius: AppCornerRadius.info))
    }
}

#Preview {
    RatingGuideView()
}
