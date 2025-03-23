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
    @State private var selectedTimeFrame: TimeFrame = .week
    @State private var showingRecommendations = false
    @State private var animateCharts = false
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