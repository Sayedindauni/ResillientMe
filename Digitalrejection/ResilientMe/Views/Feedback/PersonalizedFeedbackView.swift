//
//  PersonalizedFeedbackView.swift
//  ResilientMe
//
//  Created by Sayed Mohamed on 21.03.25.
//

import SwiftUI
import CoreData
// Import app module
import ResilientMe

// MARK: - Type Definitions

// Define what we need from the ResilientMe module locally
struct EngineMoodRecommendation: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let triggerPattern: String
    let strategies: [Any] // This would be the actual type in the project
    let resources: [EngineRecommendedResource]
    let confidenceLevel: Double // 0.0-1.0 representing AI confidence
    
    // Add additional properties
    var rationale: String = "Understanding your emotional patterns can help build resilience and improve well-being over time."
    var suggestedStrategies: [ViewStrategyDetail]? = nil
    
    // Add convenience initializer that takes a string ID
    init(id: String, title: String, description: String, triggerPattern: String, strategies: [Any], resources: [EngineRecommendedResource], confidenceLevel: Double) {
        self.id = UUID(uuidString: id) ?? UUID()
        self.title = title
        self.description = description
        self.triggerPattern = triggerPattern
        self.strategies = strategies
        self.resources = resources
        self.confidenceLevel = confidenceLevel
    }
    
    // Standard initializer
    init(id: UUID, title: String, description: String, triggerPattern: String, strategies: [Any], resources: [EngineRecommendedResource], confidenceLevel: Double) {
        self.id = id
        self.title = title
        self.description = description
        self.triggerPattern = triggerPattern
        self.strategies = strategies
        self.resources = resources
        self.confidenceLevel = confidenceLevel
    }
    
    // Helper method to create preview data
    static func mockRecommendations(with strategies: [ViewStrategyDetail]) -> [EngineMoodRecommendation] {
        return [
            EngineMoodRecommendation(
                id: UUID(),
                title: "Improve Your Sleep Quality",
                description: "Your sleep patterns may be affecting your mood. Consider these strategies to improve your sleep quality.",
                triggerPattern: "Sleep disturbance",
                strategies: strategies,
                resources: [],
                confidenceLevel: 0.85
            ),
            EngineMoodRecommendation(
                id: UUID(),
                title: "Manage Stress with Mindfulness",
                description: "Regular mindfulness practice can help reduce stress and improve your emotional response.",
                triggerPattern: "Stress response",
                strategies: strategies,
                resources: [],
                confidenceLevel: 0.9
            )
        ]
    }
}

struct EngineRecommendedResource: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let type: ViewResourceType
    let url: URL?
    let source: String
    let isNew: Bool
}

// Define FeedbackData structure once, outside the PersonalizedFeedbackView
// Will be used by the view and other components
struct FeedbackData {
    let moodState: String
    let intensity: Int
    let situation: String
}

// Use fully qualified type names to avoid ambiguity
typealias AppMoodStoreProtocol = ResilientMe.MoodStoreProtocol

// MARK: - Type Aliases for Compatibility
// Update references to imported types - make sure these match the actual ResilientMe module types
// typealias EngineMoodRecommendation = ResilientMe.MoodRecommendation
// typealias EngineRecommendedResource = ResilientMe.RecommendedResource
// Use the MoodStore from ResilientMe module
// typealias MoodStore = ResilientMe.MoodStore

// MARK: - View-specific Types

// Define CopingStrategy Duration enum
enum ViewStrategyDuration: String, Identifiable, CaseIterable {
    case short = "5 min"
    case medium = "15 min" 
    case long = "30+ min"
    
    var id: String { self.rawValue }
    
    var iconName: String {
        switch self {
        case .short: return "timer"
        case .medium: return "clock"
        case .long: return "hourglass"
        }
    }
}

// Define CopingStrategy Category for View Layer
enum ViewStrategyCategory: String, CaseIterable, Identifiable {
    case mindfulness = "Mindfulness"
    case cognitive = "Cognitive"
    case physical = "Physical"
    case social = "Social"
    case creative = "Creative"
    case selfCare = "Self-Care"
    
    var id: String { self.rawValue }
    
    var displayName: String { self.rawValue }
    
