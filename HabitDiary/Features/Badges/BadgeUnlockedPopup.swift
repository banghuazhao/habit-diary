//
// Created by Banghua Zhao on 01/01/2025
// Copyright Apps Bay Limited. All rights reserved.
//

import Dependencies
import SwiftUI

struct BadgeUnlockedPopup: View {
    let achievement: Badge
    @Binding var isPresented: Bool
    @State private var animationScale: CGFloat = 0.1
    @State private var animationOpacity: Double = 0
    @State private var showConfetti = false

    @Dependency(\.themeManager) private var themeManager

    private var theme: AppTheme { themeManager.current }

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissPopup()
                }

            VStack(spacing: AppSpacing.medium) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [theme.warning, theme.primaryColor.opacity(0.92)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: theme.warning.opacity(0.35), radius: 12, x: 0, y: 6)

                    Text(achievement.icon)
                        .font(.system(size: 50))
                        .scaleEffect(animationScale)
                        .opacity(animationOpacity)
                }

                Text(String(localized: "Badge unlocked"))
                    .font(.system(.title2, design: .serif))
                    .fontWeight(.bold)
                    .foregroundStyle(theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .opacity(animationOpacity)

                VStack(spacing: AppSpacing.smallMedium) {
                    Text(achievement.title)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(theme.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(achievement.description)
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.small)
                }
                .opacity(animationOpacity)

                ShareLink(
                    item: createAchievementShareText(achievement),
                    subject: Text(String(localized: "Badge unlocked")),
                    message: Text(String(localized: "From Habit Diary"))
                ) {
                    Label(String(localized: "Share badge"), systemImage: "square.and.arrow.up")
                        .font(AppFont.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.smallMedium)
                }
                .buttonStyle(.borderedProminent)
                .tint(theme.primaryColor)
                .opacity(animationOpacity)
                .padding(.horizontal, AppSpacing.small)

                Button(action: dismissPopup) {
                    Text(String(localized: "Continue"))
                        .font(AppFont.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.smallMedium)
                }
                .buttonStyle(.bordered)
                .tint(theme.primaryColor)
                .opacity(animationOpacity)
                .padding(.horizontal, AppSpacing.small)
            }
            .padding(AppSpacing.large)
            .background {
                RoundedRectangle(cornerRadius: AppCornerRadius.card)
                    .fill(theme.card)
                    .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: 12)
            }
            .overlay {
                RoundedRectangle(cornerRadius: AppCornerRadius.card)
                    .strokeBorder(theme.textSecondary.opacity(0.12), lineWidth: 1)
            }
            .padding(.horizontal, AppSpacing.large)
            .scaleEffect(animationScale)
            .opacity(animationOpacity)

            if showConfetti {
                ConfettiView()
            }
        }
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        Haptics.shared.vibrateIfEnabled()

        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            animationScale = 1.0
            animationOpacity = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showConfetti = true
            }
        }
    }

    private func dismissPopup() {
        withAnimation(.easeInOut(duration: 0.3)) {
            animationScale = 0.1
            animationOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPresented = false
        }
    }

    private func createAchievementShareText(_ achievement: Badge) -> String {
        let appName = String(localized: "Habit Diary")
        let appStoreURL = "https://apps.apple.com/app/id\(Constants.AppID.appID)"

        var shareText = String(localized: "Badge unlocked!\n\n")
        shareText += "\(achievement.title)\n"
        shareText += "\(achievement.description)\n\n"

        if let unlockDate = achievement.unlockedDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            shareText += String(localized: "Unlocked \(formatter.string(from: unlockDate))\n\n")
        }

        shareText += String(localized: "\(appName)\n\(appStoreURL)")
        return shareText
    }
}

// MARK: - Confetti

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    @Dependency(\.themeManager) private var themeManager

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                ConfettiParticleView(particle: particle)
            }
        }
        .onAppear {
            createParticles()
        }
    }

    private func createParticles() {
        let theme = themeManager.current
        let palette: [Color] = [
            theme.primaryColor,
            theme.warning,
            theme.success,
            theme.accent,
            theme.primaryColor.opacity(0.65),
            theme.warning.opacity(0.85),
            theme.success.opacity(0.9)
        ]
        particles = (0 ..< 50).map { _ in
            ConfettiParticle(
                id: UUID(),
                x: Double.random(in: 0 ... 1),
                y: Double.random(in: 0 ... 1),
                rotation: Double.random(in: 0 ... 360),
                scale: Double.random(in: 0.5 ... 1.5),
                color: palette.randomElement() ?? theme.primaryColor
            )
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id: UUID
    let x: Double
    let y: Double
    let rotation: Double
    let scale: Double
    let color: Color
}

struct ConfettiParticleView: View {
    let particle: ConfettiParticle
    @State private var animationOffset: CGSize = .zero
    @State private var animationRotation: Double = 0
    @State private var animationOpacity: Double = 1

    var body: some View {
        Circle()
            .fill(particle.color)
            .frame(width: 8, height: 8)
            .scaleEffect(particle.scale)
            .position(
                x: UIScreen.main.bounds.width * particle.x + animationOffset.width,
                y: UIScreen.main.bounds.height * particle.y + animationOffset.height
            )
            .rotationEffect(.degrees(particle.rotation + animationRotation))
            .opacity(animationOpacity)
            .onAppear {
                animateParticle()
            }
    }

    private func animateParticle() {
        let randomOffset = CGSize(
            width: Double.random(in: -100 ... 100),
            height: Double.random(in: -200 ... 200)
        )
        let randomRotation = Double.random(in: -360 ... 360)

        withAnimation(.easeOut(duration: 2.0)) {
            animationOffset = randomOffset
            animationRotation = randomRotation
            animationOpacity = 0
        }
    }
}

#Preview {
    BadgeUnlockedPopup(
        achievement: Badge(
            id: 1,
            title: "First Steps",
            description: "Complete a habit 3 days in a row",
            icon: "🔥",
            type: .streak,
            criteria: BadgeCriteria(targetValue: 3),
            isUnlocked: true,
            unlockedDate: Date(),
            habitID: nil
        ),
        isPresented: .constant(true)
    )
}
