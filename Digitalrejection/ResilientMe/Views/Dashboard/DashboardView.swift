//
//  DashboardView.swift
//  ResillientMe
//
//  Created by Sayed Mohamed on 21.03.25.
//

import SwiftUI
import Foundation
import ResilientMe

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

// Haptic Feedback function if missing
enum HapticFeedback {
    static func success() {
        // Mock implementation for compilation
        // In a real app, this would use UIKit's haptic feedback
    }
    
    static func light() {
        // Mock implementation for compilation
        // In a real app, this would use UIKit's haptic feedback
    }
}

// Screen reader announcement
func announceToScreenReader(_ message: String, delay: Double = 0.1) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        // For compilation purposes, using NotificationCenter instead of UIAccessibility
        NotificationCenter.default.post(name: NSNotification.Name("UIAccessibilityAnnouncementDidFinish"), object: message)
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
    let mood: Mood
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
    @State private var currentMood: Mood = .neutral
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
    
    init() {
        let strategy = AppCopy.randomCopingStrategy()
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
                HapticFeedback.success()
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
                            HapticFeedback.light()
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
            SectionHeader(title: "Coping Strategies", icon: "brain.head.profile")
            
            VStack(alignment: .leading, spacing: 20) {
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
                
                // Recently used section
                if !recentlyUsedStrategies.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recently Used")
                            .font(AppTextStyles.h4)
                            .foregroundColor(AppColors.textDark)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(recentlyUsedStrategies) { strategy in
                                    strategyCard(strategy)
                                        .onTapGesture {
                                            selectedStrategy = strategy
                                            showingStrategyDetail = true
                                        }
                                }
                            }
                            .padding(.bottom, 8)
                        }
                    }
                }
                
                // Quick Relief section
                strategiesSection(
                    title: "Quick Relief",
                    description: "5 minutes or less",
                    strategies: getStrategiesByTime(minutes: 5, includeUnder: true)
                )
                
                // Moderate Practice section
                strategiesSection(
                    title: "Moderate Practice",
                    description: "5-15 minutes",
                    strategies: getStrategiesByTime(minutes: 15, includeUnder: true, minimum: 5)
                )
                
                // In-Depth Process section
                strategiesSection(
                    title: "In-Depth Process",
                    description: "More than 15 minutes",
                    strategies: getStrategiesByTime(minutes: 15, includeUnder: false)
                )
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
    
    func strategyCard(_ strategy: AppCopingStrategyDetail) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category and intensity pill
            HStack {
                Text(strategy.category.rawValue)
                    .font(AppTextStyles.body3)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(strategy.category.color)
                    .cornerRadius(8)
                
                Spacer()
                
                // Time indicator
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                    Text(strategy.timeToComplete)
                        .font(AppTextStyles.body3)
                }
                .foregroundColor(AppColors.textMedium)
            }
            
            // Strategy title
            Text(strategy.title)
                .font(AppTextStyles.h4)
                .foregroundColor(AppColors.textDark)
                .lineLimit(2)
                .frame(height: 48, alignment: .top)
            
            // Strategy description
            Text(strategy.description)
                .font(AppTextStyles.body3)
                .foregroundColor(AppColors.textMedium)
                .lineLimit(3)
                .frame(height: 54, alignment: .top)
        }
        .padding()
        .frame(width: 250)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
    
    func strategyDetailView(_ strategy: AppCopingStrategyDetail) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(strategy.category.rawValue)
                            .font(AppTextStyles.body2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(strategy.category.color)
                            .cornerRadius(12)
                        
                        Spacer()
                        
                        Button(action: {
                            toggleFavorite(strategy)
                        }) {
                            Image(systemName: isFavorite(strategy) ? "heart.fill" : "heart")
                                .font(.system(size: 20))
                                .foregroundColor(isFavorite(strategy) ? .red : AppColors.textMedium)
                        }
                        
                        Text(strategy.timeToComplete)
                            .font(AppTextStyles.body3)
                            .foregroundColor(AppColors.textMedium)
                    }
                    
                    Text(strategy.title)
                        .font(AppTextStyles.h3)
                        .fontWeight(.bold)
                    
                    Text(strategy.description)
                        .font(AppTextStyles.body2)
                        .foregroundColor(AppColors.textMedium)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Divider
                Divider()
                    .padding(.vertical, 8)
                
                // Steps
                VStack(alignment: .leading, spacing: 16) {
                    Text("How to Practice")
                        .font(AppTextStyles.h4)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(strategy.steps.enumerated()), id: \.element) { index, step in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1)")
                                    .font(AppTextStyles.body2)
                                    .fontWeight(.bold)
                                    .frame(width: 24, height: 24)
                                    .background(Circle().fill(strategy.category.color.opacity(0.1)))
                                    .foregroundColor(strategy.category.color)
                                
                                Text(step)
                                    .font(AppTextStyles.body2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                
                // "I've Practiced This" button
                Button(action: {
                    markStrategyAsUsed(strategy)
                    showingStrategyDetail = false
                    HapticFeedback.success()
                }) {
                    Text("I've Practiced This")
                        .font(AppTextStyles.buttonFont)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(strategy.category.color)
                        .cornerRadius(12)
                }
                .padding(.top, 24)
            }
            .padding()
        }
    }
    
    func toggleFavorite(_ strategy: AppCopingStrategyDetail) {
        if isFavorite(strategy) {
            favoriteStrategies.removeAll { $0 == strategy.id }
        } else {
            favoriteStrategies.append(strategy.id)
            HapticFeedback.light()
        }
    }
    
    func isFavorite(_ strategy: AppCopingStrategyDetail) -> Bool {
        return favoriteStrategies.contains(strategy.id)
    }
    
    func markStrategyAsUsed(_ strategy: AppCopingStrategyDetail) {
        // Remove if already in the list
        recentlyUsedStrategies.removeAll { $0.id == strategy.id }
        
        // Add to the beginning
        recentlyUsedStrategies.insert(strategy, at: 0)
        
        // Keep only most recent 5
        if recentlyUsedStrategies.count > 5 {
            recentlyUsedStrategies = Array(recentlyUsedStrategies.prefix(5))
        }
        
        // Increment rejection count if this is a rejection-related strategy
        if strategy.moodTargets.contains("rejected") {
            rejectionCount += 1
        }
    }
    
    // MARK: - Resources Section
    
    var resourcesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Resources", icon: "book")
            
            ForEach(resources) { resource in
                ResourceCard(resource: resource)
            }
        }
    }
    
    // MARK: - Community Section
    
    var communitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Community", icon: "person.3")
            
            ZStack(alignment: .bottomTrailing) {
                // Community card
                VStack(alignment: .leading, spacing: 16) {
                    Text("You're not alone")
                        .font(AppTextStyles.h3)
                        .foregroundColor(.white)
                    
                    Text("Join 4,823 others learning to process digital rejection and build resilience together.")
                        .font(AppTextStyles.body1)
                        .foregroundColor(Color.white.opacity(0.9))
                    
                    Button(action: {}) {
                        HStack {
                            Text("Join the conversation")
                            Image(systemName: "arrow.right")
                        }
                        .font(AppTextStyles.buttonFont)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .foregroundColor(AppColors.primary)
                        .cornerRadius(20)
                    }
                    .withMinTouchArea()
                    .makeAccessible(label: "Join community conversation", hint: "Connect with others in the community")
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [AppColors.primary, AppColors.accent2]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(AppLayout.cornerRadius)
                
                // Decorative images (hidden from accessibility)
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color.white.opacity(0.1))
                    .offset(x: -40, y: -20)
                    .decorativeImage()
            }
        }
    }
    
    // MARK: - Daily Tip Card
    
    var tipCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 20))
                
                Text("Daily Coping Tip")
                    .font(AppTextStyles.h3)
                    .foregroundColor(AppColors.textDark)
                
                Spacer()
                
                Button(action: {
                    // Get a new random strategy
                    let newStrategy = AppCopy.randomCopingStrategy()
                    withAnimation {
                        currentTipTitle = newStrategy.title
                        currentTipDescription = newStrategy.description
                    }
                    HapticFeedback.light()
                }) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundColor(AppColors.primary)
                        .font(.system(size: 16))
                }
                .padding(.horizontal, 8)
                
                Button(action: {
                        showingTip = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.gray.opacity(0.5))
                        .font(.system(size: 20))
                }
            }
            
            Text(currentTipTitle)
                .font(AppTextStyles.h4)
                .foregroundColor(AppColors.textDark)
                .padding(.top, 4)
            
            Text(currentTipDescription)
                .font(AppTextStyles.body2)
                .foregroundColor(AppColors.textMedium)
                .fixedSize(horizontal: false, vertical: true)
            
            // Interactive buttons
            HStack(spacing: 16) {
                Button(action: {
                    // Mark this tip as practiced
                    rejectionCount += 1
                    streakDays += 1
                    HapticFeedback.success()
                    
                    // Show confirmation
                    withAnimation {
                        showingTip = false
                    }
                }) {
                    HStack {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12))
                        Text("I've Tried This")
                            .font(AppTextStyles.body3)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppColors.primary.opacity(0.2))
                    .foregroundColor(AppColors.primary)
                    .cornerRadius(AppLayout.cornerRadius)
                }
                
                Button(action: {
                    // Switch to the strategies tab
                    NotificationCenter.default.post(name: Notification.Name("switchToStrategiesTab"), object: nil)
                }) {
                    HStack {
                        Text("Explore More")
                            .font(AppTextStyles.body3)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppColors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(AppLayout.cornerRadius)
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
        .transition(.opacity)
        .animation(.easeInOut, value: showingTip)
        .accessibleCard(label: "Daily coping tip", hint: "Tip: \(currentTipTitle). \(currentTipDescription)")
    }
    
    // MARK: - Helper Functions
    
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
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
    @Binding var selectedMood: Mood
    let onSave: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("How are you feeling?")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 16) {
                ForEach(Mood.allCases) { mood in
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

// MARK: - Preview
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
} 
