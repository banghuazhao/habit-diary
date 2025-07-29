//
// Created by Banghua Zhao on 26/06/2025
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation
import SwiftUI

struct HabitIconEditView: View {
    @Binding var color: Int
    @Binding var icon: String

    func onSelectColor(_ newColor: Int) {
        color = newColor
    }

    func onSelectIcon(_ newIcon: String) {
        icon = newIcon
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: [
                            GridItem(.flexible(minimum: 50, maximum: 100)),
                            GridItem(.flexible(minimum: 50, maximum: 100)),
                        ], spacing: 10) {
                            ColorPicker(
                                "",
                                selection: Binding(
                                    get: { Color(hex: color) },
                                    set: { onSelectColor($0.hexIntWithAlpha) }
                                )
                            )
                            .labelsHidden()

                            ForEach(HabitIconColorDataSource.colors, id: \.self) { colorHex in
                                Circle()
                                    .fill(Color(hex: colorHex))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        color == colorHex ? Circle().stroke(Color.black, lineWidth: 2) : nil
                                    )
                                    .onTapGesture {
                                        onSelectColor(colorHex)
                                    }
                            }
                        }
                        .padding()
                    }
                    .frame(maxWidth: 800)

                    EmojiPickerView(
                        selectedEmoji: $icon,
                        categoryOrder: [.activities, .food, .objects, .animals, .smileys]
                    )

                    Spacer()
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var color = 0xFFFFFFFF
    @Previewable @State var icon = "🥑"
    
    HabitIconEditView(
        color: $color,
        icon: $icon
        
    )
}
