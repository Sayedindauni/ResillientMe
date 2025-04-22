import Foundation
import ResilientMe // Assuming this contains Core types and EngineModels

// MARK: - Journal Analysis for Coping Strategies

/// Analyzes journal content to extract emotional keywords and recommend coping strategies.
/// Assumes LocalCopingStrategyDetail and LocalCopingStrategiesLibrary are defined elsewhere.
func analyzeJournalContentForStrategies(_ text: String) -> [LocalCopingStrategyDetail] {
    // Define emotional keywords mapping to Core coping categories.
    // This could be expanded or moved to a configuration.
    let emotionalKeywords: [String: ResilientMe.CoreCopingCategory] = [
        "anxious": .cognitive,
        "sad": .selfCare,
        "stress": .mindfulness,
        "lonely": .social,
        "angry": .physical,
        "rejected": .selfCare,
        "calm": .mindfulness,
        "happy": .creative,
        "disappointed": .cognitive, // Example addition
        "frustrated": .physical,   // Example addition
        "worried": .cognitive     // Example addition
    ]
    
    let normalizedText = text.lowercased()
    var matchedCategories = Set<ResilientMe.CoreCopingCategory>()
    
    // Find matching keywords in the text.
    for (keyword, category) in emotionalKeywords {
        if normalizedText.contains(keyword) {
            matchedCategories.insert(category)
        }
    }
    
    // If no specific keywords match, recommend general categories.
    if matchedCategories.isEmpty {
        matchedCategories = [.selfCare, .mindfulness]
    }
    
    // Retrieve strategies from the library based on matched categories.
    // Get the singleton instance directly without trying to unwrap it
    let copingStrategiesLibrary = LocalCopingStrategiesLibrary.shared
    var recommendedStrategies: [LocalCopingStrategyDetail] = []
    
    // Collect strategies, ensuring variety and limiting per category.
    for category in matchedCategories {
        let localCategory = coreToLocalCategory(category) // Convert Core to Local category
        let strategiesInCategory = copingStrategiesLibrary.strategies.filter { $0.category == localCategory }
        // Add up to 2 strategies per matched category.
        recommendedStrategies.append(contentsOf: strategiesInCategory.prefix(2))
    }
    
    // Shuffle and limit the total number of recommendations.
    return Array(recommendedStrategies.shuffled().prefix(5))
}

/// Helper function to convert CoreCopingCategory to LocalCopingStrategyCategory.
/// Assumes both enums are defined and accessible.
private func coreToLocalCategory(_ coreCategory: ResilientMe.CoreCopingCategory) -> LocalCopingStrategyCategory {
    switch coreCategory {
    case .mindfulness: return .mindfulness
    case .cognitive: return .cognitive
    case .physical: return .physical
    case .social: return .social
    case .creative: return .creative
    case .selfCare: return .selfCare
    // Ensure all cases are handled or provide a default/error.
    }
}

/// Helper function to convert time strings (e.g., "Under 2 min") to CoreStrategyDuration enum.
/// Assumes CoreStrategyDuration enum is defined and accessible.
private func getDurationFromTimeString(_ timeString: String) -> ResilientMe.CoreStrategyDuration {
    let lowercasedTime = timeString.lowercased()
    if lowercasedTime.contains("under 2") || lowercasedTime.contains("1-2") {
        return .veryShort
    } else if lowercasedTime.contains("3-5") || lowercasedTime.contains("2-5") {
        return .short
    } else if lowercasedTime.contains("5-15") || lowercasedTime.contains("10-15") {
        return .medium
    } else if lowercasedTime.contains("15+") || lowercasedTime.contains("long") { // Handle longer durations
        return .long
    } else {
        return .medium // Default duration if parsing fails
    }
}

/// Conversion function to map between engine strategy types and core strategy types.
/// Assumes EngineModels.StrategyCategory and CoreCopingCategory enums are defined.
private func convertEngineToCore(_ engineCategory: ResilientMe.EngineModels.StrategyCategory) -> ResilientMe.CoreCopingCategory {
    switch engineCategory {
    case .mindfulness: return .mindfulness
    case .cognitive: return .cognitive
    case .physical: return .physical
    case .social: return .social
    case .creative: return .creative
    case .selfCare: return .selfCare
    // Ensure all cases are handled.
    }
}

// MARK: - Sentiment Analysis (Simplified)

