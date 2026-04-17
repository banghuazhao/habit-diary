//
// Created by Banghua Zhao on 01/01/2025
// Copyright Apps Bay Limited. All rights reserved.
//

import Dependencies
import SQLiteData
import SwiftUI

struct ReminderEditorView: View {
    @State var viewModel: ReminderEditorViewModel

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    DatePicker("Time", selection: $viewModel.reminder.time, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                }
                .navigationTitle(
                    viewModel.isEdit
                        ? "Edit Reminder"
                        : "New Reminder"
                )
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                                .appRectButtonStyle()
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            viewModel.onTapSaveReminder()
                            dismiss()
                        } label: {
                            Text(viewModel.isEdit ? "Update" : "Save")
                                .appRectButtonStyle()
                        }
                    }
                }
            }
        }
    }
}
