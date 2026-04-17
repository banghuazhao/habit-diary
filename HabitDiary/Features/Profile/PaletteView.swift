//
//  PaletteView.swift
//  TimesMatter
//
//  Created by Lulin Yang on 2025/7/11.
//

import Dependencies
import SwiftUI

struct PaletteView: View {
    @Dependency(\.themeManager) var themeManager
    @Environment(\.dismiss) private var dismiss

    private let themeColors: [PaletteOption] = [
        PaletteOption(themeColor: .ink,    color: Color(red: 0.12, green: 0.34, blue: 0.60), icon: "pencil.tip"),
        PaletteOption(themeColor: .sepia,  color: Color(red: 0.55, green: 0.35, blue: 0.17), icon: "book.closed.fill"),
        PaletteOption(themeColor: .sage,   color: Color(red: 0.24, green: 0.48, blue: 0.36), icon: "leaf.fill"),
        PaletteOption(themeColor: .violet, color: Color(red: 0.42, green: 0.27, blue: 0.63), icon: "sparkles"),
        PaletteOption(themeColor: .rose,   color: Color(red: 0.75, green: 0.27, blue: 0.37), icon: "heart.fill"),
        PaletteOption(themeColor: .amber,  color: Color(red: 0.72, green: 0.46, blue: 0.16), icon: "flame.fill"),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.large) {
                Text(String(localized: "Select your preferred primary color for the app"))
                    .font(AppFont.body)
                    .foregroundStyle(themeManager.current.textSecondary)
                    .multilineTextAlignment(.center)

                // Theme Color Options
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: AppSpacing.large) {
                    ForEach(themeColors, id: \.themeColor.rawValue) { themeOption in
                        PaletteCard(
                            themeOption: themeOption,
                            isSelected: themeManager.currentThemeColor == themeOption.themeColor.rawValue,
                            onTap: {
                                themeManager.updateThemeColor(themeOption.themeColor.rawValue)
                            }
                        )
                    }
                }
                .padding(.horizontal)

                // Preview Section
                VStack(alignment: .leading, spacing: AppSpacing.medium) {
                    Text(String(localized: "Preview"))
                        .appSectionHeader(theme: themeManager.current)

                    VStack(spacing: AppSpacing.medium) {
                        // Sample button
                        HStack {
                                                    Button(action: {
                            Haptics.shared.vibrateIfEnabled()
                        }) {
                            Text(String(localized: "Sample Button"))
                        }
                            .buttonStyle(.appRect)
                            
                            Button(action: {
                                Haptics.shared.vibrateIfEnabled()
                            }) {
                                Image(systemName: "plus")
                            }
                            .buttonStyle(.appCircular)
                        }

                        // Sample card
                        VStack(alignment: .leading, spacing: AppSpacing.small) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(themeManager.current.primaryColor)
                                Text(String(localized: "Sample Card"))
                                    .font(AppFont.headline)
                                    .foregroundStyle(themeManager.current.textPrimary)
                                Spacer()
                            }
                            Text(String(localized: "This is how your selected theme color will look throughout the app."))
                                .font(AppFont.body)
                                .foregroundStyle(themeManager.current.textSecondary)
                        }
                        .appCardStyle(theme: themeManager.current)
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Theme Color")
            .navigationBarTitleDisplayMode(.inline)
        }
        .background(themeManager.current.background)
    }
}

struct PaletteOption {
    let themeColor: ThemeColor
    let color: Color
    let icon: String
}

struct PaletteCard: View {
    @Dependency(\.themeManager) var themeManager
    let themeOption: PaletteOption
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            Haptics.shared.vibrateIfEnabled()
            onTap()
        }) {
            VStack(spacing: AppSpacing.medium) {
                // Color circle with icon
                ZStack {
                    Circle()
                        .fill(themeOption.color)
                        .frame(width: 50, height: 50)
                        .shadow(color: themeOption.color.opacity(0.3), radius: 8, x: 0, y: 4)

                    Image(systemName: themeOption.icon)
                        .font(.title)
                        .foregroundStyle(.white)
                }

                Text(themeOption.themeColor.displayName)
                    .font(AppFont.headline)
                    .foregroundStyle(themeOption.color)
            }
            .frame(maxWidth: .infinity)
            .padding(AppSpacing.medium)
            .background(themeManager.current.card)
            .clipShape(.rect(cornerRadius: AppCornerRadius.card))
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.card)
                    .stroke(isSelected ? themeOption.color : Color.clear, lineWidth: 3)
            )
            .shadow(color: AppShadow.card.color, radius: AppShadow.card.radius, x: AppShadow.card.x, y: AppShadow.card.y)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PaletteView()
}