/// Analyzes text to detect a primary emotion and its intensity (0.0 - 1.0).
/// This is a basic keyword-based implementation. A real app would use NLP.
private func analyzeSentiment(in text: String) -> (emotion: String, intensity: Double)? {
    let lowercasedText = text.lowercased()
    
    // Define keywords and their associated base intensities.
    // Prioritize negative emotions as they might require more attention.
    let negativeEmotions = [
        "sad": 0.7, "disappointed": 0.6, "hurt": 0.7, "lonely": 0.75,
        "angry": 0.8, "frustrated": 0.65,
        "anxious": 0.75, "worried": 0.6, "stressed": 0.7, "overwhelmed": 0.8,
        "rejected": 0.85
    ]
    
    let positiveEmotions = [
        "happy": 0.8, "excited": 0.9, "proud": 0.75, "confident": 0.8, "loved": 0.9,
        "grateful": 0.85, "hopeful": 0.7, "peaceful": 0.6, "calm": 0.5
    ]

    // Check for negative emotions first.
    for (emotion, baseIntensity) in negativeEmotions {
        if lowercasedText.contains(emotion) {
            // Could add logic to adjust intensity based on frequency or modifiers (e.g., "very sad")
            return (emotion, baseIntensity)
        }
    }
    
    // Then check for positive emotions.
    for (emotion, baseIntensity) in positiveEmotions {
        if lowercasedText.contains(emotion) {
            return (emotion, baseIntensity)
        }
    }
    
    // If no strong keywords found, consider it neutral if there's enough content.
    if text.count > 30 { // Adjusted threshold
        return ("neutral", 0.5)
    }
    
    return nil // Not enough information or no keywords detected.
}

/// Converts the output of `analyzeSentiment` to a `JournalMood` enum value.
/// Assumes JournalMood enum is defined and accessible.
private func moodFromSentiment(_ sentiment: (emotion: String, intensity: Double)?) -> JournalMood? {
    guard let sentiment = sentiment else { return nil }
    
    // Map detected emotion strings to JournalMood cases.
    switch sentiment.emotion.lowercased() {
    case "sad", "disappointed", "hurt", "lonely":
        return .sad
    case "angry", "frustrated":
        return .angry
    case "anxious", "worried", "stressed":
        return .anxious
    case "overwhelmed", "rejected": // Grouping intense negative feelings
         return .overwhelmed
    case "happy", "excited", "proud", "confident", "loved":
        return .great
    case "grateful", "peaceful", "hopeful", "calm":
        return .good
    case "neutral":
        return .neutral
    default:
        // If the detected emotion doesn't map directly, return neutral or nil.
        return .neutral 
    }
}

// MARK: - Local Coping Strategy Category Extension

// Add displayName extension to LocalCopingStrategyCategory if it doesn't exist elsewhere.
// Ensure LocalCopingStrategyCategory is defined and accessible.
/* 
 // This extension might belong in a file defining LocalCopingStrategyCategory
 // or a dedicated extensions file.
 extension LocalCopingStrategyCategory {
     var displayName: String {
         switch self {
         case .mindfulness: return "Mindfulness"
         case .cognitive: return "Cognitive"
         case .physical: return "Physical"
         case .social: return "Social"
         case .creative: return "Creative"
         case .selfCare: return "Self-Care"
         }
     }
 } 
*/

// Placeholder for required types if not imported from ResilientMe or defined elsewhere

// protocol LocalCopingStrategyDetail: Identifiable { // Example protocol
//     var id: String { get }
//     var title: String { get }
//     var description: String { get }
//     var category: LocalCopingStrategyCategory { get }
//     var timeToComplete: String { get }
//     var steps: [String] { get }
// }

// enum LocalCopingStrategyCategory { // Example enum
//     case mindfulness, cognitive, physical, social, creative, selfCare
// }

// class LocalCopingStrategiesLibrary { // Example singleton
//     static let shared = LocalCopingStrategiesLibrary()
//     var strategies: [LocalCopingStrategyDetail] = []
//     private init() { /* Load strategies */ }
// }

// Assume Core enums and EngineModels are defined within ResilientMe module
// namespace ResilientMe {
//     enum CoreCopingCategory { case mindfulness, cognitive, physical, social, creative, selfCare }
//     enum CoreStrategyDuration { case veryShort, short, medium, long }
//     namespace EngineModels {
//         enum StrategyCategory { case mindfulness, cognitive, physical, social, creative, selfCare }
//     }
// }

// Assume JournalMood enum is defined (e.g., in JournalModels.swift)
// enum JournalMood { case sad, angry, anxious, overwhelmed, great, good, neutral } 