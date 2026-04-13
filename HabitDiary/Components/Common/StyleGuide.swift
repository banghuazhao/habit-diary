import SwiftUI
import Dependencies
import Sharing

// MARK: - Theme Protocol
protocol AppTheme {
    var primaryColor: Color { get }
    var secondaryGray: Color { get }
    var background: Color { get }
    var card: Color { get }
    var accent: Color { get }
    var success: Color { get }
    var warning: Color { get }
    var error: Color { get }
    var textPrimary: Color { get }
    var textSecondary: Color { get }
    /// Subtle tinted surface used for info chips and secondary sections.
    var surface: Color { get }
}

// MARK: - Theme Colors — diary-inspired palette
enum ThemeColor: String, CaseIterable {
    /// Deep fountain-pen blue  — the iconic "diary ink" look.
    case ink    = "Ink"
    /// Warm antique sepia — old journal/notebook feel.
    case sepia  = "Sepia"
    /// Muted sage — botanical, grounded, NOT clinical-health green.
    case sage   = "Sage"
    /// Deep violet — creative, introspective journaling.
    case violet = "Violet"
    /// Dusty rose — warm and personal.
    case rose   = "Rose"
    /// Honey amber — vintage notebook warmth.
    case amber  = "Amber"

    var displayName: String {
        switch self {
        case .ink:    String(localized: "Ink")
        case .sepia:  String(localized: "Sepia")
        case .sage:   String(localized: "Sage")
        case .violet: String(localized: "Violet")
        case .rose:   String(localized: "Rose")
        case .amber:  String(localized: "Amber")
        }
    }

    var primaryColor: Color {
        switch self {
        case .ink:    return Color(red: 0.12, green: 0.34, blue: 0.60) // #1E5799 — fountain-pen blue
        case .sepia:  return Color(red: 0.55, green: 0.35, blue: 0.17) // #8B5A2B — sepia brown
        case .sage:   return Color(red: 0.24, green: 0.48, blue: 0.36) // #3D7A5C — muted sage
        case .violet: return Color(red: 0.42, green: 0.27, blue: 0.63) // #6B46A1 — deep violet
        case .rose:   return Color(red: 0.75, green: 0.27, blue: 0.37) // #C0445E — dusty rose
        case .amber:  return Color(red: 0.72, green: 0.46, blue: 0.16) // #B8762A — honey amber
        }
    }

    var accentColor: Color {
        switch self {
        case .ink:    return Color(red: 0.88, green: 0.93, blue: 0.98)
        case .sepia:  return Color(red: 0.97, green: 0.92, blue: 0.84)
        case .sage:   return Color(red: 0.88, green: 0.95, blue: 0.91)
        case .violet: return Color(red: 0.94, green: 0.91, blue: 0.98)
        case .rose:   return Color(red: 0.98, green: 0.91, blue: 0.93)
        case .amber:  return Color(red: 0.98, green: 0.94, blue: 0.86)
        }
    }

    /// Warm parchment-tinted background — intentionally paper-like, not clinical white.
    var backgroundColor: Color {
        switch self {
        case .ink:    return Color(red: 0.94, green: 0.96, blue: 0.98) // cool-white paper
        case .sepia:  return Color(red: 0.97, green: 0.94, blue: 0.89) // warm cream
        case .sage:   return Color(red: 0.93, green: 0.96, blue: 0.94) // pale herbal
        case .violet: return Color(red: 0.95, green: 0.93, blue: 0.98) // pale lavender
        case .rose:   return Color(red: 0.98, green: 0.94, blue: 0.95) // pale blush
        case .amber:  return Color(red: 0.98, green: 0.95, blue: 0.89) // warm parchment
        }
    }
}

