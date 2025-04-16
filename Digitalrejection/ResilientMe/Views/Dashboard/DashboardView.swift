//
//  DashboardView.swift
//  ResillientMe
//
//  Created by Sayed Mohamed on 21.03.25.
//

import SwiftUI
import Foundation
import UIKit

// MARK: - Utility Definitions

// Layout constants
struct AppLayout {
    static let spacing: CGFloat = 16
    static let cornerRadius: CGFloat = 12
    static let smallCornerRadius: CGFloat = 8
    static let padding: CGFloat = 16
}

// Theme and style constants
struct AppColors {
    static let primary = Color.blue
    static let secondary = Color(red: 0.58, green: 0.71, blue: 0.62)
    static let accent1 = Color.orange
    static let accent2 = Color.purple
    static let accent3 = Color.green
    static let textDark = Color.black
    static let textMedium = Color.gray
    static let textLight = Color.gray.opacity(0.5)
    static let background = Color(.systemBackground)
    static let cardBackground = Color(.systemBackground)
    static let joy = Color.yellow
    static let calm = Color.mint
    static let sadness = Color.blue.opacity(0.7)
    static let error = Color(red: 0.96, green: 0.72, blue: 0.69)
    static let frustration = Color(red: 0.83, green: 0.71, blue: 0.74)
    static let warning = Color.orange
    static let info = Color.blue
}

struct AppTextStyles {
    static let h1 = Font.system(size: 30, weight: .bold)
    static let h2 = Font.system(size: 24, weight: .bold)
    static let h3 = Font.system(size: 20, weight: .bold)
    static let h4 = Font.system(size: 18, weight: .semibold)
    static let body1 = Font.system(size: 16, weight: .regular)
    static let body2 = Font.system(size: 14, weight: .regular)
    static let body3 = Font.system(size: 12, weight: .regular)
    static let captionText = Font.system(size: 12, weight: .regular)
    static let buttonFont = Font.system(size: 16, weight: .medium)
    static var smallText: Font {
        .system(size: 12)
    }
}

// Define Mood enum
enum DashboardMood: String, CaseIterable, Identifiable {
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
}

// Screen reader announcement helper
func announceToScreenReader(_ message: String, delay: Double = 0.1) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        UIAccessibility.post(notification: .announcement, argument: message)
    }
}

// MARK: - Local Haptics Implementation
/// Provides haptic feedback for the Dashboard view
class LocalHaptics {
    /// Generates light haptic feedback
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// Generates medium haptic feedback
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    /// Generates heavy haptic feedback
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    /// Generates selection feedback
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    /// Generates success feedback
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    /// Generates warning feedback
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    /// Generates error feedback
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}

// MARK: - Utility Types and Constants

// Define the shared breathing enums
// MARK: - Breathing Phase Model
enum DashboardBreathingPhase: String, Equatable, Identifiable {
    case inhale
    case hold
    case exhale
    case holdAfterExhale
    case complete
    
    var id: String { self.rawValue }
    
    var instruction: String {
        switch self {
        case .inhale: return "Inhale"
        case .hold: return "Hold"
        case .exhale: return "Exhale"
        case .holdAfterExhale: return "Hold"
        case .complete: return "Complete"
        }
    }
    
    func duration(for pattern: DashboardBreathingPattern) -> Double {
        switch self {
        case .inhale: return pattern.inhaleTime
        case .hold: return pattern.holdTime
        case .exhale: return pattern.exhaleTime
        case .holdAfterExhale: return pattern.holdAfterExhaleTime
        case .complete: return 0.0
        }
    }
}

// MARK: - Breathing Pattern Model
enum DashboardBreathingPattern: Int, CaseIterable, Identifiable {
    case fourSevenEight
    case box
    case deep
    
    var id: String { String(self.rawValue) }
    
    var title: String {
        switch self {
        case .fourSevenEight:
            return "4-7-8 Breathing"
        case .box:
            return "Box Breathing"
        case .deep:
            return "Deep Breathing"
        }
    }
    
    var description: String {
        switch self {
        case .fourSevenEight:
            return "Inhale for 4 seconds, hold for 7 seconds, exhale for 8 seconds. This pattern has calming effects on the nervous system."
        case .box:
            return "Inhale for 4 seconds, hold for 4 seconds, exhale for 4 seconds, hold for 4 seconds. This creates a balanced, stabilizing breath."
        case .deep:
            return "Inhale deeply for 5 seconds, hold briefly for 2 seconds, exhale fully for 5 seconds. Focus on filling and emptying the lungs completely."
        }
    }
    
    var inhaleTime: Double {
        switch self {
        case .fourSevenEight: return 4.0
        case .box: return 4.0
        case .deep: return 5.0
        }
    }
    
    var holdTime: Double {
        switch self {
        case .fourSevenEight: return 7.0
        case .box: return 4.0
        case .deep: return 2.0
        }
    }
    
    var exhaleTime: Double {
        switch self {
        case .fourSevenEight: return 8.0
        case .box: return 4.0
        case .deep: return 5.0
        }
    }
    
    var holdAfterExhaleTime: Double {
        switch self {
        case .fourSevenEight: return 0.0
        case .box: return 4.0
        case .deep: return 0.0
        }
    }
    
    var hasHold: Bool {
        return holdTime > 0
    }
    
    var totalCycleTime: Double {
        return inhaleTime + holdTime + exhaleTime + holdAfterExhaleTime
    }
}


// MARK: - Models for coping strategies

// Add these model types directly in this file
enum AppCopingStrategyCategory: String, CaseIterable, Identifiable {
    case mindfulness = "Mindfulness"
    case cognitive = "Cognitive"
    case physical = "Physical"
    case social = "Social"
    case creative = "Creative"
    case selfCare = "Self-Care"
    
    var id: String { rawValue }
    
    var color: Color {
        switch self {
        case .mindfulness: return Color.teal
        case .cognitive: return Color.blue
        case .physical: return Color.green
        case .social: return Color.purple
        case .creative: return Color.orange
        case .selfCare: return Color.pink
        }
    }
    
    var iconName: String {
        switch self {
        case .mindfulness: return "brain.head.profile"
        case .cognitive: return "lightbulb"
        case .physical: return "figure.walk"
        case .social: return "person.2"
        case .creative: return "paintbrush"
        case .selfCare: return "heart.circle"
        }
    }
}

struct AppCopingStrategyDetail: Identifiable {
    let id: String
    let title: String
    let description: String
    let category: AppCopingStrategyCategory
    let steps: [String]
    let timeToComplete: String
    let moodTargets: [String]
    
    init(id: String = UUID().uuidString, 
         title: String, 
         description: String, 
         category: AppCopingStrategyCategory, 
         steps: [String], 
         timeToComplete: String, 
         moodTargets: [String] = ["rejected", "anxious", "sad"]) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.steps = steps
        self.timeToComplete = timeToComplete
        self.moodTargets = moodTargets
    }
}

// Library to manage coping strategies
class AppCopingStrategiesLibrary: ObservableObject {
    static let shared = AppCopingStrategiesLibrary()
    
