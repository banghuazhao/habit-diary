//
// Created by Banghua Zhao on 02/06/2025
// Copyright Apps Bay Limited. All rights reserved.
//

import Dependencies
import SwiftUI

/// Library shelf card: parchment body + habit-colored “spine” + emoji tile (not a full-bleed color slab).
struct HabitCard: View {
    let habit: Habit
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onToggleFavorite: () -> Void
    let onToggleArchive: () -> Void

    @Dependency(\.themeManager) private var themeManager
    @State private var showDeleteAlert = false

    private var theme: AppTheme { themeManager.current }
    private var habitTint: Color { Color(hex: habit.color) }

    var body: some View {
        HStack(alignment: .center, spacing: AppSpacing.smallMedium) {
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        colors: [habitTint, habitTint.opacity(0.45)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 4, height: 56)

            Text(habit.icon)
                .font(.system(size: 28))
                .frame(width: 52, height: 52)
                .background(habitTint.opacity(0.16))
                .clipShape(.rect(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(habit.borderColor.opacity(0.35), lineWidth: 1)
                )
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(habit.name)
                        .font(.system(.subheadline, design: .serif))
                        .fontWeight(.semibold)
                        .foregroundStyle(theme.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    if habit.isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.caption2)
                            .foregroundStyle(theme.primaryColor)
                            .accessibilityLabel(String(localized: "Favorite"))
                    }

                    if habit.isArchived {
                        Text(String(localized: "Archived"))
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(theme.textSecondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(theme.textSecondary.opacity(0.12))
                            .clipShape(.capsule)
                    }

                    Spacer(minLength: 0)
                }

                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.caption2.weight(.semibold))
                    Text(habit.frequencyDescription)
                        .font(AppFont.caption)
                        .lineLimit(2)
                }
                .foregroundStyle(theme.textSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(theme.surface.opacity(0.85))
                .clipShape(.capsule)
            }

            Spacer(minLength: 4)

            Menu {
                Button(action: onEdit) {
                    Label(String(localized: "Edit"), systemImage: "pencil")
                }

                Divider()

                Button(action: onToggleFavorite) {
                    Label(
                        habit.isFavorite
                            ? String(localized: "Remove from Favorites")
                            : String(localized: "Add to Favorites"),
                        systemImage: habit.isFavorite ? "heart.slash" : "heart"
                    )
                }

                Button(action: onToggleArchive) {
                    Label(
                        habit.isArchived ? String(localized: "Unarchive") : String(localized: "Archive"),
                        systemImage: habit.isArchived ? "archivebox" : "archivebox.fill"
                    )
                }

                Divider()

                Button(role: .destructive, action: { showDeleteAlert = true }) {
                    Label(String(localized: "Delete"), systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .font(.title3)
                    .foregroundStyle(theme.primaryColor.opacity(0.85))
                    .frame(width: 40, height: 40)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(String(localized: "Habit actions"))
        }
        .padding(.vertical, 12)
        .padding(.leading, 12)
        .padding(.trailing, 10)
        .background { cardBackground }
        .clipShape(.rect(cornerRadius: AppCornerRadius.card))
        .overlay {
            RoundedRectangle(cornerRadius: AppCornerRadius.card)
                .strokeBorder(
                    habit.isArchived
                        ? theme.textSecondary.opacity(0.28)
                        : habit.borderColor.opacity(0.28),
                    style: habit.isArchived
                        ? StrokeStyle(lineWidth: 1, dash: [5, 4])
                        : StrokeStyle(lineWidth: 1),
                    antialiased: true
                )
        }
        .opacity(habit.isArchived ? 0.78 : 1)
        .alert(
            String(localized: "Delete “\(habit.truncatedName)”?"),
            isPresented: $showDeleteAlert,
            actions: {
                Button(String(localized: "Delete"), role: .destructive) { onDelete() }
                Button(String(localized: "Cancel"), role: .cancel) {}
            },
            message: {
                Text(
                    String(
                        localized: "This will permanently delete this habit and its journal entries. This can’t be undone."
                    )
                )
            }
        )
    }

    @ViewBuilder
    private var cardBackground: some View {
        if #available(iOS 26, *) {
            Color.clear
                .glassEffect(in: .rect(cornerRadius: AppCornerRadius.card))
        } else {
            theme.card
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 12) {
            HabitCard(
                habit: DiaryHabitLibrary.morningWalk.toMock,
                onEdit: {},
                onDelete: {},
                onToggleFavorite: {},
                onToggleArchive: {}
            )
            HabitCard(
                habit: DiaryHabitLibrary.swimming.toMock,
                onEdit: {},
                onDelete: {},
                onToggleFavorite: {},
                onToggleArchive: {}
            )
        }
        .padding()
    }
    .background(ThemeManager.shared.current.background)
}
