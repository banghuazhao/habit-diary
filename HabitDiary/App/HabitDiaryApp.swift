//
// Created by Banghua Zhao on 31/05/2025
// Copyright Apps Bay Limited. All rights reserved.
//

import SQLiteData
import SwiftUI
import GoogleMobileAds

// MARK: - Tab enum for type-safe selection
enum AppTab: String, Hashable {
    case journal
    case library
    case insights
    case profile
}

@main
struct HabitDiaryApp: App {
    @AppStorage("darkModeEnabled") private var darkModeEnabled: Bool = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @Dependency(\.badgeService) private var badgeService
    @Dependency(\.themeManager) private var themeManager
    @Dependency(\.premiumAccessManager) private var premiumAccessManager
    @StateObject private var openAd = OpenAd()
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab: AppTab = .journal

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
                    if let achievementToShow = badgeService.achievementToShow {
                        BadgeUnlockedPopup(
                            achievement: achievementToShow,
                            isPresented: Binding(
                                get: { badgeService.achievementToShow != nil },
                                set: { if !$0 { badgeService.achievementToShow = nil } }
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
                        if !premiumAccessManager.isPremiumUserPurchased {
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
                    WelcomeFlowView()
                }
        }
    }

    @available(iOS 18.0, *)
    var tabViewModern: some View {
        TabView(selection: $selectedTab) {
            Tab(String(localized: "Journal"), systemImage: "book.pages.fill", value: AppTab.journal) {
                JournalHomeView()
                    .onAppear {
                        AdCoordinator.requestATTPermission(with: 3)
                    }
            }

            Tab(String(localized: "Library"), systemImage: "books.vertical.fill", value: AppTab.library) {
                HabitLibraryView()
            }

            Tab(String(localized: "Insights"), systemImage: "chart.line.text.clipboard.fill", value: AppTab.insights) {
                InsightsView()
            }

            Tab(String(localized: "Profile"), systemImage: "person.crop.square.fill", value: AppTab.profile) {
                ReaderProfileView()
                    .onAppear {
                        AdCoordinator.requestATTPermission(with: 1)
                    }
            }
        }
    }

    var tabViewLegacy: some View {
        TabView {
            JournalHomeView()
                .tabItem { Label(String(localized: "Journal"), systemImage: "book.pages.fill") }
                .onAppear { AdCoordinator.requestATTPermission(with: 3) }

            HabitLibraryView()
                .tabItem { Label(String(localized: "Library"), systemImage: "books.vertical.fill") }

            InsightsView()
                .tabItem { Label(String(localized: "Insights"), systemImage: "chart.line.text.clipboard.fill") }

            ReaderProfileView()
                .tabItem { Label(String(localized: "Profile"), systemImage: "person.crop.square.fill") }
                .onAppear { AdCoordinator.requestATTPermission(with: 1) }
        }
    }

    private func requestNotificationPermissions() async {
        @Dependency(\.reminderNotificationCenter) var reminderNotificationCenter
        await reminderNotificationCenter.requestPermission()
        await reminderNotificationCenter.printAllNotifications()
    }
}
