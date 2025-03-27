//
//  AppTypes.swift
//  ResilientMe
//
//  Created by Sayed Mohamed on 21.03.25.
//

import Foundation
import SwiftUI

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
public struct OnboardingMessage: Identifiable {
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

enum AppResourceType: String, Codable, CaseIterable, Identifiable {
    case article = "Article"
    case video = "Video"
    case audio = "Audio"
    case app = "App"
    case book = "Book"
    case exercise = "Exercise"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .article: return "doc.text"
        case .video: return "play.rectangle"
        case .audio: return "headphones"
        case .app: return "iphone"
        case .book: return "book"
        case .exercise: return "figure.mind.and.body"
        }
    }
    
    var color: Color {
        switch self {
        case .article: return Color(AppColors.primary) // Blue
        case .video: return Color(AppColors.accent1)   // Soft peach
        case .audio: return Color(AppColors.accent2)   // Lavender
        case .app: return Color(AppColors.secondary)   // Sage green
        case .book: return Color(AppColors.accent3)    // Powder blue
        case .exercise: return Color(AppColors.calm)   // Calm blue
        }
    }
}

// MARK: - Coping Strategy Categories

public enum AppCopingStrategyCategory: String, CaseIterable, Identifiable {
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
    
    var color: Color {
        switch self {
        case .mindfulness: return Color(AppColors.calm)
        case .cognitive: return Color(AppColors.primary)
        case .physical: return Color(red: 0.2, green: 0.8, blue: 0.4)
        case .social: return Color(red: 0.6, green: 0.4, blue: 0.8)
        case .creative: return Color(red: 0.9, green: 0.3, blue: 0.5)
        case .selfCare: return Color(red: 0.9, green: 0.4, blue: 0.4)
        }
    }
}

// MARK: - Coping Strategy Detail

public struct AppCopingStrategyDetail: Identifiable {
    public let id: String
    public let title: String
    public let description: String
    public let category: AppCopingStrategyCategory
    public let timeToComplete: String
    public let steps: [String]
    public let intensity: StrategyIntensity
    public let moodTargets: [String]
    
    // Optional additional fields
    public var tips: [String]?
    public var resources: [String]?
    
    // Enum for strategy intensity
    public enum StrategyIntensity: String, Codable {
        case quick = "Quick"
        case moderate = "Moderate"
        case intensive = "Intensive"
        
        public var color: Color {
            switch self {
            case .quick: return Color.green
            case .moderate: return Color.blue
            case .intensive: return Color.purple
            }
        }
    }
}

// MARK: - Coping Strategies Library

public class AppCopingStrategiesLibrary {
    // Singleton instance
    public static let shared = AppCopingStrategiesLibrary()
    
    // All available strategies
    public var strategies: [AppCopingStrategyDetail] = []
    
    // Private initializer for singleton
    private init() {
        loadStrategies()
    }
    
    // Get strategies for a specific category
    public func getStrategies(for category: AppCopingStrategyCategory) -> [AppCopingStrategyDetail] {
        return strategies.filter { $0.category == category }
    }
    
    // Recommend strategies based on mood and trigger
    public func recommendStrategies(for mood: String, intensity: Int, trigger: String? = nil) -> [AppCopingStrategyDetail] {
        // In a real app, this would have complex logic
        // For now, return a filtered subset based on mood type
        
        let isNegativeMood = ["sad", "angry", "frustrated", "anxious", "stressed"]
            .contains(where: { mood.lowercased().contains($0) })
        
        if isNegativeMood {
            // For negative moods, return strategies that help with calming
            return strategies.filter { 
                $0.category == .mindfulness || $0.category == .selfCare 
            }
        } else {
            // For positive/neutral moods, return general strategies
            return Array(strategies.prefix(5))
        }
    }
    
    // Convert detailed strategies to simple strings (for backward compatibility)
    public static func getSimpleStrategyStrings(from strategies: [AppCopingStrategyDetail]) -> [String] {
        return strategies.map { $0.title }
    }
    