    @Published var strategies: [AppCopingStrategyDetail] = [
        AppCopingStrategyDetail(
            title: "Mindful Breathing",
            description: "Focus on your breath to calm your mind and reduce anxiety after rejection",
            category: .mindfulness,
            steps: [
                "Find a comfortable position and close your eyes if possible",
                "Begin by taking deep breaths, inhaling through your nose for 4 counts",
                "Hold for 1-2 seconds",
                "Exhale slowly through your mouth for 6 counts",
                "Notice the sensation of your breath without judgment",
                "Continue for 5-10 minutes"
            ],
            timeToComplete: "5-10 minutes"
        ),
        AppCopingStrategyDetail(
            title: "Thought Reframing",
            description: "Identify and challenge negative thoughts about rejection",
            category: .cognitive,
            steps: [
                "Notice negative thoughts that arose from the rejection",
                "Write down these thoughts",
                "Question the evidence for and against each thought",
                "Create a more balanced perspective",
                "Practice repeating the new perspective"
            ],
            timeToComplete: "15 minutes"
        ),
        AppCopingStrategyDetail(
            title: "Quick Walk",
            description: "Use physical movement to process emotions and clear your mind",
            category: .physical,
            steps: [
                "Put on comfortable shoes and appropriate clothing",
                "Head outside for a 10-minute walk",
                "Focus on your surroundings rather than the rejection",
                "Notice 5 things you can see, 4 things you can hear, etc.",
                "Return feeling refreshed with new perspective"
            ],
            timeToComplete: "10 minutes"
        ),
        AppCopingStrategyDetail(
            title: "Journaling",
            description: "Process your emotions through writing about the rejection experience",
            category: .creative,
            steps: [
                "Find a quiet space with your journal",
                "Write freely about the rejection experience",
                "Explore your feelings without judgment",
                "Consider what you can learn from this experience",
                "End with three positive affirmations"
            ],
            timeToComplete: "10-15 minutes"
        ),
        AppCopingStrategyDetail(
            title: "Connect with Support",
            description: "Reach out to someone you trust to share your experience",
            category: .social,
            steps: [
                "Identify someone supportive in your life",
                "Reach out via message or call",
                "Share your experience and feelings",
                "Listen to their perspective",
                "Thank them for their support"
            ],
            timeToComplete: "15-30 minutes"
        ),
        AppCopingStrategyDetail(
            title: "Body Scan",
            description: "A quick tension release technique to help center yourself",
            category: .mindfulness,
            steps: [
                "Sit or lie down comfortably",
                "Close your eyes and bring attention to your body",
                "Scan from head to toe, noticing tension",
                "Breathe into any areas of tension",
                "Release the tension with each exhale"
            ],
            timeToComplete: "3 minutes"
        ),
        AppCopingStrategyDetail(
            title: "Self-Compassion Break",
            description: "Practice kindness toward yourself during difficult moments",
            category: .cognitive,
            steps: [
                "Notice your suffering ('This is a moment of difficulty')",
                "Remind yourself this is part of being human ('Suffering is part of life')",
                "Place your hands over your heart",
                "Offer yourself kindness ('May I be kind to myself')",
                "Take a deep breath and feel the compassion"
            ],
            timeToComplete: "2 minutes"
        ),
        AppCopingStrategyDetail(
            title: "Quick Stretch",
            description: "Release physical tension associated with rejection stress",
            category: .physical,
            steps: [
                "Stand tall with feet hip-width apart",
                "Reach arms overhead and stretch up",
                "Fold forward at the waist",
                "Roll up slowly, one vertebra at a time",
                "Repeat 3 times"
            ],
            timeToComplete: "2 minutes"
        )
    ]
}

// MARK: - Extensions for necessary components

// Remove the AppTextStyles extension but keep the View extensions

// Extension for accessibility related functions
extension View {
    func accessibleCard(label: String, hint: String? = nil) -> some View {
        return self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
    }
    
    // Add missing decorativeImage extension method
    func decorativeImage() -> some View {
        return self.accessibility(hidden: true)
    }
}

// MARK: - Models for Dashboard

struct Activity: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

enum ResourceType {
    case article
    case video
    case podcast
    case community
    case collection
}

struct Resource: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let type: ResourceType
    
    enum ResourceType {
        case article
        case video
        case podcast
        case community
        case collection
        case exercise
    }
}

// MARK: - Mood Button View

