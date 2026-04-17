//
// Created by Banghua Zhao on 03/06/2025
// Copyright Apps Bay Limited. All rights reserved.
//

import SQLiteData
import SwiftUI
import SwiftUINavigation

struct JournalHomeView: View {
    @State var viewModel = JournalHomeViewModel()
    
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
                        DailyReflectionCard(quote: quote) {
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
                                HabitTile(
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
                HabitEditorView(viewModel: habitFormViewModel)
            }
            .sheet(item: $viewModel.route.addNote) { context in
                DiaryEntryEditor(
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
                ToolbarItem(placement: .topBarLeading) {
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
                
                ToolbarItem(placement: .topBarTrailing) {
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
        let total     = viewModel.todayHabits.count
        let progress  = total > 0 ? Double(completed) / Double(total) : 0
        let allDone   = completed == total && total > 0
        let primary   = themeManager.current.primaryColor

        return VStack(spacing: 0) {
            // ── Diary entry header ──────────────────────────────
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    // Day name — large, like a chapter heading
                    Text(viewModel.selectedDate, format: .dateTime.weekday(.wide))
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundStyle(primary)

                    // Full date — subtitle line
                    Text(viewModel.selectedDate, format: .dateTime.month(.wide).day().year())
                        .font(.system(size: 13, weight: .regular, design: .serif))
                        .foregroundStyle(themeManager.current.textSecondary)
                        .italic()
                }
                Spacer()
                // Bookmark-style completion badge
                VStack(spacing: 2) {
                    Text(allDone ? "✅" : "📔")
                        .font(.title2)
                    Text("\(completed)/\(total)")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(allDone ? .green : primary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)

            // ── Ruled-line progress bar ──────────────────────────
            VStack(spacing: 6) {
                // Notebook-rule divider
                Rectangle()
                    .fill(primary.opacity(0.18))
                    .frame(height: 1)

                HStack {
                    Text(allDone
                         ? String(localized: "Today's entry is complete! 🎉")
                         : String(localized: "\(completed) of \(total) habits written today"))
                        .font(.caption)
                        .foregroundStyle(allDone ? .green : themeManager.current.textSecondary)
                    Spacer()
                    Text(String(format: "%.0f%%", progress * 100))
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(allDone ? .green : primary)
                }
                .padding(.horizontal, 16)

                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(
                        tint: allDone ? .green : primary
                    ))
                    .scaleEffect(x: 1, y: 1.8, anchor: .center)
                    .padding(.horizontal, 16)
            }
            .padding(.bottom, 12)
        }
        .background(themeManager.current.card)
        .clipShape(.rect(cornerRadius: 14))
        .overlay(
            // Left accent border — like a notebook margin rule
            RoundedRectangle(cornerRadius: 14)
                .fill(primary)
                .frame(width: 4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .clipShape(.rect(cornerRadius: 14))
        )
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
    }
}

#Preview {
    let _ = prepareDependencies {
        $0.defaultDatabase = try! appDatabase()
    }
    JournalHomeView()
}
