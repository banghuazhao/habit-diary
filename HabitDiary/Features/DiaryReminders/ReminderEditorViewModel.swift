//
// Created by Banghua Zhao on 17/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import Dependencies
import SQLiteData
import SwiftUI

@Observable
@MainActor
class ReminderEditorViewModel: HashableObject {
    var reminder: Reminder.Draft
    let onSave: ((Reminder.Draft) -> Void)?

    let isEdit: Bool

    init(
        reminder: Reminder.Draft,
        onSave: ((Reminder.Draft) -> Void)? = nil
    ) {
        self.reminder = reminder
        self.onSave = onSave
        isEdit = reminder.id != nil
    }

    func onTapSaveReminder() {
        onSave?(reminder)
    }
}