struct MoodButton: View {
    let mood: DashboardMood
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Text(mood.emoji)
                    .font(.system(size: 30))
                Text(mood.name)
                    .font(.caption)
            }
            .frame(width: 80, height: 80)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct DashboardView: View {
    @State private var userName = "Friend"
    @State private var currentMood: DashboardMood = .neutral
    @State private var showMoodPicker = false
    @State private var rejectionCount = 0
    @State private var streakDays = 0
    @State private var showingTip = true
    @State private var currentTipTitle = ""
    @State private var currentTipDescription = ""
    
    // Add states for coping strategies functionality
    @State private var favoriteStrategies: [String] = []
    @State private var recentlyUsedStrategies: [AppCopingStrategyDetail] = []
    @State private var selectedStrategy: AppCopingStrategyDetail? = nil
    @State private var showingStrategyDetail = false
    @State private var searchText = ""
    
    // State variables for sheet presentations
    @State private var showingDailyInfo = false
    @State private var showingQuotesView = false
    @State private var showingActivityDetail = false
    @State private var showingStreaksDetail = false
    @State private var showingAllStrategies = false
    @State private var selectedCategoryFilter: LocalCopingStrategyCategory?
    
    // Define ResillienceActivity struct
    struct ResillienceActivity: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let iconName: String
    }
    
    @State private var selectedActivity: ResillienceActivity?
    @State private var selectedQuote: String = ""
    
    init() {
        let strategy = getRandomCopingStrategy()
        _currentTipTitle = State(initialValue: strategy.title)
        _currentTipDescription = State(initialValue: strategy.description)
        
        // Initialize with recently used strategies
        let initialStrategies = AppCopingStrategiesLibrary.shared.strategies.prefix(3)
        _recentlyUsedStrategies = State(initialValue: Array(initialStrategies))
    }
    
    // Sample data
    let activities = [
        Activity(icon: "brain.head.profile", title: "Coping Strategies", description: "Browse evidence-based techniques to manage rejection"),
        Activity(icon: "heart.text.square", title: "Compassion Practice", description: "Develop self-kindness in the face of rejection"),
        Activity(icon: "arrow.up.heart", title: "Build Resilience", description: "Strengthen your ability to bounce back")
    ]
    
    let resources = [
        Resource(icon: "doc.text", title: "Understanding Digital Rejection", description: "Why online rejection hits differently", type: Resource.ResourceType.article),
        Resource(icon: "person.2", title: "Community Stories", description: "How others overcame rejection", type: Resource.ResourceType.community),
        Resource(icon: "books.vertical", title: "Resilience Library", description: "Curated resources for building strength", type: Resource.ResourceType.collection)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppLayout.spacing) {
                // The AffirmationBanner is now shown above this view in ContentView
                // Adjusted spacing to account for the banner above
                
                // Header with greeting and mood check-in
                headerSection
                    .padding(.top, 8) // Reduced top padding since AffirmationBanner is above
                
                // Stats section
                statsSection
                
                // Daily coping tip
                if showingTip {
                    tipCard
                }
                
                // Quick activities section
                activitiesSection
                
                // Coping Strategies Library section
                copingStrategiesSection
                
                // Resources section
                resourcesSection
                
                // Community section
                communitySection
            }
            .padding(.horizontal)
        }
        .background(AppColors.background.edgesIgnoringSafeArea(.all))
        .sheet(isPresented: $showMoodPicker) {
            MoodPickerView(selectedMood: $currentMood) {
                LocalHaptics.success()
                announceToScreenReader("Mood updated to \(currentMood.name)")
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Greeting
            Text("Hello, \(userName)")
                .font(AppTextStyles.h2)
                .foregroundColor(AppColors.textDark)
                .accessibilityAddTraits(.isHeader)
            
            // Today's date
            Text(formattedDate())
                .font(AppTextStyles.body2)
                .foregroundColor(AppColors.textMedium)
            
            // Mood check-in button
            HStack(spacing: 12) {
                Button(action: { showMoodPicker = true }) {
                    HStack {
                        Image(systemName: "face.smiling")
                            .font(.system(size: 18))
                        
                        Text(currentMood == .neutral ? "How are you feeling?" : "Feeling \(currentMood.name)")
                            .font(AppTextStyles.body1)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textLight)
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .foregroundColor(AppColors.textDark)
                    .cornerRadius(AppLayout.cornerRadius)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                }
                .buttonStyle(.plain)
                .makeAccessible(label: "Mood check-in", hint: "Track how you're feeling today")
            }
        }
        .padding(.top)
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        HStack(spacing: 12) {
            // Rejections Processed Card
            StatsCard(
                value: "\(rejectionCount)",
                label: "Rejections\nProcessed",
                icon: "checkmark.shield",
                color: AppColors.primary
            )
            
            // Current Streak Card
            StatsCard(
                value: "\(streakDays)",
                label: "Day\nStreak",
                icon: "flame",
                color: AppColors.accent3
            )
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Daily Tip Section
    
    private var tipCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Daily Coping Strategy")
                    .font(AppTextStyles.h3)
                    .foregroundColor(AppColors.textDark)
                
                Spacer()
                
                Button(action: {
                    // Get a new random strategy
                    let newStrategy = getRandomCopingStrategy()
                    withAnimation {
                        currentTipTitle = newStrategy.title
                        currentTipDescription = newStrategy.description
                    }
                    LocalHaptics.light()
                }) {
                    Image(systemName: "arrow.2.squarepath")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.primary)
                        .padding(8)
                        .background(AppColors.primary.opacity(0.1))
                        .cornerRadius(8)
                }
                .accessibilityLabel("Get new strategy")
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text(currentTipTitle)
                    .font(AppTextStyles.h4)
                    .foregroundColor(AppColors.textDark)
                    .accessibilityAddTraits(.isHeader)
                
                Text(currentTipDescription)
                    .font(AppTextStyles.body2)
                    .foregroundColor(AppColors.textMedium)
                
                Button(action: {
                    // Find the actual strategy from the library
                    if let strategy = AppCopingStrategiesLibrary.shared.strategies.first(where: { $0.title == currentTipTitle }) {
                        selectedStrategy = strategy
                        showingStrategyDetail = true
                    } else {
                        // Post a notification to switch to the Strategies tab
                        NotificationCenter.default.post(
                            name: NSNotification.Name("SwitchToStrategiesTab"),
                            object: nil
                        )
                    }
                }) {
                    Text("View Details")
                        .font(AppTextStyles.body3)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(AppColors.primary)
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
        .accessibleCard(label: "Daily coping strategy: \(currentTipTitle)", hint: currentTipDescription)
    }
    
    // MARK: - Quick Activities Section
    
    private var activitiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Activities")
                .font(AppTextStyles.h3)
                .foregroundColor(AppColors.textDark)
            
            // Activities grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(activities) { activity in
                    if activity.title == "Coping Strategies" {
                        // Special handling for Coping Strategies activity
                        Button(action: {
                            // Switch to the strategies tab
                            NotificationCenter.default.post(name: Notification.Name("switchToStrategiesTab"), object: nil)
                        }) {
                            activityCard(activity)
                        }
                    } else {
                        // Regular activity card
                        Button(action: {
                            // Handle tapping on regular activity
                            LocalHaptics.light()
                        }) {
                            activityCard(activity)
                        }
                    }
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
        .accessibleCard(label: "Quick activities", hint: "Start one of these activities to build resilience")
    }
    
    private func activityCard(_ activity: Activity) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: activity.icon)
                .font(.system(size: 24))
                .foregroundColor(AppColors.primary)
            
            Text(activity.title)
                .font(AppTextStyles.body1)
                .foregroundColor(AppColors.textDark)
                .lineLimit(1)
            
            Text(activity.description)
                .font(AppTextStyles.captionText)
                .foregroundColor(AppColors.textMedium)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(height: 120)
        .padding()
        .background(AppColors.background)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    // MARK: - Coping Strategies Library Section
    
    private var copingStrategiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with View All button
            HStack {
                SectionHeader(title: "Coping Strategies", icon: "brain.head.profile")
                
                Spacer()
                
                Button(action: {
                    // Show all strategies in a sheet instead of switching tabs
                    showingAllStrategies = true
                }) {
                    Text("View All")
                        .font(AppTextStyles.body3)
                        .foregroundColor(AppColors.primary)
                }
            }
            
            // Category filters for quick access
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(LocalCopingStrategyCategory.allCases) { category in
                        Button(action: {
                            // Set category filter and show all strategies
                            selectedCategoryFilter = category
                            showingAllStrategies = true
                        }) {
                            HStack {
                                Image(systemName: category.iconName)
                                    .font(.system(size: 12))
                                
                                Text(category.displayName)
                                    .font(AppTextStyles.body3)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(category.color.opacity(0.1))
                            )
                            .foregroundColor(category.color)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            
            // Featured strategies - just show a few highlighted ones
            VStack(alignment: .leading, spacing: 16) {
                // Recently used or recommended strategies
                if !recentlyUsedStrategies.isEmpty {
                    Text("Recently Used")
                        .font(AppTextStyles.h4)
                        .foregroundColor(AppColors.textDark)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(recentlyUsedStrategies.prefix(3)) { strategy in
                                strategyCard(strategy)
                                    .onTapGesture {
                                        selectedStrategy = strategy
                                        showingStrategyDetail = true
                                    }
                            }
                        }
                    }
                    .padding(.bottom, 8)
                }
            
                // Quick strategies section - just a few examples
                Text("Quick Relief")
                .font(AppTextStyles.h4)
                .foregroundColor(AppColors.textDark)
            
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        let quickStrategies = getStrategiesByTime(minutes: 5, includeUnder: true).prefix(3)
                        ForEach(Array(quickStrategies)) { strategy in
                            strategyCard(strategy)
                                .onTapGesture {
                                    selectedStrategy = strategy
                                    showingStrategyDetail = true
                                }
                        }
                    }
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
        .accessibleCard(label: "Coping strategies", hint: "Browse evidence-based techniques to manage rejection")
        .sheet(isPresented: $showingStrategyDetail) {
            if let strategy = selectedStrategy {
                strategyDetailView(strategy)
            }
        }
        .sheet(isPresented: $showingAllStrategies, onDismiss: {
            // Reset the category filter when the sheet is dismissed
            selectedCategoryFilter = nil
        }) {
            // Use a more comprehensive strategies view
            DashboardStrategiesView(
                initialCategory: selectedCategoryFilter,
                onStrategySelected: { strategy in
                    selectedStrategy = convertToAppStrategy(strategy)
                    showingAllStrategies = false
                    showingStrategyDetail = true
                }
            )
        }
    }
    
    // MARK: - Strategy Section Helpers
    
    func strategiesSection(title: String, description: String, strategies: [AppCopingStrategyDetail]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppTextStyles.h4)
                        .foregroundColor(AppColors.textDark)
                    
                    Text(description)
                    .font(AppTextStyles.body3)
                        .foregroundColor(AppColors.textMedium)
                }
                
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(strategies.prefix(5)) { strategy in
                        strategyCard(strategy)
                            .onTapGesture {
                                selectedStrategy = strategy
                                showingStrategyDetail = true
                            }
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    func getStrategiesByTime(minutes: Int, includeUnder: Bool, minimum: Int = 0) -> [AppCopingStrategyDetail] {
        let allStrategies = AppCopingStrategiesLibrary.shared.strategies
        
        return allStrategies.filter { strategy in
            // Parse the timeToComplete string to get minutes
            let timeString = strategy.timeToComplete.lowercased()
            let extractedMinutes = extractMinutes(from: timeString)
            
            if includeUnder {
                return extractedMinutes <= minutes && extractedMinutes >= minimum
            } else {
                return extractedMinutes > minutes
            }
        }
    }
    
    func extractMinutes(from timeString: String) -> Int {
        // Extract numeric values from strings like "5 minutes", "10-15 minutes"
        // For ranges, take the average or maximum
        if timeString.contains("-") {
            let components = timeString.components(separatedBy: "-")
            if components.count >= 2 {
                let firstPart = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let secondPart = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
                
                if let min = Int(firstPart.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()),
                   let max = Int(secondPart.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
                    return max // Use maximum of range
                }
            }
        }
        
        // Extract single values
        let numbers = timeString.components(separatedBy: CharacterSet.decimalDigits.inverted)
                                .joined()
        if let minutes = Int(numbers) {
            return minutes
        }
        
        // Default values based on common descriptions
        if timeString.contains("quick") || timeString.contains("brief") {
            return 5
        } else if timeString.contains("moderate") {
            return 10
        } else if timeString.contains("long") || timeString.contains("extended") {
            return 20
        }
        
        return 10 // Default assumption
    }
    
    private func strategyCard(_ strategy: AppCopingStrategyDetail) -> some View {
            VStack(alignment: .leading, spacing: 12) {
            // Category Icon
            ZStack {
                Circle()
                    .fill(strategy.category.color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: strategy.category.iconName)
                    .font(.system(size: 18))
                    .foregroundColor(strategy.category.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(strategy.title)
                    .font(AppTextStyles.h4)
                    .foregroundColor(AppColors.textDark)
                    .lineLimit(1)
                
                Text(strategy.description)
                    .font(AppTextStyles.body3)
                    .foregroundColor(AppColors.textMedium)
                    .lineLimit(2)
                    .frame(height: 40)
                
                HStack {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                    Text(strategy.timeToComplete)
                        .font(AppTextStyles.body3)
                        .foregroundColor(AppColors.textMedium)
                }
            }
        }
            .padding()
        .frame(width: 200)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
        .onTapGesture {
            // When tapped, set the selectedStrategy and show the detail
            selectedStrategy = strategy
            
            // Option to redirect to the main strategies tab if desired
            if redirectToMainTab {
                // First store the selected strategy ID in UserDefaults
                if let id = strategy.id as? String {
                    UserDefaults.standard.set(id, forKey: "selectedStrategyID")
                }
                
                // Then post notification to switch tabs and show detail
                NotificationCenter.default.post(
                    name: NSNotification.Name("ShowStrategyDetail"),
                    object: nil
                )
            } else {
                // Show in-place detail
                showingStrategyDetail = true
            }
        }
    }
    
    // Option to control whether to show detail in-place or redirect to main tab
    private var redirectToMainTab = false
    
    // Enhanced Strategy Detail View with interactive elements
    private func strategyDetailView(_ strategy: AppCopingStrategyDetail) -> some View {
        NavigationView {
        ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header Section
                    VStack(alignment: .leading, spacing: 16) {
                    HStack {
                            // Category Tag
                        Text(strategy.category.rawValue)
                                .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                                .background(strategy.category.color.opacity(0.2))
                                .foregroundColor(strategy.category.color)
                                .cornerRadius(16)
                        
                        Spacer()
                        
                            // Time to complete
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.system(size: 14))
                        Text(strategy.timeToComplete)
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(Color.gray)
                    }
                    
                    Text(strategy.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color.primary)
                    
                    Text(strategy.description)
                            .font(.system(size: 16))
                            .foregroundColor(Color.gray)
                        .fixedSize(horizontal: false, vertical: true)
                }
                    .padding(.horizontal)
                    
                    // Interactive Features
                    Group {
                        // Guided Practice Toggle
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle(isOn: $guidedModeEnabled) {
                                HStack {
                                    Image(systemName: "figure.mind.and.body")
                                        .foregroundColor(strategy.category.color)
                                    Text("Guided Practice Mode")
                                        .font(.system(size: 16, weight: .medium))
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            
                            if guidedModeEnabled {
                                Text("I'll guide you through each step of this practice with timers and prompts.")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.gray)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Specialized breathing exercise for mindfulness practices
                        if isBreathingStrategy(strategy) && !practiceInProgress {
                            breathingExerciseSection(strategy: strategy)
                                .padding(.horizontal)
                        }
                    }
                    
                    // Practice Section (Steps)
                VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Steps")
                                .font(.system(size: 20, weight: .bold))
                            Spacer()
                            if !practiceInProgress && !guidedModeEnabled {
                                startPracticeButton
                            }
                        }
                        
                        if practiceInProgress {
                            // Guided practice view with active step
                            guidedStepsView(strategy: strategy)
                        } else {
                            // Regular steps list
                            stepsListView(strategy: strategy)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Timer Section (if practice is in progress)
                    if practiceInProgress && !isBreathingExerciseActive {
                        timerSection
                            .padding(.horizontal)
                    }
                    
                    // Completion Rating (if completed)
                    if practiceCompleted {
                        completionRatingView(strategy: strategy)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 24)
            }
            .navigationBarTitle("", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if practiceInProgress {
                        Button("End Practice") {
                            withAnimation {
                                practiceInProgress = false
                                practiceCompleted = false
                                currentStep = 0
                                if timer != nil {
                                    timer?.invalidate()
                                    timer = nil
                                }
                            }
                            LocalHaptics.medium()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .onAppear {
                // Initialize mood before if needed
                if moodBefore == nil {
                    moodBefore = "Neutral"
                }
            }
            .onDisappear {
                // Clean up timer if active
                if timer != nil {
                    timer?.invalidate()
                    timer = nil
                }
            }
        }
        .environmentObject(AppCopingStrategiesLibrary.shared)
    }
    
    // MARK: - Interactive Practice State
    @State private var guidedModeEnabled = false
    @State private var moodBefore: String? = nil
    @State private var moodAfter: String? = nil
    @State private var moodIntensityBefore: Double = 5
    @State private var moodIntensityAfter: Double = 5
    @State private var practiceInProgress = false
    @State private var practiceCompleted = false
    @State private var currentStep = 0
    @State private var timer: Timer? = nil
    @State private var remainingTime: Double = 0
    @State private var effectiveness: Int? = nil
    @State private var selectedNotes: String = ""
    @State private var showingMoodCheckIn = false
    @State private var isBreathingExerciseActive = false
    @State private var breathingPhase: DashboardBreathingPhase = .inhale
    @State private var breathingCycleCount = 0
    @State private var breathingPattern: DashboardBreathingPattern = .fourSevenEight
    
    // MARK: - Helper Views and Methods
    
    // Check if a strategy is a breathing exercise
    private func isBreathingStrategy(_ strategy: AppCopingStrategyDetail) -> Bool {
        let title = strategy.title.lowercased()
        return title.contains("breath") || 
               title.contains("breathing") || 
               title.contains("meditation") ||
               (strategy.category == .mindfulness && 
                (strategy.description.lowercased().contains("breath") || 
                 strategy.steps.joined().lowercased().contains("breath")))
    }
    
    // Breathing exercise section
    private func breathingExerciseSection(strategy: AppCopingStrategyDetail) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "lungs")
                    .foregroundColor(strategy.category.color)
                Text("Breathing Exercise")
                    .font(.system(size: 18, weight: .semibold))
                Spacer()
            }
            
            Text("This strategy includes guided breathing patterns to help you practice mindful breathing.")
                                        .font(.system(size: 14))
                .foregroundColor(Color.gray)
            
            // Breathing pattern selection
            HStack {
                Text("Choose a pattern:")
                    .font(.system(size: 14, weight: .medium))
                
                Picker("Breathing Pattern", selection: $breathingPattern) {
                    ForEach(DashboardBreathingPattern.allCases, id: \.self) { pattern in
                        Text(pattern.title).tag(pattern)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Text(breathingPattern.description)
                .font(.system(size: 13))
                .foregroundColor(Color.gray)
            
            // Breathing visualization
            VStack(spacing: 12) {
                Text(getPhaseInstructionText())
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(strategy.category.color)
                
                // Breathing circle animation
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 2)
                        .frame(width: 120, height: 120)
                    
                    let duration = CGFloat(breathingPhase.duration(for: breathingPattern))
                    Circle()
                        .trim(from: 0, to: 1 - CGFloat(remainingTime) / duration)
                        .stroke(strategy.category.color, lineWidth: 4)
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear, value: remainingTime)
                    
                    // Scale the inner circle based on breath phase
                    Circle()
                        .fill(strategy.category.color.opacity(0.2))
                        .frame(
                            width: breathingPhase == DashboardBreathingPhase.inhale ? 100 : (breathingPhase == DashboardBreathingPhase.exhale ? 40 : 70),
                            height: breathingPhase == DashboardBreathingPhase.inhale ? 100 : (breathingPhase == DashboardBreathingPhase.exhale ? 40 : 70)
                        )
                        .animation(.easeInOut, value: breathingPhase)
                }
                
                Text("Cycle \(breathingCycleCount + 1) of 5")
                    .font(.system(size: 14))
                    .foregroundColor(Color.gray)
            }
            
                Button(action: {
                // Start breathing exercise
                startBreathingExercise()
            }) {
                HStack {
                    Image(systemName: "play.circle.fill")
                    Text("Start Breathing Exercise")
                }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(strategy.category.color)
                .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // Start the breathing exercise
    private func startBreathingExercise() {
        withAnimation {
            isBreathingExerciseActive = true
            practiceInProgress = true
            breathingPhase = .inhale
            breathingCycleCount = 0
            
            // Start the first phase
            startBreathingPhase()
        }
        LocalHaptics.medium()
    }
    
    // Start a breathing phase
    private func startBreathingPhase() {
        if timer != nil {
            timer?.invalidate()
        }
        
        // Set the time for the current phase
        let durationInTenths = CGFloat(breathingPhase.duration(for: breathingPattern))
        remainingTime = durationInTenths
        
        // Create a timer that fires every 0.1 seconds for smooth animation
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] _ in
            if remainingTime > 0 {
                remainingTime -= 0.1
            } else {
                moveToNextBreathingPhase()
            }
        }
    }
    
    // Move to the next breathing phase
    private func moveToNextBreathingPhase() {
        withAnimation {
            switch breathingPhase {
            case .inhale:
                breathingPhase = breathingPattern.hasHold ? .hold : .exhale
                LocalHaptics.light()
            case .hold:
                breathingPhase = .exhale
                LocalHaptics.light()
            case .exhale:
                if breathingPattern.holdAfterExhaleTime > 0 {
                    breathingPhase = .holdAfterExhale
        } else {
                    breathingPhase = .inhale
                    breathingCycleCount += 1
                    LocalHaptics.medium()
                }
                
                // End breathing exercise after a certain number of cycles
                if breathingCycleCount >= 5 {
                    completeBreathingExercise()
                    return
                }
            case .holdAfterExhale:
                // Fix placeholder
                breathingPhase = .inhale
                breathingCycleCount += 1
                LocalHaptics.medium()
                
                if breathingCycleCount >= 5 {
                    completeBreathingExercise()
                    return
                }
            case .complete:
                // Fix placeholder
                return // No action needed, already completed
            }
            
            // Start the next phase
            startBreathingPhase()
        }
    }
    
    // Complete the breathing exercise
    private func completeBreathingExercise() {
        timer?.invalidate()
        timer = nil
        
        withAnimation {
            isBreathingExerciseActive = false
            practiceCompleted = true
        }
        
        LocalHaptics.success()
    }
    
    // Guided steps view
    private func guidedStepsView(strategy: AppCopingStrategyDetail) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Progress indicator
            HStack {
                Text("Step \(currentStep + 1) of \(strategy.steps.count)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.gray)
                
                Spacer()
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(width: geometry.size.width, height: 6)
                            .opacity(0.2)
                            .foregroundColor(Color.gray)
                        
                        Rectangle()
                            .frame(width: geometry.size.width * CGFloat(currentStep + 1) / CGFloat(strategy.steps.count), height: 6)
                            .foregroundColor(strategy.category.color)
                    }
                    .cornerRadius(3)
                }
                .frame(height: 6)
                .padding(.vertical, 8)
            }
            
            if isBreathingExerciseActive {
                // Breathing visualization
                VStack(spacing: 12) {
                    Text(getPhaseInstructionText())
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(strategy.category.color)
                    
                    // Breathing circle animation
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 2)
                            .frame(width: 120, height: 120)
                        
                        let duration = CGFloat(breathingPhase.duration(for: breathingPattern))
                        Circle()
                            .trim(from: 0, to: 1 - CGFloat(remainingTime) / duration)
                            .stroke(strategy.category.color, lineWidth: 4)
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear, value: remainingTime)
                        
                        // Scale the inner circle based on breath phase
                        Circle()
                            .fill(strategy.category.color.opacity(0.2))
                            .frame(
                                width: breathingPhase == DashboardBreathingPhase.inhale ? 100 : (breathingPhase == DashboardBreathingPhase.exhale ? 40 : 70),
                                height: breathingPhase == DashboardBreathingPhase.inhale ? 100 : (breathingPhase == DashboardBreathingPhase.exhale ? 40 : 70)
                            )
                            .animation(.easeInOut, value: breathingPhase)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            } else {
                // Current step card
        VStack(alignment: .leading, spacing: 12) {
                    Text(strategy.steps[currentStep])
                        .font(.system(size: 18))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    
                    if currentStep < strategy.steps.count - 1 {
                        Button("Next Step") {
                            withAnimation {
                                currentStep += 1
                            }
                            LocalHaptics.light()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(strategy.category.color)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    } else {
                        Button("Complete Practice") {
                            withAnimation {
                                practiceCompleted = true
                                practiceInProgress = false
                            }
                            LocalHaptics.success()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(strategy.category.color)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
    
    // Regular steps list view
    private func stepsListView(strategy: AppCopingStrategyDetail) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(0..<strategy.steps.count, id: \.self) { index in
                HStack(alignment: .top) {
                    Text("\(index + 1)")
                        .font(.system(size: 14, weight: .bold))
                        .frame(width: 24, height: 24)
                        .background(strategy.category.color.opacity(0.2))
                        .foregroundColor(strategy.category.color)
                        .clipShape(Circle())
                    
                    Text(strategy.steps[index])
                        .font(.system(size: 16))
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    // Timer section for guided practice
    private var timerSection: some View {
                VStack(alignment: .leading, spacing: 16) {
            Text("Take your time")
                .font(.system(size: 18, weight: .bold))
            
            Text("Stay with this step as long as you need. When you're ready, move on to the next step.")
                .font(.system(size: 14))
                .foregroundColor(Color.gray)
            
            HStack {
                Image(systemName: "timer")
                    .font(.system(size: 14))
                Text("Time spent: \(formatTime(Int(Date().timeIntervalSince(practiceStartTime))))")
                    .font(.system(size: 14))
            }
            .foregroundColor(Color.gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // Format time in seconds to MM:SS
    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    // Completion rating view
    private func completionRatingView(strategy: AppCopingStrategyDetail) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Practice Complete!")
                .font(.system(size: 20, weight: .bold))
            
            Text("How effective was this strategy for you?")
                .font(.system(size: 16))
            
            // Star rating
            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { rating in
                    Image(systemName: rating <= (effectiveness ?? 0) ? "star.fill" : "star")
                        .font(.system(size: 32))
                        .foregroundColor(rating <= (effectiveness ?? 0) ? strategy.category.color : Color.gray.opacity(0.3))
                        .onTapGesture {
                            effectiveness = rating
                            LocalHaptics.selection()
                        }
                }
            }
            .padding(.vertical, 8)
            
            // Notes field
            TextField("Any notes about your experience? (Optional)", text: $selectedNotes)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            // Save button
            Button("Save Rating") {
                // Save rating to the store
                // In a real app, this would be persisted
                withAnimation {
                    practiceCompleted = false
                    effectiveness = nil
                    selectedNotes = ""
                }
                LocalHaptics.success()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(effectiveness == nil ? Color.gray : strategy.category.color)
                        .foregroundColor(.white)
            .cornerRadius(12)
            .disabled(effectiveness == nil)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // Start practice button
    private var startPracticeButton: some View {
        Button(action: {
            if guidedModeEnabled && moodBefore == nil {
                showingMoodCheckIn = true
            } else {
                startPractice()
            }
        }) {
            HStack {
                Image(systemName: "play.fill")
                Text("Start")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }
    
    // Start the practice session
    private func startPractice() {
        withAnimation {
            practiceInProgress = true
            practiceStartTime = Date()
        }
        LocalHaptics.medium()
    }
    
    // Mood check-in view
    private func moodCheckInView() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How are you feeling?")
                .font(.system(size: 18, weight: .bold))
            
            Text("Before we begin, let's check in with your current mood.")
                .font(.system(size: 14))
                .foregroundColor(Color.gray)
            
            // Mood input
            TextField("Describe your mood (e.g., anxious, sad)", text: Binding(
                get: { moodBefore ?? "" },
                set: { moodBefore = $0 }
            ))
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Mood intensity slider
            VStack(alignment: .leading, spacing: 8) {
                Text("Intensity:")
                    .font(.system(size: 14, weight: .medium))
                
                // Slider with color
                let sliderColor = moodIntensityColor(intensity: moodIntensityBefore)
                Slider(value: $moodIntensityBefore, in: 1...10, step: 1)
                    .accentColor(sliderColor)
                
                // Intensity labels
                        HStack {
                    Text("Mild")
                        .font(.system(size: 12))
                        .foregroundColor(Color.gray)
                    
                    Spacer()
                    
                    Text("Moderate")
                        .font(.system(size: 12))
                        .foregroundColor(Color.gray)
                    
                    Spacer()
                    
                    Text("Intense")
                        .font(.system(size: 12))
                        .foregroundColor(Color.gray)
                }
            }
            
            // Buttons
            HStack {
                Button("Skip") {
                    showingMoodCheckIn = false
                    startPractice()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.2))
                .foregroundColor(Color.primary)
                .cornerRadius(12)
                
                Button("Start Practice") {
                    showingMoodCheckIn = false
                    startPractice()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .disabled(moodBefore?.isEmpty ?? true)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 5)
    }
    
    // Get color based on mood intensity
    private func moodIntensityColor(intensity: Double) -> Color {
        let normalizedIntensity = intensity / 10.0
        if normalizedIntensity < 0.3 {
            return .green
        } else if normalizedIntensity < 0.7 {
            return .orange
        } else {
            return .red
        }
    }
    
    // Store practice start time
    @State private var practiceStartTime = Date()
    
    // MARK: - Helper Functions
    
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }
    
    // MARK: - Resources Section
    
    private var resourcesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SectionHeader(title: "Resources", icon: "book.fill")
                
                Spacer()
                
                Button(action: {
                    // Later we could implement a "View All Resources" action
                }) {
                    Text("View All")
                        .font(AppTextStyles.body3)
                        .foregroundColor(AppColors.primary)
                }
            }
                
            VStack(spacing: 12) {
                ForEach(resources) { resource in
                Button(action: {
                        // Handle resource selection
                        LocalHaptics.light()
                    }) {
                        ResourceCard(resource: resource)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
        .accessibleCard(label: "Resources", hint: "Access helpful articles, videos, and more")
    }
    
    // MARK: - Community Section
    
    private var communitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Community", icon: "person.3.fill")
            
            VStack(alignment: .leading, spacing: 16) {
                // Community updates
                Text("Recent Activity")
                .font(AppTextStyles.h4)
                .foregroundColor(AppColors.textDark)
                
                VStack(spacing: 16) {
                    // Sample community activity
                    HStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(AppColors.primary)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Charlotte shared a success story")
                .font(AppTextStyles.body2)
                                .foregroundColor(AppColors.textDark)
                            
                            Text("2 hours ago")
                                .font(AppTextStyles.captionText)
                .foregroundColor(AppColors.textMedium)
                        }
                        
                        Spacer()
                    }
                    
                    Divider()
                    
                    HStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(AppColors.accent1)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("New support group: Digital Resilience")
                                .font(AppTextStyles.body2)
                                .foregroundColor(AppColors.textDark)
                            
                            Text("1 day ago")
                                .font(AppTextStyles.captionText)
                                .foregroundColor(AppColors.textMedium)
                        }
                        
                        Spacer()
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Join community button
                Button(action: {
                    // Switch to Community tab
                    NotificationCenter.default.post(name: Notification.Name("switchToCommunityTab"), object: nil)
                }) {
                    HStack {
                        Image(systemName: "person.3")
                        Text("View Community")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
        .accessibleCard(label: "Community", hint: "Connect with others on similar journeys")
    }
    
    // Helper function to get phase instruction text
    private func getPhaseInstructionText() -> String {
        switch breathingPhase {
        case .inhale:
            return "Breathe in slowly"
        case .hold:
            return breathingPattern.hasHold ? "Hold your breath" : "Continue to exhale"
        case .exhale:
            return "Breathe out slowly"
        case .holdAfterExhale:
            return "Hold before inhaling"
        case .complete:
            return "Breathing complete"
        }
    }
    
    // Helper method to convert LocalCopingStrategyDetail to AppCopingStrategyDetail
    private func convertToAppStrategy(_ localStrategy: LocalCopingStrategyDetail) -> AppCopingStrategyDetail {
        // Find an existing AppCopingStrategyDetail with the same title if possible
        if let existingStrategy = AppCopingStrategiesLibrary.shared.strategies.first(where: { $0.title == localStrategy.title }) {
            return existingStrategy
        }
        
        // Create a new AppCopingStrategyDetail based on the local strategy
        // Note: This assumes that AppCopingStrategyDetail has a similar structure to LocalCopingStrategyDetail
        return AppCopingStrategyDetail(
            title: localStrategy.title,
            description: localStrategy.description,
            category: convertLocalToAppCategory(localStrategy.category),
            steps: localStrategy.steps,
            timeToComplete: localStrategy.timeToComplete
        )
    }
    
    // Helper method to convert LocalCopingStrategyCategory to AppCopingStrategyCategory
    private func convertLocalToAppCategory(_ localCategory: LocalCopingStrategyCategory) -> AppCopingStrategyCategory {
        switch localCategory {
        case .mindfulness: return .mindfulness
        case .cognitive: return .cognitive
        case .physical: return .physical
        case .social: return .social
        case .creative: return .creative
        case .selfCare: return .selfCare
        }
    }
}

// MARK: - Supporting Views

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(AppColors.primary)
            
            Text(title)
                .font(AppTextStyles.h3)
                .foregroundColor(AppColors.textDark)
            
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

struct StatsCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppColors.textDark)
            
            Text(label)
                .font(AppTextStyles.captionText)
                .foregroundColor(AppColors.textMedium)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .accessibleCard(label: "\(value) \(label)", hint: "Tracking your progress")
    }
}

struct ResourceCard: View {
    let resource: Resource
    
    private var typeColor: Color {
        switch resource.type {
        case .article:
            return AppColors.primary
        case .video:
            return AppColors.joy
        case .podcast:
            return AppColors.calm
        case .community:
            return AppColors.accent1
        case .collection:
            return AppColors.accent2
        case .exercise:
            return AppColors.accent3
        }
    }
    
    private var typeIcon: String {
        switch resource.type {
        case .article:
            return "doc.text"
        case .video:
            return "video"
        case .podcast:
            return "headphones"
        case .community:
            return "person.2"
        case .collection:
            return "books.vertical"
        case .exercise:
            return "figure.mind.and.body"
        }
    }
    
    private var typeLabel: String {
        switch resource.type {
        case .article:
            return "Article"
        case .video:
            return "Video"
        case .podcast:
            return "Podcast"
        case .community:
            return "Community"
        case .collection:
            return "Collection"
        case .exercise:
            return "Exercise"
        }
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // Resource icon
            Image(systemName: resource.icon)
                .font(.system(size: 24))
                .foregroundColor(typeColor)
                .frame(width: 50, height: 50)
                .background(typeColor.opacity(0.1))
                .cornerRadius(10)
            
            // Resource info
            VStack(alignment: .leading, spacing: 6) {
                Text(resource.title)
                    .font(AppTextStyles.h4)
                    .foregroundColor(AppColors.textDark)
                    .lineLimit(1)
                
                Text(resource.description)
                    .font(AppTextStyles.body2)
                    .foregroundColor(AppColors.textMedium)
                    .lineLimit(2)
                
                // Type label
                HStack(spacing: 4) {
                    Image(systemName: typeIcon)
                        .font(.system(size: 10))
                    
                    Text(typeLabel)
                        .font(AppTextStyles.captionText)
                }
                .foregroundColor(typeColor)
                .padding(.top, 2)
            }
            
            Spacer()
            
            // Arrow indicator
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(AppColors.textLight)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .accessibleCard(label: "\(typeLabel): \(resource.title)", hint: resource.description)
    }
}

// MARK: - Mood Picker View

struct MoodPickerView: View {
    @Binding var selectedMood: DashboardMood
    let onSave: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("How are you feeling?")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 16) {
                ForEach(DashboardMood.allCases) { mood in
                    MoodButton(mood: mood, isSelected: selectedMood == mood) {
                        selectedMood = mood
                    }
                }
            }
            
            Button(action: onSave) {
                Text("Save")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
    }
}

// MARK: - Strategies Overview View
struct StrategiesOverviewView: View {
    let recentlyUsedStrategies: [AppCopingStrategyDetail]
    let onStrategySelected: (AppCopingStrategyDetail) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    @State private var selectedCategory: AppCopingStrategyCategory? = nil
    @State private var selectedIntensity: StrategyIntensity? = nil
    
    enum StrategyIntensity: String, CaseIterable, Identifiable {
        case quick = "Quick Relief"
        case moderate = "Moderate Practice"
        case intensive = "In-Depth Process"
        
        var id: String { rawValue }
        
        var description: String {
            switch self {
            case .quick: return "5 minutes or less"
            case .moderate: return "5-15 minutes"
            case .intensive: return "More than 15 minutes"
            }
        }
        
        var minutes: Int {
            switch self {
            case .quick: return 5
            case .moderate: return 15
            case .intensive: return 30
            }
        }
        
        var includeUnder: Bool {
            switch self {
            case .quick, .moderate: return true
            case .intensive: return false
            }
        }
        
        var minimum: Int {
            switch self {
            case .quick: return 0
            case .moderate: return 5
            case .intensive: return 15
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Search and filter
                VStack(spacing: 12) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppColors.textMedium)
                        
                        TextField("Search strategies...", text: $searchText)
                            .font(AppTextStyles.body2)
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(AppColors.textMedium)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                    // Filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            // All categories chip
                            filterChip(
                                title: "All",
                                isSelected: selectedCategory == nil,
                                action: { selectedCategory = nil }
                            )
                            
                            // Category chips
                            ForEach(AppCopingStrategyCategory.allCases) { category in
                                filterChip(
                                    title: category.rawValue,
                                    color: category.color,
                                    isSelected: selectedCategory == category,
                                    action: {
                                        if selectedCategory == category {
                                            selectedCategory = nil
                                        } else {
                                            selectedCategory = category
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    // Intensity chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            // All intensities
                            filterChip(
                                title: "All Durations",
                                isSelected: selectedIntensity == nil,
                                action: { selectedIntensity = nil }
                            )
                            
                            // Intensity options
                            ForEach(StrategyIntensity.allCases) { intensity in
                                filterChip(
                                    title: intensity.rawValue,
                                    isSelected: selectedIntensity == intensity,
                                    action: {
                                        if selectedIntensity == intensity {
                                            selectedIntensity = nil
                                        } else {
                                            selectedIntensity = intensity
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(.horizontal)
                
                // Strategy list organized by sections
                ScrollView {
                    VStack(spacing: 24) {
                        // Recently used section
                        if !recentlyUsedStrategies.isEmpty && searchText.isEmpty {
                            strategiesSection(
                                title: "Recently Used",
                                strategies: recentlyUsedStrategies
                            )
                        }
                        
                        // Show strategies by intensity if no search/filter
                        if searchText.isEmpty && selectedCategory == nil && selectedIntensity == nil {
                            // Quick relief section
                            let quickStrategies = getStrategiesByTime(minutes: 5, includeUnder: true)
                            if !quickStrategies.isEmpty {
                                strategiesSection(
                                    title: "Quick Relief",
                                    description: "5 minutes or less",
                                    strategies: quickStrategies
                                )
                            }
                            
                            // Moderate strategies
                            let moderateStrategies = getStrategiesByTime(minutes: 15, includeUnder: true, minimum: 5)
                            if !moderateStrategies.isEmpty {
                                strategiesSection(
                                    title: "Moderate Practice",
                                    description: "5-15 minutes",
                                    strategies: moderateStrategies
                                )
                            }
                            
                            // Intensive strategies
                            let intensiveStrategies = getStrategiesByTime(minutes: 15, includeUnder: false)
                            if !intensiveStrategies.isEmpty {
                                strategiesSection(
                                    title: "In-Depth Process",
                                    description: "More than 15 minutes",
                                    strategies: intensiveStrategies
                                )
                            }
                        } else {
                            // Show filtered results
                            let filteredStrategies = getFilteredStrategies()
                            
                            if filteredStrategies.isEmpty {
                                VStack(spacing: 20) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 40))
                                        .foregroundColor(AppColors.textLight)
                                    
                                    Text("No strategies found")
                                        .font(AppTextStyles.h3)
                                        .foregroundColor(AppColors.textDark)
                                    
                                    Text("Try adjusting your search or filters")
                                        .font(AppTextStyles.body2)
                                        .foregroundColor(AppColors.textMedium)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 60)
                            } else {
                                strategiesSection(
                                    title: "Results",
                                    strategies: filteredStrategies
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Coping Strategies")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(AppColors.textDark)
                    }
                }
            }
            .background(Color(.systemGray6).ignoresSafeArea())
        }
    }
    
    // Reusable filter chip
    private func filterChip(title: String, color: Color = AppColors.primary, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(AppTextStyles.body3)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color.opacity(0.2) : Color(.systemGray5))
                .foregroundColor(isSelected ? color : AppColors.textMedium)
                .cornerRadius(16)
        }
    }
    
    // Strategies section with cards
    private func strategiesSection(title: String, description: String? = nil, strategies: [AppCopingStrategyDetail]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTextStyles.h3)
                    .foregroundColor(AppColors.textDark)
                
                if let description = description {
                    Text(description)
                        .font(AppTextStyles.body3)
                        .foregroundColor(AppColors.textMedium)
                }
            }
            
            // Strategy cards
            LazyVStack(spacing: 12) {
                ForEach(strategies) { strategy in
                    compactStrategyCard(strategy)
                        .onTapGesture {
                            onStrategySelected(strategy)
                        }
                }
            }
        }
    }
    
    // Compact strategy card for list view
    private func compactStrategyCard(_ strategy: AppCopingStrategyDetail) -> some View {
        HStack(spacing: 16) {
            // Category icon
            ZStack {
                Circle()
                    .fill(strategy.category.color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: strategy.category.iconName)
                    .font(.system(size: 20))
                    .foregroundColor(strategy.category.color)
            }
            
            // Strategy details
            VStack(alignment: .leading, spacing: 4) {
                Text(strategy.title)
                    .font(AppTextStyles.h4)
                    .foregroundColor(AppColors.textDark)
                    .lineLimit(1)
                
                Text(strategy.description)
                    .font(AppTextStyles.body3)
                    .foregroundColor(AppColors.textMedium)
                    .lineLimit(2)
                
                HStack(spacing: 12) {
                    // Time
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                        Text(strategy.timeToComplete)
                            .font(AppTextStyles.body3)
                    }
                    .foregroundColor(AppColors.textMedium)
                    
                    // Category pill
                    Text(strategy.category.rawValue)
                        .font(.system(size: 10, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(strategy.category.color.opacity(0.1))
                        .foregroundColor(strategy.category.color)
                        .cornerRadius(10)
                }
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(AppColors.textLight)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // Get strategies by time filter
    private func getStrategiesByTime(minutes: Int, includeUnder: Bool, minimum: Int = 0) -> [AppCopingStrategyDetail] {
        let allStrategies = AppCopingStrategiesLibrary.shared.strategies
        
        return allStrategies.filter { strategy in
            // Parse the timeToComplete string to get minutes
            let timeString = strategy.timeToComplete.lowercased()
            let extractedMinutes = extractMinutes(from: timeString)
            
            if includeUnder {
                return extractedMinutes <= minutes && extractedMinutes >= minimum
            } else {
                return extractedMinutes > minutes
            }
        }
    }
    
    // Extract minutes from time string
    private func extractMinutes(from timeString: String) -> Int {
        // Extract numeric values from strings like "5 minutes", "10-15 minutes"
        // For ranges, take the average or maximum
        if timeString.contains("-") {
            let components = timeString.components(separatedBy: "-")
            if components.count >= 2 {
                let firstPart = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let secondPart = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
                
                if let min = Int(firstPart.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()),
                   let max = Int(secondPart.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
                    return max // Use maximum of range
                }
            }
        }
        
        // Extract single values
        let numbers = timeString.components(separatedBy: CharacterSet.decimalDigits.inverted)
                                .joined()
        if let minutes = Int(numbers) {
            return minutes
        }
        
        // Default values based on common descriptions
        if timeString.contains("quick") || timeString.contains("brief") {
            return 5
        } else if timeString.contains("moderate") {
            return 10
        } else if timeString.contains("long") || timeString.contains("extended") {
            return 20
        }
        
        return 10 // Default assumption
    }
    
    // Get filtered strategies based on search and filters
    private func getFilteredStrategies() -> [AppCopingStrategyDetail] {
        var strategies = AppCopingStrategiesLibrary.shared.strategies
        
        // Apply category filter
        if let category = selectedCategory {
            strategies = strategies.filter { $0.category == category }
        }
        
        // Apply intensity filter
        if let intensity = selectedIntensity {
            strategies = strategies.filter { strategy in
                let minutes = extractMinutes(from: strategy.timeToComplete.lowercased())
                
                if intensity.includeUnder {
                    return minutes <= intensity.minutes && minutes >= intensity.minimum
                } else {
                    return minutes > intensity.minimum
                }
            }
        }
        
        // Apply search text filter
        if !searchText.isEmpty {
            let searchTerms = searchText.lowercased().split(separator: " ")
            strategies = strategies.filter { strategy in
                let searchableText = "\(strategy.title) \(strategy.description) \(strategy.category.rawValue)".lowercased()
                
                return searchTerms.allSatisfy { searchableText.contains($0) }
            }
        }
        
        return strategies
    }
}

// MARK: - Preview
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
} 

// Add a local function to get random coping strategies without directly calling DashboardCopy
func getRandomCopingStrategy() -> (title: String, description: String) {
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

// MARK: - Dashboard Strategies View
struct DashboardStrategiesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var strategyStore = LocalStrategyEffectivenessStore.shared
    
    @State private var strategiesLibrary = LocalCopingStrategiesLibrary.shared
    @State private var searchText = ""
    @State private var selectedCategory: LocalCopingStrategyCategory?
    @State private var showingFilterOptions = false
    @State private var selectedTimeFilter: TimeFilterOption?
    @State private var strategies: [LocalCopingStrategyDetail] = []
    
    var onStrategySelected: (LocalCopingStrategyDetail) -> Void
    
    // Initialize with an optional initial category filter
    init(initialCategory: LocalCopingStrategyCategory? = nil, onStrategySelected: @escaping (LocalCopingStrategyDetail) -> Void) {
        self.onStrategySelected = onStrategySelected
        self._selectedCategory = State(initialValue: initialCategory)
    }
    
    enum TimeFilterOption: String, CaseIterable, Identifiable {
        case quick = "Quick Relief (< 5 min)"
        case moderate = "Moderate (5-15 min)" 
        case intensive = "In-Depth (> 15 min)"
        
        var id: String { self.rawValue }
        
        var color: Color {
            switch self {
            case .quick: return .green
            case .moderate: return .blue
            case .intensive: return .purple
            }
        }
        
        var description: String {
            switch self {
            case .quick: return "Strategies that take 5 minutes or less"
            case .moderate: return "Strategies that take 5-15 minutes"
            case .intensive: return "Strategies that take more than 15 minutes"
            }
        }
        
        var iconName: String {
            switch self {
            case .quick: return "bolt"
            case .moderate: return "clock"
            case .intensive: return "hourglass"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search bar
                    searchBarView
                    
                    // Filter options
                    filterOptionsView
                    
                    // Strategy list
                    if filteredStrategies.isEmpty {
                        emptyResultsView
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredStrategies) { strategy in
                                    strategyRow(strategy)
                                        .onTapGesture {
                                            onStrategySelected(strategy)
                                        }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Coping Strategies")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                strategies = strategiesLibrary.strategies
            }
        }
    }
    
    private var searchBarView: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppColors.textLight)
            
            TextField("Search strategies...", text: $searchText)
                .font(AppTextStyles.body2)
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColors.textLight)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .padding()
    }
    
    private var filterOptionsView: some View {
        VStack(spacing: 12) {
            // Categories
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    categoryFilterButton(nil, "All")
                    
                    ForEach(LocalCopingStrategyCategory.allCases) { category in
                        categoryFilterButton(category, category.displayName)
                    }
                }
                .padding(.horizontal)
            }
            
            // Time filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    timeFilterButton(nil, "Any Duration")
                    
                    ForEach(TimeFilterOption.allCases) { option in
                        timeFilterButton(option, option.rawValue)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom)
    }
    
    private func categoryFilterButton(_ category: LocalCopingStrategyCategory?, _ title: String) -> some View {
        Button(action: {
            withAnimation {
                selectedCategory = category
            }
        }) {
            HStack {
                if let category = category {
                    Image(systemName: category.iconName)
                        .font(.system(size: 12))
                } else {
                    Image(systemName: "square.grid.2x2")
                        .font(.system(size: 12))
                }
                
                Text(title)
                    .font(AppTextStyles.body3)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(selectedCategory == category ? AppColors.primary.opacity(0.2) : AppColors.cardBackground)
                    .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
            )
            .foregroundColor(selectedCategory == category ? AppColors.primary : AppColors.textMedium)
        }
    }
    
    private func timeFilterButton(_ option: TimeFilterOption?, _ title: String) -> some View {
        Button(action: {
            withAnimation {
                selectedTimeFilter = option
            }
        }) {
            HStack {
                if let option = option {
                    Image(systemName: option.iconName)
                        .font(.system(size: 12))
                } else {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                }
                
                Text(title)
                    .font(AppTextStyles.body3)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(selectedTimeFilter == option ? AppColors.primary.opacity(0.2) : AppColors.cardBackground)
                    .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
            )
            .foregroundColor(selectedTimeFilter == option ? AppColors.primary : AppColors.textMedium)
        }
    }
    
    private func strategyRow(_ strategy: LocalCopingStrategyDetail) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                // Category icon
                ZStack {
                    Circle()
                        .fill(strategy.category.color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: strategy.category.iconName)
                        .font(.system(size: 18))
                        .foregroundColor(strategy.category.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(strategy.title)
                        .font(AppTextStyles.h4)
                        .foregroundColor(AppColors.textDark)
                    
                    Text(strategy.category.displayName)
                        .font(AppTextStyles.body3)
                        .foregroundColor(AppColors.textMedium)
                }
                
                Spacer()
                
                // Time indicator
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                    Text(strategy.timeToComplete)
                        .font(AppTextStyles.body3)
                }
                .foregroundColor(AppColors.textMedium)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textLight)
            }
            
            Text(strategy.description)
                .font(AppTextStyles.body2)
                .foregroundColor(AppColors.textMedium)
                .lineLimit(2)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
    
    private var emptyResultsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(AppColors.textLight)
            
            Text("No matching strategies found")
                .font(AppTextStyles.h3)
                .foregroundColor(AppColors.textMedium)
            
            Text("Try adjusting your filters or search term")
                .font(AppTextStyles.body2)
                .foregroundColor(AppColors.textLight)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                searchText = ""
                selectedCategory = nil
                selectedTimeFilter = nil
            }) {
                Text("Clear All Filters")
                    .font(AppTextStyles.body1)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(AppColors.primary)
                    .cornerRadius(AppLayout.cornerRadius)
            }
            .padding(.top, 10)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Filtering Logic
    
    private var filteredStrategies: [LocalCopingStrategyDetail] {
        var result = strategies
        
        // Apply category filter
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        // Apply time filter
        if let timeFilter = selectedTimeFilter {
            result = result.filter { strategy in
                let timeString = strategy.timeToComplete.lowercased()
                let extractedMinutes = extractMinutes(from: timeString)
                
                switch timeFilter {
                case .quick:
                    return extractedMinutes <= 5
                case .moderate:
                    return extractedMinutes > 5 && extractedMinutes <= 15
                case .intensive:
                    return extractedMinutes > 15
                }
            }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter { strategy in
                strategy.title.lowercased().contains(searchText.lowercased()) ||
                strategy.description.lowercased().contains(searchText.lowercased()) ||
                strategy.category.displayName.lowercased().contains(searchText.lowercased()) ||
                strategy.steps.joined().lowercased().contains(searchText.lowercased())
            }
        }
        
        return result
    }
    
    private func extractMinutes(from timeString: String) -> Int {
        // Extract numeric values from strings like "5 minutes", "10-15 minutes"
        // For ranges, take the average
        if timeString.contains("-") {
            let components = timeString.components(separatedBy: "-")
            if components.count >= 2 {
                let firstPart = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let secondPart = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
                
                if let min = Int(firstPart.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()),
                   let max = Int(secondPart.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
                    return (min + max) / 2
                }
            }
        }
        
        // Extract single values
        let numbers = timeString.components(separatedBy: CharacterSet.decimalDigits.inverted)
                                .joined()
        if let minutes = Int(numbers) {
            return minutes
        }
        
        // Default values based on common descriptions
        if timeString.contains("quick") || timeString.contains("brief") {
            return 5
        } else if timeString.contains("moderate") {
            return 10
        } else if timeString.contains("long") || timeString.contains("extended") {
            return 20
        }
        
        return 10 // Default assumption
    }
}

// Define ResillienceActivity if it doesn't exist
struct ResillienceActivity: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let iconName: String
}

