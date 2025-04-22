import Foundation
import CoreData
import SwiftUI
import ResilientMe
import Combine

// MARK: - Define missing protocols and classes 

// MoodStoreProtocol definition - renamed to LocalMoodStoreProtocol to avoid ambiguity with ResilientMe.MoodStoreProtocol
public protocol LocalMoodStoreProtocol {
    // Empty protocol to represent the data store
    // This is a stub to satisfy compiler requirements
}

// Renamed to avoid conflict with ResilientMe.StrategyEffectivenessStore and other implementations
public class MoodStoreStrategyEffectiveness: ObservableObject {
    public static let shared = MoodStoreStrategyEffectiveness()
    
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

// MARK: - ChartData for visualization
struct ChartData: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
    let percentage: Double
}

// MARK: - MoodData for view use
public struct MoodData: Identifiable, Hashable {
    public let id: String
    public let date: Date
    public let mood: String
    public let customMood: String? // For user-defined moods
    public let intensity: Int
    public let note: String?
    public let rejectionRelated: Bool
    public let rejectionTrigger: String?
    public let copingStrategy: String?
    public let journalPromptShown: Bool // Track if a journal prompt was shown
    public let recommendedCopingStrategies: [String]? // AI-recommended strategies
    
    public init(id: String, date: Date, mood: String, customMood: String? = nil, 
                intensity: Int, note: String? = nil, rejectionRelated: Bool = false, 
                rejectionTrigger: String? = nil, copingStrategy: String? = nil, 
                journalPromptShown: Bool = false, recommendedCopingStrategies: [String]? = nil) {
        self.id = id
        self.date = date
        self.mood = mood
        self.customMood = customMood
        self.intensity = intensity
        self.note = note
        self.rejectionRelated = rejectionRelated
        self.rejectionTrigger = rejectionTrigger
        self.copingStrategy = copingStrategy
        self.journalPromptShown = journalPromptShown
        self.recommendedCopingStrategies = recommendedCopingStrategies
    }
    
    public static func == (lhs: MoodData, rhs: MoodData) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - PredefinedMoods for consistent selection options
struct PredefinedMoods {
    static let positive = ["Happy", "Calm", "Excited", "Grateful", "Proud", "Motivated", "Confident"]
    static let negative = ["Sad", "Anxious", "Angry", "Discouraged", "Frustrated", "Disappointed", "Embarrassed", "Overwhelmed"]
    static let neutral = ["Neutral", "Tired", "Confused", "Surprised", "Curious"]
    
    static var all: [String] {
        positive + negative + neutral
    }
    
    static func categoryFor(mood: String) -> String {
        if positive.contains(mood) { return "Positive" }
        if negative.contains(mood) { return "Negative" }
        return "Neutral"
    }
}

// MARK: - RejectionTriggers for categorizing rejection experiences
struct RejectionTriggers {
    static let social = ["Social media rejection", "Friend ignored me", "Excluded from group", "Message left on read"]
    static let romantic = ["Dating app rejection", "Romantic interest chose someone else", "Breakup", "Date canceled"]
    static let professional = ["Job application rejected", "Promotion passed over", "Project feedback negative", "Idea dismissed at work"]
    static let family = ["Family criticism", "Family disagreement", "Not supported by family"]
    static let academic = ["Poor grade received", "Academic application rejected", "Criticism from instructor"]
    
    static var all: [String] {
        social + romantic + professional + family + academic
    }
    
    static func categoryFor(trigger: String) -> String {
        if social.contains(trigger) { return "Social" }
        if romantic.contains(trigger) { return "Romantic" }
        if professional.contains(trigger) { return "Professional" }
        if family.contains(trigger) { return "Family" }
        if academic.contains(trigger) { return "Academic" }
        return "Other"
    }
}

// MARK: - CopingStrategies for suggesting and tracking methods
struct CopingStrategyCategories {
    static let active = ["Physical activity", "Creative expression", "Talking to someone", "Problem solving"]
    static let cognitive = ["Positive self-talk", "Reframing the situation", "Finding the lesson", "Focusing on strengths"]
    static let relaxation = ["Deep breathing", "Meditation", "Progressive muscle relaxation", "Nature walk"]
    static let distraction = ["Engaging hobby", "Watching a movie", "Reading", "Listening to music"]
    
