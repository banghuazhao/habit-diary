//
// Created by Banghua Zhao on 01/01/2025
// Copyright Apps Bay Limited. All rights reserved.
//

import Dependencies
import SQLiteData
import SwiftUI

struct InsightsView: View {
    @Dependency(\.themeManager) private var themeManager
    @State private var viewModel = InsightsViewModel()

    private var theme: AppTheme { themeManager.current }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.large) {
                    insightRatingCard

                    if let breakdown = viewModel.scoreBreakdown {
                        motivationalCard(rating: breakdown.rating)
                    }

                    scoreBreakdownSection
                }
                .padding(.horizontal)
                .padding(.vertical, AppSpacing.small)
            }
            .appBackground()
            .navigationTitle(String(localized: "Insights"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(
                        item: viewModel.createShareText(),
                        subject: Text(String(localized: "My habit insights")),
                        message: Text(String(localized: "Here’s my habit insight summary from Habit Diary."))
                    ) {
                        Image(systemName: "square.and.arrow.up")
                            .appCircularButtonStyle()
                    }
                }
            }
            .refreshable {
                await viewModel.loadRatingData()
            }
            .task {
                await viewModel.loadRatingData()
            }
            .sheet(item: $viewModel.route.scoreBreakdownDetail, id: \.self) { scoreDetailViewModel in
                RatingBreakdownView(viewModel: scoreDetailViewModel)
            }
            .sheet(
                isPresented: Binding($viewModel.route.ratingSystemExplanation)
            ) {
                RatingGuideView()
            }
        }
    }

    // MARK: - Main rating card (journal “snapshot” layout)

    private var insightRatingCard: some View {
        Group {
            if let breakdown = viewModel.scoreBreakdown {
                let rating = breakdown.rating
                JournalAccentPanel(theme: theme, accent: theme.primaryColor) {
                    VStack(alignment: .leading, spacing: AppSpacing.medium) {
                        Text(String(localized: "Insight snapshot"))
                            .font(AppFont.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(theme.textSecondary)
                            .textCase(.uppercase)
                            .tracking(0.75)
                        
                        HStack(alignment: .center, spacing: AppSpacing.medium) {
                            Text(rating.displayName)
                                .font(.system(size: 52, weight: .bold, design: .rounded))
                                .foregroundStyle(rating.color)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                            
                            Spacer(minLength: 0)
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(String(localized: "Total"))
                                    .font(AppFont.caption)
                                    .foregroundStyle(theme.textSecondary)
                                Text("\(breakdown.totalScore)")
                                    .font(.system(.title2, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundStyle(theme.textPrimary)
                                Text(String(localized: "of \(breakdown.maxPossibleScore)"))
                                    .font(AppFont.caption)
                                    .foregroundStyle(theme.textSecondary)
                            }
                        }
                        
                        Text(rating.description)
                            .font(.system(.title3, design: .serif))
                            .foregroundStyle(theme.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        VStack(spacing: 10) {
                            HStack {
                                Text(String(localized: "Overall progress"))
                                    .font(AppFont.subheadline)
                                    .foregroundStyle(theme.textSecondary)
                                Spacer()
                                Text("\(breakdown.totalScore)/\(breakdown.maxPossibleScore)")
                                    .font(AppFont.subheadline.weight(.semibold))
                                    .foregroundStyle(theme.textPrimary)
                            }
                            
                            ProgressView(value: breakdown.overallProgress)
                                .tint(rating.color)
                                .scaleEffect(x: 1, y: 1.8, anchor: .center)
                            
                            HStack {
                                Text(
                                    String(
                                        localized: "Within \(rating.description)"
                                    )
                                )
                                .font(AppFont.caption)
                                .foregroundStyle(theme.textSecondary)
                                Spacer()
                                Text(String(format: "%.0f%%", breakdown.progressInCurrentRating * 100))
                                    .font(AppFont.caption.weight(.semibold))
                                    .foregroundStyle(rating.color)
                            }
                            
                            ProgressView(value: breakdown.progressInCurrentRating)
                                .tint(rating.color.opacity(0.85))
                                .scaleEffect(x: 1, y: 1.4, anchor: .center)
                        }
                        .padding(AppSpacing.smallMedium)
                        .background(theme.surface.opacity(0.65))
                        .clipShape(.rect(cornerRadius: AppCornerRadius.info))
                        
                        if let nextRating = viewModel.scoreBreakdown?.nextRating {
                            progressToNextBlock(nextRating: nextRating)
                        }
                        
                        HStack(spacing: 6) {
                            Image(systemName: "hand.tap.fill")
                                .font(.caption2)
                            Text(String(localized: "Tap for category breakdown"))
                                .font(AppFont.caption)
                        }
                        .foregroundStyle(theme.textSecondary.opacity(0.9))
                    }
                }
                .onTapGesture {
                    viewModel.onTapRatingCard()
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(
                    String(
                        localized: "Insight rating \(rating.displayName), \(breakdown.totalScore) points"
                    )
                )
                .accessibilityHint(String(localized: "Opens score breakdown"))
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            }
        }
    }

    @ViewBuilder
    private var insightCardBackground: some View {
        if #available(iOS 26, *) {
            Color.clear
                .glassEffect(in: .rect(cornerRadius: AppCornerRadius.card))
        } else {
            theme.card
        }
    }

    private func motivationalCard(rating: HabitRating) -> some View {
        JournalAccentPanel(theme: theme, accent: theme.primaryColor) {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                Label {
                    Text(String(localized: "Reflection"))
                        .font(AppFont.headline)
                        .foregroundStyle(theme.textPrimary)
                } icon: {
                    Image(systemName: "text.quote")
                        .foregroundStyle(rating.color)
                }

                Text(rating.motivationalMessage)
                    .font(.system(.body, design: .serif))
                    .italic()
                    .foregroundStyle(theme.textSecondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppSpacing.medium)
        }
        .background {
            if #available(iOS 26, *) {
                Color.clear
                    .glassEffect(in: .rect(cornerRadius: AppCornerRadius.card))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: AppCornerRadius.card)
                        .fill(rating.color.opacity(0.06))
                    RoundedRectangle(cornerRadius: AppCornerRadius.card)
                        .strokeBorder(rating.color.opacity(0.22), lineWidth: 1)
                }
            }
        }
    }

    private func progressToNextBlock(nextRating: HabitRating) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Label {
                Text(String(localized: "Next tier"))
                    .font(AppFont.subheadline.weight(.semibold))
                    .foregroundStyle(theme.textPrimary)
            } icon: {
                Image(systemName: "arrow.up.forward.circle.fill")
                    .foregroundStyle(nextRating.color)
            }

            if let breakdown = viewModel.scoreBreakdown {
                HStack {
                    Text(
                        String(
                            localized: "\(breakdown.scoreToNextRating) pts to \(nextRating.displayName)"
                        )
                    )
                    .font(AppFont.caption)
                    .foregroundStyle(theme.textSecondary)
                    Spacer()
                    Text(nextRating.description)
                        .font(AppFont.caption.weight(.medium))
                        .foregroundStyle(nextRating.color)
                }

                Text(rangeLine(for: nextRating))
                    .font(AppFont.footnote)
                    .foregroundStyle(theme.textSecondary)
            }
        }
        .padding(AppSpacing.smallMedium)
        .background(nextRating.color.opacity(0.08))
        .clipShape(.rect(cornerRadius: AppCornerRadius.info))
    }

    private func rangeLine(for nextRating: HabitRating) -> String {
        let range = nextRating.scoreRange
        if range.upperBound == Int.max {
            return String(localized: "Range: \(range.lowerBound)+ points")
        }
        return String(localized: "Range: \(range.lowerBound)–\(range.upperBound) points")
    }

    // MARK: - Score breakdown list

    private var scoreBreakdownSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.smallMedium) {
            VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "Where your score comes from"))
                    .font(.system(.title3, design: .serif))
                    .fontWeight(.semibold)
                    .foregroundStyle(theme.textPrimary)
                Text(String(localized: "Tap a row for details."))
                    .font(AppFont.caption)
                    .foregroundStyle(theme.textSecondary)
            }

            if let breakdownItems = viewModel.scoreBreakdownItems {
                LazyVStack(spacing: AppSpacing.small) {
                    ForEach(Array(breakdownItems.enumerated()), id: \.offset) { _, item in
                        InsightsScoreBreakdownRow(item: item, theme: theme)
                            .onTapGesture {
                                viewModel.onTapScoreBreakdownItem(item)
                            }
                    }
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
            }
        }
    }
}

