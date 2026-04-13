//
// Created by Banghua Zhao on 03/06/2025
// Copyright Apps Bay Limited. All rights reserved.
//

import SQLiteData
import SwiftUI
import SwiftUINavigation

struct TodayView: View {
    @State var viewModel = TodayViewModel()
    
    @Dependency(\.themeManager) var themeManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: .zero) {
                    // Diary-style daily progress banner
                    if !viewModel.todayHabits.isEmpty {
                        diaryProgressBanner
                            .padding(.horizontal, AppSpacing.medium)
                            .padding(.bottom, AppSpacing.medium)
                    }

                    if viewModel.showMotivationalQuote, let quote = viewModel.currentQuote {
                        MotivationalQuoteView(quote: quote) {
                            viewModel.dismissMotivationalQuote()
                        }
                        .padding(.bottom, AppSpacing.medium)
                        .padding(.horizontal, AppSpacing.medium)
                    }

                    if viewModel.todayHabits.isEmpty {
                        EmptyStateView(
                            icon: "📔",
                            title: "No Habits for Today",
                            subtitle: "You don't have any habits scheduled for today. Create some habits to start writing your story!",
                            buttonTitle: "Add Habit"
                        ) {
                            viewModel.onTapAddHabit()
                        }
                    } else {
                        LazyVGrid(
                            columns: [
                                GridItem(.adaptive(minimum: 80),  alignment: .top)
                            ],
                            spacing: 12
                        ) {
                            ForEach(viewModel.todayHabits, id: \.habit.id) { todayHabit in
                                HabitItemView(
                                    todayHabit: todayHabit
                                ) {
                                    viewModel.onTapHabitItem(todayHabit)
                                }
                                .overlay(alignment: .topLeading) {
                                    if viewModel.isEditing {
                                        Button {
                                            viewModel.showDeleteAlert(todayHabit.habit)
                                        } label: {
                                            Image(systemName: "trash")
                                                .appCircularButtonStyle(overrideColor: .red)
                                        }
                                        .offset(x: -10, y: -10)
                                    }
                                }
                                .alert(
                                    item: $viewModel.route.showDeleteAlert,
                                    title: { habit in
                                        Text(String(localized: "Delete '\(habit.truncatedName)'?"))
                                    },
                                    actions: { habit in
                                        Button("Delete", role: .destructive) {
                                            viewModel.confirmDeleteHabit(habit)
                                        }
                                        Button("Cancel", role: .cancel) {}
                                    },
                                    message: { habit in
                                        Text(String(localized: "This will permanently delete the habit '\(habit.truncatedName)' and all its check-in history. This action cannot be undone. Are you sure you want to proceed?"))
                                    }
                                )
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .padding()
            }
            .sheet(item: $viewModel.route.createHabit, id: \.self) { habitFormViewModel in
                HabitFormView(viewModel: habitFormViewModel)
            }
            .sheet(item: $viewModel.route.addNote) { context in
                CheckInNoteView(
                    checkIn: context.checkIn,
                    habitName: context.habit.name,
                    habitIcon: context.habit.icon
                ) { note in
                    viewModel.saveNoteForCheckIn(context.checkIn, note: note)
                }
            }
            .appBackground()
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        viewModel.onTapEdit()
                    }) {
                        Text(viewModel.isEditing ? "Done" : "Edit")
                            .appRectButtonStyle()
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    DatePicker(
                        "",
                        selection: Binding(
                            get: { viewModel.selectedDate },
                            set: { newDate in
                                withAnimation {
                                    viewModel.selectedDate = newDate
                                }
                            }
                        ),
                        displayedComponents: .date
                    )
                    .environment(\.calendar, viewModel.userCalendar)
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .tint(ThemeManager.shared.current.primaryColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.onTapAddHabit()
                    }) {
                        Image(systemName: "plus")
                            .appCircularButtonStyle()
                    }
                }
            }
            .onAppear {
                viewModel.updateMotivationalQuote()
            }
        }
    }

    private var diaryProgressBanner: some View {
        let completed = viewModel.todayHabits.filter(\.isCompleted).count
        let total = viewModel.todayHabits.count
        let progress = total > 0 ? Double(completed) / Double(total) : 0
        let allDone = completed == total && total > 0

        return HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(allDone ? String(localized: "All done for today! 🎉") : String(localized: "Today's Journal"))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.current.textPrimary)
                Text(String(localized: "\(completed) of \(total) habits recorded"))
                    .font(.caption)
                    .foregroundColor(themeManager.current.textSecondary)
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: allDone ? .green : themeManager.current.primaryColor))
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
                    .padding(.top, 2)
            }
            Spacer()
            ZStack {
                Circle()
                    .fill((allDone ? Color.green : themeManager.current.primaryColor).opacity(0.12))
                    .frame(width: 44, height: 44)
                Text(allDone ? "✅" : "📔")
                    .font(.title3)
            }
        }
        .padding(12)
        .background(themeManager.current.card)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    let _ = prepareDependencies {
        $0.defaultDatabase = try! appDatabase()
    }
    TodayView()
}
