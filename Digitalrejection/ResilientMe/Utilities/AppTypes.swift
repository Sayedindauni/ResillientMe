//
//  AppTypes.swift
//  ResilientMe
//
//  Created by Sayed Mohamed on 21.03.25.
//

import Foundation
import SwiftUI
// Add specific import for the EngineCopingStrategyCategory
import ResilientMe
// Remove the ResilientMe import to avoid circular reference
// import ResilientMe

// MARK: - AppModels namespace to avoid conflicts
// This only contains the data models, not the styles
// For styles, import them from Theme.swift

// MARK: - Data Models for App Content

/// Enum representing different mood states
public enum Mood: String, CaseIterable, Identifiable {
    case joyful
    case content
    case neutral
    case sad
    case frustrated
    case stressed
    case anxious
    case angry
    case happy
    case calm
    case rejected
    
    public var id: String { self.rawValue }
    
    public var name: String {
        switch self {
        case .joyful: return "Joyful"
        case .content: return "Content"
        case .neutral: return "Neutral"
        case .sad: return "Sad"
        case .frustrated: return "Frustrated"
        case .stressed: return "Stressed"
        case .anxious: return "Anxious"
        case .angry: return "Angry"
        case .happy: return "Happy"
        case .calm: return "Calm"
        case .rejected: return "Rejected"
        }
    }
    
    public var emoji: String {
        switch self {
        case .joyful: return "😄"
        case .content: return "😊"
        case .neutral: return "😐"
        case .sad: return "😔"
        case .frustrated: return "😤"
        case .stressed: return "😰"
        case .anxious: return "😟"
        case .angry: return "😠"
        case .happy: return "😃"
        case .calm: return "😌"
        case .rejected: return "😞"
        }
    }
}

/// Model for a coping strategy
public struct Strategy: Identifiable {
    public let id = UUID()
    public let title: String
    public let description: String
}

/// Model for onboarding messages
public struct AppOnboardingMessage: Identifiable {
    public let id = UUID()
    public let title: String
    public let subtitle: String
    public let message: String
}

/// Model for a journal entry
public struct JournalEntry: Identifiable {
    public let id: String
    public let date: Date
    public let title: String
    public let content: String
    public let tags: [String]
    public let mood: Mood?
    public let moodIntensity: Int?
}

// Extend JournalEntry to conform to Equatable
extension JournalEntry: Equatable {
    public static func == (lhs: JournalEntry, rhs: JournalEntry) -> Bool {
        return lhs.id == rhs.id
    }
}

/// Model for a coping resource
public struct CopingResource: Identifiable {
    public let id = UUID()
    public let title: String
    public let description: String
    public let type: String
    public let url: URL?
}

// MARK: - App Resource Types

// Resource types for the app
public enum AppResourceType: String, CaseIterable, Identifiable {
    case article = "Article"
    case video = "Video"
    case audio = "Audio"
    case app = "App"
    case book = "Book"
    case exercise = "Exercise"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .article: return "doc.text"
        case .video: return "play.rectangle.fill"
        case .audio: return "headphones"
        case .app: return "iphone"
        case .book: return "book.fill"
        case .exercise: return "figure.walk"
        }
    }
    
    public var color: Color {
        switch self {
        case .article: return .blue // Use standard SwiftUI Color
        case .video: return .orange   
        case .audio: return .purple   
        case .app: return .green  
        case .book: return .indigo    
        case .exercise: return .blue   
        }
    }
}

// MARK: - Coping Strategy Categories

// These type aliases were causing ambiguity - removing them
// public typealias ExportCopingStrategyCategory = LocalCopingStrategyCategory
// public typealias ExportCopingStrategyDetail = LocalCopingStrategyDetail  
// public typealias ExportCopingStrategiesLibrary = LocalCopingStrategiesLibrary

// Use the #if compiler directive to prevent duplicate definitions
// Define USE_COPING_TYPES to indicate we're using types from CopingTypes.swift
// #define USE_COPING_TYPES 1

#if !LIBRARY_MODULE && !USE_COPING_TYPES
// Local versions for the implementation
// These would normally be in the library module
// public enum LocalCopingStrategyCategory: String, CaseIterable, Identifiable {
//     case mindfulness = "Mindfulness"
//     case cognitive = "Cognitive"
//     case physical = "Physical"
//     case social = "Social"
//     case creative = "Creative"
//     case selfCare = "Self-Care"
//     
//     public var id: String { rawValue }
//     
//     public var iconName: String {
//         switch self {
//         case .mindfulness: return "brain.head.profile"
//         case .cognitive: return "lightbulb"
//         case .physical: return "figure.walk"
//         case .social: return "person.2"
//         case .creative: return "paintpalette"
//         case .selfCare: return "heart.fill"
//         }
//     }
//     
//     public var color: Color {
//         switch self {
//         case .mindfulness: return .blue
//         case .cognitive: return .blue
//         case .physical: return .green
//         case .social: return .purple
//         case .creative: return .orange
//         case .selfCare: return .pink
//         }
//     }
// }

