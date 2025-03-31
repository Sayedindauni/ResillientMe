//
//  MoodEngineModels.swift
//  ResilientMe
//
//  Created by Sayed Mohamed on 21.03.25.
//

import Foundation
import SwiftUI

// MARK: - Engine Models Namespace
// This module should be imported as `import ResilientMe` to access EngineModels
public enum EngineModels {
    // MARK: - Recommendation Data Types
    
    /// Main recommendation data type used by the engine
    public struct RecommendationData: Identifiable, Hashable {
    public let id = UUID()
    public let title: String
    public let description: String
    public let triggerPattern: String
        public let strategies: [CopingStrategy]
        public let resources: [ResourceData]
    public let confidenceLevel: Double // 0.0-1.0 representing AI confidence
        
        public init(
            title: String,
            description: String,
            triggerPattern: String,
            strategies: [CopingStrategy],
            resources: [ResourceData],
            confidenceLevel: Double
        ) {
            self.title = title
            self.description = description
            self.triggerPattern = triggerPattern
            self.strategies = strategies
            self.resources = resources
            self.confidenceLevel = confidenceLevel
        }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
        public static func == (lhs: RecommendationData, rhs: RecommendationData) -> Bool {
        return lhs.id == rhs.id
    }
}

    /// Strategy for coping with moods
    public struct CopingStrategy: Identifiable, Hashable {
    public let id = UUID()
    public let title: String
    public let description: String
        public let timeToComplete: String // e.g. "5 minutes" or "15-20 minutes"
        public let steps: [String]
        public let category: StrategyCategory
        public var intensity: StrategyIntensity = .moderate
        public var moodTargets: [String] = []
        public var tips: [String] = []
        
        public init(
            title: String,
            description: String,
            timeToComplete: String,
            steps: [String],
            category: StrategyCategory,
            intensity: StrategyIntensity = .moderate,
            moodTargets: [String] = [],
            tips: [String] = []
        ) {
            self.title = title
            self.description = description
            self.timeToComplete = timeToComplete
            self.steps = steps
            self.category = category
            self.intensity = intensity
            self.moodTargets = moodTargets
            self.tips = tips
        }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
        public static func == (lhs: CopingStrategy, rhs: CopingStrategy) -> Bool {
        return lhs.id == rhs.id
    }
}

    /// Resource data for recommendations
    public struct ResourceData: Identifiable, Hashable {
        public let id = UUID()
        public let title: String
        public let type: ResourceType
        public let description: String
        public let url: URL?
        public let imageURL: URL?
        public let source: String
        public let isNew: Bool
        
        public init(
            title: String,
            type: ResourceType,
            description: String,
            url: URL? = nil,
            imageURL: URL? = nil,
            source: String,
            isNew: Bool = false
        ) {
            self.title = title
            self.type = type
            self.description = description
            self.url = url
            self.imageURL = imageURL
            self.source = source
            self.isNew = isNew
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        public static func == (lhs: ResourceData, rhs: ResourceData) -> Bool {
            return lhs.id == rhs.id
        }
    }
    
    // MARK: - Enums
    
    /// Intensity of a strategy
    public enum StrategyIntensity: String, Codable {
        case mild, moderate, intensive
        
        public var displayName: String {
            switch self {
            case .mild: return "Quick"
            case .moderate: return "Regular"
            case .intensive: return "Deep Work"
            }
        }
    }
    
    /// Types of resources
    public enum ResourceType: String, Codable, CaseIterable, Identifiable {
        case article = "Article"
        case video = "Video"
        case audio = "Audio"
        case book = "Book"
        case app = "App"
        case exercise = "Exercise"
        
        public var id: String { rawValue }
        
        public var iconName: String {
            switch self {
            case .article: return "doc.text"
            case .video: return "play.rectangle"
            case .audio: return "headphones"
            case .book: return "book"
            case .app: return "iphone"
            case .exercise: return "figure.walk"
            }
        }
        
