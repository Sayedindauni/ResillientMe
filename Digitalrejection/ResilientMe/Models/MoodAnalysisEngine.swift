//
//  MoodAnalysisEngine.swift
//  ResilientMe
//
//  Created by Sayed Mohamed on 21.03.25.
//

import Foundation
import CoreData
import SwiftUI
import Combine
import UserNotifications
// Keep this comment to explain what we're doing
// We'll use our own internal types instead of importing from Theme

// Extension for TimeInterval to provide .seconds method
extension TimeInterval {
    static func seconds(_ value: Double) -> TimeInterval {
        return value
    }
}

// Stub definitions for types to fix compilation errors
// Replace these with proper imports when available

// MoodStore stub
class EngineMoodStore: ObservableObject {
    @Published var moodEntries: [EngineMoodEntry] = []
    
    func saveMoodEntry(mood: String, intensity: Int, note: String, rejectionRelated: Bool = false, rejectionTrigger: String? = nil, copingStrategy: String? = nil) {
        // Implementation would save to backing store, here we just add to the array
        let entry = EngineMoodEntry(
            id: UUID(),
            mood: EngineMood(rawValue: mood.lowercased()) ?? .calm,
            intensity: intensity,
            date: Date(),
            notes: note,
            rejectionRelated: rejectionRelated,
            rejectionTrigger: rejectionTrigger
        )
        moodEntries.append(entry)
    }
}

// MoodEntry stub
struct EngineMoodEntry: Identifiable, Codable {
    var id = UUID()
    var mood: EngineMood
    var intensity: Int
    var date: Date
    var notes: String
    var rejectionRelated: Bool = false
    var rejectionTrigger: String? = nil
}

// Mood enum stub
enum EngineMood: String, Codable, CaseIterable, Identifiable {
    case happy, sad, anxious, angry, calm, rejected
    var id: String { rawValue }
}

// PuterAIService stub
class StubPuterAIService {
    var isInitialized = CurrentValueSubject<Bool, Never>(false)
    func analyzeText(_ text: String, completion: @escaping (Result<String, Error>) -> Void) {}
    func analyzeMoodPatterns(entries: [EngineMoodEntry], completion: @escaping (Result<[EngineMoodInsight], Error>) -> Void) {}
    func generateCopingStrategies(for mood: EngineMood, intensity: Int, completion: @escaping (Result<EngineCopingStrategies, Error>) -> Void) {}
    func generateJournalPrompt(for mood: EngineMood, completion: @escaping (Result<EngineJournalPrompts, Error>) -> Void) {}
}

// NotificationManager stub
class StubNotificationManager {
    func setupNotificationCategories() {}
    func scheduleNotification(title: String, body: String, identifier: String) {}
    func sendRecommendationNotification(title: String, body: String, recommendation: EngineMoodRecommendation? = nil) {}
    func scheduleImmediateNotification(title: String, body: String) {}
}

// Additional required types
struct EngineCopingStrategies: Identifiable, Codable {
    var id = UUID()
    var strategies: [String] = []
    
    // Add helper methods
    func recommendFor(mood: MoodEngineCopingStrategyCategory) -> [String] {
        return strategies
    }
}

struct EngineJournalPrompts: Identifiable, Codable {
    var id = UUID()
    var prompts: [String] = []
    
    // Add helper methods
    func forMood(mood: MoodEngineCopingStrategyCategory) -> String {
        return prompts.first ?? "No prompt available"
    }
}

// MoodInsight stub for AI analysis
struct EngineMoodInsight: Identifiable, Hashable {
    var id = UUID()
    var title: String
    var description: String
    
    // Add data property to fix error
    var data: Data {
        let jsonString = "{\"title\":\"\(title)\",\"description\":\"\(description)\"}"
        return jsonString.data(using: .utf8)!
    }
}

// MARK: - Recommendation Models

/// Structured models for personalized feedback and recommendations
struct EngineMoodRecommendation: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let triggerPattern: String
    let strategies: [EngineCopingStrategy]
    let resources: [EngineRecommendedResource]
    let confidenceLevel: Double // 0.0-1.0 representing AI confidence
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: EngineMoodRecommendation, rhs: EngineMoodRecommendation) -> Bool {
        return lhs.id == rhs.id
    }
}

// Define CopingStrategyCategory here to avoid import issues
public enum EngineAnalysisCopingStrategyCategory: String, CaseIterable, Identifiable {
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
        case .cognitive: return .purple
        case .physical: return Color(red: 0.2, green: 0.8, blue: 0.4)
        case .social: return Color(red: 0.6, green: 0.4, blue: 0.8)
        case .creative: return Color(red: 0.9, green: 0.3, blue: 0.5)
        case .selfCare: return Color(red: 0.9, green: 0.4, blue: 0.4)
        }
    }
}

// First, define a new enum name for MoodEngineCopingStrategyCategory
enum MoodEngineCopingStrategyCategory: String, CaseIterable {
    case mindfulness = "Mindfulness"
    case cognitive = "Cognitive"
    case physical = "Physical"
    case social = "Social"
    case creative = "Creative"
    case selfCare = "Self-Care"
    
    // Add any methods or properties that are used with this enum
    var color: Color {
        switch self {
        case .mindfulness: return .blue
        case .cognitive: return .purple
        case .physical: return Color(red: 0.2, green: 0.8, blue: 0.4)
        case .social: return Color(red: 0.6, green: 0.4, blue: 0.8)
        case .creative: return Color(red: 0.9, green: 0.3, blue: 0.5)
        case .selfCare: return Color(red: 0.9, green: 0.4, blue: 0.4)
        }
    }
}

// Now update the references to use the new enum name
struct EngineCopingStrategy: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let timeToComplete: String // e.g. "5 minutes" or "15-20 minutes"
    let steps: [String]
    let category: MoodEngineCopingStrategyCategory
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: EngineCopingStrategy, rhs: EngineCopingStrategy) -> Bool {
        return lhs.id == rhs.id
    }
}

// Define AppResourceType enum to avoid import issues
enum EngineAppResourceType: String, Codable, CaseIterable, Identifiable {
    case article = "Article"
    case video = "Video"
    case audio = "Audio"
    case book = "Book"
    case app = "App"
    case exercise = "Exercise"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .article: return "doc.text"
        case .video: return "play.rectangle"
        case .audio: return "headphones"
        case .book: return "book"
        case .app: return "iphone"
        case .exercise: return "figure.walk"
        }
    }
    
    var color: Color {
        switch self {
        case .article: return .blue
        case .video: return .red
        case .audio: return .purple
        case .book: return .orange
        case .app: return .green
        case .exercise: return .teal
        }
    }
}

