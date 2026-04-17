//
//  DiaryRemindersView.swift
//  Habit Diary
//
//  Created by Lulin Yang on 2025/6/30.
//

import SwiftUI
import Dependencies
import SQLiteData
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

struct DiaryRemindersView: View {
    @State var viewModel: DiaryRemindersViewModel = DiaryRemindersViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 1. Top info box
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "bell.badge")
                        .foregroundStyle(.yellow)
                        .font(.title2)
                    Text("To receive timely reminders, please set notification method on your phone to \"Immediate Push.\"")
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.yellow))

                // Permission warning and button
                if viewModel.notificationStatus == .denied {
                    VStack(spacing: 10) {
                        Text("Notifications are disabled. Please enable them in Settings to receive reminders.")
                            .font(.subheadline)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                        Button("Go to Settings") {
                            viewModel.openSettings()
                        }
                        .appButtonStyle()
                    }
                }

                // 2. Add Reminder Button
                Button(action: {
                    viewModel.onTapAddReminder()
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add a Reminder")
                    }
                }
                .appButtonStyle()

                // 3. Reminders List
                if viewModel.reminders.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 48))
                            .foregroundStyle(.gray)
                        
                        Text("No reminders set")
                            .font(.headline)
                            .foregroundStyle(.gray)
                        
                        Text("Tap Add a Reminder to get started")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                            .multilineTextAlignment(.center)
                        
                        Button("Create Daily Reminder") {
                            Task {
                                await viewModel.createDefaultDailyReminder()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(.rect(cornerRadius: 8))
                    }
                    .padding(.vertical, 40)
                } else {
                    VStack {
                        ForEach(viewModel.reminders, id: \.id) { reminder in
                            ReminderCell(
                                time: reminder.time,
                                title: reminder.title,
                                onDelete: {
                                    viewModel.onTapDeleteReminder(reminder)
                                }
                            )
                            .onTapGesture {
                                viewModel.onTapEditReminder(reminder)
                            }
                        }
                    }
                    .appCardStyle()
                }

                // 4. Info Footer
                if !viewModel.reminders.isEmpty {
                    Text("At most 64 notifications allowed. Currently \(viewModel.reminders.count) set.")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle("Reminders")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await viewModel.checkNotificationPermission()
            }
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

#Preview {
    let _ = prepareDependencies {
        $0.defaultDatabase = try! appDatabase()
    }
    
    NavigationStack {
        DiaryRemindersView()
    }
}
