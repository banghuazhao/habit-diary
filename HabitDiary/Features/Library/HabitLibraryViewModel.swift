//
// Created by Banghua Zhao on 17/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation
import Observation
import Sharing
import SQLiteData
import SwiftUI
import SwiftNavigation

@Observable
@MainActor
class HabitLibraryViewModel {
    @ObservationIgnored
    @FetchAll(animation: .default) var habits: [Habit]

    @ObservationIgnored
    @Dependency(\.defaultDatabase) var database

    @ObservationIgnored
    @Dependency(\.reminderNotificationCenter) var reminderNotificationCenter

    // Add sort and filter properties
    enum SortOption: String, CaseIterable {
        case `default` = "Default"
        case name = "Name"

        var displayName: String {
            return rawValue
        }
    }

    enum FilterOption: String, CaseIterable {
        case all = "All"
        case favorites = "Favorites"
        case active = "Active"
        case archived = "Archived"

        var displayName: String {
            return rawValue
        }
    }

    @ObservationIgnored
    @Shared(.appStorage("selectedSortOption")) var selectedSortOption: SortOption = .default
    @ObservationIgnored
    @Shared(.appStorage("selectedFilterOption")) var selectedFilterOption: FilterOption = .all
    
    init() {}

    // Computed property for filtered and sorted habits
    var filteredHabits: [Habit] {
        var filtered = habits

        // Apply additional filters
        switch selectedFilterOption {
        case .all:
            break // No additional filtering
        case .favorites:
            filtered = filtered.filter { $0.isFavorite }
        case .archived:
            filtered = filtered.filter { $0.isArchived }
        case .active:
            filtered = filtered.filter { !$0.isArchived }
        }

        // Apply sorting
        switch selectedSortOption {
        case .default:
            break
        case .name:
            filtered.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        }

        return filtered
    }

    @CasePathable
    enum Route {
        case editHabit(HabitEditorViewModel)
        case createHabit(HabitEditorViewModel)
        case habitDetail(HabitPageViewModel)
    }

    var route: Route?

    func confirmDeleteHabit(_ habit: Habit) {
        withErrorReporting {
            reminderNotificationCenter.removeRemindersForHabit(habit.id)
            try database.write { db in
                try Habit.delete(habit).execute(db)
            }
        }
    }

    func onTapHabitItem(_ habit: Habit) {
        route = .habitDetail(HabitPageViewModel(habit: habit))
    }

    func onTapEditHabit(_ habit: Habit) {
        route = .editHabit(
            HabitEditorViewModel(
                habit: Habit.Draft(habit)
            ) { [weak self] _ in
                guard let self else { return }
                route = nil
            }
        )
    }

    func toggleFavorite(_ habit: Habit) {
        var updatedHabit = habit
        updatedHabit.isFavorite = !habit.isFavorite
        withErrorReporting {
            try database.write { db in
                try Habit
                    .update(updatedHabit)
                    .execute(db)
            }
        }
    }

    func toggleArchive(_ habit: Habit) {
        var updatedHabit = habit
        updatedHabit.isArchived = !habit.isArchived
        withErrorReporting {
            try database.write { db in
                try Habit
                    .update(updatedHabit)
                    .execute(db)
            }
        }
    }

    func onTapCreateHabit() {
        route = .createHabit(
            HabitEditorViewModel(
                habit: Habit.Draft()
            ) { [weak self] _ in
                guard let self else { return }
                route = nil
            }
        )
    }

    func selectSortOption(_ option: SortOption) {
        withAnimation {
            $selectedSortOption.withLock { $0 = option }
        }
    }

    func selectFilterOption(_ option: FilterOption) {
        withAnimation {
            $selectedFilterOption.withLock { $0 = option }
        }
    }
}