    static var all: [String] {
        active + cognitive + relaxation + distraction
    }
    
    static func categoryFor(strategy: String) -> String {
        if active.contains(strategy) { return "Active" }
        if cognitive.contains(strategy) { return "Cognitive" }
        if relaxation.contains(strategy) { return "Relaxation" }
        if distraction.contains(strategy) { return "Distraction" }
        return "Other"
    }
    
    // Return strategies appropriate for a particular mood/trigger
    static func recommendFor(mood: String, trigger: String? = nil) -> [String] {
        var recommendations: [String] = []
        
        // Based on mood type
        if PredefinedMoods.negative.contains(mood) {
            // For negative moods, suggest a mix of strategies
            recommendations.append(contentsOf: cognitive.prefix(2))
            recommendations.append(contentsOf: relaxation.prefix(2))
        }
        
        // Add trigger-specific recommendations
        if let trigger = trigger {
            if RejectionTriggers.social.contains(trigger) {
                recommendations.append(contentsOf: ["Talking to a trusted friend", "Social media break"])
            } else if RejectionTriggers.professional.contains(trigger) {
                recommendations.append(contentsOf: ["Reviewing accomplishments", "Seeking mentorship"])
            }
        }
        
        // If we don't have at least 3 recommendations, add some general ones
        if recommendations.count < 3 {
            recommendations.append(contentsOf: ["Deep breathing", "Positive self-talk", "Taking a walk"].prefix(3 - recommendations.count))
        }
        
        return Array(recommendations.prefix(5)) // Limit to 5 recommendations
    }
}

// MARK: - JournalPrompts for guided reflection
struct JournalPrompts {
    static func getPromptForMood(_ mood: String, trigger: String? = nil) -> String {
        // First, handle rejection-specific prompts if applicable
        if let trigger = trigger {
            // Prompts specifically for rejection experiences
            if RejectionTriggers.social.contains(trigger) {
                if mood == "Anxious" {
                    return "Social rejection can trigger anxiety. What specific fears came up during this experience? How have you successfully navigated similar social situations in the past?"
                } else if mood == "Sad" || mood == "Discouraged" {
                    return "Social connection is a fundamental need. How did this social rejection experience affect your sense of belonging? What supports or connections can you lean on right now?"
                } else if mood == "Angry" {
                    return "Social rejection can feel unfair. What boundaries might have been crossed? How can you honor your feelings while responding in a way that aligns with your values?"
                } else {
                    return "Social rejection can be challenging. What have you learned about yourself through this experience? How might this insight help with future interactions?"
                }
            } else if RejectionTriggers.professional.contains(trigger) {
                if mood == "Discouraged" || mood == "Sad" {
                    return "Professional setbacks often feel personal but rarely are. What strengths and accomplishments can you remind yourself of right now? What is one small step toward your goals?"
                } else if mood == "Embarrassed" {
                    return "Professional rejection in front of others can be difficult. How would you view this situation if it happened to a colleague you respect? What perspective might help you be kinder to yourself?"
                } else {
                    return "Professional rejection is part of everyone's journey. What lessons or feedback might be valuable here? How can you separate your worth from this particular outcome?"
                }
            } else if RejectionTriggers.romantic.contains(trigger) {
                if mood == "Sad" || mood == "Discouraged" {
                    return "Romantic rejection touches our deepest vulnerabilities. What does this experience bring up about your fears or past relationships? What would you tell a friend going through this?"
                } else if mood == "Angry" {
                    return "Romantic disappointments can bring up strong emotions. What unmet expectation or need is beneath this anger? What healthy boundaries might need to be established?"
                } else {
                    return "Romantic rejection, while painful, often redirects us to better paths. What have you learned about your needs and values through this experience?"
                }
            }
        }
        
        // Standard mood-based prompts if no rejection trigger or specific prompt was found
        if PredefinedMoods.negative.contains(mood) {
            if mood == "Anxious" {
                return "What specifically about this situation is making you feel anxious? What's the worst that could happen, and how likely is it? What resources do you have to cope?"
            } else if mood == "Sad" || mood == "Discouraged" {
                return "What thoughts are contributing to your sadness? Is there another perspective you could consider? What small comfort might help right now?"
            } else if mood == "Angry" || mood == "Frustrated" {
                return "What's beneath your anger? Is there a boundary that was crossed or a need that wasn't met? How can you honor this emotion while responding thoughtfully?"
            } else if mood == "Overwhelmed" {
                return "What's contributing to feeling overwhelmed right now? How might you break things down into smaller, manageable parts? What can you let go of temporarily?"
            } else if mood == "Embarrassed" {
                return "We all experience embarrassment. How might this look from an outside perspective? How significant will this feel in a week, a month, or a year?"
            }
            
            // Generic negative mood prompt
            return "What thoughts are going through your mind right now? How might you respond to a friend feeling this way? What small step might help you feel better?"
        } else if PredefinedMoods.positive.contains(mood) {
            // Positive mood prompts
            return "What contributed to this positive feeling? How can you create more moments like this? Who might you share this experience with?"
        }
        
        // Default prompt
        return "How are you feeling right now, and what might have contributed to this feeling? What would support you in this moment?"
    }
}

// MARK: - Strategy Effectiveness Store
// Using the shared StrategyEffectivenessStore from MoodEngineModels
// Added implementation details for backward compatibility

// Wrapper class to hold properties that can't go in an extension
class StrategyEffectivenessStoreHelper {
    static let shared = StrategyEffectivenessStoreHelper()
    @Published var recommendationWeights: [String: Double] = [:]
    @Published var userPreferences: UserStrategyPreferences = UserStrategyPreferences.default
    