// Use type from CopingTypes.swift instead
// Using typealias defined in CopingTypes.swift
// public typealias LocalCopingStrategyCategory = ResilientMe.EngineCopingStrategyCategory

// Add a typealias to resolve the naming issue
// public typealias LocalCopingStrategyCategory = EngineCopingStrategyCategory

// Define the enum directly to avoid import and typealias issues
public enum LocalCopingStrategyCategory: String, CaseIterable, Identifiable {
    case mindfulness = "Mindfulness"
    case cognitive = "Cognitive"
    case physical = "Physical"
    case social = "Social"
    case creative = "Creative"
    case selfCare = "Self-Care"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .mindfulness: return "brain.head.profile"
        case .cognitive: return "lightbulb"
        case .physical: return "figure.walk"
        case .social: return "person.2"
        case .creative: return "paintpalette"
        case .selfCare: return "heart.fill"
        }
    }
    
    public var color: Color {
        switch self {
        case .mindfulness: return .blue
        case .cognitive: return .blue
        case .physical: return .green
        case .social: return .purple
        case .creative: return .orange
        case .selfCare: return .pink
        }
    }
}

// The actual coping strategy detail type
public struct LocalCopingStrategyDetail: Identifiable, Hashable {
    public let id: UUID
    public let title: String
    public let description: String
    // Using the typealias for EngineModels.StrategyCategory
    public let category: LocalCopingStrategyCategory
    public let timeToComplete: String
    public let difficultyLevel: String
    public let steps: [String]
    public let source: String
    public let tags: [String]
    
    public init(id: UUID = UUID(), title: String, description: String, category: LocalCopingStrategyCategory, timeToComplete: String, difficultyLevel: String = "Beginner", steps: [String], source: String = "ResilientMe", tags: [String] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.timeToComplete = timeToComplete
        self.difficultyLevel = difficultyLevel
        self.steps = steps
        self.source = source
        self.tags = tags
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: LocalCopingStrategyDetail, rhs: LocalCopingStrategyDetail) -> Bool {
        lhs.id == rhs.id
    }
}

// Coping strategies library for accessing strategies
public class LocalCopingStrategiesLibrary {
    public static let shared = LocalCopingStrategiesLibrary()
    
    public var strategies: [LocalCopingStrategyDetail] = []
    
    private init() {
        loadStrategies()
    }
    
    private func loadStrategies() {
        // Load built-in strategies
        strategies = LocalCopingStrategiesLibrary.defaultStrategies
    }
    
    public func getStrategies(for category: LocalCopingStrategyCategory) -> [LocalCopingStrategyDetail] {
        return strategies.filter { $0.category == category }
    }
    
    public func recommendStrategies(for mood: String, intensity: Int, trigger: String? = nil) -> [LocalCopingStrategyDetail] {
        // Simple implementation that recommends strategies based on mood
        
        // For high intensity emotions, prioritize grounding and mindfulness
        if intensity >= 4 {
            let mindfulnessStrategies = getStrategies(for: .mindfulness).prefix(2)
            let cognitiveStrategies = getStrategies(for: .cognitive).prefix(1)
            return Array(mindfulnessStrategies) + Array(cognitiveStrategies)
        }
        
        // For rejection-related moods, prioritize self-compassion and social support
        if mood.lowercased().contains("reject") || mood.lowercased().contains("disappoint") {
            let selfCareStrategies = getStrategies(for: .selfCare).prefix(2)
            let socialStrategies = getStrategies(for: .social).prefix(1)
            return Array(selfCareStrategies) + Array(socialStrategies)
        }
        
        // Default case: mix of strategies
        var recommendations: [LocalCopingStrategyDetail] = []
        for category in LocalCopingStrategyCategory.allCases {
            if let strategy = getStrategies(for: category).first {
                recommendations.append(strategy)
            }
            if recommendations.count >= 3 {
                break
            }
        }
        
        return recommendations
    }
    
    // Helper to convert strategy objects to simple strings for older interfaces
    public static func getSimpleStrategyStrings(from strategies: [LocalCopingStrategyDetail]) -> [String] {
        return strategies.map { $0.title }
    }
    
