//
//  ContentView.swift
//  ResillientMe
//
//  Created by Sayed Mohamed on 21.03.25.
//

import SwiftUI

// Define MoodEntry here to avoid scope issues
struct MoodEntry: Identifiable, Equatable, Codable {
    let id: String
    let date: Date
    let mood: String
    let intensity: Int
    let note: String?
    let rejectionTrigger: String?
    let copingStrategy: String?
    
    static func == (lhs: MoodEntry, rhs: MoodEntry) -> Bool {
        return lhs.id == rhs.id
    }
}

// Forward declaration to resolve the naming conflict
struct QuickRejectionModal: View {
    @Binding var isPresented: Bool
    var onSave: ((String, String, String, Int) -> Void)?
    
    var body: some View {
        QuickRejectionModalCommon(isPresented: $isPresented, onSave: onSave)
    }
}

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showOnboarding = true // Control for onboarding flow
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showingRejectionCapture = false // For quick "add rejection" modal
    @State private var dailyAffirmation = AppCopy.randomAffirmation()
    
    // Persistent data storage for rejection entries
    @State private var rejectionEntries: [MoodEntry] = []
    
    // Observer for affirmation refresh notifications
    let affirmationRefreshObserver = NotificationCenter.default.publisher(
        for: Notification.Name("refreshAffirmation")
    )
    
    var body: some View {
        ZStack {
            // Main app content
            VStack(spacing: 0) {
                // Daily affirmation banner (collapsible)
                AffirmationBanner(affirmation: dailyAffirmation)
                
                // Tab view for main navigation
                TabView(selection: $selectedTab) {
                    DashboardView()
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                        .tag(0)
                        .makeAccessible(
                            label: "Home Dashboard", 
                            hint: "View your dashboard with resources and activities"
                        )
                    
                    JournalView()
                        .tabItem {
                            Image(systemName: "book.fill")
                            Text("Journal")
                        }
                        .tag(1)
                        .makeAccessible(
                            label: "Journal", 
                            hint: "Record your thoughts and feelings"
                        )
                    
                    MoodView()
                        .tabItem {
                            Image(systemName: "chart.bar.fill")
                            Text("Mood")
                        }
                        .tag(2)
                        .makeAccessible(
                            label: "Mood Tracker", 
                            hint: "Track your moods and emotions"
                        )
                    
                    CommunityView()
                        .tabItem {
                            Image(systemName: "person.3.fill")
                            Text("Community")
                        }
                        .tag(3)
                        .makeAccessible(
                            label: "Community", 
                            hint: "Connect with others for support"
                        )
                    
                    ProfileView()
                        .tabItem {
                            Image(systemName: "person.circle.fill")
                            Text("Profile")
                        }
                        .tag(4)
                        .makeAccessible(
                            label: "Profile", 
                            hint: "Manage your profile and settings"
                        )
                }
                .onChange(of: selectedTab) { _ in
                    AppHapticFeedback.light()
                }
            }
            
            // Quick add rejection button
            VStack(spacing: 0) {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        showingRejectionCapture = true
                        AppHapticFeedback.light()
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(AppColors.primary)
                            .cornerRadius(28)
                            .shadow(color: AppColors.primary.opacity(0.4), radius: 4, x: 0, y: 4)
                    }
                    .accessibilityLabel("Log a rejection experience")
                    .padding()
                    .padding(.bottom, 70) // Increased bottom padding to move the button up
                }
            }
            
            // Onboarding overlay (shown on first launch)
            if showOnboarding && !hasCompletedOnboarding {
                OnboardingScreenView(
                    isPresented: $showOnboarding,
                    hasCompletedOnboarding: $hasCompletedOnboarding
                )
                .transition(.opacity)
                .zIndex(100) // Ensure onboarding appears on top
            }
            
            // Quick rejection capture modal
            if showingRejectionCapture {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showingRejectionCapture = false
                            }
                        }
                    
                    QuickRejectionModal(
                        isPresented: $showingRejectionCapture,
                        onSave: { description, trigger, mood, intensity in
                            addRejectionEntry(
                                description: description,
                                trigger: trigger,
                                mood: mood,
                                intensity: intensity
                            )
                        }
                    )
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
                .transition(.opacity)
                .zIndex(90)
            }
        }
        .onAppear {
            // Check if we need to show onboarding
            showOnboarding = !hasCompletedOnboarding
            
            // Load saved rejection entries
            // In a real app, this would load from persistent storage
        }
        .onReceive(affirmationRefreshObserver) { _ in
            refreshAffirmation()
        }
    }
    
    // Refresh the daily affirmation
    private func refreshAffirmation() {
        withAnimation {
            dailyAffirmation = AppCopy.randomAffirmation()
        }
    }
    
    // Add a new rejection entry
    private func addRejectionEntry(description: String, trigger: String, mood: String, intensity: Int) {
        // Create a new mood entry for the rejection
        let newEntry = MoodEntry(
            id: UUID().uuidString,
            date: Date(),
            mood: mood,
            intensity: intensity,
            note: description,
            rejectionTrigger: trigger,
            copingStrategy: nil
        )
        
        // Add to the array
        rejectionEntries.append(newEntry)
        
        // In a real app, you would persist this to storage
        // and potentially sync with the Mood tab data
        
        // Automatically switch to the mood tab to encourage follow-up
        withAnimation {
            selectedTab = 2 // Mood tab
        }
    }
}

// MARK: - Supporting Views

// Forward reference to AffirmationBanner that is defined in a separate file
// struct AffirmationBanner: View {
//     let affirmation: String
//     @State private var isExpanded = true
//     
//     var body: some View {
//         // Implementation in Views/Common/AffirmationBanner.swift
//     }
// }

// Floating action button for quick actions
struct ActionButton: View {
    let iconName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(AppColors.primary)
                .clipShape(Circle())
                .shadow(color: AppColors.primary.opacity(0.3), radius: 5, x: 0, y: 3)
        }
        .withMinTouchArea()
    }
}

// Forward reference to QuickRejectionModalCommon that is defined in a separate file
// struct QuickRejectionModalCommon: View {
//     @Binding var isPresented: Bool
//     var onSave: ((String, String, String, Int) -> Void)?
//     
//     // Implementation in Views/Common/QuickRejectionModal_Common.swift
// }

// Onboarding view shown on first launch
// Forward reference to OnboardingScreenView that is defined in a separate file
// struct OnboardingScreenView: View {
//     @Binding var isPresented: Bool
//     @Binding var hasCompletedOnboarding: Bool
//     
//     // Implementation in Views/Common/OnboardingView.swift
// }

// Preference key for overlay positioning
struct NavigationPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
