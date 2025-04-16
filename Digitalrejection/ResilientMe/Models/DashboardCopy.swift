import SwiftUI
import Foundation

/// DashboardCopy provides text content for the dashboard view
public class AppDashboardCopyProvider {
    // MARK: - Dashboard Tips
    
    private static let affirmations = [
        "I am resilient in the face of digital rejection.",
        "Each rejection brings me closer to my goals.",
        "I value myself beyond online validation.",
        "My worth is not determined by likes or followers.",
        "I am becoming stronger with each challenge.",
        "I choose to respond with self-compassion today.",
        "I am learning valuable lessons from every experience.",
        "I have the power to rise above rejection.",
        "I am cultivating inner strength day by day.",
        "I celebrate my progress, not perfection."
    ]
    
    /// Returns a random affirmation
    public static func randomAffirmation() -> String {
        return affirmations.randomElement() ?? "I am resilient."
    }
    
    // MARK: - Quotes
    
    private static let quotes = [
        "The greatest glory in living lies not in never falling, but in rising every time we fall. — Nelson Mandela",
        "Life is 10% what happens to you and 90% how you react to it. — Charles R. Swindoll",
        "You may encounter many defeats, but you must not be defeated. — Maya Angelou",
        "Resilience is accepting your new reality, even if it's less good than the one you had before. — Elizabeth Edwards",
        "Rock bottom became the solid foundation on which I rebuilt my life. — J.K. Rowling"
    ]
    
    /// Returns a random inspirational quote
    public static func randomQuote() -> String {
        return quotes.randomElement() ?? "The only way out is through."
    }
    
    // MARK: - Tips
    
    private static let resilientTips = [
        "Practice mindful breathing for 2 minutes when feeling rejected.",
        "Write down three strengths that aren't dependent on external validation.",
        "Reach out to a supportive friend after experiencing rejection.",
        "Remember a time you overcame a similar challenge successfully.",
        "Focus on what you can learn from the rejection experience."
    ]
    
    /// Returns a random resilience tip
    public static func randomTip() -> String {
        return resilientTips.randomElement() ?? "Practice self-compassion daily."
    }
    
    // MARK: - Coping Strategies
    
    public static func randomCopingStrategy() -> (title: String, description: String) {
        let titles = [
            "Mindful Breathing",
            "Thought Reframing",
            "Quick Movement Break",
            "Gratitude Practice",
            "Social Connection"
        ]
        
        let descriptions = [
            "Focus on your breath to calm your mind and reduce anxiety after rejection",
            "Challenge negative thoughts by identifying evidence that contradicts them",
            "Physical movement to release tension and shift your mental state",
            "Counter negative emotions by listing things you're grateful for",
            "Reach out to someone supportive to share your experience"
        ]
        
        let randomIndex = Int.random(in: 0..<min(titles.count, descriptions.count))
        return (titles[randomIndex], descriptions[randomIndex])
    }
} 

// Add typealias for backward compatibility
public typealias DashboardCopyProvider = AppDashboardCopyProvider
public typealias DashboardCopy = AppDashboardCopyProvider 