struct EngineRecommendedResource: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let type: EngineAppResourceType
    let description: String
    let url: URL?
    let imageURL: URL?
    let source: String
    let isNew: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: EngineRecommendedResource, rhs: EngineRecommendedResource) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Mood Analysis Engine

class MoodAnalysisEngine: ObservableObject {
    @Published var currentRecommendations: [EngineMoodRecommendation] = []
    @Published var hasNewRecommendations: Bool = false
    @Published var isAnalyzing: Bool = false
    @Published var aiInitialized: Bool = false
    
    private var moodStore: EngineMoodStore
    private let insightThreshold = 3 // Minimum entries needed for pattern recognition
    private var cancellables = Set<AnyCancellable>()
    private let notificationManager = StubNotificationManager()
    private let aiService = StubPuterAIService()
    
    // Initialize with a MoodStore instance
    init(moodStore: EngineMoodStore) {
        self.moodStore = moodStore
        
        // Setup notification categories
        notificationManager.setupNotificationCategories()
        
        // Subscribe to MoodStore updates
        moodStore.$moodEntries
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.analyzePatterns()
            }
            .store(in: &cancellables)
            
        // Monitor AI service initialization status
        aiService.isInitialized
            .receive(on: DispatchQueue.main)
            .sink { [weak self] initialized in
                self?.aiInitialized = initialized
            }
            .store(in: &cancellables)
        
