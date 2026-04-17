//
//  DiarySettingsView.swift
//  Habit Diary
//
//  Created by Lulin Yang on 2025/7/1.
//
import Dependencies
import Sharing
import SwiftUI

struct DiarySettingsView: View {
    @AppStorage("startWeekOnMonday") private var startWeekOnMonday: Bool = true
    @AppStorage("buttonSoundEnabled") private var buttonSoundEnabled: Bool = true
    @AppStorage("vibrateEnabled") private var vibrateEnabled: Bool = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled: Bool = false
    @AppStorage("motivationalQuotesEnabled") private var motivationalQuotesEnabled: Bool = true
    @Shared(.appStorage("lastQuoteDismissedDate")) private var lastQuoteDismissedDate: Date? = nil
    @Dependency(\.themeManager) private var themeManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                headerBlock

                LedgerSettingsSection(
                    theme: themeManager.current,
                    title: String(localized: "Calendar"),
                    subtitle: String(localized: "How weeks line up in your journal"),
                    systemImage: "calendar"
                ) {
                    weekStartPills
                }

                LedgerSettingsSection(
                    theme: themeManager.current,
                    title: String(localized: "Feedback"),
                    subtitle: String(localized: "Sounds and haptics when you log habits"),
                    systemImage: "waveform"
                ) {
                    VStack(spacing: 0) {
                        settingsToggleRow(
                            icon: "speaker.wave.2.fill",
                            title: String(localized: "Entry sound"),
                            tint: themeManager.current.primaryColor
                        ) {
                            Toggle("", isOn: $buttonSoundEnabled)
                                .labelsHidden()
                                .tint(themeManager.current.primaryColor)
                        }
                        ledgerDivider
                        settingsToggleRow(
                            icon: "iphone.radiowaves.left.and.right",
                            title: String(localized: "Haptics"),
                            tint: themeManager.current.primaryColor
                        ) {
                            Toggle("", isOn: $vibrateEnabled)
                                .labelsHidden()
                                .tint(themeManager.current.primaryColor)
                        }
                    }
                }

                LedgerSettingsSection(
                    theme: themeManager.current,
                    title: String(localized: "Reflection"),
                    subtitle: String(localized: "Daily prompts on your Journal home"),
                    systemImage: "text.quote"
                ) {
                    VStack(spacing: 0) {
                        settingsToggleRow(
                            icon: "sun.horizon.fill",
                            title: String(localized: "Daily prompts"),
                            tint: themeManager.current.primaryColor
                        ) {
                            Toggle("", isOn: $motivationalQuotesEnabled)
                                .labelsHidden()
                                .tint(themeManager.current.primaryColor)
                        }
                        ledgerDivider
                        settingsActionRow(
                            icon: "arrow.counterclockwise",
                            title: String(localized: "Show today’s prompt again"),
                            subtitle: String(localized: "Clears the dismiss for this day"),
                            theme: themeManager.current
                        ) {
                            Button {
                                $lastQuoteDismissedDate.withLock { $0 = nil }
                            } label: {
                                Text(String(localized: "Reset"))
                                    .font(AppFont.subheadline.weight(.semibold))
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(themeManager.current.primaryColor)
                            .controlSize(.small)
                        }
                    }
                }

                LedgerSettingsSection(
                    theme: themeManager.current,
                    title: String(localized: "Appearance"),
                    subtitle: String(localized: "Light or dark paper tone"),
                    systemImage: "paintbrush.fill"
                ) {
                    settingsToggleRow(
                        icon: "moon.stars.fill",
                        title: String(localized: "Dark Mode"),
                        tint: themeManager.current.primaryColor
                    ) {
                        Toggle("", isOn: $darkModeEnabled)
                            .labelsHidden()
                            .tint(themeManager.current.primaryColor)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.medium)
            .padding(.vertical, AppSpacing.large)
        }
        .background(themeManager.current.background.ignoresSafeArea())
        .navigationTitle(String(localized: "Settings"))
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(darkModeEnabled ? .dark : .light)
    }

    private var headerBlock: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text(String(localized: "Journal preferences"))
                .font(.system(.title2, design: .serif))
                .fontWeight(.semibold)
                .foregroundStyle(themeManager.current.textPrimary)

