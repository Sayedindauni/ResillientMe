import Foundation
import SwiftUI

// MARK: - Coping Strategy Library

/// Main structure representing a coping strategy with all details
struct CopingStrategyDetail: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let timeToComplete: String
    let steps: [String]
    let category: CopingStrategyCategory
    let moodTargets: [String]
    let intensity: StrategyIntensity
    let resources: [String]?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: CopingStrategyDetail, rhs: CopingStrategyDetail) -> Bool {
        return lhs.id == rhs.id
    }
}

/// Intensity level of a coping strategy
enum StrategyIntensity: String, CaseIterable {
    case quick = "Quick Relief"
    case moderate = "Moderate Practice"
    case intensive = "In-Depth Process"
    
    var timeEstimate: String {
        switch self {
        case .quick: return "2-5 minutes"
        case .moderate: return "10-15 minutes"
        case .intensive: return "30+ minutes"
        }
    }
    
    var color: Color {
        switch self {
        case .quick: return .green
        case .moderate: return .blue
        case .intensive: return .purple
        }
    }
}

/// The main library class that manages all coping strategies
final class CopingStrategiesLibrary {
    static let shared = CopingStrategiesLibrary()
    
    private(set) var strategies: [CopingStrategyDetail]
    
    private init() {
        // Initialize with all available strategies
        strategies = CopingStrategiesLibrary.allStrategies
    }
    
    /// Recommends strategies based on mood, intensity, and optional trigger
    func recommendStrategies(for mood: String, intensity: Int, trigger: String? = nil) -> [CopingStrategyDetail] {
        // Strong emotional reactions (intensity 4-5)
        let isStrongReaction = intensity >= 4
        
        var filteredStrategies = strategies
        
        // Filter by mood type
        filteredStrategies = filteredStrategies.filter { strategy in
            strategy.moodTargets.contains(mood) || 
            strategy.moodTargets.contains("Any")
        }
        
        // For strong reactions, prioritize quick relief strategies first
        if isStrongReaction {
            let quickStrategies = filteredStrategies.filter { $0.intensity == .quick }
            let otherStrategies = filteredStrategies.filter { $0.intensity != .quick }
            
            filteredStrategies = quickStrategies + otherStrategies.shuffled().prefix(3)
        }
        
        // If we have a trigger, try to include strategies that address it
        if let trigger = trigger, !trigger.isEmpty {
            let triggerKeywords = trigger.lowercased().components(separatedBy: " ")
            let triggerRelatedStrategies = strategies.filter { strategy in
                let desc = strategy.description.lowercased()
                return triggerKeywords.contains { keyword in
                    desc.contains(keyword)
                }
            }
            
            // Add trigger-specific strategies if we found any
            if !triggerRelatedStrategies.isEmpty {
                let uniqueStrategies = Array(Set(filteredStrategies + triggerRelatedStrategies))
                filteredStrategies = uniqueStrategies
            }
        }
        
        // Ensure we return at most 5 strategies, prioritizing strategy diversity by category
        var result: [CopingStrategyDetail] = []
        var usedCategories: Set<CopingStrategyCategory> = []
        
        // First add strategies with different categories
        for strategy in filteredStrategies {
            if !usedCategories.contains(strategy.category) {
                result.append(strategy)
                usedCategories.insert(strategy.category)
                
                if result.count >= 5 {
                    break
                }
            }
        }
        
        // If we still need more strategies, add the rest
        if result.count < 5 {
            for strategy in filteredStrategies {
                if !result.contains(strategy) {
                    result.append(strategy)
                    
                    if result.count >= 5 {
                        break
                    }
                }
            }
        }
        
        return result
    }
    
    /// Get strategies by category
    func getStrategies(for category: CopingStrategyCategory) -> [CopingStrategyDetail] {
        return strategies.filter { $0.category == category }
    }
    
    /// Get quick relief strategies (for emergency use)
    func getQuickReliefStrategies() -> [CopingStrategyDetail] {
        return strategies.filter { $0.intensity == .quick }
    }
}

// MARK: - Library Content

