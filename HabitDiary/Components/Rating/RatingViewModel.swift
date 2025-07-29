//
// Created by Banghua Zhao on 01/01/2025
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation
import SharingGRDB
import SwiftNavigation

@Observable
@MainActor
class RatingViewModel {
    var scoreBreakdown: HabitScoreBreakdown?
    var scoreBreakdownItems: [ScoreBreakdownItem]?
    var isLoading = false
    
    @ObservationIgnored
    @Dependency(\.ratingService) private var ratingService
    
    @CasePathable
    enum Route {
        case scoreBreakdownDetail(ScoreDetailViewModel)
        case ratingSystemExplanation
    }
    var route: Route?
    
    func loadRatingData() async {
        isLoading = true
        
        scoreBreakdown = ratingService.calculateHabitScore()
        scoreBreakdownItems = ratingService.getScoreBreakdown()
        
        isLoading = false
    }
    
    func refreshData() async {
        await loadRatingData()
    }
    
    func onTapScoreBreakdownItem(_ item: ScoreBreakdownItem) {
        let detailViewModel = ScoreDetailViewModel(category: item.category)
        route = .scoreBreakdownDetail(detailViewModel)
    }
    
    func onTapRatingCard() {
        route = .ratingSystemExplanation
    }
    
    func createShareText() -> String {
        guard let breakdown = scoreBreakdown else {
            return String(localized: "My Habit Rating - Loading...")
        }
        
        var shareText = "🏆 My Habit Rating: \(breakdown.rating.displayName) (\(breakdown.rating.description))\n"
        shareText += "📊 Total Score: \(breakdown.totalScore)/1200 points\n\n"
        
        if let items = scoreBreakdownItems {
            shareText += "📈 Score Breakdown:\n"
            for item in items {
                let percentage = Int(item.percentage * 100)
                shareText += "• \(item.title): \(item.score)/\(item.maxScore) (\(percentage)%)\n"
            }
        }
        
        if let nextRating = breakdown.nextRating {
            shareText += "\n🎯 Next Goal: \(nextRating.displayName) (\(nextRating.description)) - \(breakdown.scoreToNextRating) more points needed"
        }
        
        shareText += "\n\n📱 Tracked with Habit Diary"
        
        return shareText
    }
}
