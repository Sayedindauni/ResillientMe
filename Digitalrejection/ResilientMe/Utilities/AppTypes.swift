//
//  AppTypes.swift
//  ResilientMe
//
//  Created by Sayed Mohamed on 21.03.25.
//

import Foundation
import SwiftUI

// MARK: - Data Models for App Content

/// Enum representing different mood states
public enum Mood: String, CaseIterable, Identifiable {
    case joyful
    case content
    case neutral
    case sad
    case frustrated
    case stressed
    
    public var id: String { self.rawValue }
    
    public var name: String {
        switch self {
        case .joyful: return "Joyful"
        case .content: return "Content"
        case .neutral: return "Neutral"
        case .sad: return "Sad"
        case .frustrated: return "Frustrated"
        case .stressed: return "Stressed"
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
}

// MARK: - Coping Strategy Categories

enum CopingStrategyCategory: String, CaseIterable, Identifiable {
    case mindfulness = "Mindfulness"
    case cognitive = "Cognitive"
    case physical = "Physical"
    case social = "Social"
    case creative = "Creative"
    case selfCare = "Self-Care"
    
    var id: String { rawValue }
    
    var iconName: String {
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
        case .mindfulness: return AppColors.calm
        case .cognitive: return AppColors.primary
        case .physical: return Color(red: 0.2, green: 0.8, blue: 0.4)
        case .social: return Color(red: 0.6, green: 0.4, blue: 0.8)
        case .creative: return Color(red: 0.9, green: 0.3, blue: 0.5)
        case .selfCare: return Color(red: 0.9, green: 0.4, blue: 0.4)
        }
    }
} 