    var iconName: String {
        switch self {
        case .mindfulness: return "brain.head.profile"
        case .cognitive: return "lightbulb"
        case .physical: return "figure.walk"
        case .social: return "person.2"
        case .creative: return "paintbrush"
        case .selfCare: return "heart"
        }
    }
    
    var color: Color {
        switch self {
        case .mindfulness: return .blue
        case .cognitive: return .purple
        case .physical: return Color(red: 0.2, green: 0.8, blue: 0.4)
        case .social: return Color(red: 0.6, green: 0.4, blue: 0.8)
        case .creative: return Color(red: 0.9, green: 0.3, blue: 0.5)
        case .selfCare: return Color(red: 0.9, green: 0.4, blue: 0.4)
        }
    }
}

// Define View-specific CopingStrategyDetail
struct ViewStrategyDetail: Identifiable {
    let id: UUID
    let name: String
    let description: String
    let category: ViewStrategyCategory
    let duration: ViewStrategyDuration
    let steps: [String]
    let benefits: [String]
    let researchBacked: Bool
}

// Define AppResourceType
enum ViewResourceType: String, Codable, CaseIterable, Identifiable {
    case article = "Article"
    case video = "Video"
    case audio = "Audio"
    case book = "Book"
    case app = "App"
    case exercise = "Exercise"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .article: return "doc.text"
        case .video: return "play.rectangle"
        case .audio: return "headphones"
        case .book: return "book"
        case .app: return "iphone"
        case .exercise: return "figure.walk"
        }
    }
    
    var color: Color {
        switch self {
        case .article: return .blue
        case .video: return .red
        case .audio: return .purple
        case .book: return .orange
        case .app: return .green
        case .exercise: return .teal
        }
    }
}

// Define ViewMoodRecommendation
struct ViewMoodRecommendation: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let triggerPattern: String
    let strategies: [ViewStrategyDetail]
    let resources: [EngineRecommendedResource]
    let confidenceLevel: Double // 0.0-1.0 representing AI confidence
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ViewMoodRecommendation, rhs: ViewMoodRecommendation) -> Bool {
        return lhs.id == rhs.id
    }
}

// MoodAnalysisEngine definition moved to /Models/MoodAnalysisEngine.swift

struct PersonalizedFeedbackView: View {
    @ObservedObject var analysisEngine: MoodAnalysisEngine
    @Environment(\.dismiss) private var dismiss
    @State private var selectedRecommendation: EngineMoodRecommendation?
    @State private var selectedStrategy: ViewStrategyDetail?
    @State private var selectedResource: EngineRecommendedResource?
    @State private var showingStrategyDetail = false
    @State private var showingResourceDetail = false
    @State private var recommendedStrategies: [ViewStrategyDetail] = []
    @State private var showingCopingStrategies = false
    @State private var copingStrategy: ViewStrategyDetail? = nil
    @State private var sampleRecommendations: [EngineMoodRecommendation] = []
    
    // Add feedback data property
    var feedbackData: FeedbackData?
    
    // Add initializer with optional feedback data
    init(analysisEngine: MoodAnalysisEngine, feedbackData: FeedbackData? = nil) {
        self.analysisEngine = analysisEngine
        self.feedbackData = feedbackData
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with AI badge
                    headerView
                    
                    // Recommendations list section
                    recommendationsSection
                    
                    // Selected recommendation details
                    if let recommendation = selectedRecommendation {
                        recommendationDetails(recommendation)
                    }
                    
                    // Add a section for coping strategies recommendations in your view
                    Section(header: Text("Recommended Strategies")) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Building resilience takes practice. Try these evidence-based techniques:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.bottom, 4)
                            