        // Set up notification observer for coping strategy follow-ups
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCopingStrategyFollowUp(notification:)),
            name: NSNotification.Name("copingStrategyFollowUp"),
            object: nil
        )
        
        // Set up notification observer for tracking applied strategies
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStrategyApplied(notification:)),
            name: NSNotification.Name("strategyApplied"),
            object: nil
        )
        
        // Start adaptive recommendations after a delay to allow app initialization
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.sendAdaptiveCopingRecommendations()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleCopingStrategyFollowUp(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let strategy = userInfo["strategy"] as? String,
              let wasHelpful = userInfo["wasHelpful"] as? Bool else {
            return
        }
        
        // Process the follow-up response
        processCopingStrategyFollowUp(strategy: strategy, wasHelpful: wasHelpful)
    }
    
    @objc private func handleStrategyApplied(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let strategy = userInfo["strategy"] as? String,
              let timestamp = userInfo["timestamp"] as? Date else {
            return
        }
        
        // Schedule a follow-up for this strategy
        scheduleFollowUpForCopingStrategy(strategy: strategy, appliedAt: timestamp)
    }
    
    // Main analysis method that identifies patterns and generates recommendations
    func analyzePatterns() {
        // Skip analysis if we're already analyzing or the AI isn't ready
        guard !isAnalyzing, aiInitialized, !moodStore.moodEntries.isEmpty else {
            return
        }
        
        // Mark that we're analyzing to prevent duplicate analysis
        isAnalyzing = true
        
        // Use AI service to analyze patterns
        aiService.analyzeMoodPatterns(entries: moodStore.moodEntries) { [weak self] result in
            guard let self = self else { return }
            
            self.isAnalyzing = false
            
            switch result {
            case .success(let aiResponse):
                do {
                    // Parse the AI response - fix the data access
                    let jsonData = self.convertInsightsToData(aiResponse)
                    if let jsonData = jsonData {
                        let decoder = JSONDecoder()
                        
                        do {
                            // Try to decode as a recommendations response
                            let recommendationsResponse = try decoder.decode(AIRecommendationsResponse.self, from: jsonData)
                            let newRecommendations = recommendationsResponse.recommendations.compactMap { recommendationData in
                                return self.convertAIRecommendation(recommendationData)
                            }
                            
                            // Check if we have new recommendations different from current ones
                            let hasChanges = !newRecommendations.isEmpty && Set(newRecommendations) != Set(self.currentRecommendations)
                            
                            // Update recommendations
                            self.currentRecommendations = newRecommendations
                            
                            // Send notification if we have new recommendations
                            if hasChanges {
                                self.hasNewRecommendations = true
                                
                                // Send a local notification if we have permission
                                if !newRecommendations.isEmpty {
                                    self.notificationManager.sendRecommendationNotification(
                                        title: "New Personalized Insights Available",
                                        body: "I've noticed patterns in your mood tracking and have personalized strategies ready for you to try."
                                    )
                                }
                            }
                        } catch {
                            // If parsing failed, fall back to rule-based analysis
                            print("Failed to parse AI response: \(aiResponse)")
                            self.analyzePatternsFallback()
                        }
                    }
                } catch {
                    print("Error processing AI response: \(error)")
                    self.analyzePatternsFallback()
                }
                
            case .failure(let error):
                print("Error analyzing mood patterns: \(error)")
                self.analyzePatternsFallback()
            }
        }
    }
    
    // Fallback to rule-based analysis when AI is unavailable
    private func analyzePatternsFallback() {
        // Start with empty recommendations
        var newRecommendations: [EngineMoodRecommendation] = []
        
        // Pattern 1: Frequent anxiety after rejection
        if let anxietyRecommendation = analyzeAnxietyAfterRejection() {
            newRecommendations.append(anxietyRecommendation)
        }
        
        // Pattern 2: Persistent sadness
        if let sadnessRecommendation = analyzePersistentSadness() {
            newRecommendations.append(sadnessRecommendation)
        }
        
        // Pattern 3: Social rejection sensitivity
        if let socialRejectionRecommendation = analyzeSocialRejectionSensitivity() {
            newRecommendations.append(socialRejectionRecommendation)
        }
        
        // Pattern 4: Professional rejection patterns
        if let professionalRejectionRecommendation = analyzeProfessionalRejectionPattern() {
            newRecommendations.append(professionalRejectionRecommendation)
        }
        
        // Check if we have new recommendations different from current ones
        let hasChanges = !newRecommendations.isEmpty && Set(newRecommendations) != Set(currentRecommendations)
        
        // Update published properties
        DispatchQueue.main.async {
            self.currentRecommendations = newRecommendations
            
            // Send notification if we have new recommendations
            if hasChanges {
                self.hasNewRecommendations = true
                
                // Send a local notification if we have permission
                if !newRecommendations.isEmpty {
                    self.notificationManager.sendRecommendationNotification(
                        title: "New Personalized Insights Available",
                        body: "I've noticed patterns in your mood tracking and have personalized strategies ready for you to try."
                    )
                }
            }
        }
    }
    
    // Convert AI recommendation to our app model
    func convertAIRecommendation(_ aiRecommendation: AIRecommendation) -> EngineMoodRecommendation {
        // Convert strategies
        let strategies = aiRecommendation.strategies.map { strategyData -> EngineCopingStrategy in
            let category: MoodEngineCopingStrategyCategory
            switch strategyData.category.lowercased() {
            case "mindfulness": category = .mindfulness
            case "cognitive": category = .cognitive
            case "physical": category = .physical
            case "social": category = .social
            case "creative": category = .creative
            default: category = .selfCare
            }
            
            return EngineCopingStrategy(
                title: strategyData.title,
                description: strategyData.description,
                timeToComplete: strategyData.time_to_complete,
                steps: strategyData.steps,
                category: category
            )
        }
        
        // Convert resources
        let resources = aiRecommendation.resources.map { resourceData -> EngineRecommendedResource in
            let type: EngineAppResourceType
            switch resourceData.type.lowercased() {
            case "article": type = .article
            case "video": type = .video
            case "audio": type = .audio
            case "app": type = .app
            case "book": type = .book
            default: type = .exercise
            }
            
            return EngineRecommendedResource(
                title: resourceData.title,
                type: type,
                description: resourceData.description,
                url: resourceData.url != nil ? URL(string: resourceData.url!) : nil,
                imageURL: resourceData.image_url != nil ? URL(string: resourceData.image_url!) : nil,
                source: "",
                isNew: false
            )
        }
        
        return EngineMoodRecommendation(
            title: aiRecommendation.title,
            description: aiRecommendation.description,
            triggerPattern: aiRecommendation.trigger_pattern,
            strategies: strategies,
            resources: resources,
            confidenceLevel: aiRecommendation.confidence_level
        )
    }
    
    // Update the mapCategoryString function to use the new enum name
    private func mapCategoryString(_ category: String) -> Mood? {
        switch category.lowercased() {
        case "anxiety": return .anxious
        case "sadness": return .sad
        case "anger": return .angry
        case "happiness": return .happy
        case "calm": return .calm
        case "rejection": return .rejected
        default: return nil
        }
    }
    
    // Helper to map resource type strings to our enum
    private func mapResourceTypeString(_ type: String) -> AppResourceType? {
        let lowercased = type.lowercased()
        if lowercased.contains("article") || lowercased.contains("blog") {
            return .article
        } else if lowercased.contains("video") {
            return .video
        } else if lowercased.contains("audio") || lowercased.contains("podcast") {
            return .audio
        } else if lowercased.contains("app") {
            return .app
        } else if lowercased.contains("book") {
            return .book
        } else if lowercased.contains("exercise") || lowercased.contains("practice") {
            return .exercise
        }
        return nil
    }
    
    // Helper function to convert Mood to EngineMood
    private func convertToEngineMood(_ mood: Mood) -> EngineMood {
        switch mood {
        case .happy, .joyful, .content: return .happy
        case .sad: return .sad
        case .anxious, .stressed: return .anxious
        case .angry, .frustrated: return .angry
        case .calm, .neutral: return .calm
        case .rejected: return .rejected
        }
    }
    
    // Update the getStrategiesForMood function to use the conversion
    func getStrategiesForMood(_ mood: Mood, trigger: Mood? = nil) -> [String] {
        // If AI is not initialized, use rule-based fallback
        if !aiInitialized {
            return CopingStrategies.recommendFor(mood: moodToString(mood), trigger: trigger != nil ? moodToString(trigger!) : nil)
        }
        
        // Convert Mood to EngineMood
        let engineMood = convertToEngineMood(mood)
        
        // Use AI to generate strategies (this happens asynchronously, so we'll still return fallback strategies initially)
        aiService.generateCopingStrategies(for: engineMood, intensity: 3) { result in
            switch result {
            case .success(let strategies):
                print("Received AI coping strategies: \(strategies)")
                // In a real app, you would store these and update the UI
            case .failure(let error):
                print("Error generating coping strategies: \(error)")
            }
        }
        
        // Return fallback strategies for now
        return CopingStrategies.recommendFor(mood: moodToString(mood), trigger: trigger != nil ? moodToString(trigger!) : nil)
    }
    
    // Update the getJournalPromptForMood function to use the conversion
    func getJournalPromptForMood(_ mood: Mood, trigger: Mood? = nil) -> String {
        // If AI is not initialized, use rule-based fallback
        if !aiInitialized {
            return JournalPrompts.getPromptForMood(moodToString(mood), trigger: trigger != nil ? moodToString(trigger!) : nil)
        }
        
        // Convert Mood to EngineMood
        let engineMood = convertToEngineMood(mood)
        
        // Use AI to generate a prompt (this happens asynchronously, so we'll still return fallback prompt initially)
        aiService.generateJournalPrompt(for: engineMood) { result in
            switch result {
            case .success(let prompt):
                print("Received AI journal prompt: \(prompt)")
                // In a real app, you would store this and update the UI
            case .failure(let error):
                print("Error generating journal prompt: \(error)")
            }
        }
        
        // Return fallback prompt for now
        return JournalPrompts.getPromptForMood(moodToString(mood), trigger: trigger != nil ? moodToString(trigger!) : nil)
    }
    
    // MARK: - Pattern Analysis Methods
    
    private func analyzeAnxietyAfterRejection() -> EngineMoodRecommendation? {
        let entries = moodStore.moodEntries
        
        // Find anxiety-related entries connected to rejection
        let anxietyRejectionEntries = entries.filter { entry in
            entry.rejectionRelated && 
            (entry.mood == .anxious) &&
            entry.intensity >= 3
        }
        
        // Only proceed if we have enough entries to detect a pattern
        guard anxietyRejectionEntries.count >= insightThreshold else { return nil }
        
        // Calculate confidence based on consistency and recent entries
        let confidence = min(1.0, Double(anxietyRejectionEntries.count) / 10.0 + 0.3)
        
        // Create strategies based on the specific anxiety triggers
        var strategies: [EngineCopingStrategy] = []
        
        // Check if there's a social component to the anxiety
        let socialAnxiety = anxietyRejectionEntries.contains { entry in
            entry.rejectionTrigger?.contains("social") == true ||
            entry.rejectionTrigger?.contains("friend") == true
        }
        
        if socialAnxiety {
            strategies.append(socialAnxietyStrategy)
        }
        
        // Add general anxiety strategies
        strategies.append(anxietyMindfulnessStrategy)
        strategies.append(anxietyCognitiveStrategy)
        
        // Resources
        let resources = [
            anxietyArticleResource,
            anxietyExerciseResource
        ]
        
        return EngineMoodRecommendation(
            title: "Managing Anxiety After Rejection",
            description: "I've noticed a pattern of anxiety after rejection experiences. Here are some evidence-based strategies that may help you regulate these feelings more effectively.",
            triggerPattern: "Anxiety following rejection experiences",
            strategies: strategies,
            resources: resources,
            confidenceLevel: confidence
        )
    }
    
    private func analyzePersistentSadness() -> EngineMoodRecommendation? {
        let entries = moodStore.moodEntries
        let recentEntries = entries.prefix(20) // Look at the last 20 entries
        
        // Find sadness-related entries
        let sadnessRejectionEntries = entries.filter { entry in
            entry.rejectionRelated && 
            (entry.mood == .sad) &&
            entry.intensity >= 3
        }
        
        // Only proceed if sadness appears frequently
        guard sadnessRejectionEntries.count >= insightThreshold else { return nil }
        
        // Calculate what percentage of recent entries involve sadness
        let sadnessRatio = Double(sadnessRejectionEntries.count) / Double(min(20, entries.count))
        
        // Only proceed if sadness is a significant portion of recent moods
        guard sadnessRatio >= 0.35 else { return nil }
        
        // Calculate confidence based on consistency and intensity
        let confidence = min(1.0, sadnessRatio + 0.2)
        
        // Create strategies
        let strategies = [
            pleasureActivitiesStrategy,
            sadnessCognitiveStrategy,
            selfCompassionStrategy
        ]
        
        // Resources
        let resources = [
            sadnessArticleResource,
            sadnessBookResource
        ]
        
        return EngineMoodRecommendation(
            title: "Navigating Periods of Sadness",
            description: "I've noticed recurring feelings of sadness in your recent entries. Here are some strategies that research suggests can help lift your mood gradually.",
            triggerPattern: "Persistent feelings of sadness or discouragement",
            strategies: strategies,
            resources: resources,
            confidenceLevel: confidence
        )
    }
    
    private func analyzeSocialRejectionSensitivity() -> EngineMoodRecommendation? {
        let entries = moodStore.moodEntries
        
        // Find social rejection entries with high emotional impact
        let socialRejectionEntries = entries.filter { entry in
            entry.rejectionRelated &&
            entry.intensity >= 4 &&
            (entry.rejectionTrigger?.contains("social") == true ||
             entry.rejectionTrigger?.contains("friend") == true ||
             entry.rejectionTrigger?.contains("group") == true ||
             entry.rejectionTrigger?.contains("media") == true)
        }
        
        // Only proceed if we detect a pattern
        guard socialRejectionEntries.count >= insightThreshold else { return nil }
        
        // Calculate confidence
        let confidence = min(1.0, Double(socialRejectionEntries.count) / 8.0 + 0.25)
        
        // Create strategies
        let strategies = [
            socialRejectionCognitiveStrategy,
            socialConnectionStrategy,
            assertivenessTrainingStrategy
        ]
        
        // Resources
        let resources = [
            socialSkillsArticleResource,
            rejectionSensitivityAppResource
        ]
        
        return EngineMoodRecommendation(
            title: "Building Social Resilience",
            description: "I've noticed that social rejection experiences particularly affect you. These strategies can help build resilience against social rejection and strengthen your support network.",
            triggerPattern: "High sensitivity to social rejection experiences",
            strategies: strategies,
            resources: resources,
            confidenceLevel: confidence
        )
    }
    
    private func analyzeProfessionalRejectionPattern() -> EngineMoodRecommendation? {
        let entries = moodStore.moodEntries
        
        // Find professional rejection entries
        let professionalRejectionEntries = entries.filter { entry in
            entry.rejectionRelated &&
            (entry.rejectionTrigger?.contains("professional") == true ||
             entry.rejectionTrigger?.contains("job") == true ||
             entry.rejectionTrigger?.contains("work") == true ||
             entry.rejectionTrigger?.contains("career") == true)
        }
        
        // Only proceed if we detect a pattern
        guard professionalRejectionEntries.count >= insightThreshold else { return nil }
        
        // Calculate confidence
        let confidence = min(1.0, Double(professionalRejectionEntries.count) / 8.0 + 0.3)
        
        // Create strategies
        let strategies = [
            professionalResilienceStrategy,
            growthMindsetStrategy,
            achievementsReviewStrategy
        ]
        
        // Resources
        let resources = [
            careerResilienceArticleResource,
            professionalRejectionBookResource
        ]
        
        return EngineMoodRecommendation(
            title: "Professional Resilience Development",
            description: "I've noticed that professional rejection experiences impact you significantly. These strategies can help reframe professional setbacks as growth opportunities.",
            triggerPattern: "Emotional responses to professional rejection",
            strategies: strategies,
            resources: resources,
            confidenceLevel: confidence
        )
    }
    
    // MARK: - Feedback Mechanism
    
    func markRecommendationAsHelpful(_ recommendation: EngineMoodRecommendation) {
        // In a full implementation, this would update a user profile or learning model
        // to improve future recommendations
        print("Recommendation marked as helpful: \(recommendation.title)")
    }
    
    func markRecommendationAsUnhelpful(_ recommendation: EngineMoodRecommendation) {
        // In a full implementation, this would adjust the recommendation algorithm
        print("Recommendation marked as unhelpful: \(recommendation.title)")
    }
    
    // MARK: - Adaptive Coping Recommendations
    
    /// Sends personalized coping recommendations based on detected patterns
    func sendAdaptiveCopingRecommendations() {
        // Check if we have enough data to make meaningful recommendations
        guard moodStore.moodEntries.count >= insightThreshold else { return }
        
        // Analyze recent patterns in user mood data
        let recentEntries = moodStore.moodEntries.prefix(30) // Focus on last 30 entries
        var detectedPatterns: [(trigger: String, mood: String, frequency: Int)] = []
        
        // Pattern detection logic
        // 1. Check for frequent self-doubt
        let selfDoubtEntries = recentEntries.filter { entry in
            entry.notes.lowercased().contains("doubt") ||
            entry.notes.lowercased().contains("not good enough") ||
            entry.notes.lowercased().contains("inadequate") ||
            entry.notes.lowercased().contains("unworthy") ||
            entry.notes.lowercased().contains("imposter")
        }
        
        if selfDoubtEntries.count >= 3 {
            detectedPatterns.append((trigger: "self-doubt", mood: "anxious", frequency: selfDoubtEntries.count))
        }
        
        // 2. Check for loneliness
        let lonelinessEntries = recentEntries.filter { entry in
            entry.notes.lowercased().contains("lonely") ||
            entry.notes.lowercased().contains("alone") ||
            entry.notes.lowercased().contains("isolated") ||
            entry.notes.lowercased().contains("disconnected")
        }
        
        if lonelinessEntries.count >= 3 {
            detectedPatterns.append((trigger: "loneliness", mood: "sad", frequency: lonelinessEntries.count))
        }
        
        // 3. Check for job/professional rejection patterns
        let professionalRejectionEntries = recentEntries.filter { entry in
            entry.rejectionRelated &&
            (entry.rejectionTrigger?.contains("job") == true ||
             entry.rejectionTrigger?.contains("work") == true ||
             entry.rejectionTrigger?.contains("career") == true ||
             entry.rejectionTrigger?.contains("interview") == true)
        }
        
        if professionalRejectionEntries.count >= 3 {
            detectedPatterns.append((trigger: "job-rejection", mood: "discouraged", frequency: professionalRejectionEntries.count))
        }
        
        // Send personalized notifications for detected patterns
        for pattern in detectedPatterns {
            switch pattern.trigger {
            case "self-doubt":
                notificationManager.sendRecommendationNotification(
                    title: "Feeling unsure of yourself?",
                    body: "Try a quick 'Self-Compassion Break' or review your 'Achievements Quick-List'."
                )
                
            case "loneliness":
                notificationManager.sendRecommendationNotification(
                    title: "Feeling disconnected?",
                    body: "Consider a 'Connection Quick-Chat' or try a 'Solo Enjoyment Activity' from your toolbox."
                )
                
            case "job-rejection":
                notificationManager.sendRecommendationNotification(
                    title: "Processing job search feedback?",
                    body: "Review your 'Professional Strengths' list or try the 'Growth Mindset Reflection' exercise."
                )
                
            default:
                break
            }
        }
        
        // Schedule the next pattern check in 24 hours
        // In a real app, this would be more sophisticated (e.g., using background tasks)
        DispatchQueue.main.asyncAfter(deadline: .now() + 86400) { [weak self] in
            self?.sendAdaptiveCopingRecommendations()
        }
    }
    
    /// Tracks and follows up on coping strategies to reinforce helpful behaviors
    func scheduleFollowUpForCopingStrategy(strategy: String, appliedAt: Date) {
        // Store the strategy usage in the user's data
        // (In a real implementation, this would be saved to persistent storage)
        let strategyUsage = (strategy: strategy, appliedAt: appliedAt)
        
        // Schedule a follow-up notification for 24 hours later
        let followUpTime = Calendar.current.date(byAdding: .hour, value: 24, to: appliedAt) ?? Date()
        
        // Create a user notification for the follow-up
        let content = UNMutableNotificationContent()
        content.title = "How did it go?"
        content.body = "Yesterday you tried '\(strategy)'. Did it help improve your mood?"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "COPING_FOLLOWUP_CATEGORY"
        
        // Add custom data to identify which strategy this is following up on
        content.userInfo = ["strategy": strategy]
        
        // Create a calendar trigger for the specified follow-up time
        let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: followUpTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        
        // Create the request
        let request = UNNotificationRequest(
            identifier: "coping-followup-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        // Schedule the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling follow-up notification: \(error)")
            } else {
                print("Follow-up scheduled for strategy: \(strategy)")
            }
        }
    }
    
    /// Processes the response to a coping strategy follow-up
    func processCopingStrategyFollowUp(strategy: String, wasHelpful: Bool) {
        // In a full implementation, this would update a learning model to
        // refine future recommendations based on what works for this user
        
        if wasHelpful {
            // Log this strategy as effective for this user
            print("Strategy '\(strategy)' was helpful - recording for future recommendations")
            
            // Send a reinforcement notification
            notificationManager.scheduleImmediateNotification(
                title: "Great progress!",
                body: "You've added an effective tool to your resilience toolkit. Keep using what works for you."
            )
        } else {
            // Log this strategy as less effective for this user
            print("Strategy '\(strategy)' was not helpful - adjusting future recommendations")
            
            // Offer alternative strategies
            let alternatives = CopingStrategies.recommendFor(mood: "neutral")
            
            if !alternatives.isEmpty {
                let alternativeStrategy = alternatives.first!
                notificationManager.sendRecommendationNotification(
                    title: "Let's try something different",
                    body: "Here's another approach that might work better: \(alternativeStrategy)"
                )
            }
        }
    }
    
    // MARK: - Predefined Strategies
    
    // Anxiety strategies
    private var anxietyMindfulnessStrategy: EngineCopingStrategy {
        EngineCopingStrategy(
            title: "Grounding Technique",
            description: "A simple mindfulness exercise to reduce anxiety by connecting with your senses.",
            timeToComplete: "5 minutes",
            steps: [
                "Find a comfortable position and take a slow, deep breath.",
                "Notice 5 things you can see around you.",
                "Acknowledge 4 things you can touch or feel.",
                "Listen for 3 sounds in your environment.",
                "Identify 2 things you can smell.",
                "Notice 1 thing you can taste.",
                "Repeat the cycle if needed, focusing on how your anxiety level changes."
            ],
            category: .mindfulness
        )
    }
    
    private var anxietyCognitiveStrategy: EngineCopingStrategy {
        EngineCopingStrategy(
            title: "Thought Challenging",
            description: "Identify and challenge anxiety-producing thoughts related to rejection.",
            timeToComplete: "10-15 minutes",
            steps: [
                "Write down your anxious thought (e.g., 'Everyone will reject me now').",
                "Rate how strongly you believe it (0-100%).",
                "Identify the evidence that supports this thought.",
                "List evidence that contradicts or doesn't support this thought.",
                "Generate a more balanced alternative thought.",
                "Rate your belief in the alternative thought and notice any change in anxiety."
            ],
            category: .cognitive
        )
    }
    
    private var socialAnxietyStrategy: EngineCopingStrategy {
        EngineCopingStrategy(
            title: "Social Confidence Builder",
            description: "Gradually build confidence in social situations after rejection.",
            timeToComplete: "Ongoing practice",
            steps: [
                "Create a 'social ladder' with steps from least to most anxiety-provoking.",
                "Start with a low-anxiety social interaction (e.g., texting a supportive friend).",
                "Practice one small social step daily, using deep breathing before each attempt.",
                "Reward yourself for each step taken, regardless of outcome.",
                "Gradually work up to more challenging interactions.",
                "Keep a log of successful interactions to review when anxiety rises."
            ],
            category: .social
        )
    }
    
    // Sadness strategies
    private var pleasureActivitiesStrategy: EngineCopingStrategy {
        EngineCopingStrategy(
            title: "Pleasure Activities Scheduling",
            description: "Deliberately schedule activities that bring joy or a sense of accomplishment.",
            timeToComplete: "15 minutes planning, then ongoing",
            steps: [
                "Make a list of activities that have brought you joy in the past.",
                "Include simple activities that take 5-10 minutes and longer ones.",
                "Schedule at least one small pleasant activity daily.",
                "Schedule one larger activity weekly.",
                "After completing each activity, note your mood before and after.",
                "Gradually increase activities as your energy allows."
            ],
            category: .cognitive
        )
    }
    
    private var sadnessCognitiveStrategy: EngineCopingStrategy {
        EngineCopingStrategy(
            title: "Negative Thought Disruption",
            description: "Techniques to interrupt persistent negative thought patterns.",
            timeToComplete: "5-10 minutes",
            steps: [
                "When you notice a spiral of negative thoughts, say 'stop' firmly to yourself.",
                "Take a deep breath and physically change your position.",
                "Engage your senses with something immediate (hold an ice cube, smell an essential oil).",
                "Choose a simple mental activity (count backward from 100 by 7s, name animals alphabetically).",
                "Once disrupted, redirect to a neutral or positive activity."
            ],
            category: .cognitive
        )
    }
    
    private var selfCompassionStrategy: EngineCopingStrategy {
        EngineCopingStrategy(
            title: "Self-Compassion Practice",
            description: "Learn to treat yourself with the kindness you would offer a good friend.",
            timeToComplete: "10 minutes",
            steps: [
                "Place your hand over your heart and feel its warmth.",
                "Acknowledge your sadness with 'This is a moment of suffering' or 'This is hard right now'.",
                "Remind yourself 'Suffering is part of life' and 'I'm not alone in feeling this way'.",
                "Ask 'What do I need right now?' and 'How can I comfort myself?'",
                "Offer yourself a kind phrase such as 'May I be kind to myself' or 'I'm doing the best I can'."
            ],
            category: .mindfulness
        )
    }
    
    // Social rejection strategies
    private var socialRejectionCognitiveStrategy: EngineCopingStrategy {
        EngineCopingStrategy(
            title: "Rejection Reframing",
            description: "Change how you think about social rejection to reduce its emotional impact.",
            timeToComplete: "15 minutes",
            steps: [
                "Describe the rejection experience objectively, without interpretation.",
                "Identify assumptions you made about why the rejection happened.",
                "List at least three alternative explanations that don't involve your worth as a person.",
                "Consider what advice you'd give a friend experiencing this rejection.",
                "Write down what you can learn from this experience.",
                "Create a short self-affirmation to remember your value beyond this incident."
            ],
            category: .cognitive
        )
    }
    
    private var socialConnectionStrategy: EngineCopingStrategy {
        EngineCopingStrategy(
            title: "Connection Inventory",
            description: "Identify and strengthen positive social connections in your life.",
            timeToComplete: "20 minutes initial, then ongoing",
            steps: [
                "Make a list of people who have been supportive or made you feel valued.",
                "Note what type of support each person provides (emotional, practical, etc.).",
                "Identify one small way to nurture each key relationship this week.",
                "Schedule specific times to connect with supportive people.",
                "Practice asking for what you need from these supportive relationships.",
                "Regularly update your inventory as relationships evolve."
            ],
            category: .social
        )
    }
    
    private var assertivenessTrainingStrategy: EngineCopingStrategy {
        EngineCopingStrategy(
            title: "Assertiveness Training",
            description: "Build skills to express your needs and boundaries respectfully.",
            timeToComplete: "15-20 minutes practice sessions",
            steps: [
                "Identify situations where you'd like to be more assertive.",
                "Use the format: 'I feel [emotion] when [situation]. I need [specific request].'",
                "Practice your assertive statements aloud or in writing.",
                "Role-play difficult conversations with a trusted person or in the mirror.",
                "Start with lower-pressure situations and work up to more challenging ones.",
                "Celebrate your assertiveness efforts regardless of outcome."
            ],
            category: .social
        )
    }
    
    // Professional rejection strategies
    private var professionalResilienceStrategy: EngineCopingStrategy {
        EngineCopingStrategy(
            title: "Professional Rejection Protocol",
            description: "A structured approach to process and learn from professional setbacks.",
            timeToComplete: "30 minutes",
            steps: [
                "Allow yourself 24 hours to feel disappointment fully.",
                "Write down what you learned from the experience.",
                "Identify what was in your control and what wasn't.",
                "Request specific feedback when possible.",
                "Update your skills or approach based on feedback.",
                "Set a concrete next step or new goal.",
                "Create a 'resilience file' of past successes to review after rejections."
            ],
            category: .cognitive
        )
    }
    
    private var growthMindsetStrategy: EngineCopingStrategy {
        EngineCopingStrategy(
            title: "Growth Mindset Development",
            description: "Cultivate a perspective that sees challenges and rejection as opportunities to grow.",
            timeToComplete: "10 minutes daily practice",
            steps: [
                "Catch yourself using fixed mindset language ('I'm not good at this').",
                "Replace with growth mindset alternatives ('I'm still learning this').",
                "Add 'yet' to end of limiting statements ('I haven't mastered this skill yet').",
                "Keep a daily log of challenges and what you learned from them.",
                "Celebrate effort and process rather than just outcomes.",
                "Create a personal mantra that reinforces growth through challenges."
            ],
            category: .cognitive
        )
    }
    
    private var achievementsReviewStrategy: EngineCopingStrategy {
        EngineCopingStrategy(
            title: "Achievements Inventory",
            description: "Create a comprehensive record of your professional accomplishments to build confidence.",
            timeToComplete: "45 minutes initial, then ongoing updates",
            steps: [
                "List all professional achievements, large and small, from your entire career.",
                "For each achievement, note the skills and strengths you demonstrated.",
                "Collect positive feedback you've received in one document.",
                "Create a 'wins' document and update it weekly with even small successes.",
                "Schedule a monthly review of your achievements inventory.",
                "Read through your inventory before professional challenges like interviews."
            ],
            category: .cognitive
        )
    }
    
    // MARK: - Predefined Resources
    
    // Anxiety resources
    private var anxietyArticleResource: EngineRecommendedResource {
        EngineRecommendedResource(
            title: "The Science Behind Anxiety After Rejection",
            type: EngineAppResourceType.article,
            description: "Research-based explanations of how the brain processes rejection and why it can trigger anxiety.",
            url: URL(string: "https://example.com/anxiety-article"),
            imageURL: nil,
            source: "Resilient Mind Blog",
            isNew: true
        )
    }
    
    private var anxietyExerciseResource: EngineRecommendedResource {
        EngineRecommendedResource(
            title: "Progressive Muscle Relaxation Audio Guide",
            type: EngineAppResourceType.audio,
            description: "A 15-minute guided audio exercise to release physical tension associated with anxiety.",
            url: URL(string: "https://example.com/relaxation-audio"),
            imageURL: nil,
            source: "Calm Mind App",
            isNew: false
        )
    }
    
    // Sadness resources
    private var sadnessArticleResource: EngineRecommendedResource {
        EngineRecommendedResource(
            title: "How to Apply Behavioral Activation for Depression",
            type: EngineAppResourceType.article,
            description: "Practical guide to the clinically-proven technique of behavioral activation to combat low mood.",
            url: URL(string: "https://example.com/behavior-activation"),
            imageURL: nil,
            source: "Psychology Today",
            isNew: false
        )
    }
    
    private var sadnessBookResource: EngineRecommendedResource {
        EngineRecommendedResource(
            title: "The Upward Spiral",
            type: EngineAppResourceType.book,
            description: "Using neuroscience to reverse the course of depression, one small change at a time.",
            url: URL(string: "https://example.com/upward-spiral-book"),
            imageURL: nil,
            source: "Alex Korb, PhD",
            isNew: true
        )
    }
    
    // Social rejection resources
    private var socialSkillsArticleResource: EngineRecommendedResource {
        EngineRecommendedResource(
            title: "Building Social Resilience After Rejection",
            type: EngineAppResourceType.article,
            description: "Practical techniques to bounce back from social rejection and strengthen your social connections.",
            url: URL(string: "https://example.com/social-resilience"),
            imageURL: nil,
            source: "Resilient Mind Blog",
            isNew: false
        )
    }
    
    private var rejectionSensitivityAppResource: EngineRecommendedResource {
        EngineRecommendedResource(
            title: "MindDoc: Mood Tracker",
            type: EngineAppResourceType.app,
            description: "An app that helps track mood patterns and provides evidence-based interventions.",
            url: URL(string: "https://example.com/minddoc-app"),
            imageURL: nil,
            source: "MindDoc Health",
            isNew: true
        )
    }
    
    // Professional rejection resources
    private var careerResilienceArticleResource: EngineRecommendedResource {
        EngineRecommendedResource(
            title: "The Professional's Guide to Rejection Recovery",
            type: EngineAppResourceType.article,
            description: "Strategies used by successful professionals to overcome rejection in their careers.",
            url: URL(string: "https://example.com/professional-rejection"),
            imageURL: nil,
            source: "Harvard Business Review",
            isNew: false
        )
    }
    
    private var professionalRejectionBookResource: EngineRecommendedResource {
        EngineRecommendedResource(
            title: "Rejection Proof",
            type: EngineAppResourceType.book,
            description: "How to turn rejection into the greatest professional opportunity.",
            url: URL(string: "https://example.com/rejection-proof-book"),
            imageURL: nil,
            source: "Jia Jiang",
            isNew: true
        )
    }
    
    // MARK: - Demo Data Generation
    
    func generateDemoData() {
        // Create sample mood entries for demonstration
        let moodOptions = ["Joyful", "Content", "Neutral", "Sad", "Frustrated", "Stressed"]
        let triggerOptions = [
            "Social media rejection", 
            "Friend ignored me", 
            "Job application rejected", 
            "Project feedback negative", 
            "Family criticism", 
            "Academic application rejected"
        ]
        let strategyOptions = [
            "Deep breathing", 
            "Physical activity", 
            "Talking to a friend", 
            "Meditation", 
            "Problem solving"
        ]
        
        // Create entries over the past 30 days
        let calendar = Calendar.current
        let today = Date()
        
        for dayOffset in 0..<30 {
            // Skip some days randomly to create a realistic pattern
            if Int.random(in: 0...10) < 3 {
                continue
            }
            
            // Create 1-3 entries per day
            let entriesCount = Int.random(in: 1...3)
            
            for entryNum in 0..<entriesCount {
                // Calculate date with random time
                guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
                let hourOffset = entryNum * 5 + Int.random(in: 0...4) // Space entries throughout the day
                guard let entryDate = calendar.date(byAdding: .hour, value: -hourOffset, to: date) else { continue }
                
                // Randomly select a mood
                let mood = moodOptions[Int.random(in: 0..<moodOptions.count)]
                
                // Make negative moods more likely to be rejection-related
                let isRejectionRelated = (mood == "Sad" || mood == "Frustrated" || mood == "Stressed") ? 
                    Int.random(in: 0...10) < 7 : // 70% chance for negative moods
                    Int.random(in: 0...10) < 2   // 20% chance for positive moods
                
                // Create the entry
                var rejectionTrigger: String? = nil
                var copingStrategy: String? = nil
                var note: String? = nil
                
                if isRejectionRelated {
                    rejectionTrigger = triggerOptions[Int.random(in: 0..<triggerOptions.count)]
                    copingStrategy = strategyOptions[Int.random(in: 0..<strategyOptions.count)]
                    note = "I felt \(mood.lowercased()) after experiencing \(rejectionTrigger!)"
                }
                
                // Create the entry with random intensity between 1-5
                let intensity = Int.random(in: 1...5)
                
                // Use the MoodStore to save the entry
                self.moodStore.saveMoodEntry(
                    mood: mood,
                    intensity: intensity,
                    note: note ?? "",
                    rejectionRelated: isRejectionRelated,
                    rejectionTrigger: rejectionTrigger,
                    copingStrategy: copingStrategy
                )
            }
        }
        
        // Generate recommendations based on the sample data
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.analyzePatterns()
        }
    }
}