    private init() {
        // Private initializer for singleton
        initializeDefaultWeights()
    }
    
    // User preferences type
    struct UserStrategyPreferences: Codable {
        var preferredDuration: StrategyDuration
        var preferredTimeOfDay: [TimeOfDay]
        var avoidedCategories: [String]
        var favoriteCategories: [String]
        
        enum StrategyDuration: String, Codable, CaseIterable {
            case veryShort = "Under 2 minutes"
            case short = "2-5 minutes"
            case medium = "5-15 minutes"
            case long = "Over 15 minutes"
        }
        
        enum TimeOfDay: String, Codable, CaseIterable {
            case morning = "Morning"
            case afternoon = "Afternoon"
            case evening = "Evening"
            case night = "Night"
        }
        
        static var `default`: UserStrategyPreferences {
            return UserStrategyPreferences(
                preferredDuration: .short,
                preferredTimeOfDay: [.morning, .evening],
                avoidedCategories: [],
                favoriteCategories: []
            )
        }
    }
    
    // Initialize default weights
    func initializeDefaultWeights() {
        recommendationWeights = [
            "mindfulness": 1.0,
            "cognitive": 1.0,
            "physical": 1.0,
            "social": 1.0,
            "creative": 1.0,
            "selfCare": 1.0
        ]
    }
}

// Extend the shared MoodStoreStrategyEffectiveness with additional functionality
extension MoodStoreStrategyEffectiveness {
    private var helper: StrategyEffectivenessStoreHelper { StrategyEffectivenessStoreHelper.shared }
    private var userDefaults: UserDefaults { UserDefaults.standard }
    
    // Access helper properties
    var recommendationWeights: [String: Double] {
        get { helper.recommendationWeights }
        set { helper.recommendationWeights = newValue }
    }
    
    var userPreferences: StrategyEffectivenessStoreHelper.UserStrategyPreferences {
        get { helper.userPreferences }
        set { helper.userPreferences = newValue }
    }
    
    // Save ratings to UserDefaults
    func saveRatings() {
        if let encoded = try? JSONEncoder().encode(ratingData) {
            userDefaults.set(encoded, forKey: "strategyRatings")
        }
    }
    
    // Save weights to UserDefaults
    func saveWeights() {
        if let encoded = try? JSONEncoder().encode(recommendationWeights) {
            userDefaults.set(encoded, forKey: "recommendationWeights")
        }
    }
    
