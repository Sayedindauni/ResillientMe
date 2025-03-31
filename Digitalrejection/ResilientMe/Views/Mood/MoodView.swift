import SwiftUI
import Charts // Import Charts framework for visualizations
import CoreData
import Combine

// MARK: - Local Helpers

// Add CopingStrategies class to fix missing type errors
fileprivate class CopingStrategies {
    // Static method to recommend strategies for a mood and optional trigger
    static func recommendFor(mood: String?, trigger: String? = nil) -> [String] {
        // Simple implementation that returns generic strategies
        if let mood = mood, !mood.isEmpty {
            switch mood.lowercased() {
            case "sad", "disappointed", "rejected":
                return [
                    "Practice self-compassion meditation",
                    "Write down 3 personal strengths",
                    "Reach out to a supportive friend",
                    "Take a walk in nature"
                ]
            case "anxious", "nervous", "worried":
                return [
                    "Try 4-7-8 breathing technique",
                    "Progressive muscle relaxation",
                    "Write down your worries",
                    "Listen to calming music"
                ]
            case "angry", "frustrated":
                return [
                    "Physical exercise to release tension",
                    "Journal about your feelings",
                    "Practice visualization",
                    "Take a time-out"
                ]
            default:
                return [
                    "Mindful breathing exercise",
                    "Gratitude journaling",
                    "Light physical activity",
                    "Connect with a friend"
                ]
            }
        } else {
            return [
                "Mindful breathing exercise",
                "Gratitude journaling",
                "Light physical activity",
                "Connect with a friend"
            ]
        }
    }
}

// MARK: - Local Style Definitions 
// Custom style definitions for this view only (renamed to avoid conflicts)

// Colors definitions for use in this view only
private struct MoodViewColors {
    // Primary application colors
    static let primary = Color("AppPrimary") // Blue
    static let secondary = Color(hex: "94B49F") // Sage green
    static let accent = Color(hex: "D7A9E3") // Lavender
    
    // Text colors
    static let textDark = Color(hex: "3A3A3A") // Dark gray
    static let textLight = Color(hex: "9F9F9F") // Light gray
    static let textMuted = Color(hex: "C0C0C0") // Muted gray
    static let textMedium = Color(hex: "696969") // Medium gray
    
    // Background colors
    static let background = Color(hex: "F8F7F4") // Off-white
    static let cardBackground = Color(hex: "FFFFFF") // White
    
    // Warning/Error
    static let warning = Color.red
    
    // Other colors needed for this view
    static let calm = Color(hex: "A7C5EB") // Calm blue
}

// Text style definitions for use in this view only
private struct MoodViewTextStyles {
    static let h1 = Font.system(size: 28, weight: .bold)
    static let h2 = Font.system(size: 24, weight: .bold)
    static let h3 = Font.system(size: 20, weight: .semibold)
    static let h4 = Font.system(size: 18, weight: .semibold)
    static let body1 = Font.system(size: 16, weight: .regular)
    static let body2 = Font.system(size: 14, weight: .regular)
    static let body3 = Font.system(size: 13, weight: .regular)
    static let caption = Font.system(size: 12, weight: .regular)
    static let button = Font.system(size: 16, weight: .medium)
}

// Helper extension for hex color in this file only
private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Fixed references to all accessibility extensions
extension View {
    func accessibilityCard(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
    }
}

// MARK: - Extensions and Utility Types

// Class to handle follow-up mood check notifications
private class FollowUpMoodObserver {
    private var observer: Any?
    
    func setupObserver() {
        observer = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("followUpMoodCheck"),
            object: nil,
            queue: .main
        ) { notification in
            if let userInfo = notification.userInfo,
               let originalMood = userInfo["originalMood"] as? String,
               let originalIntensity = userInfo["originalIntensity"] as? Int {
                
                // Post a new notification to handle state updates
                NotificationCenter.default.post(
                    name: NSNotification.Name("updateFollowUpMoodCheckState"),
                    object: nil,
                    userInfo: [
                        "showFollowUpMoodCheck": true,
                        "followUpOriginalMood": originalMood,
                        "followUpOriginalIntensity": originalIntensity
                    ]
                )
            }
        }
    }
    
    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

// Renamed to avoid ambiguity with the MoodEntry in AppTypes
struct MoodTrackerEntry: Identifiable, Hashable {
    let id: String
    let date: Date
    let mood: String
    let intensity: Int // 1-5
    let note: String?
    let rejectionTrigger: String? // New field to track rejection triggers
    let copingStrategy: String? // New field to track coping strategies used
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MoodTrackerEntry, rhs: MoodTrackerEntry) -> Bool {
        return lhs.id == rhs.id
    }
}

