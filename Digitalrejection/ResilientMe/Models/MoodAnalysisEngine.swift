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

// MARK: - Recommendation Models

/// Structured models for personalized feedback and recommendations
struct MoodRecommendation: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let triggerPattern: String
    let strategies: [CopingStrategy]
    let resources: [RecommendedResource]
    let confidenceLevel: Double // 0.0-1.0 representing AI confidence
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MoodRecommendation, rhs: MoodRecommendation) -> Bool {
        return lhs.id == rhs.id
    }
}

struct CopingStrategy: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let timeToComplete: String // e.g. "5 minutes" or "15-20 minutes"
    let steps: [String]
    let category: CopingStrategyCategory
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: CopingStrategy, rhs: CopingStrategy) -> Bool {
        return lhs.id == rhs.id
    }
}

struct RecommendedResource: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let type: AppResourceType
    let description: String
    let url: URL?
    let imageURL: URL?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: RecommendedResource, rhs: RecommendedResource) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Mood Analysis Engine

class MoodAnalysisEngine: ObservableObject {
    @Published var currentRecommendations: [MoodRecommendation] = []
    @Published var hasNewRecommendations: Bool = false
    @Published var isAnalyzing: Bool = false
    @Published var aiInitialized: Bool = false
    
    private let moodStore: MoodStore
    private let insightThreshold = 3 // Minimum entries needed for pattern recognition
    private var cancellables = Set<AnyCancellable>()
    private let notificationManager = NotificationManager()
    private let aiService = PuterAIService()
    
    // Initialize with a MoodStore instance
    init(moodStore: MoodStore) {
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
    }
    
    // Main analysis method that identifies patterns and generates recommendations
    func analyzePatterns() {
        // Check if we have enough data
        guard moodStore.moodEntries.count >= insightThreshold else {
            return
        }
        
        // If AI is not initialized or we're already analyzing, use rule-based analysis
        if !aiInitialized || isAnalyzing {
            analyzePatternsFallback()
            return
        }
        
        isAnalyzing = true
        
        // Use AI service to analyze patterns
        aiService.analyzeMoodPatterns(moodData: moodStore.moodEntries) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isAnalyzing = false
                
                switch result {
                case .success(let aiResponse):
                    do {
                        // Parse the AI response
                        if let jsonData = aiResponse.data(using: .utf8) {
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
                    print("AI analysis error: \(error)")
                    self.analyzePatternsFallback()
                }
            }
        }
    }
    
