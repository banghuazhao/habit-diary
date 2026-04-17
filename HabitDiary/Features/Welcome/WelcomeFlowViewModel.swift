//
// Created by Banghua Zhao on 17/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import Dependencies
import SQLiteData
import SwiftUI

@Observable
@MainActor
class WelcomeFlowViewModel {
    @ObservationIgnored
    @Dependency(\.defaultDatabase) var database

    var selectedHabits: Set<Habit.Draft> = []
    var currentStep: OnboardingStep = .welcome

    enum OnboardingStep: Int, CaseIterable {
        case welcome = 0
        case features = 1
        case selectHabits = 2
        case complete = 3
    }

    var predefinedHabits: [Habit.Draft] {
        DiaryHabitLibrary.all
    }

    var filteredHabits: [Habit.Draft] {
        predefinedHabits
    }

    func toggleHabitSelection(_ habit: Habit.Draft) {
        if selectedHabits.contains(habit) {
            selectedHabits.remove(habit)
        } else {
            selectedHabits.insert(habit)
        }
    }

    func isHabitSelected(_ habit: Habit.Draft) -> Bool {
        selectedHabits.contains(habit)
    }

    func nextStep() {
        withAnimation {
            if let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep),
               currentIndex + 1 < OnboardingStep.allCases.count {
                currentStep = OnboardingStep.allCases[currentIndex + 1]
            }
        }
    }

    func previousStep() {
        withAnimation {
            if let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep),
               currentIndex > 0 {
                currentStep = OnboardingStep.allCases[currentIndex - 1]
            }
        }
    }

    func completeOnboarding() async {
        await withErrorReporting {
            try await database.write { [selectedHabits] db in
                try Habit
                    .upsert { Array(selectedHabits) }
                    .execute(db)
            }
        }

        // Mark onboarding as completed
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}