// MARK: - AI Response Models

struct AIRecommendationsResponse: Codable {
    let recommendations: [AIRecommendation]
}

struct AIRecommendation: Codable {
    let title: String
    let description: String
    let trigger_pattern: String
    let confidence_level: Double
    let strategies: [AIStrategy]
    let resources: [AIResource]
}

struct AIStrategy: Codable {
    let title: String
    let description: String
    let category: String
    let time_to_complete: String
    let steps: [String]
}

struct AIResource: Codable {
    let title: String
    let type: String
    let description: String
    let url: String?
    let image_url: String?
}

// Add a conversion function to map to the global CopingStrategyCategory
func convertToGlobalCategory(_ category: MoodEngineCopingStrategyCategory) -> AnalysisCopingStrategyCategory {
    switch category {
    case .mindfulness: return AnalysisCopingStrategyCategory.mindfulness
    case .cognitive: return AnalysisCopingStrategyCategory.cognitive
    case .physical: return AnalysisCopingStrategyCategory.physical
    case .social: return AnalysisCopingStrategyCategory.social
    case .creative: return AnalysisCopingStrategyCategory.creative
    case .selfCare: return AnalysisCopingStrategyCategory.selfCare
    }
}

// Also add function to convert from the global category
func convertFromGlobalCategory(_ category: AnalysisCopingStrategyCategory) -> MoodEngineCopingStrategyCategory {
    switch category {
    case .mindfulness: return .mindfulness
    case .cognitive: return .cognitive
    case .physical: return .physical
    case .social: return .social
    case .creative: return .creative
    case .selfCare: return .selfCare
    }
}

