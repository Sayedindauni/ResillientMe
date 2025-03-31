//
//  MoodAnalysisEngine.swift
//  ResilientMe
//
//  Created by Sayed Mohamed on 21.03.25.
//

import Foundation
import CoreData
import SwiftUI
import Combine
import UserNotifications
// Import MoodEngineModels to access the EngineModels namespace
import ResilientMe
// Remove ResilientMe import since it's causing problems
// import ResilientMe
// Keep this comment to explain what we're doing
// We'll use our own internal types instead of importing from Theme

// Import ResilientMe removed since it's causing issues
// If ViewMoodRecommendation is defined in another file, we need to import it
// This comment is just placeholder, as we may not know which file to import

// MARK: - Type Aliases to avoid ambiguity

// These type aliases help resolve conflicts between types with same name
typealias EngineMoodStoreProtocol = ResilientMe.MoodStoreProtocol
typealias EngineMoodRecommendationProtocol = ResilientMe.MoodRecommendationProtocol
typealias EngineTimeInterval = TimeInterval

// We'll reference imported types properly
// typealias CoreDataMoodStore = MoodStore 
// typealias ResourceData = EngineRecommendedResource

// Use prefix 'Local' for types defined in this file/module

// Add a forward reference for types imported from ResilientMe
// typealias EngineMoodRecommendation = ResilientMe.MoodRecommendation

// MARK: - Engine Models Namespace (Reference Only)
// The actual declaration is in MoodEngineModels.swift
// We're using the imported EngineModels from ResilientMe module

// MARK: - Stub Types for Testing and Development

// MoodEntry stub - rename to avoid conflict with imported type
struct LocalMoodEntry: Identifiable, Codable {
    var id = UUID()
    var mood: LocalMood
    var intensity: Int
    var date: Date
    var notes: String
    var rejectionRelated: Bool = false
    var rejectionTrigger: String? = nil
}

// Mood enum stub - rename to avoid conflict
enum LocalMood: String, Codable, CaseIterable, Identifiable {
    case happy, sad, anxious, angry, calm, rejected
    var id: String { rawValue }
}

// PuterAIService stub
class StubPuterAIService {
    var isInitialized = CurrentValueSubject<Bool, Never>(false)
    func analyzeText(_ text: String, completion: @escaping (Result<String, Error>) -> Void) {}
    func analyzeMoodPatterns(entries: [LocalMoodEntry], completion: @escaping (Result<[LocalMoodInsight], Error>) -> Void) {}
    func generateCopingStrategies(for mood: LocalMood, intensity: Int, completion: @escaping (Result<LocalCopingStrategies, Error>) -> Void) {}
    func generateJournalPrompt(for mood: LocalMood, completion: @escaping (Result<LocalJournalPrompts, Error>) -> Void) {}
}

// NotificationManager stub
class StubNotificationManager {
    func setupNotificationCategories() {}
    func scheduleNotification(title: String, body: String, identifier: String) {}
    func sendRecommendationNotification(title: String, body: String, recommendation: EngineModels.RecommendationData? = nil) {}
    func scheduleImmediateNotification(title: String, body: String) {}
}

// Additional required types - all renamed with Local prefix
struct LocalCopingStrategies: Identifiable, Codable {
    var id = UUID()
    var strategies: [String] = []
    
    // Add helper methods 
    func recommendFor(mood: EngineModels.StrategyCategory) -> [String] {
        return strategies
    }
}

struct LocalJournalPrompts: Identifiable, Codable {
    var id = UUID()
    var prompts: [String] = []
    
    // Add helper methods
    func forMood(mood: EngineModels.StrategyCategory) -> String {
        return prompts.first ?? "No prompt available"
    }
}

// MoodInsight stub for AI analysis
struct LocalMoodInsight: Identifiable, Hashable {
    var id = UUID()
    var title: String
    var description: String
    
    // Add data property to fix error
    var data: Data {
        let jsonString = "{\"title\":\"\(title)\",\"description\":\"\(description)\"}"
        return jsonString.data(using: .utf8)!
    }
}

// MARK: - MoodAnalysisEngine

/// Main class for analyzing moods and providing recommendations
class MoodAnalysisEngine: ObservableObject {
    var moodStore: EngineMoodStoreProtocol
    @Published var currentRecommendations: [EngineModels.RecommendationData] = []
    @Published var engineRecommendations: [Any] = [] // Will hold any objects 
    @Published var aiInitialized: Bool = false
    @Published var _hasNewRecommendations: Bool = false
    
    // Add computed property for hasNewRecommendations
    var hasNewRecommendations: Bool {
        get { return _hasNewRecommendations || !currentRecommendations.isEmpty }
        set { _hasNewRecommendations = newValue }
    }
    
    init(moodStore: EngineMoodStoreProtocol) {
        self.moodStore = moodStore
        self.aiInitialized = false
    }
    
    // Method for PersonalizedFeedbackView
    func markRecommendationAsHelpful(_ recommendation: Any) {
        // Implementation would go here
    }
    
    // Method for PersonalizedFeedbackView
    func markRecommendationAsUnhelpful(_ recommendation: Any) {
        // Implementation would go here
    }
}

// MARK: - Supporting Types

// Define InsightsRecommendationData struct used by InsightsView
public struct InsightsRecommendationData: Identifiable {
    public let id = UUID()
    public let title: String
    public let description: String
    
    public static func from(engineRecommendation: EngineModels.RecommendationData) -> InsightsRecommendationData {
        InsightsRecommendationData(
            title: engineRecommendation.title,
            description: engineRecommendation.description
        )
    }
    
    // Simple initializer
    public init(title: String, description: String) {
        self.title = title
        self.description = description
    }
}

// Extension to MoodAnalysisEngine to handle displayRecommendations
extension MoodAnalysisEngine {
    public var displayRecommendations: [InsightsRecommendationData] {
        self.currentRecommendations.map { InsightsRecommendationData.from(engineRecommendation: $0) }
    }
}

// Define LocalRecommendedResource instead of EngineRecommendedResource
struct LocalRecommendedResource: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let type: EngineModels.ResourceType
    let description: String
    let url: URL?
    let source: String
    let isNew: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: LocalRecommendedResource, rhs: LocalRecommendedResource) -> Bool {
        return lhs.id == rhs.id
    }
}

// Define LocalViewResourceType needed by LocalRecommendedResource
enum LocalViewResourceType: String, Codable, CaseIterable, Identifiable {
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

// Define LocalStrategyCategory instead of EngineStrategyCategory
enum LocalStrategyCategory: String, CaseIterable, Identifiable {
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
