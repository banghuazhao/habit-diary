//
// Created by Banghua Zhao on 21/06/2025
// Copyright Apps Bay Limited. All rights reserved.
//

import Dependencies
import MoreApps
import SQLiteData
import SwiftUI

struct ReaderProfileView: View {
    @Environment(\.openURL) private var openURL
    @Dependency(\.premiumAccessManager) var premiumAccessManager
    @Dependency(\.themeManager) var themeManager
    @ObservationIgnored
    @FetchAll(Habit.all, animation: .default) var allHabits
    @ObservationIgnored
    @FetchAll(DiaryEntry.all, animation: .default) var allCheckIns
    @ObservationIgnored
    @FetchAll(Reminder.all, animation: .default) var allReminders
    @ObservationIgnored
    @FetchAll(Badge.all, animation: .default) var allAchievements
    @AppStorage("userName") private var userName: String = String(localized: "Your Name")
    @AppStorage("userAvatar") private var userAvatar: String = "😀"
    @State private var showPurchaseSheet = false
    @State private var showEmojiPicker = false

    private var theme: AppTheme { themeManager.current }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.large) {
                    JournalAccentPanel(theme: theme, accent: theme.primaryColor) {
                        VStack(alignment: .leading, spacing: AppSpacing.medium) {
                            readerIdentitySection
                            if !premiumAccessManager.isPremiumUserPurchased {
                                Button(action: {
                                    showPurchaseSheet = true
                                }) {
                                    Text(String(localized: "Upgrade to Premium"))
                                        .appButtonStyle(theme: themeManager.current)
                                }
                            } else {
                                HStack(spacing: 8) {
                                    Image(systemName: "crown.fill")
                                        .foregroundStyle(.yellow)
                                        .font(.title3)
                                    Text(String(localized: "Welcome, Premium user!"))
                                        .font(.headline)
                                        .foregroundStyle(themeManager.current.primaryColor)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(themeManager.current.card)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppCornerRadius.button)
                                        .stroke(themeManager.current.primaryColor, lineWidth: 1.5)
                                )
                                .clipShape(.rect(cornerRadius: AppCornerRadius.button))
                                .shadow(color: AppShadow.card.color, radius: 4, x: 0, y: 2)
                            }
                        }
                    }
                    .padding(.horizontal)

                    journalToolsSection
                    discoverAndShareSection

                    Spacer().frame(height: AppSpacing.small)

                    profileFooter
                        .padding(.bottom, 20)

                    if !premiumAccessManager.isPremiumUserPurchased {
                        BannerView()
                            .frame(height: 50)
                    }
                }
                .padding(.bottom, 20)
            }
            .sheet(isPresented: $showPurchaseSheet) {
                PremiumUpgradeSheet()
            }
            .background(themeManager.current.background)
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle(String(localized: "Profile"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    /// Journal-style identity header + 2×2 stat tiles (replaces flat HStack + Dividers).
    private var readerIdentitySection: some View {
        let theme = themeManager.current
        let activeHabits = allHabits.filter { !$0.isArchived }.count
        let totalHabits = allHabits.count
        let unlockedBadges = allAchievements.filter { $0.isUnlocked }.count
        let totalBadges = allAchievements.count

        return VStack(alignment: .leading, spacing: AppSpacing.medium) {
            HStack(alignment: .center, spacing: AppSpacing.medium) {
                Button(action: { showEmojiPicker = true }) {
                    ZStack {
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [theme.primaryColor, theme.primaryColor.opacity(0.35)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                        Text(userAvatar)
                            .font(.system(size: 44))
                    }
                    .frame(width: 76, height: 76)
                    .background(theme.surface.opacity(0.9))
                    .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(String(localized: "Change avatar"))
                .sheet(isPresented: $showEmojiPicker) {
                    IconEmojiPicker(selectedEmoji: $userAvatar, title: String(localized: "Choose your avatar"))
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(String(localized: "Reader"))
                        .font(AppFont.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(theme.textSecondary)
                        .textCase(.uppercase)
                        .tracking(0.8)

                    TextField(String(localized: "Your Name"), text: $userName)
                        .font(.system(.title3, design: .serif))
                        .fontWeight(.semibold)
                        .foregroundStyle(theme.textPrimary)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(theme.background.opacity(0.85))
                        .clipShape(.rect(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(theme.textSecondary.opacity(0.15), lineWidth: 1)
                        )
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            }

            Text(String(localized: "At a glance"))
                .font(AppFont.subheadline.weight(.semibold))
                .foregroundStyle(theme.textSecondary)
                .padding(.top, AppSpacing.small)

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: AppSpacing.smallMedium), GridItem(.flexible(), spacing: AppSpacing.smallMedium)],
                spacing: AppSpacing.smallMedium
            ) {
                profileStatTile(
                    icon: "books.vertical.fill",
                    title: String(localized: "Habits"),
                    value: "\(activeHabits)/\(totalHabits)"
                )
                profileStatTile(
                    icon: "pencil.line",
                    title: String(localized: "Entries"),
                    value: "\(allCheckIns.count)"
                )
                profileStatTile(
                    icon: "bell.fill",
                    title: String(localized: "Reminders"),
                    value: "\(allReminders.count)"
                )
                profileStatTile(
                    icon: "rosette",
                    title: String(localized: "Badges"),
                    value: "\(unlockedBadges)/\(totalBadges)"
                )
            }
        }
    }

    private func profileStatTile(icon: String, title: String, value: String) -> some View {
        let theme = themeManager.current
        return HStack {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(theme.primaryColor)
                    .frame(width: 32, height: 32)
                    .background(theme.primaryColor.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 8))

                Text(title)
                    .font(AppFont.caption)
                    .foregroundStyle(theme.textSecondary)
                    .lineLimit(1)
            }
            Spacer()
            Text(value)
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(theme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.smallMedium)
        .background {
            if #available(iOS 26, *) {
                Color.clear
                    .glassEffect(in: .rect(cornerRadius: AppCornerRadius.info))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: AppCornerRadius.info)
                        .fill(theme.surface.opacity(0.7))
                    RoundedRectangle(cornerRadius: AppCornerRadius.info)
                        .strokeBorder(theme.textSecondary.opacity(0.1), lineWidth: 1)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(value)")
    }

    /// In-app tools as a vertical “table of contents” (not a 3×N icon grid).
    private var journalToolsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.smallMedium) {
            profileSectionChrome(
                title: String(localized: "Journal tools"),
                subtitle: String(localized: "Shortcuts inside Habit Diary"),
                systemImage: "rectangle.and.pencil.and.ellipsis"
            )

            VStack(spacing: AppSpacing.small) {
                NavigationLink {
                    DiarySettingsView()
                } label: {
                    ProfileShelfRow(
                        theme: themeManager.current,
                        icon: "gearshape.fill",
                        title: String(localized: "Settings"),
                        subtitle: String(localized: "Diary behavior & appearance"),
                        trailing: .chevron
                    )
                }
                .buttonStyle(.plain)

                NavigationLink {
                    JournalTimelineView()
                } label: {
                    ProfileShelfRow(
                        theme: themeManager.current,
                        icon: "book.pages.fill",
                        title: String(localized: "Journal Entries"),
                        subtitle: String(localized: "Every note you’ve logged"),
                        trailing: .chevron
                    )
                }
                .buttonStyle(.plain)

                NavigationLink {
                    DiaryRemindersView()
                } label: {
                    ProfileShelfRow(
                        theme: themeManager.current,
                        icon: "bell.badge.fill",
                        title: String(localized: "Reminders"),
                        subtitle: String(localized: "Nudges for your habits"),
                        trailing: .chevron
                    )
                }
                .buttonStyle(.plain)

                NavigationLink {
                    BadgesView()
                } label: {
                    ProfileShelfRow(
                        theme: themeManager.current,
                        icon: "rosette",
                        title: String(localized: "Badges"),
                        subtitle: String(localized: "Milestones & rewards"),
                        trailing: .chevron
                    )
                }
                .buttonStyle(.plain)

                NavigationLink {
                    PaletteView()
                } label: {
                    ProfileShelfRow(
                        theme: themeManager.current,
                        icon: "paintpalette.fill",
                        title: String(localized: "Ink & paper"),
                        subtitle: String(localized: "Theme and accent colors"),
                        trailing: .chevron
                    )
                }
                .buttonStyle(.plain)

                NavigationLink {
                    JournalStatsView()
                } label: {
                    ProfileShelfRow(
                        theme: themeManager.current,
                        icon: "chart.xyaxis.line",
                        title: String(localized: "My Stats"),
                        subtitle: String(localized: "Totals and streaks at a glance"),
                        trailing: .chevron
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }

    /// App Store / social actions — same row language, different trailing icons.
    private var discoverAndShareSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.smallMedium) {
            profileSectionChrome(
                title: String(localized: "Beyond the page"),
                subtitle: String(localized: "Reviews, mail, and sharing"),
                systemImage: "sparkles"
            )

            VStack(spacing: AppSpacing.small) {
                NavigationLink {
                    MoreAppsView()
                } label: {
                    ProfileShelfRow(
                        theme: themeManager.current,
                        icon: "square.grid.2x2.fill",
                        title: String(localized: "More Apps"),
                        subtitle: String(localized: "Other titles from the studio"),
                        trailing: .chevron
                    )
                }
                .buttonStyle(.plain)

                if let url = URL(string: "https://itunes.apple.com/app/id\(Constants.AppID.appID)?action=write-review") {
                    Button {
                        openURL(url)
                    } label: {
                        ProfileShelfRow(
                            theme: themeManager.current,
                            icon: "star.circle.fill",
                            title: String(localized: "Rate on the App Store"),
                            subtitle: String(localized: "Opens App Store review"),
                            trailing: .external
                        )
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    SupportEmail().send(openURL: openURL)
                } label: {
                    ProfileShelfRow(
                        theme: themeManager.current,
                        icon: "envelope.open.fill",
                        title: String(localized: "Send feedback"),
                        subtitle: String(localized: "Email the developer"),
                        trailing: .external
                    )
                }
                .buttonStyle(.plain)

                if let appURL = URL(string: "https://itunes.apple.com/app/id\(Constants.AppID.appID)") {
                    ShareLink(item: appURL) {
                        ProfileShelfRow(
                            theme: themeManager.current,
                            icon: "square.and.arrow.up.circle.fill",
                            title: String(localized: "Share Habit Diary"),
                            subtitle: String(localized: "Link to the App Store"),
                            trailing: .share
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal)
    }

    private var profileFooter: some View {
        let theme = themeManager.current
        return VStack(spacing: AppSpacing.small) {
            HStack(spacing: 8) {
                Rectangle()
                    .fill(theme.primaryColor.opacity(0.35))
                    .frame(width: 3, height: 14)
                Text(String(localized: "Habit Diary"))
                    .font(.system(.footnote, design: .serif))
                    .fontWeight(.semibold)
                    .foregroundStyle(theme.textPrimary)
            }

            Text(String(localized: "Your daily habit journal"))
                .font(AppFont.caption)
                .foregroundStyle(theme.textSecondary)

            Button {
                if let url = URL(string: "https://apps.apple.com/app/id\(Constants.AppID.appID)") {
                    openURL(url)
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise.circle")
                        .font(.caption)
                    Text(
                        String(
                            localized: "Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—") · Check for updates"
                        )
                    )
                }
                .font(AppFont.footnote)
                .foregroundStyle(theme.primaryColor)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.medium)
        .padding(.horizontal, AppSpacing.large)
        .background {
            if #available(iOS 26, *) {
                Color.clear
                    .glassEffect(in: .rect(cornerRadius: AppCornerRadius.card))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: AppCornerRadius.card)
                        .fill(theme.surface.opacity(0.45))
                    RoundedRectangle(cornerRadius: AppCornerRadius.card)
                        .strokeBorder(theme.textSecondary.opacity(0.12), lineWidth: 1)
                }
            }
        }
        .padding(.horizontal)
    }

    private func profileSectionChrome(title: String, subtitle: String, systemImage: String) -> some View {
        let theme = themeManager.current
        return HStack(alignment: .top, spacing: AppSpacing.smallMedium) {
            Image(systemName: systemImage)
                .font(.title2.weight(.semibold))
                .foregroundStyle(theme.primaryColor)
                .frame(width: 36, height: 36)
                .background(theme.primaryColor.opacity(0.12))
                .clipShape(.rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(theme.textPrimary)
                Text(subtitle)
                    .font(AppFont.caption)
                    .foregroundStyle(theme.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(.bottom, AppSpacing.small)
    }
}

// MARK: - Shelf row (replaces icon-grid `featureItem` / `moreItem`)

private enum ProfileShelfAccessory {
    case chevron
    case external
    case share
}

private struct ProfileShelfRow: View {
    let theme: AppTheme
    let icon: String
    let title: String
    let subtitle: String
    let trailing: ProfileShelfAccessory

    var body: some View {
        HStack(alignment: .center, spacing: AppSpacing.smallMedium) {
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        colors: [theme.primaryColor, theme.primaryColor.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 4)
                .padding(.vertical, 4)

            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(theme.primaryColor)
                .frame(width: 40, height: 40)
                .background(theme.primaryColor.opacity(0.1))
                .clipShape(.rect(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppFont.subheadline.weight(.semibold))
                    .foregroundStyle(theme.textPrimary)
                    .multilineTextAlignment(.leading)
                Text(subtitle)
                    .font(AppFont.caption)
                    .foregroundStyle(theme.textSecondary)
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: 8)

            trailingView
                .foregroundStyle(theme.textSecondary.opacity(0.85))
        }
        .padding(AppSpacing.smallMedium)
        .background { rowBackground }
        .clipShape(.rect(cornerRadius: AppCornerRadius.card))
        .contentShape(.rect(cornerRadius: AppCornerRadius.card))
    }

    @ViewBuilder
    private var trailingView: some View {
        switch trailing {
        case .chevron:
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
        case .external:
            Image(systemName: "arrow.up.right")
                .font(.caption.weight(.semibold))
        case .share:
            Image(systemName: "square.and.arrow.up")
                .font(.caption.weight(.semibold))
        }
    }

    @ViewBuilder
    private var rowBackground: some View {
        if #available(iOS 26, *) {
            Color.clear
                .glassEffect(in: .rect(cornerRadius: AppCornerRadius.card))
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: AppCornerRadius.card)
                    .fill(theme.card)
                RoundedRectangle(cornerRadius: AppCornerRadius.card)
                    .strokeBorder(theme.textSecondary.opacity(0.1), lineWidth: 1)
            }
        }
    }
}

#Preview {
    ReaderProfileView()
}

struct SupportEmail {
    let toAddress = "appsbayarea@gmail.com"
    let subject: String = String(localized: "\("Habit Diary") - \("Feedback")")
    var body: String { """
      Application Name: \(Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "Unknown")
      iOS Version: \(UIDevice.current.systemVersion)
      Device Model: \(UIDevice.current.model)
      App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "no app version")
      App Build: \(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "no app build version")

      \(String(localized: "Please describe your issue below"))
      ------------------------------------

    """ }

    func send(openURL: OpenURLAction) {
        let replacedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        let replacedBody = body.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        let urlString = "mailto:\(toAddress)?subject=\(replacedSubject)&body=\(replacedBody)"
        guard let url = URL(string: urlString) else { return }
        openURL(url) { accepted in
            if !accepted { // e.g. Simulator
                print("Device doesn't support email.\n \(body)")
            }
        }
    }
}
