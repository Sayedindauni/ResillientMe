//
//  InsightsView.swift
//  ResilientMe
//
//  Created by Sayed Mohamed on 21.03.25.
//

import SwiftUI
import Charts
import CoreData
import Combine

struct InsightsView: View {
    @ObservedObject var moodAnalysisEngine: MoodAnalysisEngine
    @ObservedObject private var strategyStore = StrategyEffectivenessStore.shared
    @State private var selectedTimeFrame: TimeFrame = .week
    @State private var showingRecommendations = false
    @State private var animateCharts = false
    @State private var showingStrategyDetails = false
    @State private var selectedStrategy: String?
    @Environment(\.managedObjectContext) private var viewContext
    
    // Add explicit initializer
    init(moodAnalysisEngine: MoodAnalysisEngine) {
        self.moodAnalysisEngine = moodAnalysisEngine
    }
    
    enum TimeFrame: String, CaseIterable, Identifiable {
        case day = "Today"
        case week = "This Week"
        case month = "This Month"
        
        var id: String { self.rawValue }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Time frame picker
                    Picker("Time Frame", selection: $selectedTimeFrame) {
                        ForEach(TimeFrame.allCases) { timeFrame in
                            Text(timeFrame.rawValue).tag(timeFrame)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Recommendations card if available
                    if !moodAnalysisEngine.currentRecommendations.isEmpty {
                        recommendationsCard
                    }
                    
                    // Mood distribution chart
                    moodDistributionCard
                    
                    // Intensity trends chart
                    intensityTrendsCard
                    
                    // Rejection triggers breakdown
                    rejectionTriggersCard
                    
                    // Coping strategies effectiveness
                    copingStrategiesCard
                    
                    // Strategy rating effectiveness
                    strategyEffectivenessCard
                    
                    // Strategy usage progress
                    strategyUsageCard
                    
                    // Milestone celebrations
                    if let milestone = getMilestoneAchievement() {
                        milestoneCard(milestone)
                    }
                }
                .padding()
                .onAppear {
                    // Animate charts when view appears
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeInOut(duration: 1.0)) {
                            animateCharts = true
                        }
                    }
                }
            }
            .navigationTitle("Insights")
            .background(Color(UIColor(named: "Background") ?? .systemBackground).ignoresSafeArea())
        }
        .sheet(isPresented: $showingRecommendations) {
            PersonalizedFeedbackView(analysisEngine: moodAnalysisEngine)
        }
        .sheet(isPresented: $showingStrategyDetails) {
            if let strategy = selectedStrategy {
                StrategyDetailsView(strategyName: strategy)
            }
        }
    }
    
    // MARK: - Recommendations Card
    
    private var recommendationsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 20))
                    .foregroundColor(Color("Primary"))
                
                Text("Personalized Recommendations")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if moodAnalysisEngine.hasNewRecommendations {
                    Text("New")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color("Accent1"))
                        .cornerRadius(10)
                }
            }
            
            let recommendation = moodAnalysisEngine.currentRecommendations.first!
            
            Text(recommendation.title)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Text(recommendation.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            
            Button(action: {
                showingRecommendations = true
                moodAnalysisEngine.hasNewRecommendations = false
            }) {
                Text("View All Recommendations")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("Primary"))
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Mood Distribution Card
    
    private var moodDistributionCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Mood Distribution")
                .font(.headline)
                .foregroundColor(.primary)
            
            // This would be a placeholder for real chart data from MoodStore
            Chart {
                ForEach(dummyMoodData) { item in
                    BarMark(
                        x: .value("Mood", item.mood),
                        y: .value("Count", animateCharts ? item.count : 0)
                    )
                    .foregroundStyle(Color(getMoodColor(mood: item.mood)))
                    .cornerRadius(8)
                }
            }
            .frame(height: 200)
            .chartYScale(domain: [0, 10])
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Intensity Trends Card
    
    private var intensityTrendsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Intensity Trends")
                .font(.headline)
                .foregroundColor(.primary)
            
            // This would be a placeholder for real chart data from MoodStore
            Chart {
                ForEach(dummyIntensityData) { item in
                    LineMark(
                        x: .value("Day", item.day),
                        y: .value("Intensity", animateCharts ? item.intensity : 0)
                    )
                    .foregroundStyle(Color("Primary"))
                    .interpolationMethod(.catmullRom)
                    
                    PointMark(
                        x: .value("Day", item.day),
                        y: .value("Intensity", animateCharts ? item.intensity : 0)
                    )
                    .foregroundStyle(Color("Primary"))
                }
            }
            .frame(height: 200)
            .chartYScale(domain: [0, 10])
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Rejection Triggers Card
    
    private var rejectionTriggersCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Rejection Triggers")
                .font(.headline)
                .foregroundColor(.primary)
            
            // This would be a placeholder for real chart data from MoodStore
            Chart {
                ForEach(dummyTriggerData) { item in
                    SectorMark(
                        angle: .value("Percentage", animateCharts ? item.percentage : 0),
                        innerRadius: .ratio(0.5),
                        angularInset: 1.5
                    )
                    .cornerRadius(5)
                    .foregroundStyle(Color(getTriggerColor(trigger: item.category)))
                }
            }
            .frame(height: 200)
            
            // Legend
            VStack(alignment: .leading, spacing: 8) {
                ForEach(dummyTriggerData) { item in
                    HStack {
                        Circle()
                            .fill(Color(getTriggerColor(trigger: item.category)))
                            .frame(width: 10, height: 10)
                        
                        Text(item.category)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(item.percentage))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Coping Strategies Card
    
    private var copingStrategiesCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Coping Strategies Effectiveness")
                .font(.headline)
                .foregroundColor(.primary)
            
            // This would be a placeholder for real chart data from MoodStore
            VStack(spacing: 12) {
                ForEach(dummyStrategiesData) { item in
                    HStack {
                        Text(item.strategy)
                            .font(.body)
                            .foregroundColor(.primary)
                            .frame(width: 120, alignment: .leading)
                        
                        Spacer()
                        
                        // Progress bar
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 12)
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color("Secondary"))
                                .frame(width: animateCharts ? (CGFloat(item.effectiveness) / 100.0 * 200.0) : 0, height: 12)
                        }
                        .frame(width: 200)
                        
                        Text("\(item.effectiveness)%")
                            .font(.caption)
                            .foregroundColor(.primary)
                            .frame(width: 40, alignment: .trailing)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Strategy Effectiveness Card
    
    private var strategyEffectivenessCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Card header
            HStack {
                Image(systemName: "star.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color("Primary"))
                
                Text("Strategy Effectiveness")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    // Open more details
                }) {
                    Text("Details")
                        .font(.caption)
                        .foregroundColor(Color("Primary"))
                }
            }
            
            // Chart section
            VStack(alignment: .leading, spacing: 12) {
                if strategyStore.ratingData.isEmpty {
                    emptyStrategyCard
                } else {
                    effectivenessChartSection
                }
            }
            .padding()
            .background(Color("CardBackground"))
            .cornerRadius(12)
            
            // Tap to view more details
            Text("Tap on a strategy to see detailed progress")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color("CardBackground"))
        .cornerRadius(12)
    }
    
    private var effectivenessChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Most Effective Strategies")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            effectivenessChart
            
            // Legend
            HStack {
                Text("1")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("5")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, -8)
        }
    }
    
    private var effectivenessChart: some View {
        Chart {
            ForEach(Array(strategyStore.getMostEffectiveStrategies().enumerated()), id: \.element.strategy) { index, item in
                BarMark(
                    x: .value("Effectiveness", animateCharts ? item.rating : 0),
                    y: .value("Strategy", shortenStrategy(item.strategy))
                )
                .foregroundStyle(getColorForRating(item.rating))
            }
        }
        .frame(height: min(CGFloat(strategyStore.getMostEffectiveStrategies().count * 50), 200))
        .animation(.easeInOut, value: animateCharts)
    }
    
    // MARK: - Strategy Usage Progress
    
    private var strategyUsageCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Card header
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color("Primary"))
                
                Text("Strategy Usage")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    // Open more details
                }) {
                    Text("Details")
                        .font(.caption)
                        .foregroundColor(Color("Primary"))
                }
            }
            
            // Chart section
            VStack(alignment: .leading, spacing: 12) {
                if strategyStore.ratingData.isEmpty {
                    emptyStrategyCard
                } else {
                    strategyUsageSection
                }
            }
            .padding()
            .background(Color("CardBackground"))
            .cornerRadius(12)
            
            // Tap to view more details
            Text("Tap on a strategy to see detailed progress")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color("CardBackground"))
        .cornerRadius(12)
    }
    
    private var strategyUsageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Most Used Strategies")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            strategyUsageChart
            
            // Legend
            HStack {
                Text("0")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(strategyStore.getMostUsedStrategies().map { $0.count }.max() ?? 0)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, -8)
        }
    }
    
    private var strategyUsageChart: some View {
        Chart {
            ForEach(Array(strategyStore.getMostUsedStrategies().enumerated()), id: \.element.strategy) { index, item in
                BarMark(
                    x: .value("Usage", animateCharts ? Double(item.count) : 0),
                    y: .value("Strategy", shortenStrategy(item.strategy))
                )
                .foregroundStyle(Color("Primary").opacity(0.8))
            }
        }
        .frame(height: min(CGFloat(strategyStore.getMostUsedStrategies().count * 50), 200))
        .animation(.easeInOut, value: animateCharts)
    }
    
    private func milestoneCard(_ milestone: Milestone) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Card header with celebration icon
            HStack {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.yellow)
                
                Text("Milestone Achieved!")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("New")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange)
                    .cornerRadius(12)
            }
            
            // Milestone details
            VStack(alignment: .leading, spacing: 12) {
                Text(milestone.title)
                    .font(.title3)
                    .foregroundColor(.primary)
                    .bold()
                
                Text(milestone.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                // Visual representation of achievement
                HStack(spacing: 0) {
                    ForEach(0..<5) { i in
                        Image(systemName: "star.fill")
                            .foregroundColor(i < milestone.level ? .yellow : Color.gray.opacity(0.3))
                            .font(.system(size: 24))
                    }
                }
                .padding(.vertical, 8)
                
                // Share button
                Button(action: {
                    // Share milestone
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share Achievement")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .background(Color("Primary"))
                    .cornerRadius(8)
                }
            }
            .padding()
            .background(Color("CardBackground"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(LinearGradient(
                        gradient: Gradient(colors: [.yellow, .orange]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ), lineWidth: 2)
            )
        }
        .padding()
        .background(Color("CardBackground"))
        .cornerRadius(12)
    }
    
    private var emptyStrategyCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "star.slash")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
                .padding()
            
            Text("No strategy ratings yet")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Rate your strategies to track their effectiveness")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
    
    // MARK: - Helper Functions
    
    private func getMoodColor(mood: String) -> UIColor {
        switch mood {
        case "Joyful": return UIColor(named: "Joy") ?? .systemYellow
        case "Content": return UIColor(named: "Calm") ?? .systemBlue
        case "Neutral": return UIColor.lightGray
        case "Sad": return UIColor(named: "Sadness") ?? .systemIndigo
        case "Frustrated": return UIColor(named: "Frustration") ?? .systemOrange
        case "Stressed": return UIColor(named: "Stressed") ?? .systemRed
        default: return UIColor(named: "Primary") ?? .systemBlue
        }
    }
    
    private func getTriggerColor(trigger: String) -> UIColor {
        switch trigger {
        case "Social": return UIColor(named: "Primary") ?? .systemBlue
        case "Work": return UIColor(named: "Secondary") ?? .systemGreen
        case "Family": return UIColor(named: "Accent1") ?? .systemOrange
        case "Academic": return UIColor(named: "Accent2") ?? .systemPurple
        default: return UIColor.lightGray
        }
    }
    
    // MARK: - Dummy Data for Preview
    
    // Mood distribution data
    struct MoodCount: Identifiable {
        let id = UUID()
        let mood: String
        let count: Int
    }
    
    private var dummyMoodData: [MoodCount] = [
        MoodCount(mood: "Joyful", count: 8),
        MoodCount(mood: "Content", count: 10),
        MoodCount(mood: "Neutral", count: 5),
        MoodCount(mood: "Sad", count: 6),
        MoodCount(mood: "Frustrated", count: 4),
        MoodCount(mood: "Stressed", count: 7)
    ]
    
    // Intensity trends data
    struct IntensityDay: Identifiable {
        let id = UUID()
        let day: String
        let intensity: Double
    }
    
    private var dummyIntensityData: [IntensityDay] = [
        IntensityDay(day: "Mon", intensity: 4.5),
        IntensityDay(day: "Tue", intensity: 6.0),
        IntensityDay(day: "Wed", intensity: 5.5),
        IntensityDay(day: "Thu", intensity: 3.0),
        IntensityDay(day: "Fri", intensity: 4.0),
        IntensityDay(day: "Sat", intensity: 7.5),
        IntensityDay(day: "Sun", intensity: 6.5)
    ]
    
    // Rejection triggers data
    struct TriggerPercentage: Identifiable {
        let id = UUID()
        let category: String
        let percentage: Double
    }
    
    private var dummyTriggerData: [TriggerPercentage] = [
        TriggerPercentage(category: "Social", percentage: 45),
        TriggerPercentage(category: "Work", percentage: 30),
        TriggerPercentage(category: "Family", percentage: 15),
        TriggerPercentage(category: "Academic", percentage: 10)
    ]
    
    // Coping strategies data
    struct StrategyEffectiveness: Identifiable {
        let id = UUID()
        let strategy: String
        let effectiveness: Int
    }
    
    private var dummyStrategiesData: [StrategyEffectiveness] = [
        StrategyEffectiveness(strategy: "Meditation", effectiveness: 85),
        StrategyEffectiveness(strategy: "Exercise", effectiveness: 75),
        StrategyEffectiveness(strategy: "Journaling", effectiveness: 65),
        StrategyEffectiveness(strategy: "Social Support", effectiveness: 90),
        StrategyEffectiveness(strategy: "Reframing", effectiveness: 70)
    ]
    
    // MARK: - Helper Functions for Strategy Tracking
    
    private func shortenStrategy(_ strategy: String) -> String {
        return strategy.count > 25 ? strategy.prefix(22) + "..." : strategy
    }
    
    private func getColorForRating(_ rating: Double) -> Color {
        switch rating {
        case 0..<2:
            return .red
        case 2..<3:
            return .orange
        case 3..<4:
            return .yellow
        case 4...5:
            return .green
        default:
            return .gray
        }
    }
    
    struct Milestone {
        let id = UUID()
        let title: String
        let description: String
        let level: Int // 1-5 stars
    }
    
    private func getMilestoneAchievement() -> Milestone? {
        // Check for consistent high ratings milestone
        if !strategyStore.ratingData.isEmpty {
            let highRatings = strategyStore.ratingData.filter { $0.rating >= 4 }.count
            let totalRatings = strategyStore.ratingData.count
            let ratio = Double(highRatings) / Double(totalRatings)
            
            if totalRatings >= 5 && ratio >= 0.8 {
                return Milestone(
                    title: "Strategy Mastery",
                    description: "You've found strategies that work exceptionally well! You rated 80% of your strategies as highly effective.",
                    level: 5
                )
            }
        }
        
        // Check for usage consistency milestone
        let mostUsedStrategies = strategyStore.getMostUsedStrategies()
        if let mostUsedStrategy = mostUsedStrategies.first,
           mostUsedStrategy.count >= 5 {
            return Milestone(
                title: "Consistency Champion",
                description: "You've used the same strategy 5+ times, showing great commitment to building resilience habits!",
                level: 4
            )
        }
        
        // Check for diversity milestone
        let uniqueStrategies = Set(strategyStore.ratingData.map { $0.strategy }).count
        if uniqueStrategies >= 3 {
            return Milestone(
                title: "Strategy Explorer",
                description: "You've tried 3 or more different coping strategies. Exploring different approaches leads to better resilience!",
                level: 3
            )
        }
        
        // First rating milestone
        if strategyStore.ratingData.count == 1 {
            return Milestone(
                title: "First Step Complete",
                description: "You've completed and rated your first coping strategy. This is the first step to building resilience!",
                level: 1
            )
        }
        
        return nil
    }
}

