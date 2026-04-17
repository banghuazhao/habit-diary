//
// Created by Banghua Zhao on 17/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import Dependencies
import SQLiteData
import SwiftUI
import SwiftUINavigation

@Observable
@MainActor
class DiaryRemindersViewModel: HashableObject {
    @ObservationIgnored
    @FetchAll(Reminder.all, animation: .default) var reminders

    @ObservationIgnored
    @Dependency(\.defaultDatabase) var database

    @ObservationIgnored
    @Dependency(\.reminderNotificationCenter) var reminderNotificationCenter

    var notificationStatus: ReminderNotificationCenter.NotificationAuthorizationStatus = .notDetermined

    @CasePathable
    enum Route: Equatable {
        case addReminder(ReminderEditorViewModel)
        case editReminder(ReminderEditorViewModel)
    }

    var route: Route?

    func onTapAddReminder() {
        route = .addReminder(
            ReminderEditorViewModel(
                reminder: Reminder.Draft(),
                onSave: { [weak self] reminder in
                    guard let self else { return }
                    onUpdateReminder(reminder)
                    route = nil
                }
            )
        )
    }

    func onTapDeleteReminder(_ reminder: Reminder) {
        onDeleteReminder(Reminder.Draft(reminder))
    }

    func onTapEditReminder(_ reminder: Reminder) {
        route = .editReminder(
            ReminderEditorViewModel(
                reminder: Reminder.Draft(reminder),
                onSave: { [weak self] reminderDraft in
                    guard let self else { return }
                    onUpdateReminder(reminderDraft)
                    route = nil
                }
            )
        )
    }

    private func onUpdateReminder(_ reminder: Reminder.Draft) {
        Task {
            await withErrorReporting {
                let updatedReminder = try await database.write { db in
                    try Reminder
                        .upsert { reminder }
                        .returning(\.self)
                        .fetchOne(db)
                }
                if let updatedReminder {
                    await reminderNotificationCenter.scheduleReminder(updatedReminder)
                }
            }
        }
    }

    private func onDeleteReminder(_ reminder: Reminder.Draft) {
        Task {
            await withErrorReporting {
                guard let reminderID = reminder.id else { return }
                let reminderToDelete = try await database.read { db in
                    try Reminder.find(reminderID).fetchOne(db)
                }
                if let reminderToDelete {
                    reminderNotificationCenter.removeReminder(reminderToDelete)
                    try await database.write { db in
                        try Reminder.delete(reminderToDelete).execute(db)
                    }
                }
            }
        }
    }

    func createDefaultDailyReminder() async {
        await withErrorReporting {
            let defaultReminder = reminderNotificationCenter.createDefaultDailyReminder()
            let reminder = try await database.write { db in
                try Reminder
                    .upsert { defaultReminder }
                    .returning(\.self)
                    .fetchOne(db)
            }
            if let reminder {
                await reminderNotificationCenter.scheduleReminder(reminder)
            }
        }
    }

    func checkNotificationPermission() async {
        notificationStatus = await reminderNotificationCenter.getAuthorizationStatus()
    }

    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