    // Update weighting for recommendations based on user feedback
    func updateRecommendationWeights() {
        // Skip if not enough data
        guard ratingData.count >= 3 else { return }
        
        // Get ratings from the past 30 days for more relevant weighting
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        let recentRatings = ratingData.filter { $0.timestamp > thirtyDaysAgo }
        
        // Group ratings by strategy category
        var categoryRatings: [String: [Int]] = [:]
        
        for rating in recentRatings {
            let category = getCategoryForStrategy(rating.strategy)
            if categoryRatings[category] == nil {
                categoryRatings[category] = []
            }
            categoryRatings[category]?.append(rating.rating)
        }
        
        // Calculate average rating per category
        for (category, ratings) in categoryRatings {
            let average = Double(ratings.reduce(0, +)) / Double(ratings.count)
            
            // Weight is scaled between 0.5 and 2.0 based on ratings (1-5)
            let weight = 0.5 + (average - 1.0) * 0.375 // Maps 1-5 to 0.5-2.0
            
            // Update weight (with some inertia from existing weight)
            if let existingWeight = recommendationWeights[category] {
                recommendationWeights[category] = existingWeight * 0.7 + weight * 0.3
            } else {
                recommendationWeights[category] = weight
            }
        }
        
        // Also consider moodImpact if available
        let highImpactRatings = recentRatings.filter { $0.moodImpact == "Major improvement" }
        for rating in highImpactRatings {
            let category = getCategoryForStrategy(rating.strategy)
            if let existingWeight = recommendationWeights[category] {
                // Boost weight further for strategies with major mood improvements
                recommendationWeights[category] = min(existingWeight * 1.1, 2.5)
            }
        }
        
        saveWeights()
    }
    
    // Get strategy category - in a real app, this would use your data model
    func getCategoryForStrategy(_ strategy: String) -> String {
        // This is a placeholder implementation
        // In your app, you would look up the actual category from your data model
        if strategy.lowercased().contains("breath") || strategy.lowercased().contains("meditat") {
            return "mindfulness"
        } else if strategy.lowercased().contains("thought") || strategy.lowercased().contains("reframe") {
            return "cognitive"
        } else if strategy.lowercased().contains("walk") || strategy.lowercased().contains("exercise") {
            return "physical"
        } else if strategy.lowercased().contains("friend") || strategy.lowercased().contains("social") {
            return "social"
        } else if strategy.lowercased().contains("creat") || strategy.lowercased().contains("art") {
            return "creative"
        } else {
            return "selfCare"
        }
    }
    
    // Updates user preferences
    func updateUserPreferences(_ newPreferences: StrategyEffectivenessStoreHelper.UserStrategyPreferences) {
        helper.userPreferences = newPreferences
        
        if let encoded = try? JSONEncoder().encode(userPreferences) {
            userDefaults.set(encoded, forKey: "userStrategyPreferences")
        }
    }
    
    // Get recommended strategies based on learned preferences
    func getRecommendedStrategiesFor(
        mood: String,
        intensity: Int,
        preferShort: Bool = false
    ) -> [String: Double] {
        // This would return a dictionary of strategy IDs with their recommendation scores
        // The calling code would then sort and select strategies based on these scores
        
        // A more sophisticated implementation would consider:
        // 1. Time of day and user's preferred times
        // 2. Duration preferences
        // 3. Category weights from past feedback
        // 4. Emotional state/mood matching
        // 5. Mixing familiar strategies with new ones
        
        // This is just a placeholder implementation
        return recommendationWeights
    }
    
    // Get strategy trend over time
    func getStrategyTrend(for strategy: String) -> [Double] {
        // Get all ratings for this strategy, sorted by date
        let ratings = ratingData
            .filter { $0.strategy == strategy }
            .sorted { $0.timestamp < $1.timestamp }
            .map { Double($0.rating) }  // Convert Int to Double here
        
        // If we have less than 5 ratings, pad with zeros
        if ratings.count < 5 {
            return ratings + Array(repeating: 0.0, count: 5 - ratings.count)
        }
        
        // Return the last 5 ratings
        return Array(ratings.suffix(5))
    }
}

// MARK: - MoodStore for CoreData interactions
// Rename to avoid redeclaration or use an extension instead
class CoreDataMoodStore: ObservableObject, LocalMoodStoreProtocol {
    @Published var moodEntries: [MoodData] = []
    @Published var recentMoods: [String] = []
    @Published var rejectionProcessedCount: Int = 0
    @Published var currentDayStreak: Int = 0
    private let context: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchMoodEntries()
        setupBindings()
    }

    private func setupBindings() {
        print("Setting up bindings for CoreDataMoodStore...")
        $moodEntries
            .receive(on: DispatchQueue.main)
            .sink { [weak self] entries in
                print("MoodEntries changed, recalculating stats...")
                self?.calculateRejectionCount(entries: entries)
                self?.calculateDayStreak(entries: entries)
                self?.updateRecentMoods(entries: entries)
            }
            .store(in: &cancellables)
    }