        public var color: Color {
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
    
    /// Categories of coping strategies
    public enum StrategyCategory: String, CaseIterable, Identifiable, Codable {
    case mindfulness = "Mindfulness"
    case cognitive = "Cognitive"
    case physical = "Physical"
    case social = "Social"
    case creative = "Creative"
    case selfCare = "Self-Care"
    
        public var id: String { self.rawValue }
        
        public var displayName: String { self.rawValue }
    
    public var iconName: String {
        switch self {
        case .mindfulness: return "brain.head.profile"
        case .cognitive: return "lightbulb"
        case .physical: return "figure.walk"
        case .social: return "person.2"
            case .creative: return "paintbrush"
            case .selfCare: return "heart"
        }
    }
    
    public var color: Color {
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
}

// MARK: - Protocol Definitions

/// Protocol for mood store implementations
public protocol MoodStoreProtocol {
    // Empty protocol to represent the data store
}

/// Protocol for recommendation types
public protocol MoodRecommendationProtocol: Identifiable {
    var id: UUID { get }
    var title: String { get }
    var description: String { get }
}

// MARK: - Utility Types and Extensions
extension TimeInterval {
    public static func seconds(_ value: Double) -> TimeInterval {
        return value
    }
}

// MARK: - Strategy Effectiveness Store
public class StrategyEffectivenessStore: ObservableObject {
    public static let shared = StrategyEffectivenessStore()
    
    @Published public var ratingData: [StrategyRating] = []
    
    public struct StrategyRating: Identifiable, Codable {
        public let id: UUID
        public let strategy: String
        public let rating: Int
        public let timestamp: Date
        public let moodBefore: String?
        public let moodAfter: String?
        public let moodImpact: String?
        public let notes: String?
        public let completionTime: TimeInterval?
        
        public init(
            id: UUID = UUID(),
            strategy: String,
            rating: Int,
            timestamp: Date = Date(),
            moodBefore: String? = nil,
            moodAfter: String? = nil,
            moodImpact: String? = nil,
            notes: String? = nil,
            completionTime: TimeInterval? = nil
        ) {
            self.id = id
            self.strategy = strategy
            self.rating = rating
            self.timestamp = timestamp
            self.moodBefore = moodBefore
            self.moodAfter = moodAfter
            self.moodImpact = moodImpact
            self.notes = notes
            self.completionTime = completionTime
        }
    }
    
    private init() {
        // Private initializer for singleton
    }
    
    // Add rating for a strategy
    public func addRating(
        for strategy: String,
        rating: Int,
        moodBefore: String? = nil,
        moodAfter: String? = nil,
        moodImpact: String? = nil,
        notes: String? = nil,
        completionTime: TimeInterval? = nil
    ) {
        let newRating = StrategyRating(
            strategy: strategy,
            rating: rating,
            moodBefore: moodBefore,
            moodAfter: moodAfter,
            moodImpact: moodImpact,
            notes: notes,
            completionTime: completionTime
        )
        
        ratingData.append(newRating)
    }
    
    // Get average rating for a strategy - primary implementation
    public func getAverageRating(for strategy: String) -> Double {
        let ratings = ratingData.filter { $0.strategy == strategy }.map { $0.rating }
        guard !ratings.isEmpty else { return 0 }
        return Double(ratings.reduce(0, +)) / Double(ratings.count)
    }
    
    // Get completion count for a strategy - primary implementation
    public func getCompletionCount(for strategy: String) -> Int {
        return ratingData.filter { $0.strategy == strategy }.count
    }
    
    // Get rating history for a strategy - primary implementation
    public func getRatingHistory(for strategy: String) -> [(date: Date, rating: Int)] {
        return ratingData
            .filter { $0.strategy == strategy }
            .sorted { $0.timestamp < $1.timestamp }
            .map { (date: $0.timestamp, rating: $0.rating) }
    }
    
    // Get most effective strategies - primary implementation
    public func getMostEffectiveStrategies() -> [(strategy: String, rating: Double)] {
        var strategyRatings: [String: [Int]] = [:]
        
        // Group ratings by strategy
        for rating in ratingData {
            if strategyRatings[rating.strategy] == nil {
                strategyRatings[rating.strategy] = []
            }
            strategyRatings[rating.strategy]?.append(rating.rating)
        }
        
        // Calculate average rating for each strategy
        let averages = strategyRatings.map { (strategy, ratings) in
            (strategy: strategy, rating: Double(ratings.reduce(0, +)) / Double(ratings.count))
        }
        
        // Sort by rating and return top 5
        return averages.sorted { $0.rating > $1.rating }.prefix(5).map { $0 }
    }
    
    // Get most used strategies - primary implementation
    public func getMostUsedStrategies() -> [(strategy: String, count: Int)] {
        var strategyCounts: [String: Int] = [:]
        
        // Count usage of each strategy
        for rating in ratingData {
            strategyCounts[rating.strategy, default: 0] += 1
        }
        
        // Convert to array and sort by count
        return strategyCounts.map { (strategy: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
            .prefix(5)
            .map { $0 }
    }
} 