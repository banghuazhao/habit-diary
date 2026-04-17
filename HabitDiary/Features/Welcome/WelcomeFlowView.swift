//
// Created by Banghua Zhao on 31/05/2025
// Copyright Apps Bay Limited. All rights reserved.
//

import Dependencies
import SQLiteData
import SwiftUI

struct WelcomeFlowView: View {
    @State private var viewModel = WelcomeFlowViewModel()
    @Environment(\.dismiss) private var dismiss
    @Dependency(\.themeManager) private var themeManager

    private var theme: AppTheme { themeManager.current }

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.currentStep {
                case .welcome:
                    welcomeView
                case .features:
                    featuresView
                case .selectHabits:
                    selectHabitsView
                case .complete:
                    completeView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(theme.background.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }

    // MARK: - Welcome

    private var welcomeView: some View {
        VStack(spacing: AppSpacing.large) {
            Spacer(minLength: 0)

            JournalAccentPanel(theme: theme, accent: theme.primaryColor) {
                VStack(spacing: AppSpacing.medium) {
                    ZStack {
                        Circle()
                            .fill(theme.primaryColor.opacity(0.12))
                            .frame(width: 112, height: 112)
                        Text("📔")
                            .font(.system(size: 56))
                    }
                    .frame(maxWidth: .infinity)

                    JournalSectionHeader(
                        title: String(localized: "Welcome to Habit Diary"),
                        subtitle: String(localized: "Your habits, your journal"),
                        systemImage: "book.pages.fill",
                        theme: theme
                    )

                    Text(
                        String(
                            localized: "Document your daily journey, reflect on your growth, and turn your intentions into lasting habits — all in one personal diary."
                        )
                    )
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal)

            Spacer(minLength: 0)

            primaryButton(title: String(localized: "Get Started")) {
                viewModel.nextStep()
            }
        }
    }

    // MARK: - Features

    private var featuresView: some View {
        VStack(spacing: 0) {
            ScrollView {
                JournalAccentPanel(theme: theme, accent: theme.primaryColor) {
                    JournalSectionHeader(
                        title: String(localized: "Why Habit Diary?"),
                        subtitle: String(localized: "More than a tracker — a journal for every habit"),
                        systemImage: "sparkles",
                        theme: theme
                    )
                }
                .padding(.horizontal)
                .padding(.top, AppSpacing.small)

                VStack(spacing: AppSpacing.smallMedium) {
                    WelcomeFeatureCard(
                        theme: theme,
                        icon: "📊",
                        title: String(localized: "Rating system"),
                        description: String(
                            localized: "Advance through 12 levels from Beginner (F) to Legend (SSS) based on your habit consistency and achievements."
                        ),
                        accent: theme.primaryColor
                    )
                    WelcomeFeatureCard(
                        theme: theme,
                        icon: "🏆",
                        title: String(localized: "Achievements"),
                        description: String(
                            localized: "Unlock badges for streaks, consistency, and milestones. Celebrate your progress."
                        ),
                        accent: theme.warning
                    )
                    WelcomeFeatureCard(
                        theme: theme,
                        icon: "📅",
                        title: String(localized: "Flexible scheduling"),
                        description: String(
                            localized: "Choose daily, weekly, or custom frequency patterns that fit your life."
                        ),
                        accent: theme.success
                    )
                    WelcomeFeatureCard(
                        theme: theme,
                        icon: "✍️",
                        title: String(localized: "Diary notes"),
                        description: String(
                            localized: "Add reflections to each entry. Look back on how you felt and how far you’ve come."
                        ),
                        accent: theme.accent
                    )
                    WelcomeFeatureCard(
                        theme: theme,
                        icon: "🔔",
                        title: String(localized: "Smart reminders"),
                        description: String(
                            localized: "Personalized notifications to keep you on track without being overwhelming."
                        ),
                        accent: theme.primaryColor.opacity(0.85)
                    )
                }
                .padding(.horizontal)
                .padding(.vertical, AppSpacing.small)
            }

            primaryButton(title: String(localized: "Choose your habits")) {
                viewModel.nextStep()
            }
        }
    }

    // MARK: - Select habits

    private var selectHabitsView: some View {
        VStack(spacing: 0) {
            ScrollView {
                JournalAccentPanel(theme: theme, accent: theme.primaryColor) {
                    VStack(alignment: .leading, spacing: AppSpacing.smallMedium) {
                        JournalSectionHeader(
                            title: String(localized: "Choose your starting habits"),
                            subtitle: String(localized: "Pick 3–7 that resonate — you can change these anytime"),
                            systemImage: "leaf.fill",
                            theme: theme
                        )

                        if !viewModel.selectedHabits.isEmpty {
                            Text(selectedCountPhrase)
                                .font(AppFont.caption.weight(.semibold))
                                .foregroundStyle(theme.primaryColor)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(theme.primaryColor.opacity(0.12))
                                .clipShape(.capsule)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, AppSpacing.small)

                LazyVStack(spacing: AppSpacing.smallMedium) {
                    ForEach(viewModel.filteredHabits, id: \.self) { habit in
                        WelcomeHabitCard(
                            habit: habit,
                            isSelected: viewModel.isHabitSelected(habit),
                            onToggle: { viewModel.toggleHabitSelection(habit) }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }

            VStack(spacing: 0) {
                Divider()
                    .background(theme.textSecondary.opacity(0.15))
                HStack(spacing: AppSpacing.smallMedium) {
                    Button {
                        viewModel.previousStep()
                    } label: {
                        Text(String(localized: "Back"))
                            .font(AppFont.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.smallMedium)
                    }
                    .buttonStyle(.bordered)
                    .tint(theme.primaryColor)

                    Button {
                        viewModel.nextStep()
                    } label: {
                        Text(
                            viewModel.selectedHabits.isEmpty
                                ? String(localized: "Skip for now")
                                : String(localized: "Continue")
                        )
                        .font(AppFont.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.smallMedium)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(theme.primaryColor)
                }
                .padding(AppSpacing.medium)
                .background(theme.card.opacity(0.95))
            }
        }
    }

    private var selectedCountPhrase: String {
        let n = viewModel.selectedHabits.count
        if n == 1 {
            return String(localized: "1 habit selected")
        }
        return String(localized: "\(n) habits selected")
    }

    // MARK: - Complete

    private var completeView: some View {
        VStack(spacing: AppSpacing.large) {
            Spacer(minLength: 0)

            JournalAccentPanel(theme: theme, accent: theme.success) {
                VStack(spacing: AppSpacing.medium) {
                    ZStack {
                        Circle()
                            .fill(theme.success.opacity(0.15))
                            .frame(width: 112, height: 112)
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(theme.success)
                            .symbolRenderingMode(.hierarchical)
                    }

                    Text(String(localized: "You’re ready to start"))
                        .font(.system(.largeTitle, design: .serif))
                        .fontWeight(.bold)
                        .foregroundStyle(theme.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(completeMessage)
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        tipRow(emoji: "✍️", text: String(localized: "Add a diary note when you log — even a few words capture your journey."))
                        tipRow(emoji: "📖", text: String(localized: "Browse journal entries anytime to reflect on your growth."))
                        tipRow(emoji: "🏆", text: String(localized: "Earn badges and climb the rating ladder toward Legend."))
                    }
                    .padding(AppSpacing.smallMedium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(theme.surface.opacity(0.55))
                    .clipShape(.rect(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(theme.textSecondary.opacity(0.1), lineWidth: 1)
                    }
                }
            }
            .padding(.horizontal)

            Spacer(minLength: 0)

            primaryButton(title: String(localized: "Begin your journey")) {
                Task {
                    await viewModel.completeOnboarding()
                    dismiss()
                }
            }
        }
    }

    private var completeMessage: String {
        let count = viewModel.selectedHabits.count
        if count == 0 {
            return String(
                localized: "You can explore the habit gallery anytime and add habits that inspire you. Start whenever you’re ready."
            )
        }
        if count == 1 {
            return String(
                localized: "Perfect! You’ve selected 1 habit to get started. Consistency is more important than quantity — you can add more as you build momentum."
            )
        }
        return String(
            localized: "Excellent! You’ve selected \(count) habits. Focus on building these consistently, and watch your rating grow from Beginner to Legend!"
        )
    }

    private func tipRow(emoji: String, text: String) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.smallMedium) {
            Text(emoji)
                .font(.body)
            Text(text)
                .font(AppFont.caption)
                .foregroundStyle(theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Buttons

    private func primaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.smallMedium)
        }
        .buttonStyle(.borderedProminent)
        .tint(theme.primaryColor)
        .padding(.horizontal)
        .padding(.bottom, AppSpacing.medium)
    }
}

// MARK: - Feature card

struct WelcomeFeatureCard: View {
    let theme: AppTheme
    let icon: String
    let title: String
    let description: String
    let accent: Color

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.medium) {
            ZStack {
                Circle()
                    .fill(accent.opacity(0.18))
                    .frame(width: 52, height: 52)
                Text(icon)
                    .font(.title2)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(theme.textPrimary)

                Text(description)
                    .font(AppFont.subheadline)
                    .foregroundStyle(theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(AppSpacing.smallMedium)
        .background {
            if #available(iOS 26, *) {
                Color.clear
                    .glassEffect(in: .rect(cornerRadius: AppCornerRadius.info))
            } else {
                RoundedRectangle(cornerRadius: AppCornerRadius.info)
                    .fill(theme.card)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: AppCornerRadius.info)
                .strokeBorder(theme.textSecondary.opacity(0.1), lineWidth: 1)
        }
    }
}

// MARK: - Habit card

struct WelcomeHabitCard: View {
    let habit: Habit.Draft
    let isSelected: Bool
    let onToggle: () -> Void

    @Dependency(\.themeManager) private var themeManager

    private var theme: AppTheme { themeManager.current }

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: AppSpacing.smallMedium) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isSelected ? theme.primaryColor : theme.secondaryGray)

                ZStack {
                    Circle()
                        .fill(Color(hex: habit.color).opacity(0.28))
                        .frame(width: 44, height: 44)
                    Text(habit.icon)
                        .font(.title3)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.name)
                        .font(.system(.headline, design: .serif))
                        .foregroundStyle(theme.textPrimary)
                        .multilineTextAlignment(.leading)

                    if !habit.note.isEmpty {
                        Text(habit.note)
                            .font(AppFont.caption)
                            .foregroundStyle(theme.textSecondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }

                    Text(habit.toMock.frequencyDescription)
                        .font(AppFont.footnote)
                        .foregroundStyle(theme.primaryColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(theme.primaryColor.opacity(0.1))
                        .clipShape(.rect(cornerRadius: 8))
                }

                Spacer(minLength: 0)
            }
            .padding(AppSpacing.smallMedium)
            .background {
                if #available(iOS 26, *) {
                    Color.clear
                        .glassEffect(in: .rect(cornerRadius: AppCornerRadius.card))
                } else {
                    RoundedRectangle(cornerRadius: AppCornerRadius.card)
                        .fill(theme.card)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: AppCornerRadius.card)
                    .strokeBorder(
                        isSelected ? theme.primaryColor : theme.textSecondary.opacity(0.15),
                        lineWidth: isSelected ? 2 : 1
                    )
            }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    WelcomeFlowView()
}
