//
// Created by Banghua Zhao on 31/05/2025
// Copyright Apps Bay Limited. All rights reserved.
//

import SwiftUI
import SwiftUINavigation

struct HabitLibraryView: View {
    @State var viewModel = HabitLibraryViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    if viewModel.filteredHabits.isEmpty {
                        EmptyStateView(
                            icon: "📚",
                            title: String(localized: "Your shelf is empty"),
                            subtitle: String(
                                localized: "Add habits you want to track — they’ll appear here like titles on a shelf."
                            ),
                            buttonTitle: String(localized: "Add a habit")
                        ) {
                            viewModel.onTapCreateHabit()
                        }
                    } else {
                        ForEach(viewModel.filteredHabits) { habit in
                            HabitCard(
                                habit: habit,
                                onEdit: { viewModel.onTapEditHabit(habit) },
                                onDelete: { viewModel.confirmDeleteHabit(habit) },
                                onToggleFavorite: { viewModel.toggleFavorite(habit) },
                                onToggleArchive: { viewModel.toggleArchive(habit) }
                            )
                            .padding(.horizontal)
                            .contentShape(.rect)
                            .onTapGesture {
                                viewModel.onTapHabitItem(habit)
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            .appBackground()
            .navigationTitle(String(localized: "Library"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Section(String(localized: "Sort by")) {
                            ForEach(HabitLibraryViewModel.SortOption.allCases, id: \.self) { option in
                                Button(action: {
                                    viewModel.selectSortOption(option)
                                }) {
                                    HStack {
                                        Text(option.displayName)
                                        if viewModel.selectedSortOption == option {
                                            Spacer()
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }

                        Section(String(localized: "Filter by")) {
                            ForEach(HabitLibraryViewModel.FilterOption.allCases, id: \.self) { option in
                                Button(action: {
                                    viewModel.selectFilterOption(option)
                                }) {
                                    HStack {
                                        Text(option.displayName)
                                        if viewModel.selectedFilterOption == option {
                                            Spacer()
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }

                        if viewModel.selectedFilterOption != .all || viewModel.selectedSortOption != .default {
                            Divider()
                            Button(String(localized: "Reset to default")) {
                                viewModel.selectSortOption(.default)
                                viewModel.selectFilterOption(.all)
                            }
                        }
                    } label: {
                        Image(
                            systemName: viewModel.selectedFilterOption != .all
                                || viewModel.selectedSortOption != .default
                                ? "line.3.horizontal.decrease.circle.fill"
                                : "line.3.horizontal.decrease.circle"
                        )
                        .appCircularButtonStyle()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        viewModel.onTapCreateHabit()
                    }) {
                        Image(systemName: "plus")
                            .appCircularButtonStyle()
                    }
                }
            }
            .sheet(item: $viewModel.route.createHabit, id: \.self) { habitFormViewModel in
                HabitEditorView(viewModel: habitFormViewModel)
            }
            .sheet(item: $viewModel.route.editHabit, id: \.self) { habitFormViewModel in
                HabitEditorView(viewModel: habitFormViewModel)
            }
            .navigationDestination(item: $viewModel.route.habitDetail) { habitDetailViewModel in
                HabitPageView(viewModel: habitDetailViewModel)
            }
        }
    }
}