struct MoodView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var moodStore: CoreDataMoodStore
    @ObservedObject var moodAnalysisEngine: MoodAnalysisEngine
    
    // Add a computed property to safely access aiInitialized
    private var isAIInitialized: Bool {
        return moodAnalysisEngine.aiInitialized
    }
    
    // Mood entry form state
    @State private var selectedMood: String?
    @State private var customMood: String = ""
    @State private var showingCustomMoodField: Bool = false
    @State private var moodIntensity: Int = 3
    @State private var moodNote: String = ""
    @State private var isRejectionRelated: Bool = false
    @State private var rejectionTrigger: String = ""
    @State private var copingStrategy: String = ""
    
    // Navigation state
    @State private var showingHistory: Bool = false
    @State private var showingInsights: Bool = false
    @State private var selectedTimeFrame: TimeFrame = .week
    @State private var showingJournalPrompt: Bool = false
    @State private var currentJournalPromptEntry: MoodData? = nil
    @State private var showingCopingStrategies: Bool = false
    @State private var selectedCopingStrategy: String?
    @State private var showingCharts: Bool = false
    @State private var journalPrompt: String = ""
    
    // New state variables for automatic suggestion features
    @State private var previousMood: String?
    @State private var previousIntensity: Int = 0
    @State private var showingAutoSuggestedStrategies: Bool = false
    @State private var showFollowUpMoodPrompt: Bool = false
    
    // Follow-up related state variables
    @State private var showFollowUpMoodCheck: Bool = false
    @State private var followUpOriginalMood: String = ""
    @State private var followUpOriginalIntensity: Int = 0
    
    // Strategy recommendation
    @State private var suggestedStrategy: LocalCopingStrategyDetail? = nil
    @State private var showingStrategyRecommendation: Bool = false
    
    // UI feedback
    @State private var showSavedConfirmation: Bool = false
    @State private var showFeedbackMessage: Bool = false
    @State private var feedbackMessage: String = ""
    
    // Properties to store initial values
    private var initialMood: String
    private var initialIntensity: Int
    
    // Properties for coping strategies and journal prompts
    @State private var recentMoods: [String] = []
    @State private var copingStrategies: [String] = []
    @State private var recommendedStrategies: [String] = []
    @State private var recommendedCopingStrategies: [String] = []
    
    // Observer for follow-up mood checks
    private let followUpObserver = FollowUpMoodObserver()
    
    // Time frames for chart filtering
    enum TimeFrame: String, CaseIterable, Identifiable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
        
        var id: String { self.rawValue }
    }
    
    // Initializer with MoodStore
    init(context: NSManagedObjectContext, initialMood: String = "", initialIntensity: Int = 3, 
         moodAnalysisEngine: MoodAnalysisEngine) {
        self._moodStore = StateObject(wrappedValue: CoreDataMoodStore(context: context))
        self.initialMood = initialMood
        self.initialIntensity = initialIntensity
        self.moodAnalysisEngine = moodAnalysisEngine
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Main content
                ScrollView {
                    VStack(spacing: 24) {
                        // Header with app title and icon buttons
                        headerView
                        
                        // Empathetic messaging
                        if !showingHistory && !showingInsights {
                            supportiveMessageView
                            
                            // Mood entry form
                            moodSelectionView
                            
                            // Intensity slider (only if mood is selected)
                            if selectedMood != nil {
                                intensitySliderView
                                rejectionRelatedView
                                noteEntryView
                                
                                // Quick access to coping strategies
                                if isRejectionRelated {
                                    copingStrategiesButtonView
                                }
                                
                                // Save button
                                saveButtonView
                            }
                        }
                        
                        // HISTORY VIEW
                        if showingHistory {
                            historyView
                        }
                        
                        // INSIGHTS VIEW
                        if showingInsights {
                            insightsView
                        }
                    }
                    .padding(.bottom, 100) // Extra padding for bottom buttons
                }
                .overlay(
                    // Saved confirmation toast
                    savedConfirmationToast
                        .opacity(showSavedConfirmation ? 1 : 0)
                        .animation(.easeInOut, value: showSavedConfirmation)
                )
                .overlay(
                    // Feedback message toast
                    feedbackMessageToast
                        .opacity(showFeedbackMessage ? 1 : 0)
                        .animation(.easeInOut, value: showFeedbackMessage)
                )
                
                // Show auto-suggested strategies overlay when applicable
                if showingAutoSuggestedStrategies {
                    VStack {
                        Spacer()
                        autoSuggestedStrategiesView
                            .padding(.horizontal)
                            .transition(.move(edge: .bottom))
                    }
                    .zIndex(2)
                    .transition(.opacity)
                    .animation(.easeInOut, value: showingAutoSuggestedStrategies)
                    .background(
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                // Allow tapping outside to dismiss only if not showing follow-up
                                if !showFollowUpMoodPrompt {
                                    showingAutoSuggestedStrategies = false
                                    
                                    // Reset mood form completely when dismissed
                                    selectedMood = nil
                                    moodIntensity = initialIntensity
                                    
                                    // Show saved confirmation
                                    showSavedConfirmation = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        withAnimation {
                                            showSavedConfirmation = false
                                        }
                                    }
                                }
                            }
                    )
                }
            }
            .navigationTitle("Mood Tracker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        // History button
                    Button(action: {
                        showingHistory.toggle()
                            showingInsights = false
                    }) {
                        Label("History", systemImage: "clock.arrow.circlepath")
                            .labelStyle(.iconOnly)
                    }
                    .accessibilityLabel("View mood history")
                    
                        // Insights button
                    Button(action: {
                        showingInsights.toggle()
                            showingHistory = false
                    }) {
                        Label("Insights", systemImage: "chart.bar.fill")
                            .labelStyle(.iconOnly)
                    }
                    .accessibilityLabel("View mood insights")
                    }
                }
            }
            // Journal prompt sheet
            .sheet(isPresented: $showingJournalPrompt) {
                if let entry = currentJournalPromptEntry {
                    journalPromptView(entry: entry)
                }
            }
            // Coping strategies sheet
            .sheet(isPresented: $showingCopingStrategies) {
                getMoodCopingStrategiesLibraryView()
            }
            .onAppear {
                // Load initial data
                loadRecentMoods()
                
                // Setup observer for follow-up mood checks
                setupFollowUpObserver()
                
                // Initialize recommendedCopingStrategies if needed
                if selectedMood != nil && recommendedCopingStrategies.isEmpty {
                    recommendedCopingStrategies = getRecommendedStrategies()
                }
                
                // Reset form
                resetForm()
                
                // Set up notification observer for follow-up prompts
                setupFollowUpObserver()
                
                // Add observer for state updates from notifications
                NotificationCenter.default.addObserver(
                    forName: NSNotification.Name("updateFollowUpMoodCheckState"),
                    object: nil,
                    queue: .main
                ) { note in
                    if let userInfo = note.userInfo,
                       let showCheck = userInfo["showFollowUpMoodCheck"] as? Bool,
                       let originalMood = userInfo["followUpOriginalMood"] as? String,
                       let originalIntensity = userInfo["followUpOriginalIntensity"] as? Int {
                        withAnimation {
                            showFollowUpMoodCheck = showCheck
                            followUpOriginalMood = originalMood
                            followUpOriginalIntensity = originalIntensity
                        }
                    }
                }
                
                // If we have a starting mood from a deep link or notification
                if !initialMood.isEmpty {
                    selectedMood = initialMood
                    updateCopingStrategies()
                    updateJournalPrompt()
                }
            }
            .onDisappear {
                // Remove the observer when view disappears
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name("updateFollowUpMoodCheckState"), object: nil)
            }
            .onChange(of: selectedMood) { newMood in
                if let mood = newMood, !mood.isEmpty {
                    updateCopingStrategies()
                    updateJournalPrompt()
                }
            }
        }
    }
    
    // MARK: - Component Views
    
    // Header view with title and navigation buttons
    private var headerView: some View {
        HStack {
            Text("How are you feeling?")
                .font(MoodViewTextStyles.h2)
                .foregroundColor(MoodViewColors.textDark)
                .accessibilityAddTraits(.isHeader)
            
            Spacer()
        }
        .padding(.top)
    }
    
    // Supportive message view
    private var supportiveMessageView: some View {
                            Text("Your feelings matter. Track them here in a safe space.")
                                .font(MoodViewTextStyles.body2)
                                .foregroundColor(MoodViewColors.textMedium)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .accessibilityLabel("Supportive message about tracking your feelings")
                        }
                        
    // Mood selection grid view
    private var moodSelectionView: some View {
                        VStack(alignment: .leading, spacing: AppLayout.spacing) {
            Text("Select your current mood")
                                .font(MoodViewTextStyles.h3)
                                .foregroundColor(MoodViewColors.textDark)
                            
            // Recent moods section
            if !moodStore.recentMoods.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent moods")
                        .font(MoodViewTextStyles.body3)
                        .foregroundColor(MoodViewColors.textMedium)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(moodStore.recentMoods, id: \.self) { mood in
                                Button(action: {
                                    selectedMood = mood
                                    showingCustomMoodField = false
                                }) {
                                    Text(mood)
                                        .font(MoodViewTextStyles.body3)
                                        .foregroundColor(selectedMood == mood ? .white : MoodViewColors.textDark)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            selectedMood == mood ? 
                                            MoodViewColors.primary : 
                                            MoodViewColors.background
                                        )
                                        .cornerRadius(20)
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 12)
            }
            
            // Positive moods
            VStack(alignment: .leading, spacing: 8) {
                Text("Positive")
                    .font(MoodViewTextStyles.body3)
                    .foregroundColor(MoodViewColors.textMedium)
                
                moodCategoryGrid(moods: PredefinedMoods.positive)
            }
            .padding(.bottom, 12)
            
            // Negative moods
            VStack(alignment: .leading, spacing: 8) {
                Text("Negative")
                    .font(MoodViewTextStyles.body3)
                    .foregroundColor(MoodViewColors.textMedium)
                
                moodCategoryGrid(moods: PredefinedMoods.negative)
            }
            .padding(.bottom, 12)
            
            // Neutral moods
            VStack(alignment: .leading, spacing: 8) {
                Text("Neutral")
                    .font(MoodViewTextStyles.body3)
                    .foregroundColor(MoodViewColors.textMedium)
                
                moodCategoryGrid(moods: PredefinedMoods.neutral)
            }
            .padding(.bottom, 12)
            
            // Custom mood option
            Button(action: {
                showingCustomMoodField.toggle()
                if showingCustomMoodField {
                    selectedMood = nil
                }
            }) {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("Custom mood")
                }
                .font(MoodViewTextStyles.body3)
                .foregroundColor(MoodViewColors.primary)
            }
            
            if showingCustomMoodField {
                TextField("Enter your mood", text: $customMood)
                    .font(MoodViewTextStyles.body2)
                    .padding()
                    .background(MoodViewColors.background)
                    .cornerRadius(AppLayout.cornerRadius / 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppLayout.cornerRadius / 2)
                            .stroke(MoodViewColors.textLight.opacity(0.3), lineWidth: 1)
                    )
                
                Button(action: {
                    selectedMood = customMood
                }) {
                    Text("Use this mood")
                        .font(MoodViewTextStyles.body3)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(customMood.isEmpty ? MoodViewColors.textLight : MoodViewColors.primary)
                        .cornerRadius(20)
                }
                .disabled(customMood.isEmpty)
            }
                        }
                        .padding()
                        .background(MoodViewColors.cardBackground)
                        .cornerRadius(AppLayout.cornerRadius)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                            .accessibilityElement(children: .combine)
        .accessibilityLabel("Mood selection")
        .accessibilityHint("Select your current mood from the options or create a custom one")
    }
    
    // Mood grid for a specific category
    private func moodCategoryGrid(moods: [String]) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 10) {
            ForEach(moods, id: \.self) { mood in
                Button(action: {
                    selectedMood = mood
                    showingCustomMoodField = false
                }) {
                    Text(mood)
                        .font(MoodViewTextStyles.body3)
                        .foregroundColor(selectedMood == mood ? .white : MoodViewColors.textDark)
                        .frame(minWidth: 80)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(
                            selectedMood == mood ? 
                            MoodViewColors.primary : 
                            MoodViewColors.background
                        )
                        .cornerRadius(20)
                }
                .accessibilityHint("Select \(mood) as your current mood")
            }
        }
    }
    
    // Intensity slider view
    private var intensitySliderView: some View {
        VStack(alignment: .leading, spacing: AppLayout.spacing) {
            Text("How intense is this feeling?")
                .font(MoodViewTextStyles.h3)
                .foregroundColor(MoodViewColors.textDark)
            
            VStack {
                Slider(value: Binding(
                    get: { Double(moodIntensity) },
                    set: { moodIntensity = Int(round($0)) }
                ), in: 1...10, step: 1)
                .accentColor(MoodViewColors.primary)
                .onChange(of: moodIntensity) { _ in
                    // Force UI update when intensity changes
                }
                
                HStack {
                    Text("1")
                        .font(MoodViewTextStyles.body3)
                        .foregroundColor(MoodViewColors.textLight)
                    
                    Spacer()
                    
                    Text("\(moodIntensity)")
                        .font(MoodViewTextStyles.body3.bold())
                        .foregroundColor(MoodViewColors.primary)
                    
                    Spacer()
                    
                    Text("10")
                        .font(MoodViewTextStyles.body3)
                        .foregroundColor(MoodViewColors.textLight)
                }
            }
        }
        .padding()
        .background(MoodViewColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
        .accessibilityCard(label: "Mood intensity", hint: "Select how strongly you feel this emotion from 1 to 10")
    }
    
    // Rejection related view
    private var rejectionRelatedView: some View {
                                VStack(alignment: .leading, spacing: AppLayout.spacing) {
                                    Toggle(isOn: $isRejectionRelated) {
                Text("Is this related to a rejection experience?")
                                            .font(MoodViewTextStyles.h3)
                                            .foregroundColor(MoodViewColors.textDark)
                                    }
                                    .toggleStyle(SwitchToggleStyle(tint: MoodViewColors.primary))
                                    
                                    if isRejectionRelated {
                                        Text("What triggered this feeling?")
                                            .font(MoodViewTextStyles.body2)
                                            .foregroundColor(MoodViewColors.textMedium)
                                            .padding(.top, 8)
                                        
                // Social triggers
                rejectionTriggerCategoryView(
                    categoryName: "Social",
                    triggers: RejectionTriggers.social
                )
                
                // Romantic triggers
                rejectionTriggerCategoryView(
                    categoryName: "Romantic",
                    triggers: RejectionTriggers.romantic
                )
                
                // Professional triggers
                rejectionTriggerCategoryView(
                    categoryName: "Professional",
                    triggers: RejectionTriggers.professional
                )
                
                // Custom trigger input
                if !RejectionTriggers.all.contains(rejectionTrigger) && !rejectionTrigger.isEmpty {
                    HStack {
                        Text("Other:")
                            .font(MoodViewTextStyles.body3)
                            .foregroundColor(MoodViewColors.textMedium)
                        
                        TextField("Describe the trigger", text: $rejectionTrigger)
                            .font(MoodViewTextStyles.body3)
                            .padding(8)
                            .background(MoodViewColors.background)
                            .cornerRadius(AppLayout.cornerRadius / 2)
                    }
                }
                
                // Custom trigger button
                                                    Button(action: {
                    rejectionTrigger = ""
                                                    }) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add custom trigger")
                    }
                                                            .font(MoodViewTextStyles.body3)
                    .foregroundColor(MoodViewColors.primary)
                }
                .padding(.top, 8)
            }
        }
                                                .padding()
        .background(MoodViewColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
        .animation(.easeInOut, value: isRejectionRelated)
        .accessibilityCard(label: "Rejection experience", hint: "Indicate if this mood is related to rejection and track triggers")
    }
    
    // Rejection trigger category view
    private func rejectionTriggerCategoryView(categoryName: String, triggers: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(categoryName)
                .font(MoodViewTextStyles.body3)
                                            .foregroundColor(MoodViewColors.textMedium)
                                        
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 10) {
                    ForEach(triggers, id: \.self) { trigger in
                                                    Button(action: {
                            rejectionTrigger = trigger
                                                    }) {
                            Text(trigger)
                                                            .font(MoodViewTextStyles.body3)
                                .foregroundColor(rejectionTrigger == trigger ? .white : MoodViewColors.textDark)
                                                            .padding(.horizontal, 12)
                                                            .padding(.vertical, 8)
                                                            .background(
                                    rejectionTrigger == trigger ? 
                                    MoodViewColors.primary : 
                                                                MoodViewColors.background
                                                            )
                                                            .cornerRadius(20)
                                                    }
                                                }
                                            }
            }
        }
        .padding(.vertical, 4)
    }
    
    // Note entry view
    private var noteEntryView: some View {
                            VStack(alignment: .leading, spacing: AppLayout.spacing) {
                                Text("Add a note (optional)")
                                    .font(MoodViewTextStyles.h3)
                                    .foregroundColor(MoodViewColors.textDark)
                                
                                TextEditor(text: $moodNote)
                                    .frame(height: 100)
                                    .padding(8)
                                    .background(MoodViewColors.background)
                                    .cornerRadius(AppLayout.cornerRadius / 2)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: AppLayout.cornerRadius / 2)
                                                .stroke(MoodViewColors.textLight.opacity(0.3), lineWidth: 1)
                                        )
                                    
                                    // Supportive message
                                    Text("Express yourself freely. This is your private space.")
                                        .font(MoodViewTextStyles.caption)
                                        .foregroundColor(MoodViewColors.textLight)
        }
        .padding()
        .background(MoodViewColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
        .accessibilityCard(label: "Note section", hint: "Add optional notes about your feelings")
    }
    
    // Coping strategies button
    private var copingStrategiesButtonView: some View {
                                Button(action: {
            // Generate recommendations based on mood and trigger
            if let selectedMood = selectedMood {
                // Use our new library for recommendations
                let isStrongReaction = moodIntensity >= 4
                
                if isStrongReaction {
                    // For strong reactions, show full library with filtered strategies
                    showingCopingStrategies = true
                } else {
                    // For milder reactions, use basic recommendations
                    recommendedStrategies = CopingStrategies.recommendFor(
                        mood: selectedMood,
                        trigger: rejectionTrigger.isEmpty ? nil : rejectionTrigger
                    )
                    showingCopingStrategies = true
                }
            }
        }) {
            HStack {
                Image(systemName: "brain.head.profile")
                Text("Suggested Coping Strategies")
                Spacer()
                Image(systemName: "chevron.right")
            }
                                        .padding()
                                        .foregroundColor(.white)
            .background(MoodViewColors.secondary)
                                        .cornerRadius(AppLayout.cornerRadius)
                                    }
        .padding(.horizontal)
        .accessibilityLabel("View suggested coping strategies")
    }
    
    // Coping strategies sheet view
    private var copingStrategiesView: some View {
        VStack {
            // For strong emotional reactions (intensity >= 4), show the full library view
            if moodIntensity >= 4 && selectedMood != nil {
                getMoodCopingStrategiesLibraryView()
            } else {
                // For milder reactions, show the simpler recommendations
                VStack(alignment: .leading, spacing: 16) {
                    // Header section
                    copingStrategiesHeader
                    
                    // Content section
                    copingStrategiesContent
                    
                    // Journal prompt section
                    journalPromptSection
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(AppLayout.cornerRadius)
            }
        }
    }
    
    // Header for coping strategies
    private var copingStrategiesHeader: some View {
        HStack {
            Text("Recommended Coping Strategies")
                .font(MoodViewTextStyles.h4)
                .foregroundColor(MoodViewColors.textDark)
            
            Spacer()
            
            // AI indicator
            if isAIInitialized {
                HStack(spacing: 4) {
                    Image(systemName: "brain")
                        .font(.system(size: 12))
                    Text("AI")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(MoodViewColors.textLight)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(MoodViewColors.textLight.opacity(0.2))
                .cornerRadius(12)
            }
        }
    }
    
    // Content for coping strategies
    private var copingStrategiesContent: some View {
        Group {
            if copingStrategies.isEmpty {
                Text("Select a mood to see personalized coping strategies.")
                    .font(MoodViewTextStyles.body1)
                    .foregroundColor(MoodViewColors.textMedium)
                    .padding(.vertical, 8)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(copingStrategies, id: \.self) { strategy in
                            copingStrategyCard(strategy)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
    }
    
    // Individual coping strategy card
    private func copingStrategyCard(_ strategy: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(strategy)
                .font(MoodViewTextStyles.body1)
                .foregroundColor(MoodViewColors.textDark)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            Button(action: {
                selectedCopingStrategy = strategy
            }) {
                Text("Try This")
                    .font(MoodViewTextStyles.caption)
                    .foregroundColor(MoodViewColors.primary)
            }
        }
        .frame(width: 200, height: 120)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                .fill(MoodViewColors.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                .stroke(selectedCopingStrategy == strategy ? MoodViewColors.primary : Color.clear, lineWidth: 2)
        )
    }
    
    // Journal prompt section
    private var journalPromptSection: some View {
        Group {
            if let selectedMood = selectedMood, !selectedMood.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text(journalPrompt)
                        .font(MoodViewTextStyles.body1)
                        .foregroundColor(MoodViewColors.textDark)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                        .background(MoodViewColors.cardBackground)
                        .cornerRadius(AppLayout.cornerRadius)
                    
                    // Journal button
                    Button(action: {
                        // In a real app, navigate to journal
                        NotificationCenter.default.post(
                            name: Notification.Name("openJournalWithPrompt"), 
                            object: nil,
                            userInfo: ["prompt": journalPrompt, "mood": selectedMood, "intensity": moodIntensity]
                        )
                    }) {
                        HStack {
                            Image(systemName: "square.and.pencil")
                            Text("Journal with this prompt")
                        }
                        .font(MoodViewTextStyles.button)
                        .foregroundColor(MoodViewColors.primary)
                        .padding(.top, 4)
                    }
                }
            }
        }
    }
    
    // Enhanced Journal prompt view for a specific entry
    private func journalPromptView(entry: MoodData) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Reflective Prompt")
                    .font(MoodViewTextStyles.h4)
                    .foregroundColor(MoodViewColors.textDark)
                
                Spacer()
                
                // AI indicator
                if isAIInitialized {
                    HStack(spacing: 4) {
                        Image(systemName: "brain")
                            .font(.system(size: 12))
                        Text("AI")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(MoodViewColors.textLight)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(MoodViewColors.textLight.opacity(0.2))
                    .cornerRadius(12)
                }
            }
            
            if let mood = selectedMood, mood.isEmpty {
                Text("Select a mood to see a personalized journal prompt.")
                    .font(MoodViewTextStyles.body1)
                    .foregroundColor(MoodViewColors.textMedium)
                    .padding(.vertical, 8)
            } else {
                Text(journalPrompt)
                    .font(MoodViewTextStyles.body1)
                    .foregroundColor(MoodViewColors.textDark)
                    .fixedSize(horizontal: false, vertical: true)
                                .padding()
                                .background(MoodViewColors.cardBackground)
                                .cornerRadius(AppLayout.cornerRadius)
            }
            
            if let selectedMood = selectedMood, !selectedMood.isEmpty {
                Button(action: {
                    // In a real app, navigate to journal
                    NotificationCenter.default.post(
                        name: Notification.Name("openJournalWithPrompt"), 
                        object: nil,
                        userInfo: ["prompt": journalPrompt, "mood": selectedMood, "intensity": moodIntensity]
                    )
                }) {
                    HStack {
                        Image(systemName: "square.and.pencil")
                        Text("Journal with this prompt")
                    }
                    .font(MoodViewTextStyles.button)
                    .foregroundColor(MoodViewColors.primary)
                    .padding(.top, 4)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    // History view
    private var historyView: some View {
                            VStack(alignment: .leading, spacing: AppLayout.spacing) {
                                HStack {
                                    Text("Your Mood History")
                                        .font(MoodViewTextStyles.h3)
                                        .foregroundColor(MoodViewColors.textDark)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        showingHistory = false
                                    }) {
                                        Text("Close")
                                            .font(MoodViewTextStyles.body3)
                                            .foregroundColor(MoodViewColors.primary)
                                    }
                                }
                                
                                Divider()
                                    .background(MoodViewColors.textLight.opacity(0.3))
                                
            // Time frame selection
            Picker("Time Frame", selection: $selectedTimeFrame) {
                ForEach(TimeFrame.allCases) { timeFrame in
                    Text(timeFrame.rawValue).tag(timeFrame)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.vertical, 8)
            
            if let legacyEntries = getLegacyMoodEntries(), !legacyEntries.isEmpty {
                ForEach(legacyEntries.filter { entry in
                    switch selectedTimeFrame {
                    case .day:
                        return Calendar.current.isDateInToday(entry.date)
                    case .week:
                        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
                        return entry.date >= oneWeekAgo
                    case .month:
                        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
                        return entry.date >= oneMonthAgo
                    }
                }.sorted(by: { $0.date > $1.date })) { entry in
                                    moodHistoryCard(entry)
                }
            } else {
                emptyHistoryView
            }
        }
        .padding()
        .background(MoodViewColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
        .accessibilityCard(label: "Mood history", hint: "View your past mood entries")
    }
    
    // Empty history view
    private var emptyHistoryView: some View {
                                    VStack(spacing: 16) {
                                        Image(systemName: "calendar.badge.clock")
                                            .font(.system(size: 40))
                                            .foregroundColor(MoodViewColors.textLight)
                                        
                                        Text("No mood entries yet")
                                            .font(MoodViewTextStyles.h4)
                                            .foregroundColor(MoodViewColors.textDark)
                                        
                                        Text("Start tracking your moods to see your history here")
                                            .font(MoodViewTextStyles.body3)
                                            .foregroundColor(MoodViewColors.textMedium)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 40)
    }
    
    // Single mood history card
    private func moodHistoryCard(_ entry: MoodTrackerEntry) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(entry.mood)
                    .font(MoodViewTextStyles.h4)
                    .foregroundColor(colorForMood(entry.mood))
                
                Spacer()
                
                Text(formattedDate(entry.date))
                    .font(MoodViewTextStyles.body3)
                    .foregroundColor(MoodViewColors.textMedium)
            }
            
            HStack {
                Text("Intensity:")
                    .font(MoodViewTextStyles.body3)
                    .foregroundColor(MoodViewColors.textMedium)
                
                // Intensity indicator
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { i in
                        Circle()
                            .fill(i <= entry.intensity ? colorForMood(entry.mood) : MoodViewColors.textLight.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                
                Spacer()
                
                if entry.rejectionTrigger != nil {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(MoodViewColors.warning)
                        .font(.system(size: 14))
                    
                    Text("Rejection")
                        .font(MoodViewTextStyles.caption)
                        .foregroundColor(MoodViewColors.warning)
                }
            }
            
            if let note = entry.note, !note.isEmpty {
                Text(note)
                    .font(MoodViewTextStyles.body3)
                    .foregroundColor(MoodViewColors.textDark)
                    .lineLimit(3)
                    .padding(.top, 4)
            }
            
            if let trigger = entry.rejectionTrigger {
                HStack {
                    Text("Trigger:")
                        .font(MoodViewTextStyles.caption)
                        .foregroundColor(MoodViewColors.textMedium)
                    
                    Text(trigger)
                        .font(MoodViewTextStyles.caption)
                        .foregroundColor(MoodViewColors.textDark)
                }
                .padding(.top, 2)
            }
            
            if let strategy = entry.copingStrategy {
                HStack {
                    Text("Coping:")
                        .font(MoodViewTextStyles.caption)
                        .foregroundColor(MoodViewColors.textMedium)
                    
                    Text(strategy)
                        .font(MoodViewTextStyles.caption)
                        .foregroundColor(MoodViewColors.textDark)
                }
                .padding(.top, 2)
                                }
                            }
                            .padding()
        .background(MoodViewColors.background)
        .cornerRadius(AppLayout.cornerRadius / 2)
        .padding(.vertical, 4)
    }
    
    // Insights view
    private var insightsView: some View {
                            VStack(alignment: .leading, spacing: AppLayout.spacing) {
                                HStack {
                                    Text("Mood Insights")
                                    .font(MoodViewTextStyles.h3)
                                    .foregroundColor(MoodViewColors.textDark)
                                
                                    Spacer()
                                    
                                    Button(action: {
                                        showingInsights = false
                                    }) {
                                        Text("Close")
                                            .font(MoodViewTextStyles.body3)
                                            .foregroundColor(MoodViewColors.primary)
                                    }
                                }
                                
                                // Time frame selection
                                Picker("Time Frame", selection: $selectedTimeFrame) {
                                    ForEach(TimeFrame.allCases) { timeFrame in
                                        Text(timeFrame.rawValue).tag(timeFrame)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .padding(.vertical, 8)
                                
            // Mood distribution chart
            moodDistributionView
            
            // Rejection triggers analysis
            rejectionTriggersView
            
            // Coping strategies effectiveness
            copingStrategiesEffectivenessView
            
            // Average mood intensity
            averageMoodIntensityView
        }
        .padding()
        .background(MoodViewColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
        .accessibilityCard(label: "Mood insights", hint: "View analytics about your mood patterns")
    }
    
    // Mood distribution analysis
    private var moodDistributionView: some View {
                                VStack(alignment: .leading, spacing: 8) {
            Text("Mood Distribution")
                                        .font(MoodViewTextStyles.h4)
                                        .foregroundColor(MoodViewColors.textDark)
                                    
            let distribution = moodStore.getMoodDistribution(timeframe: selectedTimeFrame)
            
            if distribution.isEmpty {
                Text("No data for this time period")
                    .font(MoodViewTextStyles.body3)
                    .foregroundColor(MoodViewColors.textMedium)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(MoodViewColors.background)
                    .cornerRadius(AppLayout.cornerRadius / 2)
            } else {
                VStack(spacing: 12) {
                    ForEach(distribution.sorted(by: { $0.value > $1.value }), id: \.key) { category, count in
                        HStack {
                            Text(category)
                                .font(MoodViewTextStyles.body2)
                                .foregroundColor(MoodViewColors.textDark)
                            
                            Spacer()
                            
                            // Progress bar
                            GeometryReader { geometry in
                                let maxCount = distribution.values.max() ?? 1
                                let width = geometry.size.width * CGFloat(count) / CGFloat(maxCount)
                                
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(MoodViewColors.textLight.opacity(0.2))
                                        .frame(width: geometry.size.width, height: 10)
                                        .cornerRadius(5)
                                    
                                    Rectangle()
                                        .fill(colorForCategory(category))
                                        .frame(width: width, height: 10)
                                        .cornerRadius(5)
                                }
                            }
                            .frame(height: 10)
                            .frame(width: 100)
                            
                            Text("\(count)")
                                            .font(MoodViewTextStyles.body3)
                                            .foregroundColor(MoodViewColors.textMedium)
                                .frame(width: 30, alignment: .trailing)
                        }
                        .padding()
                                            .background(MoodViewColors.background)
                                            .cornerRadius(AppLayout.cornerRadius / 2)
                    }
                }
                                    }
                                }
                                .padding(.vertical, 8)
    }
                                
                                // Rejection triggers analysis
    private var rejectionTriggersView: some View {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Common Rejection Triggers")
                                        .font(MoodViewTextStyles.h4)
                                        .foregroundColor(MoodViewColors.textDark)
                                    
            let triggerDistribution = moodStore.getRejectionTriggerDistribution(timeframe: selectedTimeFrame)
                                    
            if triggerDistribution.isEmpty {
                                        Text("No rejection-related entries in this time period")
                                            .font(MoodViewTextStyles.body3)
                                            .foregroundColor(MoodViewColors.textMedium)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(MoodViewColors.background)
                                            .cornerRadius(AppLayout.cornerRadius / 2)
                                    } else {
                                        VStack(spacing: 12) {
                    ForEach(triggerDistribution.sorted(by: { $0.value > $1.value }).prefix(3), id: \.key) { category, count in
                                                HStack {
                            Text(category)
                                                        .font(MoodViewTextStyles.body2)
                                                        .foregroundColor(MoodViewColors.textDark)
                                                    
                                                    Spacer()
                                                    
                                                    Text("\(count) time\(count == 1 ? "" : "s")")
                                                        .font(MoodViewTextStyles.body3)
                                                        .foregroundColor(MoodViewColors.textMedium)
                                                }
                                                .padding()
                                                .background(MoodViewColors.background)
                                                .cornerRadius(AppLayout.cornerRadius / 2)
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical, 8)
    }
                                
                                // Coping strategies effectiveness
    private var copingStrategiesEffectivenessView: some View {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Effective Coping Strategies")
                                        .font(MoodViewTextStyles.h4)
                                        .foregroundColor(MoodViewColors.textDark)
                                    
            let strategyCounts = moodStore.getEffectiveCopingStrategies(timeframe: selectedTimeFrame)
                                    
            if strategyCounts.isEmpty {
                                        Text("No coping strategies recorded in this time period")
                                            .font(MoodViewTextStyles.body3)
                                            .foregroundColor(MoodViewColors.textMedium)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(MoodViewColors.background)
                                            .cornerRadius(AppLayout.cornerRadius / 2)
                                    } else {
                                        VStack(spacing: 12) {
                                            ForEach(strategyCounts.sorted(by: { $0.value > $1.value }).prefix(3), id: \.key) { strategy, count in
                                                HStack {
                                                    Text(strategy)
                                                        .font(MoodViewTextStyles.body2)
                                                        .foregroundColor(MoodViewColors.textDark)
                                                    
                                                    Spacer()
                                                    
                                                    Text("\(count) time\(count == 1 ? "" : "s")")
                                                        .font(MoodViewTextStyles.body3)
                                                        .foregroundColor(MoodViewColors.textMedium)
                                                }
                                                .padding()
                                                .background(MoodViewColors.background)
                                                .cornerRadius(AppLayout.cornerRadius / 2)
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical, 8)
    }
                                
    // Average mood intensity
    private var averageMoodIntensityView: some View {
                                VStack(alignment: .leading, spacing: 8) {
            Text("Average Mood Intensity")
                                        .font(MoodViewTextStyles.h4)
                                        .foregroundColor(MoodViewColors.textDark)
                                    
            let average = moodStore.getAverageIntensity(timeframe: selectedTimeFrame)
                                    
            if average == 0 {
                Text("No data for this time period")
                    .font(MoodViewTextStyles.body3)
                                        .foregroundColor(MoodViewColors.textMedium)
                                        .padding()
                    .frame(maxWidth: .infinity)
                                        .background(MoodViewColors.background)
                                        .cornerRadius(AppLayout.cornerRadius / 2)
            } else {
                HStack(spacing: 20) {
                    // Circular progress indicator
                    ZStack {
                        Circle()
                            .stroke(
                                MoodViewColors.textLight.opacity(0.2),
                                lineWidth: 10
                            )
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(average) / 5.0)
                            .stroke(
                                MoodViewColors.primary,
                                style: StrokeStyle(
                                    lineWidth: 10,
                                    lineCap: .round
                                )
                            )
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-90))
                        
                        Text(String(format: "%.1f", average))
                            .font(MoodViewTextStyles.h3)
                    .foregroundColor(MoodViewColors.textDark)
                    }
            
            VStack(alignment: .leading, spacing: 4) {
                        Text("Out of 5")
                    .font(MoodViewTextStyles.body3)
                    .foregroundColor(MoodViewColors.textMedium)
                        
                        // Interpretation
                        Text(intensityInterpretation(average))
                    .font(MoodViewTextStyles.body3)
                            .foregroundColor(MoodViewColors.textDark)
                    }
                }
                .padding()
                .background(MoodViewColors.background)
                .cornerRadius(AppLayout.cornerRadius / 2)
            }
        }
        .padding(.vertical, 8)
    }
    
    // Save button view
    private var saveButtonView: some View {
        Button(action: {
            saveMood()
        }) {
            Text("Save Mood")
                .font(MoodViewTextStyles.h4)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
        .padding()
                .background(MoodViewColors.primary)
        .cornerRadius(AppLayout.cornerRadius)
        }
        .padding(.horizontal)
        .disabled(selectedMood == nil)
        .opacity(selectedMood == nil ? 0.6 : 1)
        .accessibilityHint("Saves your current mood entry")
    }
    
    // MARK: - Helper Methods
    
    // Save mood entry
    private func saveMood() {
        guard let selectedMood = selectedMood else { return }
        
        let isCustomMood = !PredefinedMoods.all.contains(selectedMood)
        
        // Store the current mood data for follow-up comparison
        previousMood = selectedMood
        previousIntensity = moodIntensity
        
        let entry = MoodData(
            id: UUID().uuidString,
            date: Date(),
            mood: selectedMood,
            customMood: isCustomMood ? selectedMood : nil,
            intensity: moodIntensity,
            note: moodNote.isEmpty ? nil : moodNote,
            rejectionRelated: isRejectionRelated,
            rejectionTrigger: isRejectionRelated && !rejectionTrigger.isEmpty ? rejectionTrigger : nil,
            copingStrategy: !copingStrategy.isEmpty ? copingStrategy : nil,
            journalPromptShown: false,
            recommendedCopingStrategies: isRejectionRelated ? 
                CopingStrategies.recommendFor(mood: selectedMood, trigger: rejectionTrigger.isEmpty ? nil : rejectionTrigger) : 
                nil
        )
        
        moodStore.saveMoodEntry(entry: entry)
        
        // Get coping strategies recommendation immediately
        if moodIntensity > 3 || isRejectionRelated {
            recommendedStrategies = CopingStrategies.recommendFor(
                mood: selectedMood,
                trigger: isRejectionRelated && !rejectionTrigger.isEmpty ? rejectionTrigger : nil
            )
            // Automatically show the suggested strategies
            showingAutoSuggestedStrategies = true
        }
        
        // Reset form but keep the selectedMood and intensity for potential follow-up
        self.customMood = ""
        self.showingCustomMoodField = false
        self.moodNote = ""
        self.isRejectionRelated = false
        self.rejectionTrigger = ""
        self.copingStrategy = ""
        self.journalPrompt = ""
        
        // Provide haptic feedback for mood logging completion
    }
    
    // Format date for display
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // Get color for mood category
    private func colorForCategory(_ category: String) -> Color {
        switch category {
        case "Positive":
            return Color.green
        case "Negative":
            return Color.red
        case "Neutral":
            return Color.blue
        case "Social", "Romantic":
            return Color.purple
        case "Professional", "Academic":
            return Color.orange
        case "Family":
            return Color.yellow
        default:
            return MoodViewColors.primary
        }
    }
    
    // Get color for specific mood
    private func colorForMood(_ mood: String) -> Color {
        if PredefinedMoods.positive.contains(mood) {
            return Color.green
        } else if PredefinedMoods.negative.contains(mood) {
            return Color.red
        } else {
            return Color.blue
        }
    }
    
    // Get interpretation for average intensity
    private func intensityInterpretation(_ average: Double) -> String {
        switch average {
        case 0..<2:
            return "Generally mild emotional responses"
        case 2..<3.5:
            return "Moderately intense emotions"
        case 3.5...:
            return "Strong emotional responses"
        default:
            return "Unknown intensity level"
        }
    }
    
    // Check for journal prompts that should be shown
    private func checkForJournalPrompts() {
        let entriesNeedingPrompts = moodStore.getEntriesNeedingJournalPrompts()
        
        // If there are entries that need prompting, show the first one
        if let entry = entriesNeedingPrompts.first {
            self.currentJournalPromptEntry = entry
            
            // Slight delay to allow view to finish appearing
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showingJournalPrompt = true
            }
        }
    }
    
    // Convert MoodData to legacy MoodTrackerEntry for compatibility
    private func getLegacyMoodEntries() -> [MoodTrackerEntry]? {
        return moodStore.moodEntries.map { entry in
            MoodTrackerEntry(
                id: entry.id,
                date: entry.date,
                mood: entry.mood,
                intensity: entry.intensity,
                note: entry.note,
                rejectionTrigger: entry.rejectionTrigger,
                copingStrategy: entry.copingStrategy
            )
        }
    }
    
    // Update coping strategies
    private func updateCopingStrategies() {
        guard let selectedMood = selectedMood, !selectedMood.isEmpty else {
            copingStrategies = []
            return
        }
        
        // Detect strong emotional reactions
        let isStrongReaction = moodIntensity >= 4
        
        if isStrongReaction {
            // For strong reactions, get strategies from our library
            let libraryStrategies = LocalCopingStrategiesLibrary.shared.recommendStrategies(
                for: selectedMood ?? "",
                intensity: moodIntensity,
                trigger: isRejectionRelated ? rejectionTrigger : nil
            )
            
            // Convert to simple string format for backward compatibility
            copingStrategies = LocalCopingStrategiesLibrary.getSimpleStrategyStrings(from: libraryStrategies)
        } else {
            // For milder reactions, use fallback strategies
            copingStrategies = CopingStrategies.recommendFor(
                mood: selectedMood,
                trigger: isRejectionRelated ? rejectionTrigger : nil
            )
        }
        
        // Clear any previously selected strategy
        selectedCopingStrategy = nil
    }
    
    // Update journal prompt
    private func updateJournalPrompt() {
        guard let selectedMood = selectedMood, !selectedMood.isEmpty else {
            journalPrompt = ""
            return
        }
        
        // Fallback to static prompt if no AI service available
        journalPrompt = "How has feeling \(selectedMood) affected your thoughts and actions today? What can you learn from this experience?"
    }
    
    // Reset the form to default values
    private func resetForm() {
        selectedMood = nil
        customMood = ""
        showingCustomMoodField = false
        moodIntensity = initialIntensity
        moodNote = ""
        isRejectionRelated = false
        rejectionTrigger = ""
        copingStrategy = ""
        journalPrompt = ""
        copingStrategies = []
        selectedCopingStrategy = nil
    }
    
    // MARK: - Auto-Suggested Strategies View
    
    private var autoSuggestedStrategiesView: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 22))
                
                Text("Suggested Coping Strategies")
                    .font(MoodViewTextStyles.h3)
                    .foregroundColor(MoodViewColors.textDark)
                
                Spacer()
                
                Button(action: {
                    showingAutoSuggestedStrategies = false
                    // Reset the mood form completely if user dismisses suggestions
                    selectedMood = nil
                    moodIntensity = initialIntensity
                    showSavedConfirmation = true
                    // Hide toast after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showSavedConfirmation = false
                        }
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.gray.opacity(0.7))
                        .font(.system(size: 24))
                }
            }
            .padding(.bottom, 5)
            
            // Current mood indicator with a visual indicator
            if let mood = selectedMood {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Mood")
                            .font(MoodViewTextStyles.body3)
                            .foregroundColor(MoodViewColors.textLight)
                        
                        Text(mood)
                            .font(MoodViewTextStyles.body1.bold())
                            .foregroundColor(MoodViewColors.textDark)
                    }
                    
                    Divider()
                        .frame(height: 30)
                        .padding(.horizontal, 5)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Intensity")
                            .font(MoodViewTextStyles.body3)
                            .foregroundColor(MoodViewColors.textLight)
                        
                        HStack(spacing: 5) {
                            Text("\(moodIntensity)")
                                .font(MoodViewTextStyles.body1.bold())
                                .foregroundColor(moodIntensity > 7 ? .red : (moodIntensity > 4 ? .orange : .green))
                            
                            Text("/ 10")
                                .font(MoodViewTextStyles.body3)
                                .foregroundColor(MoodViewColors.textLight)
                        }
                    }
                }
                .padding(12)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.bottom, 8)
            }
            
            // Strategy cards section
            if recommendedStrategies.isEmpty {
                Text("No specific strategies found for this mood.")
                    .font(MoodViewTextStyles.body2)
                    .foregroundColor(MoodViewColors.textMedium)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 30)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(AppLayout.cornerRadius)
            } else {
                Text("These strategies might help you feel better right now:")
                    .font(MoodViewTextStyles.body2)
                    .foregroundColor(MoodViewColors.textDark)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(recommendedStrategies, id: \.self) { strategy in
                            autoSuggestedStrategyCard(strategy)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .frame(height: 180)
            }
            
            // Follow-up prompt (only shown after a strategy is selected)
            if showFollowUpMoodPrompt, let previousMood = previousMood {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .foregroundColor(MoodViewColors.primary)
                            .font(.system(size: 18))
                        
                        Text("How are you feeling now?")
                            .font(MoodViewTextStyles.h4)
                            .foregroundColor(MoodViewColors.textDark)
                    }
                    
                    Text("Record your current mood intensity to track the effectiveness of the strategy:")
                        .font(MoodViewTextStyles.body2)
                        .foregroundColor(MoodViewColors.textMedium)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Slider for follow-up mood intensity
                    VStack(spacing: 8) {
                        // Visual comparison from before to after
                        HStack(spacing: 0) {
                            Text("Before: ")
                                .font(MoodViewTextStyles.body3)
                                .foregroundColor(MoodViewColors.textMedium)
                            
                            Text("\(previousIntensity)")
                                .font(MoodViewTextStyles.body2.bold())
                                .foregroundColor(previousIntensity > 7 ? .red : (previousIntensity > 4 ? .orange : .green))
                            
                            Spacer()
                            
                            Text("Now: ")
                                .font(MoodViewTextStyles.body3)
                                .foregroundColor(MoodViewColors.textMedium)
                            
                            Text("\(moodIntensity)")
                                .font(MoodViewTextStyles.body2.bold())
                                .foregroundColor(moodIntensity > 7 ? .red : (moodIntensity > 4 ? .orange : .green))
                        }
                        .padding(.horizontal, 4)
                        
                        Slider(value: Binding(
                            get: { Double(moodIntensity) },
                            set: { moodIntensity = Int(round($0)) }
                        ), in: 1...10, step: 1)
                        .accentColor(moodIntensity > 7 ? .red : (moodIntensity > 4 ? .orange : .green))
                        .onChange(of: moodIntensity) { _ in
                            // Force UI update when intensity changes
                        }
                        
                        HStack {
                            Text("1")
                                .font(MoodViewTextStyles.caption)
                                .foregroundColor(MoodViewColors.textLight)
                            
                            Spacer()
                            
                            ForEach([2, 3, 4, 5, 6, 7, 8, 9], id: \.self) { value in
                                Capsule()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 1, height: 8)
                                Spacer()
                            }
                            
                            Text("10")
                                .font(MoodViewTextStyles.caption)
                                .foregroundColor(MoodViewColors.textLight)
                        }
                    }
                    .padding(.vertical, 8)
                    
                    // Save follow-up mood button
                    Button(action: saveFollowUpMood) {
                        HStack {
                            Text("Log Follow-up Mood")
                                .font(MoodViewTextStyles.button)
                            
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(MoodViewColors.primary)
                        .cornerRadius(AppLayout.cornerRadius)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(AppLayout.cornerRadius)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    // Individual auto-suggested coping strategy card
    private func autoSuggestedStrategyCard(_ strategy: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                // Strategy icon based on content
                Image(systemName: strategyIcon(for: strategy))
                    .font(.system(size: 20))
                    .foregroundColor(MoodViewColors.primary)
                    .frame(width: 28, height: 28)
                    .padding(8)
                    .background(MoodViewColors.primary.opacity(0.1))
                    .cornerRadius(8)
                
                Text(strategy)
                    .font(MoodViewTextStyles.body1)
                    .foregroundColor(MoodViewColors.textDark)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            Button(action: {
                selectedCopingStrategy = strategy
                copingStrategy = strategy
                showFollowUpMoodPrompt = true
            }) {
                HStack {
                    Text("Try This")
                        .font(MoodViewTextStyles.body3.bold())
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12))
                }
                .foregroundColor(MoodViewColors.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(MoodViewColors.primary.opacity(0.1))
                .cornerRadius(AppLayout.cornerRadius)
            }
        }
        .frame(width: 200, height: 150)
        .padding()
        .background(MoodViewColors.cardBackground)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(selectedCopingStrategy == strategy ? MoodViewColors.primary : Color.clear, lineWidth: 2)
        )
    }
    
    // Get an appropriate icon for a strategy based on its content
    private func strategyIcon(for strategy: String) -> String {
        let lowercaseStrategy = strategy.lowercased()
        
        if lowercaseStrategy.contains("breath") || lowercaseStrategy.contains("deep") {
            return "lungs.fill"
        } else if lowercaseStrategy.contains("grounding") || lowercaseStrategy.contains("5-4-3-2-1") {
            return "hands.sparkles.fill"
        } else if lowercaseStrategy.contains("journal") || lowercaseStrategy.contains("write") {
            return "square.and.pencil"
        } else if lowercaseStrategy.contains("meditation") || lowercaseStrategy.contains("mindful") {
            return "brain.head.profile"
        } else if lowercaseStrategy.contains("exercise") || lowercaseStrategy.contains("walk") {
            return "figure.walk"
        } else if lowercaseStrategy.contains("talk") || lowercaseStrategy.contains("friend") {
            return "bubble.left.and.bubble.right.fill"
        } else {
            return "lightbulb.fill"
        }
    }
    
    // Save follow-up mood after using a coping strategy
    private func saveFollowUpMood() {
        guard let mood = selectedMood, let strategy = selectedCopingStrategy else { return }
        
        // Save the updated mood with the coping strategy that was used
        moodStore.saveMoodEntry(
            mood: mood,
            intensity: moodIntensity,
            note: "Follow-up after trying: \(strategy)",
            rejectionRelated: false,
            rejectionTrigger: nil,
            copingStrategy: strategy
        )
        
        // Calculate and show effectiveness
        let effectivenessMessage: String
        if let prevIntensity = previousMood != nil ? previousIntensity : nil {
            let improvement = prevIntensity - moodIntensity
            if improvement > 0 {
                effectivenessMessage = "Great job! Your mood improved by \(improvement) points."
            } else if improvement == 0 {
                effectivenessMessage = "Your mood intensity stayed the same. You might want to try a different strategy."
            } else {
                effectivenessMessage = "Your mood intensity increased. Consider consulting with a mental health professional if needed."
            }
            
            // Show toast with effectiveness message
            feedbackMessage = effectivenessMessage
            showFeedbackMessage = true
            
            // Hide toast after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    showFeedbackMessage = false
                }
            }
        }
        
        // Reset all form data
        selectedMood = nil
        moodIntensity = initialIntensity
        moodNote = ""
        isRejectionRelated = false
        rejectionTrigger = ""
        copingStrategy = ""
        selectedCopingStrategy = nil
        showFollowUpMoodPrompt = false
        showingAutoSuggestedStrategies = false
        
        // Success feedback
    }
    
    // Feedback message toast
    private var feedbackMessageToast: some View {
        VStack {
            Spacer()
            
            Text(feedbackMessage)
                .font(MoodViewTextStyles.body2)
                .foregroundColor(.white)
                .padding()
                .background(MoodViewColors.primary)
                .cornerRadius(AppLayout.cornerRadius)
                .padding(.horizontal)
                .padding(.bottom, 20)
        }
    }
    
    // Saved confirmation toast
    private var savedConfirmationToast: some View {
        VStack {
            Spacer()
            
            Text("Mood saved successfully")
                .font(MoodViewTextStyles.body2)
                .foregroundColor(.white)
                .padding()
                .background(MoodViewColors.primary)
                .cornerRadius(AppLayout.cornerRadius)
                .padding(.horizontal)
                .padding(.bottom, 20)
        }
    }
    
    // Setup observer in onAppear
    func setupFollowUpObserver() {
        followUpObserver.setupObserver()
    }
    
    // Load recent moods
    private func loadRecentMoods() {
        recentMoods = moodStore.recentMoods
    }
}

// MARK: - MoodView Coping Strategies Extension
extension MoodView {
    // Get recommended strategies
    private func getRecommendedStrategies() -> [String] {
        guard let selectedMood = selectedMood, !selectedMood.isEmpty else {
            return []
        }
        
        // Get strategies using our simple helper class
        return CopingStrategies.recommendFor(
            mood: selectedMood, 
            trigger: isRejectionRelated ? rejectionTrigger : nil
        )
    }
}

// MARK: - Preview Provider
struct MoodView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let moodStore = CoreDataMoodStore(context: context)
        
        // Create a MoodAnalysisEngine with the moodStore
        let moodAnalysisEngine = MoodAnalysisEngine(moodStore: moodStore)
        
        return MoodView(context: context, moodAnalysisEngine: moodAnalysisEngine)
            .environment(\.managedObjectContext, context)
    }
}

// Local helper function
fileprivate func getMoodCopingStrategiesLibraryView() -> some View {
    // This is a placeholder that will be replaced by the actual module implementation
    return AnyView(
        VStack(spacing: 20) {
            Text("Coping Strategies Library")
                .font(.largeTitle)
            
            Text("Loading strategies...")
                .foregroundColor(.secondary)
            
            ProgressView()
        }
        .padding()
    )
} 
