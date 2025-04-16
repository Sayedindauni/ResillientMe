import Foundation
import SwiftUI
import ResilientMe

// Single source of truth for coping strategy type definitions
public typealias EngineCopingStrategyCategory = ResilientMe.EngineModels.StrategyCategory

// MARK: - Core Coping Strategy Types
// This file contains the primary definitions for coping strategy types

// MARK: - Coping Strategy Categories
public enum CoreCopingCategory: String, Codable, CaseIterable, Identifiable {
    case mindfulness
    case cognitive
    case physical
    case social
    case creative
    case selfCare
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .mindfulness: return "Mindfulness"
        case .cognitive: return "Thought Work"
        case .physical: return "Physical Activity"
        case .social: return "Social Connection"
        case .creative: return "Creative Expression"
        case .selfCare: return "Self-Care"
        }
    }
    
    public var iconName: String {
        switch self {
        case .mindfulness: return "brain.head.profile"
        case .cognitive: return "thought.bubble"
        case .physical: return "figure.walk"
        case .social: return "person.2"
        case .creative: return "paintbrush"
        case .selfCare: return "heart"
        }
    }
    
    public var color: Color {
        switch self {
        case .mindfulness: return Color("Primary")
        case .cognitive: return Color("Secondary")
        case .physical: return Color("Accent1")
        case .social: return Color("Accent2")
        case .creative: return Color.purple
        case .selfCare: return Color.pink
        }
    }
}

// MARK: - Strategy Duration
public enum CoreStrategyDuration: String, Codable, CaseIterable, Identifiable {
    case veryShort = "Under 2 minutes"
    case short = "2-5 minutes"
    case medium = "5-15 minutes"
    case long = "Over 15 minutes"
    
    public var id: String { rawValue }
    
    public var minutes: ClosedRange<Int> {
        switch self {
        case .veryShort: return 0...2
        case .short: return 2...5
        case .medium: return 5...15
        case .long: return 15...60
        }
    }
    
    public var iconName: String {
        switch self {
        case .veryShort: return "bolt"
        case .short: return "clock"
        case .medium: return "clock.fill"
        case .long: return "hourglass"
        }
    }
}

// MARK: - Coping Strategy Detail
public struct CoreStrategyDetail: Identifiable, Codable, Hashable {
    public var id: UUID
    public var name: String
    public var description: String
    public var category: CoreCopingCategory
    public var duration: CoreStrategyDuration
    public var steps: [String]
    public var benefits: [String]
    public var researchBacked: Bool
    
    public init(id: UUID = UUID(), name: String, description: String, category: CoreCopingCategory, 
                duration: CoreStrategyDuration, steps: [String], benefits: [String], researchBacked: Bool = false) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.duration = duration
        self.steps = steps
        self.benefits = benefits
        self.researchBacked = researchBacked
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// Remove these problematic typealiases that are causing ambiguity
// We'll reference the types directly with explicit module names instead 