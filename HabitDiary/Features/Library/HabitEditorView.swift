//
// Created by Banghua Zhao on 22/06/2025
// Copyright Apps Bay Limited. All rights reserved.
//

import Dependencies
import EasyToast
import SwiftNavigation
import SwiftUI

struct HabitEditorView: View {
    @State var viewModel: HabitEditorViewModel
    @Dependency(\.themeManager) private var themeManager
    @Environment(\.dismiss) private var dismiss

    private var theme: AppTheme { themeManager.current }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.large) {
                    previewStripSection
                    nameAndCatalogSection
                    scheduleSection
                    journalNoteSection
                    remindersSection
                }
                .padding(.horizontal)
                .padding(.vertical, AppSpacing.small)
                .padding(.bottom, 40)
            }
            .background(theme.background.ignoresSafeArea())
            .navigationTitle(
                viewModel.isEdit
                    ? String(localized: "Edit habit")
                    : String(localized: "New habit")
            )
            .scrollDismissesKeyboard(.immediately)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text(String(localized: "Close"))
                            .appRectButtonStyle()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { @MainActor in
                            if await viewModel.onTapSaveHabit() {
                                dismiss()
                            }
                        }
                    } label: {
                        Text(viewModel.isEdit ? String(localized: "Update") : String(localized: "Save"))
                            .appRectButtonStyle()
                    }
                }
            }
            .onChange(of: viewModel.habit.frequency) { _, _ in
                viewModel.onChangeOfHabitFrequency()
            }
            .easyToast(
                isPresented: $viewModel.showTitleEmptyToast,
                message: String(localized: "Give your habit a name first.")
            )
            .sheet(isPresented: Binding($viewModel.route.editHabitIcon)) {
                IconPickerView(
                    color: $viewModel.habit.color,
                    icon: $viewModel.habit.icon
                )
                .presentationDetents([.fraction(0.8), .large])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: Binding($viewModel.route.habitsGallery)) {
                HabitCatalogView(habit: $viewModel.habit)
                    .presentationDetents([.fraction(0.7), .large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: Binding($viewModel.route.addReminder)) {
                if case .addReminder(let formViewModel) = viewModel.route {
                    ReminderEditorView(viewModel: formViewModel)
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                        .presentationBackgroundInteraction(.enabled)
                }
            }
            .sheet(isPresented: Binding($viewModel.route.editReminder)) {
                if case .editReminder(let formViewModel) = viewModel.route {
                    ReminderEditorView(viewModel: formViewModel)
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                        .presentationBackgroundInteraction(.enabled)
                }
            }
        }
    }

    // MARK: - Preview (emoji + tile)

    private var previewStripSection: some View {
        HabitEditorPanel(theme: theme, accent: theme.primaryColor) {
            VStack(alignment: .leading, spacing: AppSpacing.smallMedium) {
                HabitEditorSectionHeader(
                    title: String(localized: "On your shelf"),
                    subtitle: String(localized: "How this habit will look in your journal"),
                    systemImage: "books.vertical.fill",
                    theme: theme
                )

                HStack(spacing: AppSpacing.medium) {
                    DraftHabitTile(todayHabit: viewModel.todayHabit) {
                        viewModel.onTapTodayHabit()
                    }
                    .frame(maxWidth: 200)

                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        Button {
                            viewModel.onTapTodayHabit()
                        } label: {
                            Label(String(localized: "Icon & color"), systemImage: "paintpalette.fill")
                                .font(AppFont.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(theme.primaryColor)

                        Button {
                            viewModel.onTapGallery()
                        } label: {
                            Label(String(localized: "Browse catalog"), systemImage: "square.grid.2x2.fill")
                                .font(AppFont.subheadline.weight(.medium))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(theme.primaryColor)
                    }
                }
            }
        }
    }

    // MARK: - Name

    private var nameAndCatalogSection: some View {
        HabitEditorPanel(theme: theme, accent: theme.primaryColor) {
            VStack(alignment: .leading, spacing: AppSpacing.smallMedium) {
                HabitEditorSectionHeader(
                    title: String(localized: "Title"),
                    subtitle: String(localized: "Short and memorable works best"),
                    systemImage: "character.cursor.ibeam",
                    theme: theme
                )

                TextField(String(localized: "Habit name"), text: $viewModel.habit.name)
                    .font(.system(.title3, design: .serif))
                    .fontWeight(.semibold)
                    .foregroundStyle(theme.textPrimary)
                    .padding(AppSpacing.smallMedium)
                    .background(theme.background.opacity(0.9))
                    .clipShape(.rect(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(theme.textSecondary.opacity(0.18), lineWidth: 1)
                    )
            }
        }
    }

    // MARK: - Schedule

    private var scheduleSection: some View {
        HabitEditorPanel(theme: theme, accent: theme.primaryColor) {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                HabitEditorSectionHeader(
                    title: String(localized: "Schedule"),
                    subtitle: String(localized: "When this habit appears on Journal"),
                    systemImage: "calendar",
                    theme: theme
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "Repeat"))
                        .font(AppFont.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(theme.textSecondary)
                        .textCase(.uppercase)
                        .tracking(0.5)

                    Picker(String(localized: "Frequency"), selection: $viewModel.habit.frequency) {
                        ForEach(HabitFrequency.allCases, id: \.self) { mode in
                            Text(mode.title)
                                .tag(mode)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(theme.primaryColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(theme.surface.opacity(0.75))
                    .clipShape(.rect(cornerRadius: 12))
                }

                frequencyDetailContent
            }
        }
    }

    @ViewBuilder
    private var frequencyDetailContent: some View {
        switch viewModel.habit.frequency {
        case .fixedDaysInWeek:
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                ForEach(WeekDays.allCases, id: \.self) { weekDay in
                    weekDayCell(weekDay)
                }
            }
        case .fixedDaysInMonth:
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                ForEach(1 ... 28, id: \.self) { monthDay in
                    monthDayCell(monthDay)
                }
            }
        case .nDaysEachWeek:
            nDaysPicker(
                range: 1 ... 7,
                selection: Binding(
                    get: { viewModel.habit.nDaysPerWeek },
                    set: { viewModel.onSelectNDays($0) }
                ),
                singularLabel: String(localized: "day this week"),
                pluralLabel: String(localized: "days this week"),
                explanation: { n in
                    if n == 1 {
                        String(
                            localized: "After you complete it once, it hides until next week."
                        )
                    } else {
                        String(
                            localized: "After \(n) completions, it hides until next week."
                        )
                    }
                }
            )
        case .nDaysEachMonth:
            nDaysPicker(
                range: 1 ... 28,
                selection: Binding(
                    get: { viewModel.habit.nDaysPerMonth },
                    set: { viewModel.onSelectNDays($0) }
                ),
                singularLabel: String(localized: "day this month"),
                pluralLabel: String(localized: "days this month"),
                explanation: { n in
                    if n == 1 {
                        String(
                            localized: "After you complete it once, it hides until next month."
                        )
                    } else {
                        String(
                            localized: "After \(n) completions, it hides until next month."
                        )
                    }
                }
            )
        }
    }

    private func weekDayCell(_ weekDay: WeekDays) -> some View {
        let selected = viewModel.hasSelectedWeekDay(weekDay)
        return Button {
            viewModel.toggleWeekDay(weekDay)
        } label: {
            VStack(spacing: 6) {
                Text(weekDay.title)
                    .font(AppFont.caption)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
        .foregroundStyle(selected ? theme.primaryColor : theme.textPrimary)
        .background(selected ? theme.primaryColor.opacity(0.12) : theme.background.opacity(0.6))
        .clipShape(.rect(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(
                    selected ? theme.primaryColor.opacity(0.45) : theme.textSecondary.opacity(0.15),
                    lineWidth: 1
                )
        )
    }

    private func monthDayCell(_ monthDay: Int) -> some View {
        let selected = viewModel.hasSelectedMonthDay(monthDay)
        return Button {
            viewModel.toggleMonthDay(monthDay)
        } label: {
            Text("\(monthDay)")
                .font(AppFont.subheadline.weight(.medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
        .foregroundStyle(selected ? theme.primaryColor : theme.textPrimary)
        .background(selected ? theme.primaryColor.opacity(0.12) : theme.background.opacity(0.6))
        .clipShape(.rect(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(
                    selected ? theme.primaryColor.opacity(0.45) : theme.textSecondary.opacity(0.15),
                    lineWidth: 1
                )
        )
    }

    private func nDaysPicker(
        range: ClosedRange<Int>,
        selection: Binding<Int>,
        singularLabel: String,
        pluralLabel: String,
        explanation: @escaping (Int) -> String
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            HStack {
                Spacer(minLength: 0)
                Picker("", selection: selection) {
                    ForEach(Array(range), id: \.self) { n in
                        Text(n == 1 ? "\(n) \(singularLabel)" : "\(n) \(pluralLabel)")
                            .tag(n)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 120)
                .clipped()
            }

            Label {
                Text(explanation(selection.wrappedValue))
                    .font(AppFont.caption)
                    .foregroundStyle(theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            } icon: {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(theme.textSecondary.opacity(0.9))
            }
        }
    }

    // MARK: - Note

    private var journalNoteSection: some View {
        HabitEditorPanel(theme: theme, accent: theme.primaryColor) {
            VStack(alignment: .leading, spacing: AppSpacing.smallMedium) {
                HabitEditorSectionHeader(
                    title: String(localized: "Note"),
                    subtitle: String(localized: "Optional — why this habit matters to you"),
                    systemImage: "text.alignleft",
                    theme: theme
                )

                HStack(alignment: .top, spacing: AppSpacing.smallMedium) {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [theme.primaryColor.opacity(0.5), theme.primaryColor.opacity(0.2)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 3)
                        .clipShape(.rect(cornerRadius: 1.5))

                    TextEditor(text: $viewModel.habit.note)
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(theme.textPrimary)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 100)
                        .padding(10)
                        .background(theme.background.opacity(0.85))
                        .clipShape(.rect(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(theme.textSecondary.opacity(0.15), lineWidth: 1)
                        )
                }
            }
        }
    }

    // MARK: - Reminders

    private var remindersSection: some View {
        HabitEditorPanel(theme: theme, accent: theme.primaryColor) {
            VStack(alignment: .leading, spacing: AppSpacing.smallMedium) {
                HStack {
                    HabitEditorSectionHeader(
                        title: String(localized: "Reminders"),
                        subtitle: String(localized: "Optional nudges"),
                        systemImage: "bell.badge.fill",
                        theme: theme
                    )
                    Spacer(minLength: 0)
                    Button {
                        viewModel.onTapAddReminder()
                    } label: {
                        Label(String(localized: "Add"), systemImage: "plus.circle.fill")
                            .font(AppFont.subheadline.weight(.semibold))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(theme.primaryColor)
                    .controlSize(.small)
                }

                if viewModel.draftReminders.isEmpty {
                    Text(String(localized: "No reminders yet"))
                        .font(AppFont.subheadline)
                        .foregroundStyle(theme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(AppSpacing.medium)
                        .background(theme.surface.opacity(0.5))
                        .clipShape(.rect(cornerRadius: 12))
                } else {
                    VStack(spacing: AppSpacing.small) {
                        ForEach(viewModel.draftReminders, id: \.id) { draft in
                            ReminderCell(
                                time: draft.time,
                                title: String(localized: "Every day"),
                                onDelete: { viewModel.onTapDeleteReminder(draft) }
                            )
                            .onTapGesture {
                                viewModel.onTapEditReminder(draft)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Section chrome (matches Settings / Profile)

private struct HabitEditorSectionHeader: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let theme: AppTheme

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.smallMedium) {
            Image(systemName: systemImage)
                .font(.title3.weight(.semibold))
                .foregroundStyle(theme.primaryColor)
                .frame(width: 32, height: 32)
                .background(theme.primaryColor.opacity(0.12))
                .clipShape(.rect(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(theme.textPrimary)
                Text(subtitle)
                    .font(AppFont.caption)
                    .foregroundStyle(theme.textSecondary)
            }
            Spacer(minLength: 0)
        }
    }
}

private struct HabitEditorPanel<Content: View>: View {
    let theme: AppTheme
    let accent: Color
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        colors: [accent, accent.opacity(0.35)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 4)
                .padding(.vertical, 8)

            VStack(alignment: .leading, spacing: 0) {
                content()
            }
            .padding(AppSpacing.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background { panelBackground }
        .clipShape(.rect(cornerRadius: AppCornerRadius.card))
        .overlay {
            RoundedRectangle(cornerRadius: AppCornerRadius.card)
                .strokeBorder(theme.textSecondary.opacity(0.12), lineWidth: 1)
        }
    }

    @ViewBuilder
    private var panelBackground: some View {
        if #available(iOS 26, *) {
            Color.clear
                .glassEffect(in: .rect(cornerRadius: AppCornerRadius.card))
        } else {
            theme.card
        }
    }
}

#Preview {
    let _ = prepareDependencies {
        $0.defaultDatabase = try! appDatabase()
    }

    HabitEditorView(
        viewModel: HabitEditorViewModel(
            habit: Habit.Draft(
                Habit(
                    id: 0,
                    frequency: .nDaysEachWeek
                )
            )
        )
    )
}
