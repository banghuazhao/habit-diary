import Dependencies
import Observation
import Sharing
import SwiftUI
import SwiftUINavigation

struct HabitPageView: View {
    @State var viewModel: HabitPageViewModel
    @Dependency(\.themeManager) private var themeManager
    @Environment(\.dismiss) private var dismiss

    private var theme: AppTheme { themeManager.current }
    private var habitTint: Color { Color(hex: viewModel.habit.color) }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.large) {
                heroSection
                if !viewModel.habit.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    habitDescriptionPanel
                }
                calendarPanel
                if !viewModel.checkInsWithNotes.isEmpty {
                    diaryEntriesPanel
                }
                optionsPanel
                if !viewModel.reminders.isEmpty {
                    remindersPanel
                }
                if !viewModel.habitAchievements.isEmpty {
                    badgesPanel
                }
            }
            .padding(.horizontal)
            .padding(.vertical, AppSpacing.small)
        }
        .background(theme.background.ignoresSafeArea())
        .navigationTitle(viewModel.habit.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    viewModel.onTapDeleteHabit()
                } label: {
                    Image(systemName: "trash")
                        .appCircularButtonStyle(overrideColor: .red)
                }
                .accessibilityLabel(String(localized: "Delete habit"))

                Button {
                    viewModel.onTapEditHabit()
                } label: {
                    Image(systemName: "pencil")
                        .appCircularButtonStyle()
                }
                .accessibilityLabel(String(localized: "Edit habit"))
            }
        }
        .sheet(item: $viewModel.route.editHabit, id: \.self) { habitFormViewModel in
            HabitEditorView(viewModel: habitFormViewModel)
        }
        .sheet(isPresented: Binding($viewModel.route.editReminder)) {
            if case .editReminder(let formViewModel) = viewModel.route {
                ReminderEditorView(viewModel: formViewModel)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                    .presentationBackgroundInteraction(.enabled)
            }
        }
        .sheet(item: $viewModel.route.showAchievement) { achievement in
            BadgeUnlockedPopup(
                achievement: achievement,
                isPresented: Binding(
                    get: { viewModel.route.showAchievement != nil },
                    set: { if !$0 { viewModel.route = nil } }
                )
            )
        }
        .alert(
            String(localized: "Delete “\(viewModel.habit.truncatedName)”?"),
            isPresented: Binding($viewModel.route.deleteAlert)
        ) {
            Button(String(localized: "Delete"), role: .destructive) {
                viewModel.deleteHabit()
                dismiss()
            }
            Button(String(localized: "Cancel"), role: .cancel) {}
        } message: {
            Text(
                String(
                    localized: "This permanently removes this habit and its journal entries. You can’t undo this."
                )
            )
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        JournalAccentPanel(theme: theme, accent: habitTint) {
            VStack(spacing: AppSpacing.smallMedium) {
                JournalSectionHeader(
                    title: String(localized: "Habit"),
                    subtitle: String(localized: "Preview"),
                    systemImage: "leaf.fill",
                    theme: theme
                )
                HabitTile(todayHabit: viewModel.todayHabit, onTap: {})
                    .frame(maxWidth: 220)
                    .frame(maxWidth: .infinity)
                    .opacity(viewModel.habit.isArchived ? 0.65 : 1)
                if viewModel.habit.isArchived {
                    Text(String(localized: "Archived — hidden from Journal until unarchived."))
                        .font(AppFont.caption)
                        .foregroundStyle(theme.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }

    // MARK: - Description

    private var habitDescriptionPanel: some View {
        JournalAccentPanel(theme: theme, accent: habitTint) {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                JournalSectionHeader(
                    title: String(localized: "About this habit"),
                    subtitle: String(localized: "From your habit note"),
                    systemImage: "text.alignleft",
                    theme: theme
                )
                HabitNoteContent(note: viewModel.habit.note, theme: theme, accent: habitTint)
            }
        }
    }

    // MARK: - Calendar

    private var calendarPanel: some View {
        JournalAccentPanel(theme: theme, accent: habitTint) {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                JournalSectionHeader(
                    title: String(localized: "Calendar"),
                    subtitle: String(localized: "Tap a day to log or remove an entry"),
                    systemImage: "calendar",
                    theme: theme
                )

                Picker(String(localized: "View"), selection: $viewModel.calendarMode) {
                    ForEach(HabitPageViewModel.CalendarMode.allCases) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                if viewModel.calendarMode == .monthly {
                    monthlyCalendarContent
                } else {
                    yearlyCalendarContent
                }
            }
        }
    }

    private var monthlyCalendarContent: some View {
        VStack(spacing: AppSpacing.medium) {
            HStack {
                Button(action: { viewModel.previousMonth() }) {
                    Label(String(localized: "Previous"), systemImage: "chevron.left")
                        .font(AppFont.subheadline.weight(.semibold))
                }
                .tint(theme.primaryColor)
                Spacer()
                Text(viewModel.monthTitle)
                    .font(.system(.headline, design: .serif))
                Spacer()
                Button(action: { viewModel.nextMonth() }) {
                    Label(String(localized: "Next"), systemImage: "chevron.right")
                        .labelStyle(.titleAndIcon)
                        .font(AppFont.subheadline.weight(.semibold))
                }
                .tint(theme.primaryColor)
            }

            HStack {
                ForEach(viewModel.weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(AppFont.caption)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(theme.textSecondary)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(viewModel.calendarDays, id: \.self) { day in
                    CalendarDayCell(
                        day: day,
                        isToday: viewModel.isToday(day: day),
                        isChecked: viewModel.isChecked(day: day),
                        isCurrentMonth: viewModel.isCurrentMonth(day: day),
                        theme: theme,
                        accent: habitTint
                    )
                    .onTapGesture {
                        viewModel.toggleCheckIn(for: day)
                    }
                }
            }
            .opacity(viewModel.habit.isArchived ? 0.6 : 1)
            .disabled(viewModel.habit.isArchived)
        }
    }

    private var yearlyCalendarContent: some View {
        VStack(spacing: AppSpacing.medium) {
            HStack {
                Button(action: { viewModel.previousYear() }) {
                    Label(String(localized: "Previous"), systemImage: "chevron.left")
                        .font(AppFont.subheadline.weight(.semibold))
                }
                .tint(theme.primaryColor)
                Spacer()
                Text(verbatim: "\(viewModel.selectedYear)")
                    .font(.system(.headline, design: .serif))
                Spacer()
                Button(action: { viewModel.nextYear() }) {
                    Label(String(localized: "Next"), systemImage: "chevron.right")
                        .font(AppFont.subheadline.weight(.semibold))
                }
                .tint(theme.primaryColor)
            }
            YearlyCalendarGrid(
                year: viewModel.selectedYear,
                checkInsByMonth: viewModel.yearlyCheckIns(for: viewModel.selectedYear),
                calendar: viewModel.userCalendar,
                theme: theme,
                accent: habitTint
            )
            .opacity(viewModel.habit.isArchived ? 0.6 : 1)
            .disabled(viewModel.habit.isArchived)
        }
    }

    // MARK: - Diary entries (notes on check-ins)

    private var diaryEntriesPanel: some View {
        JournalAccentPanel(theme: theme, accent: habitTint) {
            VStack(alignment: .leading, spacing: AppSpacing.smallMedium) {
                HStack {
                    JournalSectionHeader(
                        title: String(localized: "Entry notes"),
                        subtitle: String(localized: "Text you added when logging"),
                        systemImage: "pencil.line",
                        theme: theme
                    )
                    Spacer(minLength: 0)
                    Text("\(viewModel.checkInsWithNotes.count)")
                        .font(AppFont.caption.weight(.bold))
                        .foregroundStyle(theme.primaryColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(theme.primaryColor.opacity(0.12))
                        .clipShape(.capsule)
                }

                VStack(spacing: AppSpacing.small) {
                    ForEach(viewModel.checkInsWithNotes.prefix(5), id: \.id) { entry in
                        HStack(alignment: .top, spacing: AppSpacing.smallMedium) {
                            VStack(spacing: 2) {
                                Text(entry.date.formatted(.dateTime.month(.abbreviated).day()))
                                    .font(AppFont.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(habitTint)
                                Text(entry.date.formatted(.dateTime.year()))
                                    .font(AppFont.footnote)
                                    .foregroundStyle(theme.textSecondary)
                            }
                            .frame(width: 44)

                            Text(entry.note)
                                .font(.system(.subheadline, design: .serif))
                                .foregroundStyle(theme.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: 0)
                        }
                        .padding(AppSpacing.smallMedium)
                        .background(theme.surface.opacity(0.65))
                        .clipShape(.rect(cornerRadius: 12))
                    }

                    if viewModel.checkInsWithNotes.count > 5 {
                        Text(
                            String(
                                localized: "and \(viewModel.checkInsWithNotes.count - 5) more…"
                            )
                        )
                        .font(AppFont.caption)
                        .foregroundStyle(theme.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
        }
    }

    // MARK: - Options

    private var optionsPanel: some View {
        JournalAccentPanel(theme: theme, accent: habitTint) {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                JournalSectionHeader(
                    title: String(localized: "Options"),
                    subtitle: String(localized: "Ordering and visibility"),
                    systemImage: "slider.horizontal.3",
                    theme: theme
                )
                FavoriteToggleWithInfo(isOn: $viewModel.habit.isFavorite, theme: theme)
                Divider().opacity(0.35)
                ArchivedToggleWithInfo(isOn: $viewModel.habit.isArchived, theme: theme)
            }
        }
    }

    private var remindersPanel: some View {
        JournalAccentPanel(theme: theme, accent: habitTint) {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                JournalSectionHeader(
                    title: String(localized: "Reminders"),
                    subtitle: String(localized: "Scheduled nudges"),
                    systemImage: "bell.badge.fill",
                    theme: theme
                )
                VStack(spacing: AppSpacing.small) {
                    ForEach(viewModel.reminders, id: \.id) { reminder in
                        ReminderCell(
                            time: reminder.time,
                            title: String(localized: "Every day"),
                            onDelete: { viewModel.onTapDeleteReminder(reminder) }
                        )
                        .onTapGesture { viewModel.onTapEditReminder(reminder) }
                    }
                }
            }
        }
    }

    private var badgesPanel: some View {
        JournalAccentPanel(theme: theme, accent: habitTint) {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                JournalSectionHeader(
                    title: String(localized: "Badges"),
                    subtitle: String(localized: "Earned for this habit"),
                    systemImage: "rosette",
                    theme: theme
                )
                VStack(spacing: AppSpacing.small) {
                    ForEach(viewModel.habitAchievements, id: \.id) { badge in
                        HabitBadgeRowView(achievement: badge, accent: habitTint)
                            .onTapGesture { viewModel.onTapAchievement(badge) }
                    }
                }
            }
        }
    }
}

// MARK: - Note (habit description)

private struct HabitNoteContent: View {
    let note: String
    let theme: AppTheme
    let accent: Color
    @State private var expanded = false

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.smallMedium) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [accent.opacity(0.55), accent.opacity(0.2)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 3)
                .clipShape(.rect(cornerRadius: 1.5))

            VStack(alignment: .leading, spacing: 6) {
                Text(note)
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(theme.textPrimary)
                    .lineLimit(expanded ? nil : 4)

                if note.count > 160 {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { expanded.toggle() }
                    } label: {
                        Text(expanded ? String(localized: "Show less") : String(localized: "Show more"))
                            .font(AppFont.footnote.weight(.semibold))
                            .foregroundStyle(theme.primaryColor)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(AppSpacing.smallMedium)
        .background(theme.surface.opacity(0.45))
        .clipShape(.rect(cornerRadius: AppCornerRadius.info))
    }
}

// MARK: - Calendar cells

struct CalendarDayCell: View {
    let day: Date?
    let isToday: Bool
    let isChecked: Bool
    let isCurrentMonth: Bool
    let theme: AppTheme
    var accent: Color

    var body: some View {
        Group {
            if let day {
                ZStack {
                    Circle()
                        .fill(isChecked ? accent : Color.clear)
                        .overlay(
                            Circle()
                                .strokeBorder(accent, lineWidth: isToday ? 2 : (isChecked ? 0 : 1))
                                .opacity(isChecked ? 1 : (isCurrentMonth ? 0.35 : 0.2))
                        )
                        .frame(width: 32, height: 32)

                    Text("\(Calendar.current.component(.day, from: day))")
                        .font(AppFont.body)
                        .foregroundStyle(
                            isCurrentMonth
                                ? (isChecked ? Color.white : theme.textPrimary)
                                : theme.textSecondary
                        )
                }
                .frame(maxWidth: .infinity, minHeight: 36)
            } else {
                Text("")
                    .frame(maxWidth: .infinity, minHeight: 36)
            }
        }
    }
}

struct YearlyCalendarGrid: View {
    let year: Int
    let checkInsByMonth: [Int: Set<Int>]
    let calendar: Calendar
    let theme: AppTheme
    var accent: Color

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.fixed(30))] + Array(repeating: GridItem(.flexible(minimum: 8, maximum: 20), spacing: 2), count: 31),
            spacing: 10
        ) {
            ForEach(1 ... 12, id: \.self) { month in
                Text(shortMonthName(for: month))
                    .font(AppFont.caption)
                    .frame(width: 30, alignment: .trailing)
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)

                ForEach(1 ... 31, id: \.self) { day in
                    if day <= daysCount(for: month) {
                        Circle()
                            .fill(checkInsByMonth[month]?.contains(day) == true ? accent : theme.secondaryGray.opacity(0.15))
                    } else {
                        Color.clear
                    }
                }
            }
        }
    }

    func daysCount(for month: Int) -> Int {
        let comps = DateComponents(year: year, month: month)
        return calendar.range(of: .day, in: .month, for: calendar.date(from: comps)!)?.count ?? 30
    }

    func shortMonthName(for month: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.shortMonthSymbols[month - 1]
    }
}

// MARK: - Toggles

private struct FavoriteToggleWithInfo: View {
    @Binding var isOn: Bool
    let theme: AppTheme
    @State private var showInfo = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Toggle(isOn: $isOn) {
                HStack {
                    Label(String(localized: "Favorite"), systemImage: isOn ? "heart.fill" : "heart")
                    Button { withAnimation { showInfo.toggle() } } label: {
                        Image(systemName: "info.circle")
                    }
                    .foregroundStyle(theme.textSecondary)
                    .buttonStyle(.plain)
                }
            }
            .tint(theme.primaryColor)
            if showInfo {
                Text(String(localized: "Favorites appear first on your Journal list."))
                    .font(AppFont.caption)
                    .foregroundStyle(theme.textSecondary)
                    .padding(AppSpacing.small)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(theme.surface.opacity(0.6))
                    .clipShape(.rect(cornerRadius: 8))
                    .onTapGesture { showInfo = false }
            }
        }
    }
}

