//
// Created by Banghua Zhao on 13/04/2026
// Copyright Apps Bay Limited. All rights reserved.
//

import Dependencies
import SQLiteData
import SwiftUI

struct DiaryEntryEditor: View {
    let checkIn: DiaryEntry
    let habitName: String
    let habitIcon: String
    var onSave: (String) -> Void

    @State private var noteText: String = ""
    @Environment(\.dismiss) private var dismiss
    @Dependency(\.themeManager) var themeManager

    private let maxNoteLength = 280

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(themeManager.current.primaryColor.opacity(0.12))
                                .frame(width: 48, height: 48)
                            Text(habitIcon)
                                .font(.system(size: 26))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(habitName)
                                .font(.headline)
                            Text(checkIn.date, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.title2)
                    }
                    .padding()
                    .background(themeManager.current.card)
                    .clipShape(.rect(cornerRadius: 12))
                    .padding(.horizontal)
                }
                .padding(.top)

                // Divider
                Divider()
                    .padding(.top)

                // Note area
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "pencil.line")
                            .foregroundStyle(themeManager.current.primaryColor)
                        Text(String(localized: "Diary Note"))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(noteText.count)/\(maxNoteLength)")
                            .font(.caption2)
                            .foregroundStyle(noteText.count > maxNoteLength ? .red : .secondary)
                    }

                    ZStack(alignment: .topLeading) {
                        if noteText.isEmpty {
                            Text(String(localized: "How did it go? Write a quick reflection… (optional)"))
                                .font(.body)
                                .foregroundStyle(.secondary.opacity(0.7))
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $noteText)
                            .font(.body)
                            .frame(minHeight: 120)
                            .scrollContentBackground(.hidden)
                            .onChange(of: noteText) { _, newValue in
                                if newValue.count > maxNoteLength {
                                    noteText = String(newValue.prefix(maxNoteLength))
                                }
                            }
                    }
                    .padding(12)
                    .background(themeManager.current.card)
                    .clipShape(.rect(cornerRadius: 12))
                }
                .padding()

                Spacer()

                // Action buttons
                VStack(spacing: 12) {
                    Button {
                        onSave(noteText)
                        dismiss()
                    } label: {
                        Text(noteText.isEmpty ? String(localized: "Skip Note") : String(localized: "Save to Journal"))
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(noteText.isEmpty ? Color.secondary : themeManager.current.primaryColor)
                            .clipShape(.rect(cornerRadius: 12))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(themeManager.current.background.ignoresSafeArea())
            .navigationTitle(String(localized: "Checked In! ✅"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Close")) {
                        onSave(noteText)
                        dismiss()
                    }
                    .foregroundStyle(themeManager.current.primaryColor)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    DiaryEntryEditor(
        checkIn: DiaryEntry(id: 1, date: Date(), habitID: 1, note: ""),
        habitName: "Morning walk",
        habitIcon: "🚶‍♂️"
    ) { _ in }
}
