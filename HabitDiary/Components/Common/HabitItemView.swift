//
// Created by Banghua Zhao on 03/06/2025
// Copyright Apps Bay Limited. All rights reserved.
//

import SQLiteData
import SwiftUI

struct HabitItemView: View {
    let todayHabit: TodayHabit
    let onTap: () -> Void

    @Dependency(\.themeManager) var themeManager

    var body: some View {
        Button(action: {
            Haptics.shared.vibrateIfEnabled()
            onTap()
        }) {
            VStack(spacing: 6) {
                // ── Habit icon circle ──────────────────────────
                ZStack(alignment: .topTrailing) {
                    // Background circle
                    Circle()
                        .fill(
                            todayHabit.isCompleted
                                ? Color(hex: todayHabit.habit.color).opacity(0.85)
                                : themeManager.current.card
                        )
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    todayHabit.isCompleted
                                        ? todayHabit.habit.borderColor
                                        : themeManager.current.secondaryGray.opacity(0.35),
                                    style: StrokeStyle(
                                        lineWidth: todayHabit.isCompleted ? 1.5 : 1,
                                        dash: todayHabit.isCompleted ? [] : [4, 4]
                                    )
                                )
                        )
                        .frame(width: 54, height: 54)
                        .shadow(
                            color: todayHabit.isCompleted
                                ? Color(hex: todayHabit.habit.color).opacity(0.25)
                                : .clear,
                            radius: 4, x: 0, y: 2
                        )

                    // Emoji
                    Text(todayHabit.habit.icon)
                        .font(.system(size: 28))
                        .frame(width: 54, height: 54)

                    // ✓ ink-badge — only when written/done
                    if todayHabit.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white, todayHabit.habit.borderColor)
                            .background(
                                Circle()
                                    .fill(themeManager.current.card)
                                    .frame(width: 14, height: 14)
                            )
                            .offset(x: 4, y: -4)
                    }
                }

                // ── Label area ──────────────────────────────────
                VStack(alignment: .leading, spacing: 2) {
                    Text(todayHabit.habit.name + (todayHabit.habit.isFavorite ? " ❤️" : ""))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(
                            todayHabit.isCompleted
                                ? themeManager.current.textPrimary
                                : themeManager.current.textSecondary
                        )
                        .minimumScaleFactor(0.6)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)

                    if let streak = todayHabit.streakDescription {
                        Text(streak)
                            .font(.system(size: 10))
                            .foregroundStyle(themeManager.current.primaryColor)
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                    }

                    if let freq = todayHabit.frequencyDescription {
                        Text(freq)
                            .font(.system(size: 10))
                            .foregroundStyle(themeManager.current.textSecondary)
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxHeight: 160)
            .opacity(todayHabit.isCompleted ? 1.0 : 0.72)
            .animation(.easeInOut(duration: 0.2), value: todayHabit.isCompleted)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LazyVGrid(
        columns: [GridItem(.adaptive(minimum: 80), alignment: .top)],
        spacing: 12
    ) {
        HabitItemView(
            todayHabit: TodayHabit(
                habit: HabitsDataStore.morningWalk.toMock,
                isCompleted: true,
                streakDescription: "🔥 4d streak",
                frequencyDescription: "1/3 weekly"
            )
        ) {}

        HabitItemView(
            todayHabit: TodayHabit(
                habit: HabitsDataStore.swimming.toMock,
                isCompleted: false,
                streakDescription: nil,
                frequencyDescription: "1/3 this week"
            )
        ) {}

        HabitItemView(
            todayHabit: TodayHabit(
                habit: HabitsDataStore.sleep.toMock,
                isCompleted: true,
                streakDescription: "🔥 4d streak",
                frequencyDescription: "2/3 weekly"
            )
        ) {}
    }
    .padding()
}
