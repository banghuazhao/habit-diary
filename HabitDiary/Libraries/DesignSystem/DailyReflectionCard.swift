//
//  DailyReflectionCard.swift
//  Habit Diary
//
//  Created by Banghua Zhao on 2025/1/27.
//  Copyright Apps Bay Limited. All rights reserved.
//

import SwiftUI
import Dependencies

struct DailyReflectionCard: View {
    let quote: DailyReflection
    let onDismiss: () -> Void

    @Dependency(\.themeManager) var themeManager

    private var theme: AppTheme { themeManager.current }

    var body: some View {
        JournalAccentPanel(theme: theme, accent: theme.primaryColor) {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                HStack(alignment: .top) {
                    Label(String(localized: "Daily Reflection"), systemImage: "pencil.tip")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(theme.primaryColor)

                    Spacer()

                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(theme.textSecondary)
                            .frame(width: 22, height: 22)
                            .background(theme.secondaryGray.opacity(0.15))
                            .clipShape(.circle)
                    }
                }

                Text(quote.text)
                    .font(.system(size: 15, weight: .regular, design: .serif))
                    .foregroundStyle(theme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .italic()

                Text("— \(quote.author)")
                    .font(.system(size: 12, weight: .regular, design: .serif))
                    .foregroundStyle(theme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .shadow(color: AppShadow.card.color, radius: AppShadow.card.radius, x: AppShadow.card.x, y: AppShadow.card.y)
    }
}

#Preview {
    DailyReflectionCard(
        quote: DailyReflection(
            text: "The secret of getting ahead is getting started.",
            author: "Mark Twain"
        )
    ) {}
    .padding()
}
