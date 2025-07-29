//
// Created by Banghua Zhao on 01/01/2025
// Copyright Apps Bay Limited. All rights reserved.
//

import SwiftUI
import SharingGRDB

struct RatingView: View {
    @State private var viewModel = RatingViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Rating Card
                    ratingCard
                    
                    // Motivational Message Card
                    if let breakdown = viewModel.scoreBreakdown {
                        motivationalCard(rating: breakdown.rating)
                    }
                    
                    // Score Breakdown
                    scoreBreakdownSection
                }
                .padding()
            }
            .appBackground()
            .navigationTitle(String(localized: "Habit Rating"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ShareLink(
                        item: viewModel.createShareText(),
                        subject: Text(String(localized: "My Habit Rating")),
                        message: Text(String(localized: "Check out my Habit rating from Habit Diary!"))
                    ) {
                        Image(systemName: "square.and.arrow.up")
                            .appCircularButtonStyle()
                    }
                }
            }
            .refreshable {
                await viewModel.loadRatingData()
            }
            .task {
                await viewModel.loadRatingData()
            }
            .sheet(item: $viewModel.route.scoreBreakdownDetail, id: \.self) { scoreDetailViewModel in
                ScoreDetailView(viewModel: scoreDetailViewModel)
            }
            .sheet(
                isPresented: Binding($viewModel.route.ratingSystemExplanation)
            ) {
                RatingSystemExplanationView()
            }
        }
    }
    
    private var ratingCard: some View {
        VStack(spacing: 16) {
            if let breakdown = viewModel.scoreBreakdown {
                // Rating Display
                VStack(spacing: 8) {
                    Text(breakdown.rating.displayName)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(breakdown.rating.color)
                    
                    Text(breakdown.rating.description)
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text(String(localized: "\(breakdown.totalScore) points"))
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                // Score Progress Bar
                VStack(spacing: 8) {
                    HStack {
                        Text(String(localized: "Total Score"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(localized: "\(breakdown.totalScore)/\(breakdown.maxPossibleScore)"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    ProgressView(value: breakdown.overallProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: breakdown.rating.color))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                    
                    // Progress within current rating
                    HStack {
                        Text(String(localized: "Progress in \(breakdown.rating.description)"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.1f%%", breakdown.progressInCurrentRating * 100))
                            .font(.caption)
                            .foregroundColor(breakdown.rating.color)
                    }
                    
                    ProgressView(value: breakdown.progressInCurrentRating)
                        .progressViewStyle(LinearProgressViewStyle(tint: breakdown.rating.color.opacity(0.7)))
                        .scaleEffect(x: 1, y: 1.5, anchor: .center)
                }
                
                if let nextRating = viewModel.scoreBreakdown?.nextRating {
                    progressToNextRatingCard(nextRating: nextRating)
                }
            } else {
                ProgressView()
                    .scaleEffect(1.5)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .onTapGesture {
            viewModel.onTapRatingCard()
        }
    }
    
    private func motivationalCard(rating: HabitRating) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "quote.bubble.fill")
                    .foregroundColor(rating.color)
                    .font(.title3)
                
                Text(String(localized: "Motivation"))
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Text(rating.motivationalMessage)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(rating.color.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(rating.color.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func progressToNextRatingCard(nextRating: HabitRating) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "arrow.up.circle.fill")
                    .foregroundColor(nextRating.color)
                Text(String(localized: "Progress to \(nextRating.displayName)"))
                    .font(.headline)
                Spacer()
            }
            
            if let breakdown = viewModel.scoreBreakdown {
                VStack(spacing: 8) {
                    HStack {
                        Text(String(localized: "\(breakdown.scoreToNextRating) points needed"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(nextRating.description)
                            .font(.subheadline)
                            .foregroundColor(nextRating.color)
                    }
                    
                    // Show score range for next rating
                    HStack {
                        Text(String(localized: "Range: \(nextRating.scoreRange.lowerBound) - \(nextRating.scoreRange.upperBound == Int.max ? "∞" : "\(nextRating.scoreRange.upperBound)") points"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
        }
    }
    
    private var scoreBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(String(localized: "Score Breakdown"))
                .font(.title2)
                .fontWeight(.bold)
            
            if let breakdownItems = viewModel.scoreBreakdownItems {
                LazyVStack(spacing: 12) {
                    ForEach(Array(breakdownItems.enumerated()), id: \.offset) { index, item in
                        ScoreBreakdownRow(item: item)
                            .onTapGesture {
                                viewModel.onTapScoreBreakdownItem(item)
                            }
                    }
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            
        }
    }
    
    struct ScoreBreakdownRow: View {
        let item: ScoreBreakdownItem
        
        @State var isInfoPresented: Bool = false
        
        var body: some View {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: item.icon)
                        .foregroundColor(item.color)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text(item.performanceLevel.description)
                            .font(.caption)
                            .foregroundColor(item.performanceLevel.color)
                    }
                    
                    Button(action: {
                        isInfoPresented.toggle()
                    }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16))
                    }
                    .buttonStyle(.borderless)
                    .popover(isPresented: $isInfoPresented) {
                        ScrollView {
                            VStack(spacing: 16) {
                                Text(String(localized: "How \(item.title) Score is Calculated"))
                                    .font(.headline)
                                    .multilineTextAlignment(.center)
                                
                                Text(item.explanation)
                                    .font(.body)
                                    .multilineTextAlignment(.leading)
                                
                                // Performance level explanation
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(String(localized: "Your Performance:"))
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Text(item.performanceLevel.description)
                                            .font(.subheadline)
                                            .foregroundColor(item.performanceLevel.color)
                                    }
                                    
                                    Text(String(format: "%.1f%% of maximum possible score", item.percentage * 100))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.top, 8)
                            }
                            .frame(minHeight: 200)
                        }
                        .padding()
                        .presentationCompactAdaptation(.popover)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(String(localized: "\(item.score)/\(item.maxScore)"))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Text(String(format: "%.0f%%", item.percentage * 100))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Progress bar with performance color
                VStack(spacing: 4) {
                    ProgressView(value: item.percentage)
                        .progressViewStyle(LinearProgressViewStyle(tint: item.performanceLevel.color))
                        .scaleEffect(x: 1, y: 1.5, anchor: .center)
                    
                    // Performance level indicator
                    HStack {
                        Spacer()
                        HStack(spacing: 4) {
                            Circle()
                                .fill(item.performanceLevel.color)
                                .frame(width: 6, height: 6)
                            Text(item.performanceLevel.description)
                                .font(.caption2)
                                .foregroundColor(item.performanceLevel.color)
                        }
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(item.performanceLevel.color.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
    }
}

#Preview {
    let _ = prepareDependencies {
        $0.defaultDatabase = try! appDatabase()
    }
    RatingView()
}