extension CopingStrategiesLibrary {
    /// All available coping strategies
    static var allStrategies: [CopingStrategyDetail] {
        return [
            // MINDFULNESS STRATEGIES
            CopingStrategyDetail(
                title: "Grounding with 5-4-3-2-1",
                description: "Use your senses to anchor yourself in the present moment and reduce overwhelming emotions.",
                timeToComplete: "2-5 minutes",
                steps: [
                    "Find a comfortable position and take a deep breath.",
                    "Name 5 things you can SEE around you.",
                    "Name 4 things you can FEEL/TOUCH (texture of your clothes, air on skin).",
                    "Name 3 things you can HEAR right now.",
                    "Name 2 things you can SMELL (or like to smell).",
                    "Name 1 thing you can TASTE (or like to taste)."
                ],
                category: .mindfulness,
                moodTargets: ["Anxious", "Overwhelmed", "Stressed", "Panicked"],
                intensity: .quick,
                resources: ["https://www.mayoclinic.org/healthy-lifestyle/consumer-health/in-depth/mindfulness-exercises/art-20046356"]
            ),
            
            CopingStrategyDetail(
                title: "Box Breathing Technique",
                description: "Control your breathing pattern to activate your parasympathetic nervous system and reduce anxiety.",
                timeToComplete: "3-5 minutes",
                steps: [
                    "Sit comfortably with your back supported.",
                    "Breathe in slowly through your nose for 4 counts.",
                    "Hold your breath for 4 counts.",
                    "Exhale slowly through your mouth for 4 counts.",
                    "Hold your breath for 4 counts.",
                    "Repeat for at least 4 cycles."
                ],
                category: .mindfulness,
                moodTargets: ["Anxious", "Stressed", "Angry", "Overwhelmed"],
                intensity: .quick,
                resources: nil
            ),
            
            CopingStrategyDetail(
                title: "Body Scan Meditation",
                description: "Progressively focus attention on different parts of your body to release tension and increase awareness.",
                timeToComplete: "10-15 minutes",
                steps: [
                    "Lie down or sit comfortably and close your eyes.",
                    "Begin by bringing awareness to your breathing.",
                    "Gradually direct attention to your feet, noticing any sensations.",
                    "Slowly move attention upward (ankles, calves, knees...) through your entire body.",
                    "For each area, notice sensations without judgment.",
                    "If you notice tension, breathe into that area and imagine releasing it.",
                    "Complete the scan at the top of your head."
                ],
                category: .mindfulness,
                moodTargets: ["Anxious", "Stressed", "Tense", "Sad"],
                intensity: .moderate,
                resources: nil
            ),
            
            // COGNITIVE STRATEGIES
            CopingStrategyDetail(
                title: "Thought Challenge",
                description: "Identify and reframe negative thoughts contributing to difficult emotions.",
                timeToComplete: "10-15 minutes",
                steps: [
                    "Write down the negative thought causing distress (e.g., 'I'll never succeed').",
                    "Rate how strongly you believe it (0-100%).",
                    "Identify evidence that supports this thought.",
                    "List evidence that contradicts or doesn't support the thought.",
                    "Write a more balanced alternative thought.",
                    "Rate your belief in the new thought and notice feeling changes."
                ],
                category: .cognitive,
                moodTargets: ["Sad", "Anxious", "Disappointed", "Rejected"],
                intensity: .moderate,
                resources: nil
            ),
            
            CopingStrategyDetail(
                title: "RAIN for Dealing with Rejection",
                description: "Process rejection feelings methodically to reduce their power over you.",
                timeToComplete: "5-10 minutes",
                steps: [
                    "R - Recognize the feelings of rejection without judgment.",
                    "A - Allow the experience to be there, just as it is.",
                    "I - Investigate with kindness how it feels in your body and mind.",
                    "N - Non-identification: These feelings are temporary, not your identity."
                ],
                category: .cognitive,
                moodTargets: ["Rejected", "Disappointed", "Hurt", "Sad"],
                intensity: .quick,
                resources: nil
            ),
            
            CopingStrategyDetail(
                title: "Growth from Rejection",
                description: "Transform rejection into a learning opportunity using a structured reflection.",
                timeToComplete: "15-20 minutes",
                steps: [
                    "Write about the rejection experience objectively.",
                    "List three things you can learn from this experience.",
                    "Identify aspects within your control vs. outside your control.",
                    "Write how this experience might benefit you in the future.",
                    "Set one small action step to move forward."
                ],
                category: .cognitive,
                moodTargets: ["Rejected", "Disappointed", "Frustrated"],
                intensity: .moderate,
                resources: nil
            ),
            
            // PHYSICAL STRATEGIES
            CopingStrategyDetail(
                title: "Movement and Music Boost",
                description: "Combine physical movement with music to shift your emotional state quickly.",
                timeToComplete: "5-10 minutes",
                steps: [
                    "Choose an uplifting or energizing song.",
                    "Play the music and allow yourself to move freely.",
                    "Dance, jump, or simply sway - no right or wrong way.",
                    "Focus on the music and sensations in your body.",
                    "Continue until the song ends, then notice how you feel."
                ],
                category: .physical,
                moodTargets: ["Sad", "Lethargic", "Stressed", "Anxious"],
                intensity: .quick,
                resources: nil
            ),
            
            CopingStrategyDetail(
                title: "Progressive Muscle Relaxation",
                description: "Systematically tense and release muscle groups to reduce physical tension.",
                timeToComplete: "10-15 minutes",
                steps: [
                    "Find a quiet, comfortable place to sit or lie down.",
                    "Start with your feet: tense the muscles for 5 seconds, then release.",
                    "Work your way up through each muscle group (calves, thighs, abdomen, etc.).",
                    "For each area, focus on the contrast between tension and relaxation.",
                    "End with facial muscles (jaw, forehead).",
                    "When complete, notice the overall sensation of relaxation."
                ],
                category: .physical,
                moodTargets: ["Anxious", "Tense", "Stressed", "Angry"],
                intensity: .moderate,
                resources: nil
            ),
            
            // SOCIAL STRATEGIES
            CopingStrategyDetail(
                title: "Connection Quick-Chat",
                description: "Reach out to a supportive person for a brief conversation to counter feelings of rejection.",
                timeToComplete: "5-15 minutes",
                steps: [
                    "Identify someone supportive in your life.",
                    "Send a message or make a call with a specific timeframe (e.g., \"Do you have 5 minutes to chat?\").",
                    "Share briefly how you're feeling without dwelling.",
                    "Listen to their perspective or simply enjoy the connection.",
                    "Express gratitude for their time and support."
                ],
                category: .social,
                moodTargets: ["Lonely", "Rejected", "Sad", "Isolated"],
                intensity: .quick,
                resources: nil
            ),
            
            CopingStrategyDetail(
                title: "Rejection Experience Sharing",
                description: "Connect with others through shared experiences of rejection for perspective and support.",
                timeToComplete: "Varies",
                steps: [
                    "Identify a trusted friend or join a support group/forum.",
                    "Share your rejection experience honestly.",
                    "Ask others about their similar experiences.",
                    "Listen for how they coped with and grew from rejection.",
                    "Note insights that shift your perspective on your own situation."
                ],
                category: .social,
                moodTargets: ["Rejected", "Embarrassed", "Inadequate"],
                intensity: .moderate,
                resources: nil
            ),
            
            // CREATIVE STRATEGIES
            CopingStrategyDetail(
                title: "Expressive Writing",
                description: "Process emotions through structured writing to gain clarity and release.",
                timeToComplete: "15-20 minutes",
                steps: [
                    "Find a private space with no distractions.",
                    "Write continuously for 15-20 minutes about your deepest thoughts and feelings.",
                    "Don't worry about grammar, spelling, or structure - just express.",
                    "Focus especially on how the rejection experience connects to past experiences.",
                    "After writing, you can either keep or destroy the writing.",
                    "Reflect on any insights gained."
                ],
                category: .creative,
                moodTargets: ["Confused", "Sad", "Angry", "Anxious", "Rejected"],
                intensity: .moderate,
                resources: nil
            ),
            
            CopingStrategyDetail(
                title: "Visualization Safe Place",
                description: "Create a mental sanctuary where you feel safe, confident and accepted.",
                timeToComplete: "5-10 minutes",
                steps: [
                    "Close your eyes and take several deep breaths.",
                    "Imagine a place where you feel completely safe and accepted.",
                    "Build details: What do you see? Hear? Smell? Feel?",
                    "Imagine supportive figures or memories in this space.",
                    "When the image is clear, affirm: \"This is my inner safe place.\"",
                    "Return to this place whenever rejection feelings arise."
                ],
                category: .creative,
                moodTargets: ["Anxious", "Rejected", "Unsafe", "Threatened"],
                intensity: .quick,
                resources: nil
            ),
            
            // SELF-CARE STRATEGIES
            CopingStrategyDetail(
                title: "Self-Compassion Break",
                description: "Apply the three components of self-compassion to difficult emotions.",
                timeToComplete: "3-5 minutes",
                steps: [
                    "Notice your suffering: \"This is a moment of difficulty.\"",
                    "Acknowledge shared humanity: \"Difficulty is part of life; many others feel this way.\"",
                    "Offer yourself kindness: Place hands over heart and say, \"May I be kind to myself right now.\"",
                    "Take several breaths, feeling the warmth of your hands and your care for yourself."
                ],
                category: .selfCare,
                moodTargets: ["Any"],
                intensity: .quick,
                resources: nil
            ),
            
            CopingStrategyDetail(
                title: "Achievements Quick-List",
                description: "Counter rejection by reminding yourself of past successes and strengths.",
                timeToComplete: "5-10 minutes",
                steps: [
                    "Take out paper or open a note app.",
                    "Quickly list 10 achievements you're proud of (big or small).",
                    "For each, note one strength or quality it demonstrates.",
                    "Choose one achievement that feels most meaningful right now.",
                    "Spend a moment fully recalling how it felt to succeed in that instance."
                ],
                category: .selfCare,
                moodTargets: ["Inadequate", "Disappointed", "Rejected", "Doubtful"],
                intensity: .quick,
                resources: nil
            ),
            
            CopingStrategyDetail(
                title: "Soothing Ritual",
                description: "Create a brief, sensory-rich ritual to comfort yourself during difficult emotions.",
                timeToComplete: "5-15 minutes",
                steps: [
                    "Choose 2-3 sensory comforts (e.g., warm tea, soft blanket, calming music).",
                    "Find a quiet space where you won't be disturbed.",
                    "Set a timer for your chosen duration.",
                    "Engage with your comfort items mindfully, focusing on sensations.",
                    "If difficult thoughts arise, gently return focus to sensory experiences.",
                    "Before ending, acknowledge this act of self-care."
                ],
                category: .selfCare,
                moodTargets: ["Sad", "Lonely", "Disappointed", "Overwhelmed"],
                intensity: .moderate,
                resources: nil
            )
        ]
    }
    
    /// Convert CopingStrategyDetail to simple string format for backward compatibility
    static func getSimpleStrategyStrings(from details: [CopingStrategyDetail]) -> [String] {
        return details.map { $0.title }
    }
} 