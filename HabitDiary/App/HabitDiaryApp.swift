//
// Created by Banghua Zhao on 31/05/2025
// Copyright Apps Bay Limited. All rights reserved.
//

import SQLiteData
import SwiftUI
import GoogleMobileAds

// MARK: - Tab enum for type-safe selection
enum AppTab: String, Hashable {
    case today
    case habits
    case rating
    case me
}

@main
struct HabitDiaryApp: App {
    @AppStorage("darkModeEnabled") private var darkModeEnabled: Bool = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @Dependency(\.achievementService) private var achievementService
    @Dependency(\.themeManager) private var themeManager
    @Dependency(\.purchaseManager) private var purchaseManager
    @StateObject private var openAd = OpenAd()
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab: AppTab = .today

    init() {
        MobileAds.shared.start(completionHandler: nil)
        prepareDependencies {
            $0.defaultDatabase = try! appDatabase()
        }
    }

    var body: some Scene {
        WindowGroup {
            content
                .overlay {
                    if let achievementToShow = achievementService.achievementToShow {
                        AchievementPopupView(
                            achievement: achievementToShow,
                            isPresented: Binding(
                                get: { achievementService.achievementToShow != nil },
                                set: { if !$0 { achievementService.achievementToShow = nil } }
                            )
                        )
                    }
                }
                .preferredColorScheme(darkModeEnabled ? .dark : .light)
                .task {
                    await requestNotificationPermissions()
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        if !purchaseManager.isPremiumUserPurchased {
                            openAd.tryToPresentAd()
                        }
                        openAd.appHasEnterBackgroundBefore = false
                    } else if newPhase == .background {
                        openAd.appHasEnterBackgroundBefore = true
                    }
                }
        }
    }

    @ViewBuilder
    var content: some View {
        ZStack {
            if #available(iOS 18.0, *) {
                tabViewModern
                    .tint(themeManager.current.primaryColor)
            } else {
                tabViewLegacy
                    .background(themeManager.current.background)
                    .tint(themeManager.current.primaryColor)
            }

            Color.clear
                .fullScreenCover(isPresented: .constant(!hasCompletedOnboarding)) {
                    OnboardingView()
                }
        }
    }

    @available(iOS 18.0, *)
    var tabViewModern: some View {
        TabView(selection: $selectedTab) {
            Tab("Today", systemImage: "calendar", value: AppTab.today) {
                TodayView()
                    .onAppear {
                        AdManager.requestATTPermission(with: 3)
                    }
            }

            Tab("Habits", systemImage: "list.bullet", value: AppTab.habits) {
                HabitsListView()
            }

            Tab("Rating", systemImage: "star.fill", value: AppTab.rating) {
                RatingView()
            }

            Tab("Me", systemImage: "person.fill", value: AppTab.me) {
                MeView()
                    .onAppear {
                        AdManager.requestATTPermission(with: 1)
                    }
            }
        }
    }

    var tabViewLegacy: some View {
        TabView {
            TodayView()
                .tabItem { Label("Today", systemImage: "calendar") }
                .onAppear { AdManager.requestATTPermission(with: 3) }

            HabitsListView()
                .tabItem { Label("Habits", systemImage: "list.bullet") }

            RatingView()
                .tabItem { Label("Rating", systemImage: "star.fill") }

            MeView()
                .tabItem { Label("Me", systemImage: "person.fill") }
                .onAppear { AdManager.requestATTPermission(with: 1) }
        }
    }

    private func requestNotificationPermissions() async {
        @Dependency(\.notificationService) var notificationService
        await notificationService.requestPermission()
        await notificationService.printAllNotifications()
    }
}
