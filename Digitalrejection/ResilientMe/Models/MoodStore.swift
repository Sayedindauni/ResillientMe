import Foundation
import CoreData
import SwiftUI

// MARK: - MoodData for view use
struct MoodData: Identifiable, Hashable {
    let id: String
    let date: Date
    let mood: String
    let customMood: String? // For user-defined moods
    let intensity: Int
    let note: String?
    let rejectionRelated: Bool
    let rejectionTrigger: String?
    let copingStrategy: String?
    let journalPromptShown: Bool // Track if a journal prompt was shown
    let recommendedCopingStrategies: [String]? // AI-recommended strategies
    
    static func == (lhs: MoodData, rhs: MoodData) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
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
struct CopingStrategies {
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
    static func forMood(_ mood: String, trigger: String? = nil) -> String {
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

// MARK: - MoodStore for CoreData interactions
class MoodStore: ObservableObject {
    @Published var moodEntries: [MoodData] = []
    @Published var recentMoods: [String] = []
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchMoodEntries()
        updateRecentMoods()
    }
    
    func fetchMoodEntries() {
        let request = NSFetchRequest<MoodEntryEntity>(entityName: "MoodEntryEntity")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MoodEntryEntity.date, ascending: false)]
        
        do {
            let entries = try context.fetch(request)
            self.moodEntries = entries.map { entity in
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
            updateRecentMoods()
        } catch {
            print("Error fetching mood entries: \(error)")
        }
    }
    
    private func updateRecentMoods() {
        // Get the 5 most recent unique moods
        let moods = moodEntries.prefix(20).map { $0.mood }
        self.recentMoods = Array(Set(moods)).prefix(5).map { $0 }
    }
    
    func saveMoodEntry(entry: MoodData) {
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
            fetchMoodEntries()
            print("Mood entry saved successfully")
        } catch {
            print("Error saving mood entry: \(error)")
        }
    }
    
    // Original method for backward compatibility
    func saveMoodEntry(mood: String, intensity: Int, note: String? = nil, 
                      rejectionRelated: Bool = false, rejectionTrigger: String? = nil, 
                      copingStrategy: String? = nil) {
        
        // Generate recommended coping strategies based on mood and trigger
        let recommendedStrategies = rejectionRelated ? 
            CopingStrategies.recommendFor(mood: mood, trigger: rejectionTrigger) : nil
        
        let newEntry = MoodEntryEntity(context: context)
        newEntry.id = UUID().uuidString
        newEntry.date = Date()
        newEntry.mood = mood
        newEntry.intensity = Int16(intensity)
        newEntry.note = note
        newEntry.rejectionRelated = rejectionRelated
        newEntry.rejectionTrigger = rejectionTrigger
        newEntry.copingStrategy = copingStrategy
        newEntry.journalPromptShown = false // Initialize as not shown
        newEntry.recommendedStrategies = recommendedStrategies?.joined(separator: ",")
        
        do {
            try context.save()
            fetchMoodEntries()
            print("Mood entry saved successfully")
        } catch {
            print("Error saving mood entry: \(error)")
        }
    }
    
    func updateJournalPromptShown(id: String, shown: Bool) {
        let request = NSFetchRequest<MoodEntryEntity>(entityName: "MoodEntryEntity")
        request.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let entries = try context.fetch(request)
            if let entry = entries.first {
                entry.journalPromptShown = shown
                try context.save()
                fetchMoodEntries()
            }
        } catch {
            print("Error updating journal prompt status: \(error)")
        }
    }
    
    func deleteMoodEntry(id: String) {
        let request = NSFetchRequest<MoodEntryEntity>(entityName: "MoodEntryEntity")
        request.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let entries = try context.fetch(request)
            if let entry = entries.first {
                context.delete(entry)
                try context.save()
                fetchMoodEntries()
                print("Mood entry deleted successfully")
            }
        } catch {
            print("Error deleting mood entry: \(error)")
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
            if let date = calendar.date(byAdding: .day, value: -7, to: now) {
                startDate = date
            } else {
                startDate = calendar.startOfDay(for: now)
            }
        case .month:
            if let date = calendar.date(byAdding: .month, value: -1, to: now) {
                startDate = date
            } else {
                startDate = calendar.startOfDay(for: now)
            }
        }
        
        return moodEntries.filter { $0.date >= startDate }
    }
    
    // Get mood aggregates by category
    func getMoodDistribution(timeframe: MoodView.TimeFrame) -> [String: Int] {
        let entries = getMoodEntriesForTimeframe(timeframe)
        var distribution: [String: Int] = [:]
        
        for entry in entries {
            let category = PredefinedMoods.categoryFor(mood: entry.mood)
            distribution[category, default: 0] += 1
        }
        
        return distribution
    }
    
    // Get rejection trigger distribution
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
    
    // Get the most effective coping strategies
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
    
    // Get total mood intensity average
    func getAverageIntensity(timeframe: MoodView.TimeFrame) -> Double {
        let entries = getMoodEntriesForTimeframe(timeframe)
        guard !entries.isEmpty else { return 0 }
        
        let sum = entries.reduce(0) { $0 + $1.intensity }
        return Double(sum) / Double(entries.count)
    }
    
    // Get entries that might need journaling prompts
    func getEntriesNeedingJournalPrompts() -> [MoodData] {
        return moodEntries
            .filter { entry -> Bool in 
                // First priority: Negative moods related to rejection that haven't been prompted
                if entry.rejectionRelated && 
                   PredefinedMoods.negative.contains(entry.mood) && 
                   !entry.journalPromptShown {
                    return true
                }
                
                // Second priority: Any high-intensity negative moods that haven't been prompted
                if PredefinedMoods.negative.contains(entry.mood) && 
                   entry.intensity >= 4 && 
                   !entry.journalPromptShown {
                    return true
                }
                
                return false
            }
            .sorted(by: { 
                // Sort by: 1) Rejection-related first, 2) Higher intensity, 3) More recent
                if $0.rejectionRelated != $1.rejectionRelated {
                    return $0.rejectionRelated
                } else if $0.intensity != $1.intensity {
                    return $0.intensity > $1.intensity
                } else {
                    return $0.date > $1.date
                }
            })
            .prefix(3) // Limit to 3 most important entries
            .map { $0 }
    }
    
    // Get a tailored journal prompt based on a specific mood entry
    func getJournalPromptFor(entry: MoodData) -> (String, String, [String]) {
        // Generate an appropriate title based on the mood and trigger
        let title: String
        if entry.rejectionRelated, let trigger = entry.rejectionTrigger {
            title = "Reflection on \(trigger)"
        } else {
            title = "Reflection on feeling \(entry.mood)"
        }
        
        // Get the appropriate prompt content
        let promptContent = JournalPrompts.forMood(entry.mood, trigger: entry.rejectionTrigger)
        
        // Suggest appropriate tags
        var suggestedTags = ["Growth"]
        if entry.rejectionRelated {
            suggestedTags.append("Rejection")
        }
        if PredefinedMoods.negative.contains(entry.mood) {
            suggestedTags.append("Insight")
        }
        
        return (title, promptContent, suggestedTags)
    }
} 