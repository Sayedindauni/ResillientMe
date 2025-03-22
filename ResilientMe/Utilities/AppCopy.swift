//
//  AppCopy.swift
//  ResillientMe
//
//  Created by Sayed Mohamed on 21.03.25.
//

import Foundation
// Import the Strategy type from AppTypes
import SwiftUI

// Supporting Types are now moved to a separate AppTypes.swift file

/// Centralized location for app copy, making it easier to maintain consistent voice and tone
public struct AppCopy {
    // MARK: - Affirmations
    
    static let affirmations = [
        "Your worth is not determined by external validation.",
        "Rejection is redirection to something better for you.",
        "You are brave for putting yourself out there.",
        "Every rejection is a step closer to acceptance.",
        "You are enough, exactly as you are right now.",
        "This feeling is temporary; your strength is permanent.",
        "Your resilience grows with each challenge you face.",
        "Today's rejection is tomorrow's redirection.",
        "You have the courage to try again tomorrow.",
        "Growth happens outside your comfort zone.",
        "Your value doesn't decrease based on someone's inability to see your worth.",
        "Rejections are just one person's opinion, not universal truth.",
        "The right people will value your authentic self.",
        "Honor your feelings without being defined by them.",
        "Each setback carries the seed of equal or greater opportunity.",
        "You're developing resilience that will serve you for life.",
        "Your path is your own—comparison only steals your joy.",
        "What feels like failure is often just a necessary step.",
        "Breathe. This moment will pass.",
        "You are learning and evolving with every experience."
    ]
    
    static func randomAffirmation() -> String {
        return affirmations.randomElement() ?? affirmations[0]
    }
    
    // MARK: - Rejection Processing Prompts
    
    static let rejectionPrompts = [
        "What thoughts came up immediately after this rejection?",
        "What strengths did you show when handling this situation?",
        "How might this experience serve you in the future?",
        "What would you say to a friend experiencing this same rejection?",
        "What aspect of this rejection feels most difficult right now?",
        "Can you identify any assumptions you're making about this situation?",
        "What's one small step you can take to care for yourself today?",
        "How has overcoming past rejections prepared you for this?",
        "If this rejection is a teacher, what is it trying to teach you?",
        "What parts of this situation are within your control?",
        "How can you separate your worth from this outcome?",
        "What would this situation look like from the other person's perspective?",
        "How might you reframe this rejection as an opportunity?",
        "What support do you need right now to process these feelings?",
        "What would your future self, who has moved past this, tell you now?"
    ]
    
    static func randomRejectionPrompt() -> String {
        return rejectionPrompts.randomElement() ?? rejectionPrompts[0]
    }
    
    // MARK: - Journal Prompts
    
    static let journalPrompts = [
        "What digital interactions brought you joy today?",
        "Describe a challenging online interaction and how you handled it.",
        "What boundaries would you like to establish in your digital life?",
        "How have your online relationships affected your self-perception?",
        "What social media habits would you like to change?",
        "List three strengths you bring to your online interactions.",
        "How do you define your identity outside of social validation?",
        "What would authentic connection look like for you online?",
        "Reflect on a time when you bounced back from online criticism.",
        "How do you practice self-care after difficult digital interactions?",
        "What values guide how you show up online?",
        "Describe your ideal relationship with technology and social media.",
        "What comparisons do you make online that don't serve you?",
        "How have your digital experiences shaped your real-world relationships?",
        "What's one way you can be more intentional with your online presence?"
    ]
    
    static func randomJournalPrompt() -> String {
        return journalPrompts.randomElement() ?? journalPrompts[0]
    }
    
    // MARK: - Coping Strategies
    
    static let copingStrategies = [
        Strategy(
            title: "5-4-3-2-1 Grounding",
            description: "Name 5 things you can see, 4 things you can touch, 3 things you can hear, 2 things you can smell, and 1 thing you can taste."
        ),
        Strategy(
            title: "Breath Focus",
            description: "Breathe in for 4 counts, hold for 2, exhale for 6. Repeat for 2 minutes to activate your parasympathetic nervous system."
        ),
        Strategy(
            title: "Digital Detox",
            description: "Take a 30-minute break from all screens. Go for a walk, journal, or connect with someone in person."
        ),
        Strategy(
            title: "Self-Compassion Practice",
            description: "Place your hand on your heart and say: 'This is a moment of suffering. Suffering is part of life. May I be kind to myself in this moment.'"
        ),
        Strategy(
            title: "Gratitude Shift",
            description: "List 3 things you're grateful for right now, no matter how small. This can help shift your perspective away from rejection."
        ),
        Strategy(
            title: "Physical Reset",
            description: "Do 10 jumping jacks, 10 squats, or dance to your favorite song. Physical movement releases tension and anxiety."
        ),
        Strategy(
            title: "Emotion Naming",
            description: "Identify and name your emotions specifically. Research shows naming feelings reduces their intensity."
        ),
        Strategy(
            title: "Future Self Letter",
            description: "Write a brief letter from your future self who has moved past this rejection. What wisdom would they share?"
        ),
        Strategy(
            title: "Rejection Reframe",
            description: "List three possible alternative explanations for the rejection that don't involve your worth or abilities."
        ),
        Strategy(
            title: "Value Alignment",
            description: "Identify one personal value you can honor today, regardless of external validation."
        )
    ]
    
    public static func randomCopingStrategy() -> Strategy {
        return copingStrategies.randomElement() ?? copingStrategies[0]
    }
    
    // MARK: - Onboarding Messages
    
    static let onboardingMessages = [
        OnboardingMessage(
            title: "It's OK to Feel",
            subtitle: "Rejection is universal",
            message: "Everyone experiences rejection, especially in the digital age. Your feelings are valid and shared by many."
        ),
        OnboardingMessage(
            title: "Build Resilience",
            subtitle: "Turn pain into growth",
            message: "Each rejection is an opportunity to develop emotional strength that will serve you throughout life."
        ),
        OnboardingMessage(
            title: "Process & Release",
            subtitle: "Track, reflect, move forward",
            message: "ResilientMe helps you safely process difficult emotions and transform rejection into deeper self-understanding."
        ),
        OnboardingMessage(
            title: "You're Not Alone",
            subtitle: "Connect with others",
            message: "Share experiences and insights with a community that understands what you're going through."
        )
    ]
} 