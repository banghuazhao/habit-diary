//
//  CheckinHistoryView.swift
//  Habit Diary
//
//  Created by Lulin Yang on 2025/6/30.
//

import SwiftUI
import SQLiteData

@MainActor
@Observable
class JournalTimelineViewModel {
    @ObservationIgnored
    @FetchAll(
        DiaryEntry
            .order { $0.date.desc() }
            .leftJoin(Habit.all) {
                $0.habitID.eq($1.id)
            }
            .select {
                JournalEntrySummary.Columns(
                    checkIn: $0,
                    habitName: $1.name ?? "",
                    habitIcon: $1.icon ?? ""
                )
            },
        animation: .default
    )
    var checkinHistories
    
    @ObservationIgnored
    @Dependency(\.defaultDatabase) var database
    
    func onTapDeleteCheckin(_ checkin: JournalEntrySummary) {
        withErrorReporting {
            try database.write { db in
                try DiaryEntry.delete(checkin.checkIn).execute(db)
            }
        }
    }
}

struct JournalTimelineView: View {
    @State private var viewModel = JournalTimelineViewModel()
    @Dependency(\.themeManager) var themeManager

    var body: some View {
        Group {
            if viewModel.checkinHistories.isEmpty {
                VStack(spacing: 16) {
                    Text("📔")
                        .font(.system(size: 56))
                    Text(String(localized: "Your journal is empty"))
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(String(localized: "Check in a habit and add a diary note to start your personal journal."))
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 80)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.checkinHistories, id: \.checkIn.id) { entry in
                        JournalEntryRow(entry: entry) {
                            viewModel.onTapDeleteCheckin(entry)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle(String(localized: "Journal Entries"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct JournalEntryRow: View {
    let entry: JournalEntrySummary
    let onDelete: () -> Void

    @Dependency(\.themeManager) var themeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Text(entry.habitIcon)
                    .font(.system(size: 28))

                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.habitName)
                        .font(.headline)
                    Text(entry.checkIn.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                        .font(.system(size: 14))
                }
                .buttonStyle(.borderless)
            }

            if !entry.checkIn.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "pencil.line")
                        .font(.caption)
                        .foregroundStyle(themeManager.current.primaryColor)
                        .padding(.top, 1)
                    Text(entry.checkIn.note)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(10)
                .background(themeManager.current.primaryColor.opacity(0.06))
                .clipShape(.rect(cornerRadius: 8))
            }
        }
        .padding(.vertical, 4)
    }
}