                            ForEach(recommendedStrategies.prefix(3), id: \.id) { strategy in
                                HStack {
                                    Image(systemName: strategy.category.iconName)
                                        .foregroundColor(strategy.category.color)
                                        .frame(width: 24, height: 24)
                                    
                                    VStack(alignment: .leading) {
                                        Text(strategy.name)
                                            .font(.system(size: 14, weight: .medium))
                                        
                                        Text(strategy.category.displayName + " • " + strategy.duration.rawValue)
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        copingStrategy = strategy
                                    }) {
                                        Text("View")
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(12)
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                            
                            Button(action: {
                                showingCopingStrategies = true
                            }) {
                                Text("See All Strategies")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Add the necessary sheets for viewing strategies
                    .sheet(isPresented: $showingCopingStrategies) {
                        getFeedbackCopingStrategiesLibraryView()
                    }
                    .sheet(item: $copingStrategy) { strategy in
                        CopingStrategyDetailView(strategy: strategy)
                    }
                }
                .padding(.vertical)
                .sheet(isPresented: $showingStrategyDetail) {
                    if let strategy = selectedStrategy {
                        FeedbackStrategyDetailView(strategy: strategy)
                    }
                }
                .sheet(isPresented: $showingResourceDetail) {
                    if let resource = selectedResource {
                        ResourceDetailView(resource: resource)
                    }
                }
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            #else
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            #endif
            .onAppear {
                loadRecommendations()
            }
        }
    }
    
    // MARK: - Component Views
    
    // Header view component
    private var headerView: some View {
        VStack(spacing: 16) {
            // AI Badge
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.purple)
                    .clipShape(Circle())
                
                Text("AI-Powered Insights")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.purple)
                
                Spacer()
                