    // Default strategies for the app
    static let defaultStrategies: [LocalCopingStrategyDetail] = [
        // Mindfulness strategies
        LocalCopingStrategyDetail(
                title: "5-4-3-2-1 Grounding Technique",
            description: "A mindfulness exercise to reconnect with your surroundings when experiencing rejection anxiety.",
                category: .mindfulness,
            timeToComplete: "5 minutes",
                steps: [
                "Find a comfortable position and take a deep breath",
                "Name 5 things you can see",
                "Name 4 things you can feel",
                "Name 3 things you can hear",
                "Name 2 things you can smell",
                "Name 1 thing you can taste",
                "Take another deep breath and notice how you feel"
            ],
            tags: ["anxiety", "rejection", "grounding", "quick"]
        ),
        
        LocalCopingStrategyDetail(
            title: "Mindful Self-Compassion Break",
            description: "A brief practice to respond to rejection with kindness rather than self-criticism.",
                category: .mindfulness,
            timeToComplete: "3-5 minutes",
                steps: [
                "Place your hands over your heart or another soothing place",
                "Acknowledge your feelings: 'This is a moment of suffering'",
                "Recognize our shared humanity: 'Rejection is something many people experience'",
                "Offer yourself kindness: 'May I be kind to myself in this moment'",
                "Ask: 'What do I need right now?'",
                "Give yourself permission to meet that need"
            ],
            tags: ["rejection", "self-compassion", "quick"]
        ),
        
        // Cognitive strategies
        LocalCopingStrategyDetail(
            title: "Thought Record for Rejection",
            description: "Examine and reframe negative thoughts following a rejection experience.",
                category: .cognitive,
            timeToComplete: "10-15 minutes",
            difficultyLevel: "Intermediate",
                steps: [
                "Write down the situation where you experienced rejection",
                "Note your automatic thoughts and how strongly you believe them (0-100%)",
                "Identify the emotions these thoughts triggered and their intensity (0-100%)",
                "List evidence that supports these thoughts",
                "List evidence that contradicts these thoughts",
                "Create a balanced alternative thought",
                "Rate how strongly you believe this new thought (0-100%)",
                "Note how your emotions change with this new perspective"
            ],
            tags: ["rejection", "cognitive restructuring", "journaling"]
        ),
        
        LocalCopingStrategyDetail(
            title: "Values Reconnection",
            description: "Reconnect with your core values to find meaning beyond rejection.",
                category: .cognitive,
            timeToComplete: "5-10 minutes",
                steps: [
                "List 3-5 personal values that are most important to you",
                "For each value, note why it matters to you",
                "Consider how this rejection experience connects to your values",
                "Identify one small action aligned with your values that you can take today",
                "Commit to taking that action regardless of feelings of rejection"
            ],
            tags: ["values", "meaning", "purpose"]
        ),
        
        // Physical strategies
        LocalCopingStrategyDetail(
            title: "Release Tension Walk",
            description: "A walking technique to release physical tension associated with rejection feelings.",
                category: .physical,
            timeToComplete: "15-20 minutes",
                steps: [
                "Find a safe place to walk (outdoors if possible)",
                "Begin walking at a comfortable pace",
                "Scan your body for areas of tension",
                "With each step, imagine sending breath to tense areas",
                "As you exhale, visualize tension flowing out through your feet into the ground",
                "If thoughts of rejection arise, acknowledge them without judgment",
                "Return focus to your breathing and walking",
                "End with three deep breaths and notice how your body feels"
            ],
            tags: ["tension", "walking", "outdoors", "breathing"]
        ),
        
        // Social strategies
        LocalCopingStrategyDetail(
            title: "Supportive Connection Script",
            description: "A guided approach to reaching out for support after rejection.",
                category: .social,
            timeToComplete: "Varies",
                steps: [
                "Identify a trusted person who has been supportive in the past",
                "Decide what kind of support you need: listening, perspective, distraction, etc.",
                "Practice what you might say: 'I experienced a rejection and could use [specific support]'",
                "Set boundaries for the conversation if needed",
                "Reach out in a way that feels comfortable",
                "Express gratitude for their support afterwards"
            ],
            tags: ["social support", "communication", "vulnerability"]
        ),
        
        // Creative strategies
        LocalCopingStrategyDetail(
            title: "Rejection Transformation Art",
            description: "Transform feelings of rejection into creative expression.",
                category: .creative,
            timeToComplete: "30+ minutes",
                steps: [
                "Choose any creative medium you enjoy (drawing, writing, music, etc.)",
                "Set a timer for 5 minutes and express your rejection feelings without judgment",
                "Take a short break and reflect",
                "Now create something that transforms or responds to these feelings",
                "This could be a hopeful ending, a lesson learned, or simply a different perspective",
                "Title your creation and consider what it taught you"
            ],
            tags: ["art therapy", "expression", "transformation"]
        ),
        
        // Self-care strategies
        LocalCopingStrategyDetail(
            title: "Rejection Resilience Care Package",
            description: "Create a personalized self-care package to use after rejection experiences.",
                category: .selfCare,
            timeToComplete: "20 minutes to create, then ongoing",
                steps: [
                "Find a container (box, basket, digital list) for your care package",
                "Include items that engage your senses (soft fabric, calming scent, etc.)",
                    "Add reminders of your strengths and past successes",
                "Include contact info for supportive people",
                "Add activities that reliably improve your mood",
                "Write a compassionate note to your future self",
                "Use the care package when experiencing rejection"
            ],
            tags: ["preparation", "self-care", "comfort"]
        )
    ]
}

// MARK: - Journal Prompts

public enum AppMoodIntensity: Int, CaseIterable {
    case veryLow = 1
    case low = 2
    case moderate = 3
    case high = 4
    case veryHigh = 5
    
    public var description: String {
        switch self {
        case .veryLow: return "Very Mild"
        case .low: return "Mild"
        case .moderate: return "Moderate"
        case .high: return "Strong"
        case .veryHigh: return "Very Strong"
        }
    }
}

// MARK: - Model Type Aliases (for backward compatibility)

// These should match the types defined in AppThemeBridge.swift
#endif