private struct ArchivedToggleWithInfo: View {
    @Binding var isOn: Bool
    let theme: AppTheme
    @State private var showInfo = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Toggle(isOn: $isOn) {
                HStack {
                    Label(String(localized: "Archived"), systemImage: isOn ? "archivebox.fill" : "archivebox")
                    Button { withAnimation { showInfo.toggle() } } label: {
                        Image(systemName: "info.circle")
                    }
                    .foregroundStyle(theme.textSecondary)
                    .buttonStyle(.plain)
                }
            }
            .tint(theme.primaryColor)
            if showInfo {
                Text(String(localized: "Archived habits stay out of Journal; your entries are kept."))
                    .font(AppFont.caption)
                    .foregroundStyle(theme.textSecondary)
                    .padding(AppSpacing.small)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(theme.surface.opacity(0.6))
                    .clipShape(.rect(cornerRadius: 8))
                    .onTapGesture { showInfo = false }
            }
        }
    }
}

struct HabitBadgeRowView: View {
    let achievement: Badge
    let accent: Color
    @Dependency(\.themeManager) private var themeManager

    private var theme: AppTheme { themeManager.current }

    var body: some View {
        HStack(alignment: .center, spacing: AppSpacing.smallMedium) {
            ZStack {
                Circle()
                    .fill(accent.opacity(0.2))
                    .frame(width: 44, height: 44)
                Text(achievement.icon)
                    .font(.title3)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(AppFont.subheadline.weight(.semibold))
                    .foregroundStyle(theme.textPrimary)
                Text(achievement.description)
                    .font(AppFont.caption)
                    .foregroundStyle(theme.textSecondary)
                    .lineLimit(2)
                if let unlockDate = achievement.unlockedDate {
                    Text(unlockDate.formatted(date: .abbreviated, time: .omitted))
                        .font(AppFont.footnote)
                        .foregroundStyle(theme.primaryColor)
                }
            }

            Spacer(minLength: 8)

            ShareLink(
                item: createAchievementShareText(achievement),
                subject: Text(String(localized: "Badge unlocked")),
                message: Text(String(localized: "From Habit Diary"))
            ) {
                Image(systemName: "square.and.arrow.up.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .font(.title3)
                    .foregroundStyle(theme.primaryColor)
            }

            Image(systemName: "chevron.right")
                .font(AppFont.caption.weight(.semibold))
                .foregroundStyle(theme.textSecondary.opacity(0.8))
        }
        .padding(AppSpacing.smallMedium)
        .background {
            if #available(iOS 26, *) {
                Color.clear
                    .glassEffect(in: .rect(cornerRadius: AppCornerRadius.info))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: AppCornerRadius.info)
                        .fill(theme.card)
                    RoundedRectangle(cornerRadius: AppCornerRadius.info)
                        .strokeBorder(accent.opacity(0.2), lineWidth: 1)
                }
            }
        }
    }

    func createAchievementShareText(_ achievement: Badge) -> String {
        let appStoreURL = "https://apps.apple.com/app/id\(Constants.AppID.appID)"
        var shareText = String(localized: "🎉 Badge unlocked\n\n")
        shareText += "\(achievement.title)\n"
        shareText += "\(achievement.description)\n\n"
        if let unlockDate = achievement.unlockedDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            shareText += String(localized: "Unlocked \(formatter.string(from: unlockDate))\n\n")
        }
        shareText += String(localized: "Habit Diary — \(appStoreURL)")
        return shareText
    }
}

#Preview {
    let _ = prepareDependencies {
        $0.defaultDatabase = try! appDatabase()
    }
    NavigationStack {
        HabitPageView(
            viewModel: HabitPageViewModel(
                habit: DiaryHabitLibrary.morningWalk.toMock
            )
        )
    }
}