    func fetchMoodEntries() {
        print("Fetching mood entries...")
        let request = NSFetchRequest<MoodEntryEntity>(entityName: "MoodEntryEntity")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MoodEntryEntity.date, ascending: false)]

        do {
            let entities = try context.fetch(request)
            self.moodEntries = entities.map { entity in
                return MoodData(
                    id: entity.id ?? UUID().uuidString,
                    date: entity.date ?? Date(),
                    mood: entity.mood ?? "Unknown",
                    customMood: entity.customMood,
                    intensity: Int(entity.intensity),
                    note: entity.note,
                    rejectionRelated: entity.rejectionRelated,
                    rejectionTrigger: entity.rejectionTrigger,
                    copingStrategy: entity.copingStrategy,
                    journalPromptShown: entity.journalPromptShown,
                    recommendedCopingStrategies: entity.recommendedStrategies?.components(separatedBy: ",")
                )
            }
            print("Fetched \(self.moodEntries.count) mood entries.")
        } catch {
            print("Error fetching mood entries: \(error)")
            self.moodEntries = []
            self.rejectionProcessedCount = 0
            self.currentDayStreak = 0
            self.recentMoods = []
        }
    }

    private func updateRecentMoods(entries: [MoodData]) {
        let moods = entries.prefix(20).map { $0.mood }
        let uniqueMoods = Array(Set(moods))
        self.recentMoods = Array(uniqueMoods.prefix(5))
        print("Updated recent moods: \(self.recentMoods)")
    }

    func saveMoodEntry(entry: MoodData) {
        print("Saving mood entry: ID \(entry.id)")
        let newEntry = MoodEntryEntity(context: context)
        newEntry.id = entry.id
        newEntry.date = entry.date
        newEntry.mood = entry.mood
        newEntry.customMood = entry.customMood
        newEntry.intensity = Int16(entry.intensity)
        newEntry.note = entry.note
        newEntry.rejectionRelated = entry.rejectionRelated
        newEntry.rejectionTrigger = entry.rejectionTrigger
        newEntry.copingStrategy = entry.copingStrategy
        newEntry.journalPromptShown = entry.journalPromptShown
        newEntry.recommendedStrategies = entry.recommendedCopingStrategies?.joined(separator: ",")

        do {
            try context.save()
            print("Mood entry saved successfully. Fetching updates...")
            fetchMoodEntries()
        } catch {
            print("Error saving mood entry: \(error)")
        }
    }

    func updateMoodEntry(entry: ResilientMe.MoodData) {
        print("Updating mood entry: ID \(entry.id)")
        let request = NSFetchRequest<MoodEntryEntity>(entityName: "MoodEntryEntity")
        request.predicate = NSPredicate(format: "id == %@", entry.id)
        request.fetchLimit = 1

        do {
            let results = try context.fetch(request)
            if let entityToUpdate = results.first {
                entityToUpdate.date = entry.date
                entityToUpdate.mood = entry.mood
                entityToUpdate.intensity = Int16(entry.intensity)
                entityToUpdate.note = entry.note
                entityToUpdate.rejectionRelated = entry.rejectionRelated
                entityToUpdate.rejectionTrigger = entry.rejectionTrigger
                entityToUpdate.copingStrategy = entry.copingStrategy
                entityToUpdate.journalPromptShown = entry.journalPromptShown
                entityToUpdate.recommendedStrategies = entry.recommendedCopingStrategies?.joined(separator: ",")

                try context.save()
                print("Mood entry updated successfully. Fetching updates...")
                fetchMoodEntries()
            } else {
                print("Error updating mood entry: ID \(entry.id) not found.")
            }
        } catch {
            print("Error updating mood entry: \(error)")
        }
    }

    func saveMoodEntry(mood: String, intensity: Int, note: String? = nil,
                      rejectionRelated: Bool = false, rejectionTrigger: String? = nil,
                      copingStrategy: String? = nil) {
        print("Saving mood entry (legacy method)...")
        let recommendedStrategies = rejectionRelated ?
            CopingStrategyCategories.recommendFor(mood: mood, trigger: rejectionTrigger) : nil

        let newEntry = MoodEntryEntity(context: context)
        newEntry.id = UUID().uuidString
        newEntry.date = Date()
        newEntry.mood = mood
        newEntry.intensity = Int16(intensity)
        newEntry.note = note
        newEntry.rejectionRelated = rejectionRelated
        newEntry.rejectionTrigger = rejectionTrigger
        newEntry.copingStrategy = copingStrategy
        newEntry.journalPromptShown = false
        newEntry.recommendedStrategies = recommendedStrategies?.joined(separator: ",")

        do {
            try context.save()
            print("Mood entry saved successfully (legacy). Fetching updates...")
            fetchMoodEntries()
        } catch {
            print("Error saving mood entry (legacy): \(error)")
        }
    }

    func updateJournalPromptShown(id: String, shown: Bool) {
        print("Updating journal prompt shown for ID \(id) to \(shown)")
        let request = NSFetchRequest<MoodEntryEntity>(entityName: "MoodEntryEntity")
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1

        do {
            let entries = try context.fetch(request)
            if let entry = entries.first {
                entry.journalPromptShown = shown
                try context.save()
                print("Journal prompt status updated. Fetching updates...")
                fetchMoodEntries()
            }
        } catch {
            print("Error updating journal prompt status: \(error)")
        }
    }

    func deleteMoodEntry(id: String) {
        print("Deleting mood entry ID \(id)")
        let request = NSFetchRequest<MoodEntryEntity>(entityName: "MoodEntryEntity")
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1

        do {
            let entries = try context.fetch(request)
            if let entry = entries.first {
                context.delete(entry)
                try context.save()
                print("Mood entry deleted successfully. Fetching updates...")
                fetchMoodEntries()
            }
        } catch {
            print("Error deleting mood entry: \(error)")
        }
    }

    private func calculateRejectionCount(entries: [MoodData]) {
        let count = entries.filter { $0.rejectionRelated }.count
        if self.rejectionProcessedCount != count {
            self.rejectionProcessedCount = count
            print("Updated Rejection Count: \(count)")
        }
    }

    private func calculateDayStreak(entries: [MoodData]) {
        guard !entries.isEmpty else {
            if self.currentDayStreak != 0 {
                self.currentDayStreak = 0
                print("Updated Day Streak: 0 (no entries)")
            }
            return
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0

        let entryDays = Set(entries.compactMap { calendar.startOfDay(for: $0.date) })

        var currentDayToCheck = today

        while true {
            if entryDays.contains(currentDayToCheck) {
                streak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDayToCheck) else { break }
                currentDayToCheck = previousDay
            } else {
                if currentDayToCheck == today {
                    guard let yesterday = calendar.date(byAdding: .day, value: -1, to: currentDayToCheck) else { break }
                    if entryDays.contains(yesterday) {
                        streak += 1
                        guard let dayBeforeYesterday = calendar.date(byAdding: .day, value: -1, to: yesterday) else { break }
                        currentDayToCheck = dayBeforeYesterday
                        continue
                    }
                }
                break
            }
        }

        if self.currentDayStreak != streak {
            self.currentDayStreak = streak
            print("Updated Day Streak: \(streak)")
        }
    }

    func getMoodEntriesForTimeframe(_ timeframe: MoodView.TimeFrame) -> [MoodData] {
        let calendar = Calendar.current
        let now = Date()
        let startDate: Date

        switch timeframe {
        case .day:
            startDate = calendar.startOfDay(for: now)
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? calendar.startOfDay(for: now)
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? calendar.startOfDay(for: now)
        }
        return moodEntries.filter { $0.date >= startDate }
    }

    func getMoodDistribution(timeframe: MoodView.TimeFrame) -> [String: Int] {
        let entries = getMoodEntriesForTimeframe(timeframe)
        var distribution: [String: Int] = [:]
        for entry in entries {
            let category = PredefinedMoods.categoryFor(mood: entry.mood)
            distribution[category, default: 0] += 1
        }
        return distribution
    }

    func getRejectionTriggerDistribution(timeframe: MoodView.TimeFrame) -> [String: Int] {
        let entries = getMoodEntriesForTimeframe(timeframe).filter { $0.rejectionRelated && $0.rejectionTrigger != nil }
        var distribution: [String: Int] = [:]
        for entry in entries {
            if let trigger = entry.rejectionTrigger {
                let category = RejectionTriggers.categoryFor(trigger: trigger)
                distribution[category, default: 0] += 1
            }
        }
        return distribution
    }

    func getEffectiveCopingStrategies(timeframe: MoodView.TimeFrame) -> [String: Int] {
        let entries = getMoodEntriesForTimeframe(timeframe).filter { $0.copingStrategy != nil }
        var strategyCounts: [String: Int] = [:]
        for entry in entries {
            if let strategy = entry.copingStrategy {
                strategyCounts[strategy, default: 0] += 1
            }
        }
        return strategyCounts
    }

    func getAverageIntensity(timeframe: MoodView.TimeFrame) -> Double {
        let entries = getMoodEntriesForTimeframe(timeframe)
        guard !entries.isEmpty else { return 0 }
        let sum = entries.reduce(0) { $0 + $1.intensity }
        return Double(sum) / Double(entries.count)
    }

    func getEntriesNeedingJournalPrompts() -> [MoodData] {
        return moodEntries
            .filter { entry -> Bool in
                if entry.rejectionRelated &&
                   PredefinedMoods.negative.contains(entry.mood) &&
                   !entry.journalPromptShown {
                    return true
                }
                if PredefinedMoods.negative.contains(entry.mood) &&
                   entry.intensity >= 4 &&
                   !entry.journalPromptShown {
                    return true
                }
                return false
            }
            .sorted { entry1, entry2 -> Bool in
                if entry1.rejectionRelated != entry2.rejectionRelated { return entry1.rejectionRelated }
                else if entry1.intensity != entry2.intensity { return entry1.intensity > entry2.intensity }
                else { return entry1.date > entry2.date }
            }
            .prefix(3)
            .map { $0 }
    }

    func getJournalPromptFor(entry: MoodData) -> (String, String, [String]) {
        let title: String
        if entry.rejectionRelated, let trigger = entry.rejectionTrigger {
            title = "Reflection on \(trigger)"
        } else {
            title = "Reflection on feeling \(entry.mood)"
        }
        let promptContent = JournalPrompts.getPromptForMood(entry.mood, trigger: entry.rejectionTrigger)
        var suggestedTags = ["Growth"]
        if entry.rejectionRelated { suggestedTags.append("Rejection") }
        if PredefinedMoods.negative.contains(entry.mood) { suggestedTags.append("Insight") }
        return (title, promptContent, suggestedTags)
    }

    func getMoodDistributionData() -> [ChartData] {
        let moodCounts = moodEntries.reduce(into: [:]) { $0[$1.mood, default: 0] += 1 }
        let total = Double(moodEntries.count)
        let sortedMoods = moodCounts.sorted { $0.value > $1.value }
        return sortedMoods.map { mood, count in
            ChartData(label: mood, value: Double(count), percentage: total > 0 ? (Double(count) / total) * 100 : 0)
        }
    }

    func convertToMoodData(entry: MoodEntryEntity) -> MoodData {
        return MoodData(
            id: entry.id ?? UUID().uuidString,
            date: entry.date ?? Date(),
            mood: entry.mood ?? "",
            customMood: nil,
            intensity: Int(entry.intensity),
            note: entry.note,
            rejectionRelated: entry.rejectionRelated,
            rejectionTrigger: entry.rejectionTrigger,
            copingStrategy: entry.copingStrategy,
            journalPromptShown: entry.journalPromptShown,
            recommendedCopingStrategies: entry.recommendedStrategies?.components(separatedBy: ",")
        )
    }
}

// MARK: - CoreDataMoodStore Extension for StrategyEffectivenessStore integration
extension CoreDataMoodStore {
    var strategyStore: MoodStoreStrategyEffectiveness { MoodStoreStrategyEffectiveness.shared }

    func getCompletionCount(for strategy: String) -> Int {
        return strategyStore.getCompletionCount(for: strategy)
    }

    func getAverageRating(for strategy: String) -> Double {
        return strategyStore.getAverageRating(for: strategy)
    }

    func getMostEffectiveStrategies() -> [(strategy: String, rating: Double)] {
        return strategyStore.getMostEffectiveStrategies()
    }

    func getMostUsedStrategies() -> [(strategy: String, count: Int)] {
        return strategyStore.getMostUsedStrategies()
    }

    func getRatingHistory(for strategy: String) -> [(date: Date, rating: Int)] {
        return strategyStore.getRatingHistory(for: strategy)
    }
}