// MARK: - Base Theme (light)
struct BaseTheme: AppTheme {
    let primaryColor: Color
    let secondaryGray   = Color(red: 0.56, green: 0.55, blue: 0.53)  // warm gray
    let background: Color
    /// Warm parchment instead of clinical white — the key diary differentiator.
    let card            = Color(red: 0.99, green: 0.97, blue: 0.93)  // #FDF8ED parchment
    let accent: Color
    let success         = Color(red: 0.18, green: 0.64, blue: 0.42)  // #2DA56B
    let warning         = Color(red: 0.82, green: 0.60, blue: 0.10)  // #D1991A
    let error           = Color(red: 0.82, green: 0.22, blue: 0.27)  // #D13844
    let textPrimary     = Color(red: 0.14, green: 0.12, blue: 0.10)  // #241F19 warm ink
    let textSecondary   = Color(red: 0.50, green: 0.47, blue: 0.43)  // #807870 warm secondary
    let surface: Color

    init(themeColor: ThemeColor) {
        self.primaryColor = themeColor.primaryColor
        self.background   = themeColor.backgroundColor
        self.accent       = themeColor.accentColor
        self.surface      = themeColor.accentColor
    }
}

// MARK: - Dark Theme
struct DarkBaseTheme: AppTheme {
    let primaryColor: Color
    let secondaryGray   = Color(red: 0.56, green: 0.55, blue: 0.53)
    let background      = Color(red: 0.11, green: 0.09, blue: 0.08)  // #1C1714 warm dark
    let card            = Color(red: 0.19, green: 0.16, blue: 0.14)  // #302924 warm dark card
    let accent: Color
    let success         = Color(red: 0.18, green: 0.64, blue: 0.42)
    let warning         = Color(red: 0.82, green: 0.60, blue: 0.10)
    let error           = Color(red: 0.82, green: 0.22, blue: 0.27)
    let textPrimary     = Color(red: 0.96, green: 0.94, blue: 0.90)  // warm off-white
    let textSecondary   = Color(red: 0.65, green: 0.62, blue: 0.58)  // warm secondary
    let surface: Color

    init(themeColor: ThemeColor) {
        self.primaryColor = themeColor.primaryColor
        self.accent       = themeColor.accentColor
        self.surface      = themeColor.primaryColor.opacity(0.15)
    }
}

// MARK: - Theme Manager
@Observable
class ThemeManager: ObservableObject {
    var current: AppTheme {
        let themeColor = ThemeColor(rawValue: selectedThemeColor) ?? .ink
        return darkModeEnabled
            ? DarkBaseTheme(themeColor: themeColor)
            : BaseTheme(themeColor: themeColor)
    }

    @ObservationIgnored
    @Shared(.appStorage("darkModeEnabled")) private var darkModeEnabled: Bool = false
    @ObservationIgnored
    @Shared(.appStorage("selectedThemeColor")) private var selectedThemeColor: String = ThemeColor.ink.rawValue

    static let shared = ThemeManager()

    var currentThemeColor: String { selectedThemeColor }

    func updateThemeColor(_ themeColorName: String) {
        $selectedThemeColor.withLock { $0 = themeColorName }
    }
}

// MARK: - DependencyKey
private enum ThemeManagerKey: DependencyKey {
    static let liveValue = ThemeManager.shared
}

extension DependencyValues {
    var themeManager: ThemeManager {
        get { self[ThemeManagerKey.self] }
        set { self[ThemeManagerKey.self] = newValue }
    }
}

// MARK: - Typography
struct AppFont {
    static let largeTitle  = Font.system(size: 34, weight: .bold)
    static let title       = Font.system(size: 28, weight: .semibold)
    static let headline    = Font.system(size: 17, weight: .semibold)
    static let body        = Font.system(size: 17, weight: .regular)
    static let subheadline = Font.system(size: 15, weight: .regular)
    static let caption     = Font.system(size: 13, weight: .regular)
    static let footnote    = Font.system(size: 12, weight: .regular)
}

// MARK: - Spacing & Layout
struct AppSpacing {
    static let small:       CGFloat = 8
    static let smallMedium: CGFloat = 12
    static let medium:      CGFloat = 16
    static let large:       CGFloat = 24
}

