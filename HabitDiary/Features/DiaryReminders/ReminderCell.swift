//
// Created by Banghua Zhao on 01/01/2025
// Copyright Apps Bay Limited. All rights reserved.
//

import Dependencies
import SwiftUI

struct ReminderCell: View {
    let time: Date
    let title: String
    let onDelete: (() -> Void)?

    @Dependency(\.themeManager) private var themeManager

    private var theme: AppTheme { themeManager.current }

    var body: some View {
        HStack(spacing: AppSpacing.smallMedium) {
            HStack {
                Image(systemName: "alarm.fill")
                    .foregroundStyle(theme.primaryColor)
                    .font(AppFont.subheadline)
                Spacer(minLength: 0)
                Text(time, format: .dateTime.hour().minute())
                    .font(AppFont.subheadline.weight(.semibold))
                    .foregroundStyle(theme.textPrimary)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .frame(width: 92, alignment: .leading)

            Rectangle()
                .fill(theme.textSecondary.opacity(0.22))
                .frame(width: 1, height: 22)

            Text(title)
                .font(.system(.body, design: .serif))
                .foregroundStyle(theme.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.9)

            Spacer(minLength: 0)

            if let onDelete {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(AppFont.subheadline)
                        .foregroundStyle(theme.error)
                }
                .buttonStyle(.borderless)
                .accessibilityLabel(String(localized: "Delete reminder"))
            }
        }
        .padding(.horizontal, AppSpacing.smallMedium)
        .padding(.vertical, AppSpacing.small)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    VStack(spacing: 12) {
        ReminderCell(
            time: Date(),
            title: "Drink Water",
            onDelete: {}
        )
        ReminderCell(
            time: Date(),
            title: "Drink Water",
            onDelete: nil
        )
    }
    .padding()
}