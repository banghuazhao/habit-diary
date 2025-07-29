//
// Created by Banghua Zhao on 31/05/2025
// Copyright Apps Bay Limited. All rights reserved.
//

import SwiftUI
import SharingGRDB

@Observable
@MainActor
class OnboardingViewModel {
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
        HabitsDataStore.all
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
                for habitDraft in selectedHabits {
                    _ = try Habit
                        .upsert { habitDraft }
                        .returning { $0 }
                        .fetchOne(db)
                }
            }
        }
        
        // Mark onboarding as completed
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}

struct OnboardingView: View {
    @State private var viewModel = OnboardingViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @Dependency(\.themeManager) var themeManager
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {                
                switch viewModel.currentStep {
                case .welcome:
                    welcomeView
                case .features:
                    featuresView
                case .selectHabits:
                    selectHabitsView
                case .complete:
                    completeView
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private var welcomeView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 24) {
                // App icon representation
                ZStack {
                    Circle()
                        .fill(themeManager.current.primaryColor.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Text("📔")
                        .font(.system(size: 64))
                }
                
                VStack(spacing: 16) {
                    Text(String(localized: "Welcome to Habit Diary"))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(String(localized: "Transform your life one habit at a time. Track your progress, earn achievements, and build the lifestyle you've always wanted."))
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            
            Spacer()
            
            Button(action: {
                viewModel.nextStep()
            }) {
                Text(String(localized: "Get Started"))
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(themeManager.current.primaryColor)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
    
    private var featuresView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Text(String(localized: "Why Habit Diary?"))
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(String(localized: "Discover the features that make habit building engaging and effective"))
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top)
            
            ScrollView {
                VStack(spacing: 20) {
                    FeatureCard(
                        icon: "📊",
                        title: String(localized: "Rating System"),
                        description: String(localized: "Advance through 12 levels from Beginner (F) to Legend (SSS) based on your habit consistency and achievements."),
                        color: themeManager.current.primaryColor
                    )
                    
                    FeatureCard(
                        icon: "🏆",
                        title: String(localized: "Achievements"),
                        description: String(localized: "Unlock exciting achievements for streaks, consistency, and milestones. Celebrate your progress!"),
                        color: .yellow
                    )
                    
                    FeatureCard(
                        icon: "📅",
                        title: String(localized: "Flexible Scheduling"),
                        description: String(localized: "Choose from daily, weekly, or custom frequency patterns that fit your lifestyle perfectly."),
                        color: .blue
                    )
                    
                    FeatureCard(
                        icon: "🎯",
                        title: String(localized: "Comprehensive Categories"),
                        description: String(localized: "35+ habit templates across health, productivity, learning, relationships, and personal growth."),
                        color: .green
                    )
                    
                    FeatureCard(
                        icon: "🔔",
                        title: String(localized: "Smart Reminders"),
                        description: String(localized: "Personalized notifications to keep you on track without being overwhelming."),
                        color: .orange
                    )
                }
                .padding(.horizontal)
            }
            
            Button(action: {
                viewModel.nextStep()
            }) {
                Text(String(localized: "Choose Your Habits"))
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(themeManager.current.primaryColor)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
    
    private var selectHabitsView: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                Text(String(localized: "Choose Your Starting Habits"))
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(String(localized: "Select 3-7 habits that resonate with you. Don't worry, you can always add more or modify these later!"))
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Selected count indicator
                if !viewModel.selectedHabits.isEmpty {
                    Text("\(viewModel.selectedHabits.count) habits selected")
                        .font(.caption)
                        .foregroundColor(themeManager.current.primaryColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(themeManager.current.primaryColor.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            .padding()
            
            // Habits list
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.filteredHabits, id: \.self) { habit in
                        OnboardingHabitCard(
                            habit: habit,
                            isSelected: viewModel.isHabitSelected(habit),
                            onToggle: { viewModel.toggleHabitSelection(habit) }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 100) // Space for floating button
            }
            
            // Floating bottom button
            VStack {
                Divider()
                
                HStack(spacing: 16) {
                    Button {
                        viewModel.previousStep()
                    } label: {
                        Text(String(localized: "Back"))
                            .font(.headline)
                            .foregroundColor(themeManager.current.primaryColor)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    
                    Button {
                        viewModel.nextStep()
                    } label: {
                        Text(viewModel.selectedHabits.isEmpty ? String(localized: "Skip for Now") : String(localized: "Continue"))
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(themeManager.current.primaryColor)
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            .background(Color(.systemBackground))
        }
    }
    
    private var completeView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 24) {
                // Success animation placeholder
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.green)
                }
                
                VStack(spacing: 16) {
                    Text(String(localized: "You're Ready to Start!"))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    if viewModel.selectedHabits.isEmpty {
                        Text(String(localized: "You can explore our habit gallery anytime and add habits that inspire you. Start your journey whenever you're ready!"))
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    } else if viewModel.selectedHabits.count == 1 {
                        Text(String(localized: "Perfect! You've selected 1 habit to get started. Remember, consistency is more important than quantity. You can always add more habits as you build momentum."))
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    } else {
                        Text(String(localized: "Excellent! You've selected \(viewModel.selectedHabits.count) habits. Focus on building these consistently, and watch your rating grow from Beginner to Legend!"))
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Quick tips
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top) {
                            Text("💡")
                            Text(String(localized: "Start small and be consistent - even 1% better each day adds up!"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(alignment: .top) {
                            Text("🎯")
                            Text(String(localized: "Check your Today tab daily to track progress and maintain streaks."))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(alignment: .top) {
                            Text("🏆")
                            Text(String(localized: "Earn achievements and climb the rating ladder to Legend status!"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            
            Spacer()
            
            Button(action: {
                Task {
                    await viewModel.completeOnboarding()
                    dismiss()
                }
            }) {
                Text(String(localized: "Begin Your Journey"))
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(themeManager.current.primaryColor)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Text(icon)
                    .font(.title2)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
}

struct OnboardingHabitCard: View {
    let habit: Habit.Draft
    let isSelected: Bool
    let onToggle: () -> Void
    
    @Dependency(\.themeManager) var themeManager
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 16) {
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? themeManager.current.primaryColor : .gray)
                
                // Habit icon and color indicator
                ZStack {
                    Circle()
                        .fill(Color(hex: habit.color).opacity(0.3))
                        .frame(width: 40, height: 40)
                    
                    Text(habit.icon)
                        .font(.title3)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(habit.note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Frequency indicator
                    Text(habit.toMock.frequencyDescription)
                        .font(.caption2)
                        .foregroundColor(themeManager.current.primaryColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(themeManager.current.primaryColor.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? themeManager.current.primaryColor : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
                    )
                    .shadow(color: .black.opacity(isSelected ? 0.1 : 0.05), radius: isSelected ? 4 : 2, x: 0, y: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    OnboardingView()
} 