// Helper method to convert insights to data
extension MoodAnalysisEngine {
    // Add a function to convert EngineMoodInsight to MoodInsight
    private func convertToMoodInsight(_ engineInsight: EngineMoodInsight) -> MoodInsight {
        return MoodInsight(
            title: engineInsight.title,
            description: engineInsight.description
        )
    }
    
    // Update convertInsightsToData to handle EngineMoodInsight
    private func convertInsightsToData(_ insights: [EngineMoodInsight]) -> Data? {
        let convertedInsights = insights.map { convertToMoodInsight($0) }
        return try? JSONEncoder().encode(convertedInsights)
    }
    
    // Helper method to convert between Mood and String for the recommendFor methods
    private func moodToString(_ mood: Mood) -> String {
        return mood.rawValue
    }
}

// Define the missing AnalysisCopingStrategyCategory enum
enum AnalysisCopingStrategyCategory: String, CaseIterable {
    case mindfulness = "Mindfulness"
    case cognitive = "Cognitive"
    case physical = "Physical"
    case social = "Social"
    case creative = "Creative"
    case selfCare = "Self-Care"
}

// Define the missing MoodInsight struct
struct MoodInsight: Identifiable, Encodable {
    var id = UUID()
    var title: String
    var description: String
    var date: Date = Date()
    var moodPattern: String?
    var confidence: Double = 0.7
}