// MARK: - Breakdown row (separate type for clarity)

private struct InsightsScoreBreakdownRow: View {
    let item: ScoreBreakdownItem
    let theme: AppTheme

    @State private var isInfoPresented = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            HStack(alignment: .center, spacing: AppSpacing.smallMedium) {
                Image(systemName: item.icon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(item.color)
                    .frame(width: 40, height: 40)
                    .background(item.color.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(AppFont.subheadline.weight(.semibold))
                        .foregroundStyle(theme.textPrimary)
                    Text(item.performanceLevel.description)
                        .font(AppFont.caption)
                        .foregroundStyle(item.performanceLevel.color)
                }

                Spacer(minLength: 8)

                Button {
                    isInfoPresented.toggle()
                } label: {
                    Image(systemName: "info.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .font(.title3)
                        .foregroundStyle(theme.textSecondary)
                }
                .buttonStyle(.plain)
                .popover(isPresented: $isInfoPresented) {
                    breakdownInfoPopover
                }

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(item.score)/\(item.maxScore)")
                        .font(AppFont.subheadline.weight(.semibold))
                        .foregroundStyle(theme.textPrimary)
                    Text(String(format: "%.0f%%", item.percentage * 100))
                        .font(AppFont.caption)
                        .foregroundStyle(theme.textSecondary)
                }
            }

            ProgressView(value: item.percentage)
                .tint(item.performanceLevel.color)
                .scaleEffect(x: 1, y: 1.4, anchor: .center)

            HStack {
                Spacer()
                HStack(spacing: 4) {
                    Circle()
                        .fill(item.performanceLevel.color)
                        .frame(width: 6, height: 6)
                    Text(item.performanceLevel.description)
                        .font(AppFont.footnote)
                        .foregroundStyle(item.performanceLevel.color)
                }
            }
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
                        .strokeBorder(item.performanceLevel.color.opacity(0.18), lineWidth: 1)
                }
            }
        }
    }

    @ViewBuilder
    private var breakdownInfoPopover: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                Text(String(localized: "How \(item.title) is calculated"))
                    .font(AppFont.headline)
                    .frame(maxWidth: .infinity, alignment: .center)

                Text(item.explanation)
                    .font(AppFont.body)
                    .foregroundStyle(theme.textPrimary)
                    .multilineTextAlignment(.leading)

                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    HStack {
                        Text(String(localized: "Performance"))
                            .font(AppFont.subheadline.weight(.semibold))
                        Text(item.performanceLevel.description)
                            .font(AppFont.subheadline)
                            .foregroundStyle(item.performanceLevel.color)
                    }
                    Text(String(format: String(localized: "%.1f%% of maximum"), item.percentage * 100))
                        .font(AppFont.caption)
                        .foregroundStyle(theme.textSecondary)
                }
                .padding(.top, AppSpacing.small)
            }
            .frame(minHeight: 200)
        }
        .padding()
        .presentationCompactAdaptation(.popover)
    }
}
