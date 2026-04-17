//
//  DiaryRemindersView.swift
//  Habit Diary
//
//  Created by Lulin Yang on 2025/6/30.
//

import Dependencies
import SQLiteData
import SwiftUI
import SwiftUINavigation

struct DiaryRemindersView: View {
    @State var viewModel: DiaryRemindersViewModel = DiaryRemindersViewModel()
    @Dependency(\.themeManager) private var themeManager

    private var theme: AppTheme { themeManager.current }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.large) {
                deliveryTipsPanel

                if viewModel.notificationStatus == .denied {
                    notificationsDeniedPanel
                }

                remindersContentPanel

                if !viewModel.reminders.isEmpty {
                    notificationLimitFooter
                }
            }
            .padding(.horizontal)
            .padding(.vertical, AppSpacing.small)
            .padding(.bottom, 24)
        }
        .background(theme.background.ignoresSafeArea())
        .navigationTitle(String(localized: "Reminders"))
        .navigationBarTitleDisplayMode(.inline)
        .tint(theme.primaryColor)
        .onAppear {
            Task {
                await viewModel.checkNotificationPermission()
            }
        }
        .sheet(isPresented: Binding($viewModel.route.addReminder)) {
            if case let .addReminder(formViewModel) = viewModel.route {
                ReminderEditorView(viewModel: formViewModel)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                    .presentationBackgroundInteraction(.enabled)
            }
        }
        .sheet(isPresented: Binding($viewModel.route.editReminder)) {
            if case let .editReminder(formViewModel) = viewModel.route {
                ReminderEditorView(viewModel: formViewModel)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                    .presentationBackgroundInteraction(.enabled)
            }
        }
    }

    // MARK: - Tips

    private var deliveryTipsPanel: some View {
        JournalAccentPanel(theme: theme, accent: theme.warning) {
            VStack(alignment: .leading, spacing: AppSpacing.smallMedium) {
                JournalSectionHeader(
                    title: String(localized: "Reliable delivery"),
                    subtitle: String(localized: "Get nudges when you expect them"),
                    systemImage: "bell.badge.fill",
                    theme: theme
                )

                Text(
                    String(
                        localized: "For the most reliable reminders, use immediate or time-sensitive delivery in Settings → Notifications → Habit Diary."
                    )
                )
                .font(AppFont.subheadline)
                .foregroundStyle(theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Permission denied

    private var notificationsDeniedPanel: some View {
        JournalAccentPanel(theme: theme, accent: theme.error) {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                JournalSectionHeader(
                    title: String(localized: "Notifications are off"),
                    subtitle: String(localized: "Habit Diary can’t schedule alerts until you allow them"),
                    systemImage: "bell.slash.fill",
                    theme: theme
                )

                Text(
                    String(
                        localized: "Turn on notifications in Settings so reminders can appear on your Lock Screen and as banners."
                    )
                )
                .font(AppFont.subheadline)
                .foregroundStyle(theme.textSecondary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

                Button {
                    viewModel.openSettings()
                } label: {
                    Label(String(localized: "Open Settings"), systemImage: "gearshape.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(theme.primaryColor)
            }
        }
    }

    // MARK: - Main content

    private var remindersContentPanel: some View {
        JournalAccentPanel(theme: theme, accent: theme.primaryColor) {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                JournalSectionHeader(
                    title: String(localized: "Your reminders"),
                    subtitle: viewModel.reminders.isEmpty
                        ? String(localized: "Add times that fit your day")
                        : String(localized: "Tap a row to edit"),
                    systemImage: "alarm.fill",
                    theme: theme
                )

                Button {
                    viewModel.onTapAddReminder()
                } label: {
                    Label(String(localized: "Add a reminder"), systemImage: "plus.circle.fill")
                        .font(AppFont.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(theme.primaryColor)

                if viewModel.reminders.isEmpty {
                    emptyRemindersContent
                } else {
                    remindersList
                }
            }
        }
    }

    private var emptyRemindersContent: some View {
        VStack(spacing: AppSpacing.medium) {
            Image(systemName: "bell.slash")
                .font(.system(size: 44))
                .foregroundStyle(theme.textSecondary.opacity(0.85))
                .padding(.top, AppSpacing.small)

            Text(String(localized: "No reminders yet"))
                .font(.system(.title3, design: .serif))
                .fontWeight(.semibold)
                .foregroundStyle(theme.textPrimary)

            Text(
                String(
                    localized: "Use reminders to nudge yourself on Journal — add one above or start with a daily suggestion."
                )
            )
            .font(AppFont.subheadline)
            .foregroundStyle(theme.textSecondary)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)

            Button {
                Task {
                    await viewModel.createDefaultDailyReminder()
                }
            } label: {
                Text(String(localized: "Create daily reminder"))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(theme.primaryColor)
            .padding(.top, AppSpacing.small)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.medium)
    }

    private var remindersList: some View {
        VStack(spacing: AppSpacing.small) {
            ForEach(viewModel.reminders, id: \.id) { reminder in
                reminderRow(reminder)
            }
        }
    }

    private func reminderRow(_ reminder: Reminder) -> some View {
        ReminderCell(
            time: reminder.time,
            title: reminder.title,
            onDelete: { viewModel.onTapDeleteReminder(reminder) }
        )
        .background { reminderRowBackground }
        .clipShape(.rect(cornerRadius: AppCornerRadius.info))
        .overlay {
            RoundedRectangle(cornerRadius: AppCornerRadius.info)
                .strokeBorder(theme.textSecondary.opacity(0.1), lineWidth: 1)
        }
        .contentShape(.rect)
        .onTapGesture {
            viewModel.onTapEditReminder(reminder)
        }
    }

    @ViewBuilder
    private var reminderRowBackground: some View {
        if #available(iOS 26, *) {
            Color.clear
                .glassEffect(in: .rect(cornerRadius: AppCornerRadius.info))
        } else {
            RoundedRectangle(cornerRadius: AppCornerRadius.info)
                .fill(theme.surface.opacity(0.55))
        }
    }

    // MARK: - Footer

    private var notificationLimitFooter: some View {
        Group {
            if viewModel.reminders.count == 1 {
                Text(
                    String(
                        localized: "Up to 64 notifications can be scheduled. You currently have 1 reminder."
                    )
                )
            } else {
                Text(
                    String(
                        localized: "Up to 64 notifications can be scheduled. You currently have \(viewModel.reminders.count) reminders."
                    )
                )
            }
        }
        .font(AppFont.footnote)
        .foregroundStyle(theme.textSecondary)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, AppSpacing.small)
    }
}
