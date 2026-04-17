//
// Created by Banghua Zhao on 28/06/2025
// Copyright Apps Bay Limited. All rights reserved.
//

import SwiftUI

struct HabitCatalogView: View {
    @Binding var habit: Habit.Draft


    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 80),  alignment: .top)
                    ],
                    spacing: 12
                ) {
                    ForEach(
                        DiaryHabitLibrary.all,
                        id: \.name
                    ) { habitNew in
                        DraftHabitTile(
                            todayHabit: habitNew.toTodayDraftHabit(),
                            onTap: {
                                Haptics.shared.vibrateIfEnabled()
                                habit = habitNew
                            }
                        )
                    }
                }
                .padding()
                
                Spacer()
            }
            .padding(.top, 20)
        }
    }
}

#Preview {
    @Previewable @State var habit = Habit.Draft(Habit(id: 0))

    HabitCatalogView(
        habit: $habit
    )
}