                Text("Based on your mood data")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            // Main header
            Text("Your Personalized Recommendations")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            Text("These recommendations are based on your mood patterns and research-backed strategies")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
        }
    }
    
    // Recommendations section
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recommendations For You")
                .font(.headline)
                .padding(.horizontal)
            
            if analysisEngine.currentRecommendations.isEmpty {
                Text("No recommendations available yet. Check back later.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        // Mock recommendations for preview
                        ForEach(sampleRecommendations, id: \.id) { recommendation in
                            recommendationCard(recommendation)
                                .onTapGesture {
                                    withAnimation {
                                        selectedRecommendation = recommendation
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    // MARK: - Recommendation Card
    
    private func recommendationCard(_ recommendation: EngineMoodRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Tag and new/viewed indicator
            HStack {
                Text(getCategoryText(recommendation))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(getCategoryColor(for: getCategoryText(recommendation)))
                    .cornerRadius(4)
                
                Spacer()
                
                // New indicator
                Text("NEW")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.orange)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(4)
            }
            
            // Title
            Text(recommendation.title)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(2)
                .frame(height: 46, alignment: .leading)
            
            // Description
            Text(recommendation.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
                .frame(height: 60, alignment: .leading)
            
            // View more button
            Button(action: {
                withAnimation {
                    selectedRecommendation = recommendation
                }
            }) {
                Text("View More")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .frame(width: 280)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // Add helper method to get category text
    private func getCategoryText(_ recommendation: EngineMoodRecommendation) -> String {
        // Default category name if the one in the recommendation is not available
        return "MOOD PATTERNS"
    }
    
    // MARK: - Recommendation Details
    
    private func recommendationDetails(_ recommendation: EngineMoodRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(getCategoryText(recommendation))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(getCategoryColor(for: getCategoryText(recommendation)))
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    // Close button
                    Button(action: {
                        withAnimation {
                            selectedRecommendation = nil
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                    }
                }
                
                Text(recommendation.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.top, 4)
                
                // Insight description
                Text(recommendation.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)
            }
            
            // Divider
            Divider()
            
            // Detailed content
            VStack(alignment: .leading, spacing: 16) {
                Text("Why This Matters")
                    .font(.headline)
                
                Text(recommendation.rationale)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                // If strategies exist, display them
                if let strategies = recommendation.suggestedStrategies, !strategies.isEmpty {
                    Text("Suggested Strategies")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    ForEach(strategies.prefix(3), id: \.id) { strategy in
                        Button(action: {
                            self.selectedStrategy = strategy as? ViewStrategyDetail
                            self.showingStrategyDetail = true
                        }) {
                            strategyListItem(strategy)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            
            // Divider
            Divider()
            
            // Feedback buttons
            HStack(spacing: 20) {
                Button(action: {
                    // Mark as unhelpful
                    analysisEngine.markRecommendationAsUnhelpful(recommendation)
                    withAnimation {
                        selectedRecommendation = nil
                    }
                }) {
                    Text("Not Helpful")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                
                Button(action: {
                    // Mark as helpful
                    analysisEngine.markRecommendationAsHelpful(recommendation)
                    withAnimation {
                        selectedRecommendation = nil
                    }
                }) {
                    Text("Helpful")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 24)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 8)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
        .padding(.horizontal)
        .transition(.opacity)
    }
    
    private func strategyListItem(_ strategy: ViewStrategyDetail) -> some View {
        HStack(spacing: 16) {
            // Strategy icon
            Image(systemName: strategy.category.iconName)
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(getCategoryColor(for: strategy.category.displayName))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(strategy.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(strategy.duration.rawValue)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Helper Functions
    
    private func getCategoryColor(for category: String) -> Color {
        switch category.lowercased() {
        case "mood patterns": return .blue
        case "stress management": return .orange
        case "sleep": return .purple
        case "social connections": return .green
        case "self-care": return .pink
        default: return .gray
        }
    }
    
    // MARK: - Data Loading Methods
    
    private func loadRecommendations() {
        // Sample recommendations for demo
        if recommendedStrategies.isEmpty {
            loadRecommendedStrategies()
        }
        
        // Use our new mock data generator
        sampleRecommendations = EngineMoodRecommendation.mockRecommendations(with: recommendedStrategies)
    }
    
    // Load recommended strategies
    private func loadRecommendedStrategies() {
        // Populate sample strategies for demo/preview
        recommendedStrategies = [
            ViewStrategyDetail(
                id: UUID(),
                name: "Progressive Muscle Relaxation",
                description: "This technique involves tensing and relaxing different muscle groups to reduce physical tension.",
                category: .mindfulness,
                duration: .medium,
                steps: [
                    "Find a comfortable position in a quiet place.",
                    "Starting with your feet, tense the muscles as hard as you can for 5 seconds.",
                    "Release the tension suddenly and notice the feeling of relaxation.",
                    "Move to your calves, thighs, buttocks and continue upward through your body."
                ],
                benefits: [
                    "Reduces physical tension",
                    "Can help with insomnia and stress",
                    "Increases body awareness"
                ],
                researchBacked: true
            ),
            ViewStrategyDetail(
                id: UUID(),
                name: "5-4-3-2-1 Grounding Exercise",
                description: "This mindfulness technique uses your five senses to help you shift focus and connect with the present moment.",
                category: .cognitive,
                duration: .short,
                steps: [
                    "Acknowledge 5 things you see around you",
                    "Acknowledge 4 things you can touch around you",
                    "Acknowledge 3 things you hear",
                    "Acknowledge 2 things you can smell",
                    "Acknowledge 1 thing you can taste"
                ],
                benefits: [
                    "Helps manage anxiety",
                    "Brings attention to the present moment",
                    "Useful during stressful situations"
                ],
                researchBacked: true
            )
        ]
    }
    
    // MARK: - Helper Methods for Fixing Specific Compile Errors
    
    // If you're getting Extra argument 'feedbackData' in call, 
    // ensure all constructors match usage sites
    static func createFeedback(analysisEngine: MoodAnalysisEngine) -> Self {
        return PersonalizedFeedbackView(analysisEngine: analysisEngine)
    }
    
    // Provide a factory method for creating with feedback data
    static func createWithFeedback(analysisEngine: MoodAnalysisEngine, feedbackData: FeedbackData) -> Self {
        return PersonalizedFeedbackView(analysisEngine: analysisEngine, feedbackData: feedbackData)
    }
}

// MARK: - Strategy Detail View
// Renamed to avoid conflict with CopingStrategiesLibraryView

struct FeedbackStrategyDetailView: View {
    let strategy: ViewStrategyDetail
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header with category and time
                    HStack {
                        Label(
                            title: { Text(strategy.category.displayName) },
                            icon: { Image(systemName: strategy.category.iconName) }
                        )
                            .font(.caption)
                            .foregroundColor(strategy.category.color)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(strategy.category.color.opacity(0.1))
                            .cornerRadius(16)
                        
                        Spacer()
                        
                        Label(
                            title: { Text(strategy.duration.rawValue) },
                            icon: { Image(systemName: strategy.duration.iconName) }
                        )
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Strategy title and description
                    Text(strategy.name)
                        .font(.title)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(strategy.description)
                        .font(.body)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Steps section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Steps")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        ForEach(Array(strategy.steps.enumerated()), id: \.0) { index, step in
                            HStack(alignment: .top) {
                                Text("\(index + 1).")
                                    .font(.body.bold())
                                    .foregroundColor(strategy.category.color)
                                    .frame(width: 24, alignment: .center)
                                
                                Text(step)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    
                    // Benefits section
                    if !strategy.benefits.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Benefits")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            ForEach(strategy.benefits, id: \.self) { benefit in
                                HStack(alignment: .top) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(strategy.category.color)
                                        .font(.system(size: 16))
                                    
                                    Text(benefit)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Strategy Details")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            #else
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            #endif
        }
    }
}

// MARK: - Resource Detail View

struct ResourceDetailView: View {
    let resource: EngineRecommendedResource
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Resource type badge
                    Label(
                        title: { Text(resource.type.rawValue) },
                        icon: { Image(systemName: resource.type.iconName) }
                    )
                        .font(.subheadline)
                        .foregroundColor(.blue) // Simplified
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1)) // Simplified
                        .cornerRadius(16)
                    
                    // Title and source
                    Text(resource.title)
                        .font(.title)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if !resource.source.isEmpty {
                        Text("Source: \(resource.source)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Description
                    Text(resource.description)
                        .font(.body)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // External link if available
                    if let url = resource.url {
                        Button(action: {
                            openURL(url)
                        }) {
                            Label("Open External Resource", systemImage: "link")
                                .font(.body)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue) // Simplified
                                .cornerRadius(12) // Used explicit value
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            #else
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            #endif
        }
    }
}

// MARK: - CopingStrategyDetailView

struct CopingStrategyDetailView: View {
    let strategy: ViewStrategyDetail
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header with category and time
                    HStack {
                        Label(
                            title: { Text(strategy.category.displayName) },
                            icon: { Image(systemName: strategy.category.iconName) }
                        )
                        .font(.caption)
                        .foregroundColor(strategy.category.color)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(strategy.category.color.opacity(0.1))
                        .cornerRadius(16)
                        
                        Spacer()
                        
                        Label(
                            title: { Text(strategy.duration.rawValue) },
                            icon: { Image(systemName: "clock") }
                        )
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    
                    // Strategy title and description
                    Text(strategy.name)
                        .font(.title)
                        .foregroundColor(.primary)
                    
                    Text(strategy.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 10)
                    
                    // Steps section
                    if !strategy.steps.isEmpty {
                        Text("Steps")
                            .font(.headline)
                            .padding(.bottom, 5)
                        
                        ForEach(Array(strategy.steps.enumerated()), id: \.0) { index, step in
                            HStack(alignment: .top, spacing: 10) {
                                Text("\(index + 1).")
                                    .fontWeight(.bold)
                                    .foregroundColor(strategy.category.color)
                                
                                Text(step)
                                    .foregroundColor(.primary)
                            }
                            .padding(.bottom, 5)
                        }
                    }
                    
                    // Benefits section
                    if !strategy.benefits.isEmpty {
                        Text("Benefits")
                            .font(.headline)
                            .padding(.vertical, 5)
                        
                        ForEach(strategy.benefits, id: \.self) { benefit in
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(strategy.category.color)
                                
                                Text(benefit)
                                    .foregroundColor(.primary)
                            }
                            .padding(.bottom, 5)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Strategy Details")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            #else
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            #endif
        }
    }
}

// MARK: - Preview
struct PersonalizedFeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        // Use mock MoodAnalysisEngine
        let mockStore = MockMoodStore()
        let analysisEngine = MoodAnalysisEngine(moodStore: mockStore as! LocalMoodStoreProtocol)
        
        // Create a sample feedback data
        let sampleFeedback = FeedbackData(
            moodState: "Rejected",
            intensity: 7,
            situation: "Job application rejection"
        )
        
        return PersonalizedFeedbackView(analysisEngine: analysisEngine, feedbackData: sampleFeedback)
    }
}

// Mock store for previews
class MockMoodStore: AppMoodStoreProtocol {
    init() {
        // Empty initialization without requiring CoreData context
    }
}

// Local helper function
fileprivate func getFeedbackCopingStrategiesLibraryView() -> some View {
    // This is a placeholder that will be replaced by the actual module implementation
    return AnyView(
        VStack(spacing: 20) {
            Text("Coping Strategies Library")
                .font(.largeTitle)
            
            Text("Loading strategies...")
                .foregroundColor(.secondary)
            
            ProgressView()
        }
        .padding()
    )
}