            Text(String(localized: "Adjust how your diary behaves and feels."))
                .font(AppFont.subheadline)
                .foregroundStyle(themeManager.current.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 6) {
                Image(systemName: "pencil.line")
                    .font(.caption.weight(.semibold))
                Text(String(localized: "Saved on this device"))
                    .font(AppFont.caption)
            }
            .foregroundStyle(themeManager.current.textSecondary.opacity(0.9))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, AppSpacing.small)
    }

    private var weekStartPills: some View {
        HStack(spacing: AppSpacing.small) {
            weekPill(
                title: String(localized: "Monday"),
                isSelected: startWeekOnMonday
            ) { startWeekOnMonday = true }

            weekPill(
                title: String(localized: "Sunday"),
                isSelected: !startWeekOnMonday
            ) { startWeekOnMonday = false }
        }
        .padding(.vertical, 4)
    }

    private func weekPill(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundStyle(isSelected ? Color.white : themeManager.current.textPrimary)
                .background {
                    if isSelected {
                        themeManager.current.primaryColor
                    } else {
                        themeManager.current.surface.opacity(0.65)
                    }
                }
                .clipShape(.rect(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            isSelected ? Color.clear : themeManager.current.textSecondary.opacity(0.2),
                            lineWidth: 1
                        )
                }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    private var ledgerDivider: some View {
        Rectangle()
            .fill(themeManager.current.textSecondary.opacity(0.12))
            .frame(height: 1)
            .padding(.leading, 52)
    }

    private func settingsToggleRow<Content: View>(
        icon: String,
        title: String,
        tint: Color,
        @ViewBuilder trailing: () -> Content
    ) -> some View {
        HStack(alignment: .center, spacing: AppSpacing.medium) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(tint)
                .frame(width: 36, height: 36)
                .background(tint.opacity(0.12))
                .clipShape(.rect(cornerRadius: 10))

            Text(title)
                .font(AppFont.body)
                .foregroundStyle(themeManager.current.textPrimary)

            Spacer(minLength: 8)

            trailing()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
        .accessibilityElement(children: .combine)
    }

    private func settingsActionRow<Content: View>(
        icon: String,
        title: String,
        subtitle: String,
        theme: AppTheme,
        @ViewBuilder trailing: () -> Content
    ) -> some View {
        HStack(alignment: .center, spacing: AppSpacing.medium) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(theme.primaryColor)
                .frame(width: 36, height: 36)
                .background(theme.primaryColor.opacity(0.12))
                .clipShape(.rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppFont.body)
                    .foregroundStyle(theme.textPrimary)
                Text(subtitle)
                    .font(AppFont.caption)
                    .foregroundStyle(theme.textSecondary)
            }

            Spacer(minLength: 8)

            trailing()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
    }
}

// MARK: - Ledger panel chrome

private struct LedgerSettingsSection<Content: View>: View {
    let theme: AppTheme
    let title: String
    let subtitle: String
    let systemImage: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.smallMedium) {
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        colors: [theme.primaryColor, theme.primaryColor.opacity(0.45)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 4)
                .padding(.vertical, 4)

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: AppSpacing.smallMedium) {
                    Image(systemName: systemImage)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(theme.primaryColor)
                        .frame(width: 28)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(AppFont.headline)
                            .foregroundStyle(theme.textPrimary)
                        Text(subtitle)
                            .font(AppFont.caption)
                            .foregroundStyle(theme.textSecondary)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.bottom, AppSpacing.smallMedium)

                content()
            }
        }
        .padding(AppSpacing.medium)
        .modifier(LedgerPanelChrome(theme: theme))
    }
}

/// Glass on iOS 26+, parchment card on earlier systems (matches app diary aesthetic).
private struct LedgerPanelChrome: ViewModifier {
    let theme: AppTheme

    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .glassEffect(in: .rect(cornerRadius: AppCornerRadius.card))
        } else {
            content
                .background {
                    ZStack {
                        RoundedRectangle(cornerRadius: AppCornerRadius.card)
                            .fill(theme.surface.opacity(0.55))
                        RoundedRectangle(cornerRadius: AppCornerRadius.card)
                            .strokeBorder(theme.textSecondary.opacity(0.12), lineWidth: 1)
                    }
                }
        }
    }
}