    // Fallback to rule-based analysis when AI is unavailable
    private func analyzePatternsFallback() {
        // Start with empty recommendations
        var newRecommendations: [MoodRecommendation] = []
        
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
    func convertAIRecommendation(_ aiRecommendation: AIRecommendation) -> MoodRecommendation {
        // Convert strategies
        let strategies = aiRecommendation.strategies.map { strategyData -> CopingStrategy in
            let category: CopingStrategyCategory
            switch strategyData.category.lowercased() {
            case "mindfulness": category = .mindfulness
            case "cognitive": category = .cognitive
            case "physical": category = .physical
            case "social": category = .social
            case "creative": category = .creative
            default: category = .selfCare
            }
            
            return CopingStrategy(
                title: strategyData.title,
                description: strategyData.description,
                timeToComplete: strategyData.time_to_complete,
                steps: strategyData.steps,
                category: category
            )
        }
        
        // Convert resources
        let resources = aiRecommendation.resources.map { resourceData -> RecommendedResource in
            let type: AppResourceType
            switch resourceData.type.lowercased() {
            case "article": type = .article
            case "video": type = .video
            case "audio": type = .audio
            case "app": type = .app
            case "book": type = .book
            default: type = .exercise
            }
            
            return RecommendedResource(
                title: resourceData.title,
                type: type,
                description: resourceData.description,
                url: resourceData.url != nil ? URL(string: resourceData.url!) : nil,
                imageURL: resourceData.image_url != nil ? URL(string: resourceData.image_url!) : nil
            )
        }
        
        return MoodRecommendation(
            title: aiRecommendation.title,
            description: aiRecommendation.description,
            triggerPattern: aiRecommendation.trigger_pattern,
            strategies: strategies,
            resources: resources,
            confidenceLevel: aiRecommendation.confidence_level
        )
    }
    
    // Helper to map category strings to our enum
    private func mapCategoryString(_ category: String) -> CopingStrategyCategory? {
        let lowercased = category.lowercased()
        if lowercased.contains("mind") {
            return .mindfulness
        } else if lowercased.contains("cognit") || lowercased.contains("think") {
            return .cognitive
        } else if lowercased.contains("physical") || lowercased.contains("exercis") {
            return .physical
        } else if lowercased.contains("social") || lowercased.contains("connect") {
            return .social
        } else if lowercased.contains("creat") || lowercased.contains("art") {
            return .creative
        } else if lowercased.contains("self") || lowercased.contains("care") {
            return .selfCare
        }
        return nil
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
    
    // AI-powered method to get coping strategies for a specific mood and trigger
    func getCopingStrategiesForMood(_ mood: String, trigger: String?) -> [String] {
        // If AI is not initialized, use rule-based fallback
        if !aiInitialized {
            return CopingStrategies.recommendFor(mood: mood, trigger: trigger)
        }
        
        // Use AI to generate strategies (this happens asynchronously, so we'll still return fallback strategies initially)
        aiService.generateCopingStrategies(mood: mood, trigger: trigger) { result in
            switch result {
            case .success(let strategies):
                print("Received AI coping strategies: \(strategies)")
                // In a real app, you would store these and update the UI
            case .failure(let error):
                print("Error generating coping strategies: \(error)")
            }
        }
        
        // Return fallback strategies for now
        return CopingStrategies.recommendFor(mood: mood, trigger: trigger)
    }
    
    // AI-powered method to get journal prompts for a specific mood and trigger
    func getJournalPromptForMood(_ mood: String, trigger: String?) -> String {
        // If AI is not initialized, use rule-based fallback
        if !aiInitialized {
            return JournalPrompts.forMood(mood, trigger: trigger)
        }
        
        // Use AI to generate a prompt (this happens asynchronously, so we'll still return fallback prompt initially)
        aiService.generateJournalPrompt(mood: mood, trigger: trigger) { result in
            switch result {
            case .success(let prompt):
                print("Received AI journal prompt: \(prompt)")
                // In a real app, you would store this and update the UI
            case .failure(let error):
                print("Error generating journal prompt: \(error)")
            }
        }
        
        // Return fallback prompt for now
        return JournalPrompts.forMood(mood, trigger: trigger)
    }
    
    // MARK: - Pattern Analysis Methods
    
    private func analyzeAnxietyAfterRejection() -> MoodRecommendation? {
        let entries = moodStore.moodEntries
        
        // Find anxiety-related entries connected to rejection
        let anxietyRejectionEntries = entries.filter { entry in
            entry.rejectionRelated && 
            (entry.mood == "Anxious" || entry.mood == "Overwhelmed") &&
            entry.intensity >= 3
        }
        
        // Only proceed if we have enough entries to detect a pattern
        guard anxietyRejectionEntries.count >= insightThreshold else { return nil }
        
        // Calculate confidence based on consistency and recent entries
        let confidence = min(1.0, Double(anxietyRejectionEntries.count) / 10.0 + 0.3)
        
        // Create strategies based on the specific anxiety triggers
        var strategies: [CopingStrategy] = []
        
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
        
        return MoodRecommendation(
            title: "Managing Anxiety After Rejection",
            description: "I've noticed a pattern of anxiety after rejection experiences. Here are some evidence-based strategies that may help you regulate these feelings more effectively.",
            triggerPattern: "Anxiety following rejection experiences",
            strategies: strategies,
            resources: resources,
            confidenceLevel: confidence
        )
    }
    
    private func analyzePersistentSadness() -> MoodRecommendation? {
        let entries = moodStore.moodEntries
        let recentEntries = entries.prefix(20) // Look at the last 20 entries
        
        // Find sadness-related entries
        let sadnessEntries = recentEntries.filter { entry in
            (entry.mood == "Sad" || entry.mood == "Discouraged") &&
            entry.intensity >= 3
        }
        
        // Only proceed if sadness appears frequently
        guard sadnessEntries.count >= insightThreshold else { return nil }
        
        // Calculate what percentage of recent entries involve sadness
        let sadnessRatio = Double(sadnessEntries.count) / Double(min(20, entries.count))
        
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
        
        return MoodRecommendation(
            title: "Navigating Periods of Sadness",
            description: "I've noticed recurring feelings of sadness in your recent entries. Here are some strategies that research suggests can help lift your mood gradually.",
            triggerPattern: "Persistent feelings of sadness or discouragement",
            strategies: strategies,
            resources: resources,
            confidenceLevel: confidence
        )
    }
    
    private func analyzeSocialRejectionSensitivity() -> MoodRecommendation? {
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
        
        return MoodRecommendation(
            title: "Building Social Resilience",
            description: "I've noticed that social rejection experiences particularly affect you. These strategies can help build resilience against social rejection and strengthen your support network.",
            triggerPattern: "High sensitivity to social rejection experiences",
            strategies: strategies,
            resources: resources,
            confidenceLevel: confidence
        )
    }
    
    private func analyzeProfessionalRejectionPattern() -> MoodRecommendation? {
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
        
        return MoodRecommendation(
            title: "Professional Resilience Development",
            description: "I've noticed that professional rejection experiences impact you significantly. These strategies can help reframe professional setbacks as growth opportunities.",
            triggerPattern: "Emotional responses to professional rejection",
            strategies: strategies,
            resources: resources,
            confidenceLevel: confidence
        )
    }
    
    // MARK: - Feedback Mechanism
    
    func markRecommendationAsHelpful(_ recommendation: MoodRecommendation) {
        // In a full implementation, this would update a user profile or learning model
        // to improve future recommendations
        print("Recommendation marked as helpful: \(recommendation.title)")
    }
    
    func markRecommendationAsUnhelpful(_ recommendation: MoodRecommendation) {
        // In a full implementation, this would adjust the recommendation algorithm
        print("Recommendation marked as unhelpful: \(recommendation.title)")
    }
    
    // MARK: - Predefined Strategies
    
    // Anxiety strategies
    private var anxietyMindfulnessStrategy: CopingStrategy {
        CopingStrategy(
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
    
    private var anxietyCognitiveStrategy: CopingStrategy {
        CopingStrategy(
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
    
    private var socialAnxietyStrategy: CopingStrategy {
        CopingStrategy(
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
    private var pleasureActivitiesStrategy: CopingStrategy {
        CopingStrategy(
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
    
    private var sadnessCognitiveStrategy: CopingStrategy {
        CopingStrategy(
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
    
    private var selfCompassionStrategy: CopingStrategy {
        CopingStrategy(
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
    private var socialRejectionCognitiveStrategy: CopingStrategy {
        CopingStrategy(
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
    
    private var socialConnectionStrategy: CopingStrategy {
        CopingStrategy(
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
    
    private var assertivenessTrainingStrategy: CopingStrategy {
        CopingStrategy(
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
    private var professionalResilienceStrategy: CopingStrategy {
        CopingStrategy(
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
    
    private var growthMindsetStrategy: CopingStrategy {
        CopingStrategy(
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
    
    private var achievementsReviewStrategy: CopingStrategy {
        CopingStrategy(
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
    private var anxietyArticleResource: RecommendedResource {
        RecommendedResource(
            title: "The Science Behind Anxiety After Rejection",
            type: .article,
            description: "Learn how rejection triggers anxiety responses in the brain and research-backed techniques to manage these feelings.",
            url: URL(string: "https://www.psychologytoday.com/us/blog/the-science-behind-behavior/201807/why-even-good-relationships-cause-anxiety"),
            imageURL: nil
        )
    }
    
    private var anxietyExerciseResource: RecommendedResource {
        RecommendedResource(
            title: "Progressive Muscle Relaxation Audio Guide",
            type: .audio,
            description: "A guided 15-minute exercise to release physical tension associated with anxiety.",
            url: URL(string: "https://www.dartmouth.edu/~healthed/relax/downloads.html"),
            imageURL: nil
        )
    }
    
    // Sadness resources
    private var sadnessArticleResource: RecommendedResource {
        RecommendedResource(
            title: "How to Apply Behavioral Activation for Depression",
            type: .article,
            description: "Evidence-based techniques from behavioral activation therapy to combat persistent sadness.",
            url: URL(string: "https://www.verywellmind.com/increasing-the-effectiveness-of-behavioral-activation-2797597"),
            imageURL: nil
        )
    }
    
    private var sadnessBookResource: RecommendedResource {
        RecommendedResource(
            title: "The Upward Spiral",
            type: .book,
            description: "Using neuroscience to reverse the course of depression, one small change at a time.",
            url: URL(string: "https://www.goodreads.com/book/show/21413760-the-upward-spiral"),
            imageURL: nil
        )
    }
    
    // Social rejection resources
    private var socialSkillsArticleResource: RecommendedResource {
        RecommendedResource(
            title: "Building Social Resilience After Rejection",
            type: .article,
            description: "Practical techniques to maintain self-esteem and social confidence after experiencing rejection.",
            url: URL(string: "https://greatergood.berkeley.edu/article/item/how_to_be_resilient"),
            imageURL: nil
        )
    }
    
    private var rejectionSensitivityAppResource: RecommendedResource {
        RecommendedResource(
            title: "MindDoc: Mood Tracker",
            type: .app,
            description: "An app that helps track emotional responses to social situations and provides personalized insights.",
            url: URL(string: "https://apps.apple.com/us/app/minddoc-your-companion/id1052216403"),
            imageURL: nil
        )
    }
    
    // Professional rejection resources
    private var careerResilienceArticleResource: RecommendedResource {
        RecommendedResource(
            title: "The Professional's Guide to Rejection Recovery",
            type: .article,
            description: "A step-by-step guide to bouncing back stronger after career setbacks.",
            url: URL(string: "https://hbr.org/2020/10/dont-let-rejection-hold-you-back"),
            imageURL: nil
        )
    }
    
    private var professionalRejectionBookResource: RecommendedResource {
        RecommendedResource(
            title: "Rejection Proof",
            type: .book,
            description: "How I Beat Fear and Became Invincible Through 100 Days of Rejection.",
            url: URL(string: "https://www.goodreads.com/book/show/22747866-rejection-proof"),
            imageURL: nil
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
                    note: note,
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