struct AppCornerRadius {
    static let info:   CGFloat = 12
    static let card:   CGFloat = 16
    static let button: CGFloat = 12
    static let avatar: CGFloat = 25
}

// MARK: - Shadows
struct AppShadow {
    static let card = ShadowStyle(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
}

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Reusable View Modifiers
extension View {

    /// Parchment card with optional left accent border — feels like a journal page.
    @ViewBuilder
    func appCardStyle(theme: AppTheme = ThemeManager.shared.current) -> some View {
        if #available(iOS 26, *) {
            self
                .padding(AppSpacing.medium)
                .glassEffect(in: .rect(cornerRadius: AppCornerRadius.card))
        } else {
            self
                .padding(AppSpacing.medium)
                .background(theme.card)
                .clipShape(.rect(cornerRadius: AppCornerRadius.card))
                .shadow(
                    color: AppShadow.card.color,
                    radius: AppShadow.card.radius,
                    x: AppShadow.card.x,
                    y: AppShadow.card.y
                )
        }
    }

    func appSectionHeader(theme: AppTheme = ThemeManager.shared.current) -> some View {
        self
            .font(AppFont.headline)
            .foregroundStyle(theme.textPrimary)
            .padding(.vertical, AppSpacing.small)
    }

    func appButtonStyle(theme: AppTheme = ThemeManager.shared.current, filled: Bool = true) -> some View {
        self
            .font(AppFont.headline)
            .padding(.vertical, AppSpacing.small)
            .padding(.horizontal, AppSpacing.large)
            .background(filled ? theme.primaryColor : Color.clear)
            .foregroundStyle(filled ? Color.white : theme.primaryColor)
            .clipShape(.rect(cornerRadius: AppCornerRadius.button))
    }

    /// Circular toolbar / icon button — Liquid Glass on iOS 26+, tinted circle otherwise.
    @ViewBuilder
    func appCircularButtonStyle(
        theme: AppTheme = ThemeManager.shared.current,
        overrideColor: Color? = nil
    ) -> some View {
        if #available(iOS 26, *) {
            self
                .font(AppFont.headline)
                .foregroundStyle(overrideColor ?? theme.primaryColor)
                .frame(width: 38, height: 38)
                .glassEffect(in: .circle)
        } else {
            self
                .font(AppFont.headline)
                .frame(width: 38, height: 38)
                .background(overrideColor?.opacity(0.12) ?? theme.primaryColor.opacity(0.12))
                .foregroundStyle(overrideColor ?? theme.primaryColor)
                .clipShape(.circle)
        }
    }

    /// Capsule text button — Liquid Glass on iOS 26+, tinted pill otherwise.
    @ViewBuilder
    func appRectButtonStyle(theme: AppTheme = ThemeManager.shared.current) -> some View {
        if #available(iOS 26, *) {
            self
                .font(AppFont.headline)
                .foregroundStyle(theme.primaryColor)
                .frame(height: 38)
                .padding(.horizontal, AppSpacing.medium)
                .glassEffect(in: .capsule)
        } else {
            self
                .font(AppFont.headline)
                .frame(height: 38)
                .padding(.horizontal, AppSpacing.medium)
                .background(theme.primaryColor.opacity(0.12))
                .foregroundStyle(theme.primaryColor)
                .clipShape(.capsule)
        }
    }

    func appBackground(theme: AppTheme = ThemeManager.shared.current) -> some View {
        self.background(theme.background)
    }

    func appInfoSection(theme: AppTheme = ThemeManager.shared.current) -> some View {
        self
            .padding(.vertical, AppSpacing.small)
            .padding(.horizontal, AppSpacing.medium)
            .background(theme.secondaryGray.opacity(0.10))
            .clipShape(.rect(cornerRadius: AppCornerRadius.info))
    }
}
