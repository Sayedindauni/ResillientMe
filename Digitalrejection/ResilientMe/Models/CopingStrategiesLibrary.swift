import Foundation
import SwiftUI
import ResilientMe

// Remove redundant typealias - already defined in CopingTypes.swift
// typealias EngineStrategyCategory = EngineCopingStrategyCategory

// MARK: - Compatibility for CoreStrategyDetail type

/// This file contains extensions to the existing LocalCopingStrategiesLibrary
/// to add support for the new CoreStrategyDetail type

extension LocalCopingStrategiesLibrary {
    
    // Add CoreStrategyDetail support
    public func getStrategiesAsDetails() -> [ResilientMe.CoreStrategyDetail] {
        // Convert LocalCopingStrategyDetail to CoreStrategyDetail
        return strategies.map { localStrategy in
            ResilientMe.CoreStrategyDetail(
                name: localStrategy.title,
                description: localStrategy.description,
                category: mapLocalCategoryToGlobal(localStrategy.category),
                duration: getDurationFromTimeString(localStrategy.timeToComplete),
                steps: localStrategy.steps,
                benefits: [],  // Default empty benefits
                researchBacked: false
            )
        }
    }
    
    // Map local categories to global CopingStrategyCategory
    private func mapLocalCategoryToGlobal(_ localCategory: LocalCopingStrategyCategory) -> ResilientMe.CoreCopingCategory {
        switch localCategory {
        case .mindfulness:
            return .mindfulness
        case .cognitive:
            return .cognitive
        case .physical:
            return .physical
        case .social:
            return .social
        case .creative:
            return .creative
        case .selfCare:
            return .selfCare
        }
    }
    
    // Convert time string to StrategyDuration
    private func getDurationFromTimeString(_ timeString: String) -> ResilientMe.CoreStrategyDuration {
        if timeString.contains("Under 2") || timeString.contains("1-2") {
            return .veryShort
        } else if timeString.contains("3-5") || timeString.contains("2-5") {
            return .short
        } else if timeString.contains("5-15") || timeString.contains("10-15") {
            return .medium
        } else {
            return .long
        }
    }
    
    // Map CopingStrategyCategory to string description
    public func mapToGlobalCategory(_ category: ResilientMe.CoreCopingCategory) -> String {
        switch category {
        case .mindfulness:
            return "Mindfulness & Meditation"
        case .cognitive:
            return "Cognitive Strategies"
        case .physical:
            return "Physical Activity"
        case .social:
            return "Social Support"
        case .creative:
            return "Creative Expression"
        case .selfCare:
            return "Self-Care Practices"
        }
    }
}

// Add ObservableObject conformance to the existing class
extension LocalCopingStrategiesLibrary: ObservableObject {} 