// MARK: - Strategy Details View

struct StrategyDetailsView: View {
    let strategyName: String
    @ObservedObject private var strategyStore = StrategyEffectivenessStore.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var animateCharts = false
    
    private var averageRating: String {
        String(format: "%.1f", strategyStore.getAverageRating(for: strategyName))
    }
    
    private var completionCount: String {
        "\(strategyStore.getCompletionCount(for: strategyName))"
    }
    
    private var ratingHistory: [(date: Date, rating: Int)] {
        strategyStore.getRatingHistory(for: strategyName)
    }
    
    private var hasRatingHistory: Bool {
        !ratingHistory.isEmpty
    }
    
    private var averageRatingValue: Double {
        strategyStore.getAverageRating(for: strategyName)
    }
    
    private var chartContent: some View {
        Chart {
            ForEach(Array(ratingHistory.enumerated()), id: \.offset) { index, rating in
                LineMark(
                    x: .value("Use", index + 1),
                    y: .value("Rating", animateCharts ? Double(rating.rating) : 0)
                )
                .foregroundStyle(Color("Primary"))
                
                PointMark(
                    x: .value("Use", index + 1),
                    y: .value("Rating", animateCharts ? Double(rating.rating) : 0)
                )
                .foregroundStyle(Color("Primary"))
            }
            
            RuleMark(y: .value("Average", averageRatingValue))
                .foregroundStyle(.gray.opacity(0.5))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                .annotation(position: .top, alignment: .trailing) {
                    Text("Average: \(averageRating)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
        }
        .frame(height: 200)
        .animation(.easeInOut, value: animateCharts)
    }
    
    private var ratingHistorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Strategy Usage History")
                .font(.headline)
                .foregroundColor(.primary)
            
            if !ratingHistory.isEmpty {
                ForEach(Array(ratingHistory.enumerated()), id: \.offset) { index, rating in
                    ratingHistoryRow(rating)
                }
            } else {
                Text("No usage history available yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
            }
        }
        .padding()
        .background(Color("CardBackground"))
        .cornerRadius(12)
    }
    
    private func ratingHistoryRow(_ rating: (date: Date, rating: Int)) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(formatDate(rating.date))
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // Rating stars
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { i in
                    Image(systemName: i <= rating.rating ? "star.fill" : "star")
                        .font(.system(size: 12))
                        .foregroundColor(i <= rating.rating ? .yellow : .gray)
                }
            }
        }
        .padding()
        .background(Color("Background"))
        .cornerRadius(8)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Overview card
                    VStack(alignment: .leading, spacing: 16) {
                        Text(strategyName)
                            .font(.title2)
                            .foregroundColor(.primary)
                            .bold()
                        
                        HStack(spacing: 24) {
                            statCard(
                                value: averageRating,
                                label: "Average Rating",
                                icon: "star.fill",
                                color: .yellow
                            )
                            
                            statCard(
                                value: completionCount,
                                label: "Times Used",
                                icon: "checkmark.circle.fill",
                                color: Color("Primary")
                            )
                        }
                    }
                    .padding()
                    .background(Color("CardBackground"))
                    .cornerRadius(12)
                    
                    // Effectiveness trend chart
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Effectiveness Over Time")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if hasRatingHistory {
                            chartContent
                            
                            Text("Your ratings show how this strategy's effectiveness has changed over time")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                        } else {
                            Text("No rating history available yet")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 60)
                        }
                    }
                    .padding()
                    .background(Color("CardBackground"))
                    .cornerRadius(12)
                    
                    // Use history
                    ratingHistorySection
                }
                .padding()
            }
            .navigationTitle("Strategy Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                // Animate charts when view appears
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        animateCharts = true
                    }
                }
            }
        }
    }
    
    private func statCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color("Background"))
        .cornerRadius(8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Remove this preview provider for now as it may reference unavailable components
/*struct InsightsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let moodStore = MoodStore(context: context)
        let analysisEngine = MoodAnalysisEngine(moodStore: moodStore)
        
        InsightsView(moodAnalysisEngine: analysisEngine)
            .environment(\.managedObjectContext, context)
    }
}*/ 