// Add extension for string-based convenience methods
extension MoodAnalysisEngine {
    // Convenience method that accepts string parameters
    func getCopingStrategiesForMood(mood: String, intensity: Int = 5, trigger: String? = nil) -> [String]? {
        // Convert string mood to Mood enum if possible
        guard let moodEnum = Mood.allCases.first(where: { moodCase in 
            moodCase.rawValue.lowercased() == mood.lowercased() 
        }) else {
            // Fallback strategies for unknown moods
            return ["Take deep breaths", "Go for a walk", "Practice mindfulness"]
        }
        
        // Convert trigger string to Mood enum if provided
        let triggerEnum: Mood? = trigger.flatMap { triggerString in
            Mood.allCases.first(where: { moodCase in 
                moodCase.rawValue.lowercased() == triggerString.lowercased() 
            }) 
        }
        
        // Get strategies using the Mood enum version
        return getCopingStrategiesForMood(moodEnum, trigger: triggerEnum)
    }
    
    // Original method using Mood enum
    func getCopingStrategiesForMood(_ mood: Mood, trigger: Mood? = nil) -> [String]? {
        // Fallback implementation - in a real app, this would use AI or a more sophisticated algorithm
        switch mood {
        case .joyful, .content, .happy, .calm:
            return ["Savor the moment", "Journal about your feelings", "Share your joy with others"]
        case .neutral:
            return ["Mindful breathing exercise", "Check in with your body", "Set an intention for the day"]
        case .sad:
            return ["Talk to someone you trust", "Self-compassion exercise", "Gentle physical activity"]
        case .frustrated, .angry:
            return ["Take a time-out", "Deep breathing", "Physical exercise to release tension"]
        case .stressed, .anxious:
            return ["Progressive muscle relaxation", "5-4-3-2-1 grounding exercise", "Limit caffeine"]
        case .rejected:
            return ["Self-validation exercise", "Remind yourself of your worth", "Connect with supportive people"]
        }
    }
    
    // Convenience method for journal prompts
    func getJournalPromptForMood(mood: String, trigger: String? = nil) -> String? {
        // Convert string mood to Mood enum if possible
        guard let moodEnum = Mood.allCases.first(where: { moodCase in
            moodCase.rawValue.lowercased() == mood.lowercased()
        }) else {
            // Fallback prompt for unknown moods
            return "How are you feeling right now? What led to this feeling?"
        }
        
        // Convert trigger string to Mood enum if provided
        let triggerEnum: Mood? = trigger.flatMap { triggerString in
            Mood.allCases.first(where: { moodCase in 
                moodCase.rawValue.lowercased() == triggerString.lowercased() 
            })
        }
        
        // Get prompt using the Mood enum version
        return getJournalPromptForMood(moodEnum, trigger: triggerEnum)
    }
} 