    // Load strategies from data
    private func loadStrategies() {
        // In a real app, these might come from a database or API
        // For now, we'll create some samples
        
        strategies = [
            // Mindfulness strategies
            AppCopingStrategyDetail(
                id: "mind1",
                title: "5-Minute Breathing Exercise",
                description: "A quick breathing technique to center yourself and reduce immediate stress.",
                category: .mindfulness,
                timeToComplete: "5 min",
                steps: [
                    "Find a comfortable seated position",
                    "Close your eyes and take a deep breath",
                    "Breathe in for 4 counts, hold for 2, exhale for 6",
                    "Focus on your breath and let thoughts pass by",
                    "Continue for 5 minutes"
                ],
                intensity: .quick,
                moodTargets: ["joyful", "content", "neutral"],
                tips: ["Try counting your breaths", "If your mind wanders, gently bring it back to your breath"]
            ),
            
            // Cognitive strategies
            AppCopingStrategyDetail(
                id: "cog1",
                title: "Thought Challenging",
                description: "Identify and reframe negative thought patterns to more balanced perspectives.",
                category: .cognitive,
                timeToComplete: "15 min",
                steps: [
                    "Identify the negative thought",
                    "Write down evidence for and against this thought",
                    "Consider alternative explanations",
                    "Create a more balanced perspective",
                    "Practice your new thought"
                ],
                intensity: .moderate,
                moodTargets: ["sad", "frustrated", "stressed"],
                tips: ["Write down evidence for and against the thought", "Consider alternative explanations"]
            ),
            
            // Physical strategies
            AppCopingStrategyDetail(
                id: "phys1",
                title: "Quick Stretch Routine",
                description: "A series of simple stretches to release physical tension.",
                category: .physical,
                timeToComplete: "10 min",
                steps: [
                    "Stretch arms above head for 15 seconds",
                    "Roll shoulders backward and forward",
                    "Gentle neck stretches side to side",
                    "Forward fold to stretch hamstrings",
                    "Finish with gentle twists"
                ],
                intensity: .quick,
                moodTargets: ["joyful", "content", "neutral"],
                tips: ["Stretch slowly and focus on your breath"]
            ),
            
            // Add a few more examples for other categories
            AppCopingStrategyDetail(
                id: "soc1",
                title: "Reach Out Exercise",
                description: "Structured approach to connecting with a supportive person.",
                category: .social,
                timeToComplete: "Varies",
                steps: [
                    "Identify someone you trust",
                    "Decide what you're comfortable sharing",
                    "Make contact via text, call, or in person",
                    "Share your feelings",
                    "Listen to their perspective"
                ],
                intensity: .moderate,
                moodTargets: ["joyful", "content", "neutral"],
                tips: ["Choose a supportive person to share with", "Listen actively and empathetically"]
            )
        ]
    }
}

// MARK: - Coping Strategies

struct CopingStrategies {
    // Simple method to recommend strategies based on mood and trigger
    static func recommendFor(mood: String, trigger: String? = nil) -> [String] {
        // Simple recommendation logic based on mood type
        var recommendations: [String] = []
        
        let moodLower = mood.lowercased()
        
        // Add general recommendations
        recommendations.append("Take 5 deep breaths")
        recommendations.append("Go for a short walk")
        
        // Add mood-specific recommendations
        if ["sad", "down", "depressed", "blue", "gloomy"]
             .contains(where: { moodLower.contains($0) }) {
            recommendations.append("Call a friend who makes you laugh")
            recommendations.append("Watch something uplifting")
            recommendations.append("Listen to upbeat music")
        } 
        else if ["anxious", "worried", "nervous", "stressed", "overwhelmed"]
                 .contains(where: { moodLower.contains($0) }) {
            recommendations.append("Progressive muscle relaxation")
            recommendations.append("Write down your worries")
            recommendations.append("Focus on what you can control")
        }
        else if ["angry", "frustrated", "irritated", "annoyed"]
                 .contains(where: { moodLower.contains($0) }) {
            recommendations.append("Count to 10 before responding")
            recommendations.append("Physical exercise to release tension")
            recommendations.append("Write about what's bothering you")
        }
        else if ["happy", "joyful", "excited", "content"]
                 .contains(where: { moodLower.contains($0) }) {
            recommendations.append("Journal about what's going well")
            recommendations.append("Share your happiness with someone")
            recommendations.append("Engage in a creative activity")
        }
        
        // Add trigger-specific recommendations
        if let trigger = trigger {
            let triggerLower = trigger.lowercased()
            
            if ["rejection", "social"]
                .contains(where: { triggerLower.contains($0) }) {
                recommendations.append("Remember past social successes")
                recommendations.append("Practice self-compassion")
                recommendations.append("Reach out to a supportive friend")
            }
            else if ["work", "professional", "job"]
                    .contains(where: { triggerLower.contains($0) }) {
                recommendations.append("Break tasks into smaller steps")
                recommendations.append("Take a short break")
                recommendations.append("List your accomplishments")
            }
            else if ["relationship", "romantic", "partner"]
                    .contains(where: { triggerLower.contains($0) }) {
                recommendations.append("Focus on what you can control")
                recommendations.append("Practice open communication")
                recommendations.append("Take time for self-care")
            }
        }
        
        // Return top 5 recommendations
        return Array(Set(recommendations)).shuffled().prefix(5).map { $0 }
    }
}

// MARK: - Type Aliases for Backward Compatibility

// These aliases help existing code reference the new type names
public typealias CopingStrategyCategory = AppCopingStrategyCategory
public typealias CopingStrategyDetail = AppCopingStrategyDetail
