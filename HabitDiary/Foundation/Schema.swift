//
// Created by Banghua Zhao on 02/06/2025
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation
import OSLog
import SQLiteData

private let logger = Logger(subsystem: "Reminders", category: "Database")

func appDatabase() throws -> any DatabaseWriter {
    @Dependency(\.context) var context

    let database: any DatabaseWriter

    var configuration = Configuration()
    configuration.foreignKeysEnabled = true
    configuration.prepareDatabase { db in
        #if DEBUG
            db.trace(options: .profile) {
                if context == .preview {
                    print($0.expandedDescription)
                } else {
                    logger.debug("\($0.expandedDescription)")
                }
            }
        #endif
    }

    switch context {
    case .live:
        let path = URL.documentsDirectory.appending(component: "db.sqlite").path()
        logger.info("open \(path)")
        database = try DatabasePool(path: path, configuration: configuration)
    case .preview, .test:
        database = try DatabaseQueue(configuration: configuration)
    }

    var migrator = DatabaseMigrator()
    #if DEBUG
        migrator.eraseDatabaseOnSchemaChange = true
    #endif
    migrator.registerMigration("Create tables") { db in
        try #sql(
            """
            CREATE TABLE "habits" (
             "id" INTEGER PRIMARY KEY AUTOINCREMENT, 
             "name" TEXT NOT NULL DEFAULT '', 
             "frequency" INTEGER NOT NULL DEFAULT 0, 
             "frequencyDetail" TEXT NOT NULL DEFAULT '', 
             "icon" TEXT NOT NULL DEFAULT '', 
             "color" TEXT NOT NULL DEFAULT '', 
             "note" TEXT NOT NULL DEFAULT '', 
             "isFavorite" INTEGER NOT NULL DEFAULT 0, 
             "isArchived" INTEGER NOT NULL DEFAULT 0 
            ) STRICT 
            """
        )
        .execute(db)

        try #sql(
            """
            CREATE TABLE "checkIns" ( 
             "id" INTEGER PRIMARY KEY AUTOINCREMENT, 
             "date" TEXT NOT NULL DEFAULT '', 
             "habitID" INTEGER NOT NULL DEFAULT 0 REFERENCES "habits"("id") ON DELETE CASCADE 
            ) STRICT
            """
        )
        .execute(db)
        
        try #sql(
            """
            CREATE TABLE "reminders" (
             "id" INTEGER PRIMARY KEY AUTOINCREMENT,
             "title" TEXT NOT NULL DEFAULT '',
             "body" TEXT NOT NULL DEFAULT '',
             "time" TEXT NOT NULL DEFAULT '',
             "habitID" INTEGER REFERENCES "habits"("id") ON DELETE CASCADE,
             "notificationID" TEXT NOT NULL DEFAULT ''
            ) STRICT
            """
        )
        .execute(db)
        
        try #sql(
            """
            CREATE TABLE "achievements" (
             "id" INTEGER PRIMARY KEY AUTOINCREMENT,
             "title" TEXT NOT NULL DEFAULT '',
             "description" TEXT NOT NULL DEFAULT '',
             "icon" TEXT NOT NULL DEFAULT '',
             "type" INTEGER NOT NULL DEFAULT 0,
             "criteria" TEXT NOT NULL DEFAULT '',
             "isUnlocked" INTEGER NOT NULL DEFAULT 0,
             "unlockedDate" TEXT,
             "habitID" INTEGER REFERENCES "habits"("id") ON DELETE SET NULL
            ) STRICT
            """
        )
        .execute(db)
    }
    #if DEBUG
        migrator.registerMigration("Seed database") { db in
            try db.seed {
                DiaryHabitLibrary.all
            }
        }
    #endif
    
    migrator.registerMigration("Add default daily reminder") { db in
        let defaultTime = Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? Date()
        var defaultReminder = Reminder.Draft()
        defaultReminder.time = defaultTime
        let reminder = try Reminder.upsert { defaultReminder }.returning(\.self).fetchOne(db)
        if let reminder {
            Task {
                await ReminderNotificationCenter.shared.scheduleReminder(reminder)
            }
        }
    }
    
    migrator.registerMigration("Add achievements") { db in
        // Insert badge definitions via raw SQL.
        // At this migration point the table is still named "achievements";
        // the later "Rename achievements to badges" migration renames it.
        // This keeps the migration identity stable for existing users.
        for draft in BadgeDefinitions.all {
            try db.execute(
                sql: #"""
                INSERT INTO "achievements"
                    ("title", "description", "icon", "type", "criteria", "isUnlocked", "unlockedDate", "habitID")
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """#,
                arguments: [
                    draft.title,
                    draft.description,
                    draft.icon,
                    draft.type.rawValue,
                    draft.criteria.encode(),
                    draft.isUnlocked,
                    draft.unlockedDate,
                    draft.habitID
                ]
            )
        }
    }

    migrator.registerMigration("Add note to checkIns") { db in
        try db.execute(sql: #"ALTER TABLE "checkIns" ADD COLUMN "note" TEXT NOT NULL DEFAULT ''"#)
    }

    migrator.registerMigration("Rename checkIns to diaryEntries") { db in
        try db.execute(sql: #"ALTER TABLE "checkIns" RENAME TO "diaryEntries""#)
    }

    migrator.registerMigration("Rename achievements to badges") { db in
        try db.execute(sql: #"ALTER TABLE "achievements" RENAME TO "badges""#)
    }

    try migrator.migrate(database)

    return database
}
