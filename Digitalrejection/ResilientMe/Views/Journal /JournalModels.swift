import Foundation
import ResilientMe // Keep necessary imports

// MARK: - Data Types

// Add a JournalMood enum to avoid ambiguity
enum JournalMood: String, CaseIterable, Identifiable {
    case great = "Great"
    case good = "Good"
    case neutral = "Neutral"
    case sad = "Sad"
    case anxious = "Anxious"
    case angry = "Angry"
    case overwhelmed = "Overwhelmed"
    
    var id: String { self.rawValue }
    
    var name: String { self.rawValue }
    
    var emoji: String {
        switch self {
        case .great: return "😄"
        case .good: return "🙂"
        case .neutral: return "😐"
        case .sad: return "😢"
        case .anxious: return "😰"
        case .angry: return "😠"
        case .overwhelmed: return "😫"
        }
    }

    // Helper function to get color associated with mood
    func moodColor() -> Color {
        switch self {
        case .great: return AppColors.joy
        case .good: return AppColors.calm
        case .neutral: return AppColors.secondary
        case .sad: return AppColors.sadness
        case .anxious: return AppColors.error // Consider specific color for anxious if available
        case .angry: return AppColors.frustration // Consider specific color for angry if available
        case .overwhelmed: return AppColors.error // Consider specific color for overwhelmed if available
        }
    }
}

// Define the JournalEntryModel type directly in this file
struct JournalEntryModel: Identifiable, Equatable {
    let id: String
    let date: Date
    let title: String
    let content: String
    let tags: [String]
    let mood: JournalMood?
    let moodIntensity: Int? // Store as Int (1-10)
    
    static func == (lhs: JournalEntryModel, rhs: JournalEntryModel) -> Bool {
        return lhs.id == rhs.id
    }
}

enum FilterOption: String, CaseIterable, Identifiable {
    case all
    case rejections
    case insights
    case gratitude
    case habits
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .all: return "All"
        case .rejections: return "Rejections"
        case .insights: return "Insights"
        case .gratitude: return "Gratitude"
        case .habits: return "Habits"
        }
    }
}

// Type aliases for backward compatibility with Core module types if needed elsewhere
// If these are only used within JournalView context, they might not be needed globally.
// Consider if these are still necessary after refactoring.
typealias CopingStrategyDetail = ResilientMe.CoreStrategyDetail
typealias CopingStrategyCategory = ResilientMe.CoreCopingCategory
typealias StrategyDuration = ResilientMe.CoreStrategyDuration

// It seems AppColors, AppTextStyles etc. are defined elsewhere.
// Need to ensure they are accessible, possibly via import or global definition.
// Assuming they are globally available or in an imported module.
import SwiftUI // Add SwiftUI for Color type

// Placeholder for AppColors and AppTextStyles if not globally defined
// struct AppColors {
//     static let joy = Color.yellow
//     static let calm = Color.blue
//     static let secondary = Color.gray
//     static let sadness = Color.purple
//     static let error = Color.red
//     static let frustration = Color.orange
//     // Add other colors used
// }
//
// struct AppTextStyles {
//     // Define text styles if needed
// }
//
// struct AppLayout {
//     // Define layout constants if needed
// }

