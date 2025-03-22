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

// Add text style button that was missing
extension AppTextStyles {
    static var button: Font {
        return Font.system(size: 16, weight: .medium)
    }
    
    static var caption: Font {
        return Font.system(size: 12, weight: .regular)
    }
}

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
        Resource(icon: "doc.text", title: "Understanding Digital Rejection", description: "Why online rejection hits differently", type: .article),
        Resource(icon: "person.2", title: "Community Stories", description: "How others overcame rejection", type: .community),
        Resource(icon: "books.vertical", title: "Resilience Library", description: "Curated resources for building strength", type: .collection)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppLayout.spacing) {
                // Header with greeting and mood check-in
                headerSection
                
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
                showMoodPicker = false
                announceToScreenReader("Mood saved as \(currentMood.name)")
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
                        .font(AppTextStyles.button)
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
                    .font(AppTextStyles.button)
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
                .font(AppTextStyles.caption)
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
                        .font(AppTextStyles.button)
                    
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
                        .font(AppTextStyles.caption)
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
    
    private let moodColors: [Mood: Color] = [
        .joyful: AppColors.joy,
        .content: AppColors.calm,
        .neutral: AppColors.secondary,
        .sad: AppColors.sadness,
        .frustrated: AppColors.frustration,
        .stressed: AppColors.error
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            Text("How are you feeling today?")
                .font(AppTextStyles.h3)
                .foregroundColor(AppColors.textDark)
                .padding(.top, 24)
            
            Text("Track your emotional state to build awareness")
                .font(AppTextStyles.body1)
                .foregroundColor(AppColors.textMedium)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            
            // Mood grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(Mood.allCases) { mood in
                    Button(action: {
                        selectedMood = mood
                        HapticFeedback.light()
                    }) {
                        VStack(spacing: 12) {
                            Text(mood.emoji)
                                .font(.system(size: 38))
                                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                            
                            Text(mood.name)
                                .font(AppTextStyles.body1)
                                .foregroundColor(selectedMood == mood ? moodColors[mood] : AppColors.textMedium)
                        }
                        .frame(height: 100)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                                .fill(selectedMood == mood ? moodColors[mood]!.opacity(0.1) : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                                .stroke(selectedMood == mood ? moodColors[mood]! : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                    .makeAccessible(
                        label: mood.name,
                        hint: "Select if you're feeling \(mood.name)"
                    )
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Save button
            Button(action: onSave) {
                Text("Save Mood")
                    .font(AppTextStyles.button)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppColors.primary)
                    .cornerRadius(AppLayout.cornerRadius)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Preview
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
} 