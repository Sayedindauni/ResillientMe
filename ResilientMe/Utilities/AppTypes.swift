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