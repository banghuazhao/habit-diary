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

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Notebook margin rule — the visual anchor that makes this feel like a diary page
            Rectangle()
                .fill(themeManager.current.primaryColor)
                .frame(width: 3)
                .clipShape(.rect(cornerRadius: 2))

            VStack(alignment: .leading, spacing: AppSpacing.small) {
                HStack(alignment: .top) {
                    // Section label
                    Label(String(localized: "Daily Reflection"), systemImage: "pencil.tip")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(themeManager.current.primaryColor)

                    Spacer()

                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(themeManager.current.textSecondary)
                            .frame(width: 22, height: 22)
                            .background(themeManager.current.secondaryGray.opacity(0.15))
                            .clipShape(.circle)
                    }
                }

                // Quote text — serif for that handwritten-in-a-journal feel
                Text(quote.text)
                    .font(.system(size: 15, weight: .regular, design: .serif))
                    .foregroundStyle(themeManager.current.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .italic()

                // Attribution
                Text("— \(quote.author)")
                    .font(.system(size: 12, weight: .regular, design: .serif))
                    .foregroundStyle(themeManager.current.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.leading, 12)
            .padding(.trailing, AppSpacing.medium)
            .padding(.vertical, AppSpacing.smallMedium)
        }
        .background(themeManager.current.card)
        .clipShape(.rect(cornerRadius: AppCornerRadius.card))
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
