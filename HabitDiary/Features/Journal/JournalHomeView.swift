//
// Created by Banghua Zhao on 03/06/2025
// Copyright Apps Bay Limited. All rights reserved.
//

import Dependencies
import SQLiteData
import SwiftUI
import SwiftUINavigation

struct JournalHomeView: View {
    @State var viewModel = JournalHomeViewModel()

    @Dependency(\.themeManager) var themeManager

    private var theme: AppTheme { themeManager.current }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: .zero) {
                    // Diary-style daily progress banner
                    if !viewModel.todayHabits.isEmpty {
                        diaryProgressBanner
                            .padding(.bottom, AppSpacing.medium)
                    }

                    if viewModel.showMotivationalQuote, let quote = viewModel.currentQuote {
                        DailyReflectionCard(quote: quote) {
                            viewModel.dismissMotivationalQuote()
                        }
                        .padding(.bottom, AppSpacing.medium)
                    }

                    if viewModel.todayHabits.isEmpty {
                        EmptyStateView(
                            icon: "📔",
                            title: String(localized: "Nothing scheduled today"),
                            subtitle: String(
                                localized: "You don’t have habits for this day yet. Add habits from Library to fill your journal."
                            ),
                            buttonTitle: String(localized: "Add habit")
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
                                        Button(String(localized: "Delete"), role: .destructive) {
                                            viewModel.confirmDeleteHabit(habit)
                                        }
                                        Button(String(localized: "Cancel"), role: .cancel) {}
                                    },
                                    message: { habit in
                                        Text(
                                            String(
                                                localized: "This permanently deletes “\(habit.truncatedName)” and its journal entries. You can’t undo this."
                                            )
                                        )
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
            .navigationTitle(String(localized: "Today"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        viewModel.onTapEdit()
                    }) {
                        Text(
                            viewModel.isEditing
                                ? String(localized: "Done")
                                : String(localized: "Edit")
                        )
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
                    .tint(theme.primaryColor)
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
        let total = viewModel.todayHabits.count
        let progress = total > 0 ? Double(completed) / Double(total) : 0
        let allDone = completed == total && total > 0
        let primary = theme.primaryColor
        let success = theme.success

        return JournalAccentPanel(theme: theme, accent: primary) {
            VStack(spacing: 0) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.selectedDate, format: .dateTime.weekday(.wide))
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundStyle(primary)

                        Text(viewModel.selectedDate, format: .dateTime.month(.wide).day().year())
                            .font(.system(size: 13, weight: .regular, design: .serif))
                            .foregroundStyle(theme.textSecondary)
                            .italic()
                    }
                    Spacer()
                    VStack(spacing: 2) {
                        Text(allDone ? "✅" : "📔")
                            .font(.title2)
                        Text("\(completed)/\(total)")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(allDone ? success : primary)
                    }
                }
                .padding(.bottom, 10)

                VStack(spacing: 6) {
                    Rectangle()
                        .fill(primary.opacity(0.18))
                        .frame(height: 1)

                    HStack {
                        Text(
                            allDone
                                ? String(localized: "Today's entry is complete! 🎉")
                                : String(localized: "\(completed) of \(total) habits written today")
                        )
                        .font(.caption)
                        .foregroundStyle(allDone ? success : theme.textSecondary)
                        Spacer()
                        Text(String(format: "%.0f%%", progress * 100))
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(allDone ? success : primary)
                    }

                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle(
                            tint: allDone ? success : primary
                        ))
                        .scaleEffect(x: 1, y: 1.8, anchor: .center)
                }
            }
        }
        .shadow(color: AppShadow.card.color, radius: AppShadow.card.radius, x: AppShadow.card.x, y: AppShadow.card.y)
    }
}

#Preview {
    let _ = prepareDependencies {
        $0.defaultDatabase = try! appDatabase()
    }
    JournalHomeView()
}
