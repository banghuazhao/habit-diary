import Dependencies
import SwiftUI

// MARK: - Upgrade sheet

struct PremiumUpgradeSheet: View {
    @Dependency(\.premiumAccessManager) private var premiumAccessManager
    @Dependency(\.themeManager) private var themeManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    @State private var isPurchasing = false
    @State private var showSuccessModal = false

    private var theme: AppTheme { themeManager.current }

    var body: some View {
        ZStack(alignment: .topLeading) {
            theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppSpacing.large) {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .appCircularButtonStyle()
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.top, AppSpacing.small)
                    .padding(.leading, AppSpacing.small)

                    JournalAccentPanel(theme: theme, accent: theme.primaryColor) {
                        VStack(spacing: AppSpacing.medium) {
                            JournalSectionHeader(
                                title: String(localized: "Distraction-free journaling"),
                                subtitle: String(localized: "Support the app and unlock premium benefits"),
                                systemImage: "crown.fill",
                                theme: theme
                            )

                            ZStack {
                                LinearGradient(
                                    colors: [theme.primaryColor, theme.warning.opacity(0.9)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .frame(width: 88, height: 88)
                                .mask(
                                    Image(systemName: "book.pages.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                )
                            }
                            .clipShape(.rect(cornerRadius: 18))
                            .frame(width: 88, height: 88)
                            .frame(maxWidth: .infinity)

                            Text(
                                String(
                                    localized: "Upgrade to Premium and keep your diary distraction-free."
                                )
                            )
                            .font(.system(.title2, design: .serif))
                            .fontWeight(.bold)
                            .foregroundStyle(theme.textPrimary)
                            .multilineTextAlignment(.center)

                            Text(
                                String(
                                    localized: "Unlock the full Habit Diary experience:"
                                )
                            )
                            .font(AppFont.subheadline)
                            .foregroundStyle(theme.textSecondary)
                            .multilineTextAlignment(.center)

                            VStack(alignment: .leading, spacing: AppSpacing.smallMedium) {
                                premiumBenefitRow(
                                    symbol: "speaker.slash.fill",
                                    title: String(localized: "No ads"),
                                    detail: String(localized: "Journal and log habits without advertising interruptions.")
                                )
                                premiumBenefitRow(
                                    symbol: "leaf.fill",
                                    title: String(localized: "Pure focus"),
                                    detail: String(localized: "A calm, immersive space for your daily entries.")
                                )
                            }
                        }
                    }
                    .padding(.horizontal)

                    purchaseSection
                        .padding(.horizontal)

                    VStack(spacing: AppSpacing.smallMedium) {
                        footerLinkButton(String(localized: "Restore purchases")) {
                            Task {
                                isPurchasing = true
                                await premiumAccessManager.restorePurchases()
                                isPurchasing = false
                            }
                        }
                        footerLinkButton(String(localized: "Contact support")) {
                            if let url = URL(string: "https://apps-bay.github.io/Apps-Bay-Website/contact/") {
                                openURL(url)
                            }
                        }
                        footerLinkButton(String(localized: "Privacy policy")) {
                            if let url = URL(string: "https://apps-bay.github.io/Apps-Bay-Website/privacy/") {
                                openURL(url)
                            }
                        }
                    }
                    .font(AppFont.body)
                    .padding(.bottom, AppSpacing.large)
                }
            }
        }
        .sheet(isPresented: $showSuccessModal) {
            PremiumCelebrationView()
        }
        .task {
            await premiumAccessManager.loadPremiumProduct()
        }
    }

    @ViewBuilder
    private var purchaseSection: some View {
        if let product = premiumAccessManager.premiumProduct {
            if premiumAccessManager.isPremiumUserPurchased {
                Text(String(localized: "You’re a Premium member — thank you!"))
                    .font(.system(.title3, design: .serif).weight(.semibold))
                    .foregroundStyle(theme.textPrimary)
                    .multilineTextAlignment(.center)
            } else {
                Button {
                    Task {
                        isPurchasing = true
                        let result = await premiumAccessManager.purchasePremium()
                        if case .success = result {
                            showSuccessModal = true
                        }
                        isPurchasing = false
                    }
                } label: {
                    HStack(spacing: AppSpacing.small) {
                        if isPurchasing {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.85)
                        }
                        Text(String(localized: "\(product.displayPrice) — Upgrade to Premium"))
                            .font(AppFont.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, AppSpacing.smallMedium)
                }
                .buttonStyle(.borderedProminent)
                .tint(theme.primaryColor)
                .disabled(isPurchasing)
            }
        } else {
            ProgressView()
                .tint(theme.primaryColor)
                .padding()
        }
    }

    private func premiumBenefitRow(symbol: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.smallMedium) {
            Image(systemName: symbol)
                .font(.body.weight(.semibold))
                .foregroundStyle(theme.primaryColor)
                .frame(width: 28, height: 28)
                .background(theme.primaryColor.opacity(0.12))
                .clipShape(.rect(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppFont.subheadline.weight(.semibold))
                    .foregroundStyle(theme.textPrimary)
                Text(detail)
                    .font(AppFont.caption)
                    .foregroundStyle(theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func footerLinkButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.subheadline.weight(.medium))
                .foregroundStyle(theme.primaryColor)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Celebration

struct ConfettiDot: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let color: Color
    let size: CGFloat
}

struct PremiumCelebrationView: View {
    var onContinue: (() -> Void)?

    @Dependency(\.themeManager) private var themeManager
    @Environment(\.dismiss) private var dismiss

    @State private var animate = false
    @State private var confetti: [ConfettiDot] = []

    private var theme: AppTheme { themeManager.current }

    var body: some View {
        ZStack {
            theme.background.opacity(0.92)
                .ignoresSafeArea()

            ForEach(confetti) { dot in
                Circle()
                    .fill(dot.color)
                    .frame(width: dot.size, height: dot.size)
                    .position(x: dot.x, y: animate ? dot.y : dot.y - 80)
                    .opacity(0.75)
                    .animation(.easeOut(duration: 1.2), value: animate)
            }

            VStack(spacing: AppSpacing.large) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [theme.warning.opacity(0.45), theme.primaryColor.opacity(0.25)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 120, height: 120)
                        .blur(radius: 10)

                    Image(systemName: "crown.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                        .foregroundStyle(theme.warning)
                        .shadow(color: theme.warning.opacity(0.35), radius: 10)
                }

                Text(String(localized: "Thank you!"))
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundStyle(theme.textPrimary)

                Text(String(localized: "You’re now Premium — enjoy an ad-free diary."))
                    .font(.title3)
                    .foregroundStyle(theme.textSecondary)
                    .multilineTextAlignment(.center)

                Divider()
                    .background(theme.textSecondary.opacity(0.2))

                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    Label {
                        Text(String(localized: "Ad-free experience"))
                            .foregroundStyle(theme.textPrimary)
                    } icon: {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(theme.success)
                    }
                    Label {
                        Text(String(localized: "Thanks for supporting Habit Diary"))
                            .foregroundStyle(theme.textPrimary)
                    } icon: {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(theme.primaryColor)
                    }
                }
                .font(AppFont.body)
                .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    onContinue?()
                    dismiss()
                } label: {
                    Text(String(localized: "Continue"))
                        .font(AppFont.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.smallMedium)
                }
                .buttonStyle(.borderedProminent)
                .tint(theme.primaryColor)
            }
            .padding(AppSpacing.large)
            .background {
                RoundedRectangle(cornerRadius: AppCornerRadius.card)
                    .fill(theme.card)
                    .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 8)
            }
            .overlay {
                RoundedRectangle(cornerRadius: AppCornerRadius.card)
                    .strokeBorder(theme.textSecondary.opacity(0.1), lineWidth: 1)
            }
            .padding(.horizontal, AppSpacing.large)
        }
        .onAppear {
            confetti = makeConfetti()
            animate = true
        }
    }

    private func makeConfetti() -> [ConfettiDot] {
        let palette: [Color] = [
            theme.primaryColor,
            theme.warning,
            theme.success,
            theme.accent,
            theme.primaryColor.opacity(0.65)
        ]
        return (0 ..< 22).map { _ in
            ConfettiDot(
                x: CGFloat.random(in: 40 ... 340),
                y: CGFloat.random(in: 80 ... 520),
                color: palette.randomElement() ?? theme.primaryColor,
                size: CGFloat.random(in: 6 ... 14)
            )
        }
    }
}

#Preview {
    PremiumUpgradeSheet()
}
