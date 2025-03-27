//
//  DashboardView.swift
//  ResillientMe
//
//  Created by Sayed Mohamed on 21.03.25.
//

import SwiftUI
import Foundation
import UIKit

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
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

// Screen reader announcement
func announceToScreenReader(_ message: String, delay: Double = 0.1) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        UIAccessibility.post(notification: .announcement, argument: message)
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
    
    init() {
        let strategy = AppCopy.randomCopingStrategy()
        _currentTipTitle = State(initialValue: strategy.title)
        _currentTipDescription = State(initialValue: strategy.description)
    }
    
    // Sample data
    let activities = [
        Activity(icon: "brain.head.profile", title: "Emotional Awareness", description: "Identify how rejection affects your emotions"),
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
            SectionHeader(title: "Quick Activities", icon: "bolt")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(activities) { activity in
                        ActivityCard(activity: activity)
                    }
                }
                .padding(.horizontal, 4) // For shadow space
            }
        }
    }
    
    // MARK: - Resources Section
    
    private var resourcesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Resources", icon: "book")
            
            ForEach(resources) { resource in
                ResourceCard(resource: resource)
            }
        }
    }
    
    // MARK: - Community Section
    
    private var communitySection: some View {
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
    
    private var tipCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(AppColors.accent1)
                    .font(.system(size: 18))
                
                Text("Coping Strategy")
                    .font(AppTextStyles.h3)
                    .foregroundColor(AppColors.textDark)
                
                Spacer()
                
                Button(action: {
                    // Implement logic to fetch a new strategy
                    let newStrategy = AppCopy.randomCopingStrategy()
                    withAnimation {
                        currentTipTitle = newStrategy.title
                        currentTipDescription = newStrategy.description
                    }
                }) {
                    Image(systemName: "arrow.2.squarepath")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.primary)
                }
                .withMinTouchArea()
                .makeAccessible(label: "New strategy", hint: "Show another coping strategy")
                
                Button(action: {
                    withAnimation {
                        showingTip = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textMedium)
                }
                .withMinTouchArea()
                .makeAccessible(label: "Dismiss strategy", hint: "Hide this coping strategy")
            }
            
            Text(currentTipTitle)
                .font(AppTextStyles.h4)
                .foregroundColor(AppColors.textDark)
            
            Text(currentTipDescription)
                .font(AppTextStyles.body1)
                .foregroundColor(AppColors.textMedium)
            
            Button(action: {}) {
                Text("Try Now")
                    .font(AppTextStyles.buttonFont)
                    .foregroundColor(AppColors.primary)
            }
            .padding(.top, 4)
            .makeAccessible(label: "Try this strategy", hint: "Practice this coping technique now")
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .transition(.opacity)
        .animation(.easeInOut, value: currentTipTitle)
        .accessibleCard(label: "Coping Strategy: \(currentTipTitle)", hint: currentTipDescription)
    }
    
    // MARK: - Helper Functions
    
    private func formattedDate() -> String {
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

struct ActivityCard: View {
    let activity: Activity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: activity.icon)
                .font(.system(size: 20))
                .foregroundColor(AppColors.primary)
                .frame(width: 36, height: 36)
                .background(AppColors.primary.opacity(0.1))
                .cornerRadius(8)
            
            Text(activity.title)
                .font(AppTextStyles.h4)
                .foregroundColor(AppColors.textDark)
                .lineLimit(1)
            
            Text(activity.description)
                .font(AppTextStyles.body2)
                .foregroundColor(AppColors.textMedium)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            Button(action: {}) {
                HStack {
                    Text("Start")
                        .font(AppTextStyles.buttonFont)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12))
                }
                .foregroundColor(AppColors.primary)
            }
            .padding(.top, 4)
        }
        .padding()
        .frame(width: 190, height: 180)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .accessibleCard(label: activity.title, hint: activity.description)
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
