//
//  JournalTimelineView.swift
//  Habit Diary
//
//  Created by Lulin Yang on 2025/6/30.
//

import Dependencies
import SwiftUI

struct JournalTimelineView: View {
    @State private var viewModel = JournalTimelineViewModel()
    @Dependency(\.themeManager) private var themeManager

    private var theme: AppTheme { themeManager.current }

    var body: some View {
        Group {
            if viewModel.checkinHistories.isEmpty {
                emptyState
            } else {
                timelineList
            }
        }
        .background(theme.background.ignoresSafeArea())
        .navigationTitle(String(localized: "Journal Entries"))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Empty

    private var emptyState: some View {
        ScrollView {
            VStack(spacing: AppSpacing.large) {
                JournalAccentPanel(theme: theme, accent: theme.primaryColor) {
                    VStack(spacing: AppSpacing.medium) {
                        JournalSectionHeader(
                            title: String(localized: "Your journal"),
                            subtitle: String(localized: "Every note you’ve logged appears here"),
                            systemImage: "book.pages.fill",
                            theme: theme
                        )
                        Text("📔")
                            .font(.system(size: 48))
                            .frame(maxWidth: .infinity)
                        Text(String(localized: "Nothing logged yet"))
                            .font(.system(.title3, design: .serif))
                            .fontWeight(.semibold)
                            .foregroundStyle(theme.textPrimary)
                            .multilineTextAlignment(.center)
                        Text(
                            String(
                                localized: "Complete a habit on Journal and add a note when prompted — your entries will show up in chronological order."
                            )
                        )
                        .font(AppFont.subheadline)
                        .foregroundStyle(theme.textSecondary)
                        .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, AppSpacing.large)
        }
    }

    // MARK: - Timeline

    private var timelineList: some View {
        List {
            ForEach(viewModel.daySections) { section in
                Section {
                    ForEach(section.entries, id: \.checkIn.id) { entry in
                        JournalEntryRow(entry: entry, theme: theme)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.onTapDeleteCheckin(entry)
                                } label: {
                                    Label(String(localized: "Delete"), systemImage: "trash")
                                }
                            }
                    }
                } header: {
                    sectionHeader(for: section.id)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func sectionHeader(for day: Date) -> some View {
        HStack {
            Text(formattedDayHeader(day))
                .font(.system(.subheadline, design: .serif))
                .fontWeight(.semibold)
                .foregroundStyle(theme.textPrimary)
            Spacer(minLength: 0)
        }
        .textCase(nil)
        .padding(.vertical, 4)
    }

    private func formattedDayHeader(_ day: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(day) { return String(localized: "Today") }
        if cal.isDateInYesterday(day) { return String(localized: "Yesterday") }
        if cal.isDate(day, equalTo: Date(), toGranularity: .year) {
            return day.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
        }
        return day.formatted(
            .dateTime.weekday(.wide).month(.abbreviated).day().year(.defaultDigits)
        )
    }
}

// MARK: - Row

private struct JournalEntryRow: View {
    let entry: JournalEntrySummary
    let theme: AppTheme

    private var habitTint: Color { Color(hex: entry.habitColor) }
    private var noteText: String {
        entry.checkIn.note.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        JournalAccentPanel(theme: theme, accent: habitTint) {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                HStack(alignment: .top, spacing: AppSpacing.smallMedium) {
                    Text(entry.habitIcon)
                        .font(.system(size: 24))
                        .frame(width: 40, height: 40)
                        .background(habitTint.opacity(0.18))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(entry.habitName)
                                .font(.system(.headline, design: .serif))
                                .foregroundStyle(theme.textPrimary)
                                .lineLimit(2)
                            Spacer(minLength: 8)
                            Text(entry.checkIn.date.formatted(date: .omitted, time: .shortened))
                                .font(AppFont.caption)
                                .foregroundStyle(theme.textSecondary)
                                .monospacedDigit()
                        }

                        if !noteText.isEmpty {
                            noteBlock
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabelText)
    }

    private var noteBlock: some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: "pencil.line")
                .font(AppFont.caption)
                .foregroundStyle(habitTint)
                .padding(.top, 2)
            Text(noteText)
                .font(.system(.subheadline, design: .serif))
                .foregroundStyle(theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppSpacing.small)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.surface.opacity(0.55))
        .clipShape(.rect(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(habitTint.opacity(0.2), lineWidth: 1)
        }
    }

    private var accessibilityLabelText: String {
        var parts: [String] = [
            entry.habitName,
            entry.checkIn.date.formatted(date: .abbreviated, time: .shortened)
        ]
        if !noteText.isEmpty {
            parts.append(noteText)
        }
        return parts.joined(separator: ". ")
    }
}
