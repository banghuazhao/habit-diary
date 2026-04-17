//
// Created by Banghua Zhao on 17/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//
  
import Dependencies
import SQLiteData
import SwiftUI

struct JournalDaySection: Identifiable {
    /// Start-of-day for the section (used as stable id).
    let id: Date
    let entries: [JournalEntrySummary]
}

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
                    habitIcon: $1.icon ?? "",
                    habitColor: $1.color ?? 0x2ECC71CC
                )
            },
        animation: .default
    )
    var checkinHistories

    /// Entries grouped by calendar day, newest days first (same order as `checkinHistories` within each day).
    var daySections: [JournalDaySection] {
        let cal = Calendar.current
        var buckets: [Date: [JournalEntrySummary]] = [:]
        for entry in checkinHistories {
            let day = cal.startOfDay(for: entry.checkIn.date)
            buckets[day, default: []].append(entry)
        }
        return buckets.keys
            .sorted(by: >)
            .map { JournalDaySection(id: $0, entries: buckets[$0] ?? []) }
    }
    
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
