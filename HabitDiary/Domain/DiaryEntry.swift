//
// Created by Banghua Zhao on 05/06/2025
// Copyright Apps Bay Limited. All rights reserved.
//
  

import SQLiteData
import Foundation

@Table
struct DiaryEntry {
    let id: Int
    @Column(as: Date.self)
    var date: Date
    var habitID: Habit.ID
    var note: String = ""
}

@Selection
struct JournalEntrySummary {
    let checkIn: DiaryEntry
    let habitName: String
    let habitIcon: String
}
