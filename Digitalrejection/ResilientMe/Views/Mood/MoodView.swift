import SwiftUI
import Charts // Import Charts framework for visualizations
import UIKit  // Import UIKit for feedback generators
import CoreData

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
    // Core Data connection
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var moodStore: MoodStore
    @ObservedObject var moodAnalysisEngine: MoodAnalysisEngine
    
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
    @State private var recommendedStrategies: [String] = []
    
    // UI feedback
    @State private var showSavedConfirmation: Bool = false
    
    // Properties to store initial values
    private var initialMood: String
    private var initialIntensity: Int
    
    // Properties for coping strategies and journal prompts
    @State private var recentMoods: [String] = []
    @State private var copingStrategies: [String] = []
    @State private var selectedCopingStrategy: String? = nil
    @State private var journalPrompt: String = ""
    
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
        self._moodStore = StateObject(wrappedValue: MoodStore(context: context))
        self.initialMood = initialMood
        self.initialIntensity = initialIntensity
        self.moodAnalysisEngine = moodAnalysisEngine
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppLayout.spacing * 1.5) {
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
                .padding(.horizontal)
                .animation(.easeInOut(duration: 0.3), value: selectedMood != nil)
                .animation(.easeInOut(duration: 0.3), value: showingHistory)
                .animation(.easeInOut(duration: 0.3), value: showingInsights)
                .animation(.easeInOut(duration: 0.3), value: isRejectionRelated)
            }
            .background(AppColors.background)
            .navigationTitle("Mood Tracker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        // History button
                    Button(action: {
                        showingHistory.toggle()
                            showingInsights = false
                        AppHapticFeedback.light()
                    }) {
                        Label("History", systemImage: "clock.arrow.circlepath")
                            .labelStyle(.iconOnly)
                    }
                    .accessibilityLabel("View mood history")
                    
                        // Insights button
                    Button(action: {
                        showingInsights.toggle()
                            showingHistory = false
                        AppHapticFeedback.light()
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
                copingStrategiesView
            }
            // Success toast notification
            .overlay {
                if showSavedConfirmation {
                    VStack {
                        Spacer()
                        Text("Mood saved successfully")
                            .font(AppTextStyles.body2)
                            .foregroundColor(.white)
                .padding()
                            .background(AppColors.primary)
                            .cornerRadius(AppLayout.cornerRadius)
                            .padding(.bottom, 16)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .onAppear {
                // Init recent moods
                recentMoods = moodStore.recentMoods
                
                // Reset form
                resetForm()
                
                // If we have a starting mood from a deep link or notification
                if !initialMood.isEmpty {
                    selectedMood = initialMood
                    updateCopingStrategies()
                    updateJournalPrompt()
                }
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
                .font(AppTextStyles.h2)
                .foregroundColor(AppColors.textDark)
                .accessibilityAddTraits(.isHeader)
            
            Spacer()
        }
        .padding(.top)
    }
    
    // Supportive message view
    private var supportiveMessageView: some View {
                            Text("Your feelings matter. Track them here in a safe space.")
                                .font(AppTextStyles.body2)
                                .foregroundColor(AppColors.textMedium)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .accessibilityLabel("Supportive message about tracking your feelings")
                        }
                        
    // Mood selection grid view
    private var moodSelectionView: some View {
                        VStack(alignment: .leading, spacing: AppLayout.spacing) {
            Text("Select your current mood")
                                .font(AppTextStyles.h3)
                                .foregroundColor(AppColors.textDark)
                            
            // Recent moods section
            if !moodStore.recentMoods.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent moods")
                        .font(AppTextStyles.body3)
                        .foregroundColor(AppColors.textMedium)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(moodStore.recentMoods, id: \.self) { mood in
                                Button(action: {
                                    selectedMood = mood
                                    showingCustomMoodField = false
                                    AppHapticFeedback.selection()
                                }) {
                                    Text(mood)
                                        .font(AppTextStyles.body3)
                                        .foregroundColor(selectedMood == mood ? .white : AppColors.textDark)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            selectedMood == mood ? 
                                            AppColors.primary : 
                                            AppColors.background
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
                    .font(AppTextStyles.body3)
                    .foregroundColor(AppColors.textMedium)
                
                moodCategoryGrid(moods: PredefinedMoods.positive)
            }
            .padding(.bottom, 12)
            
            // Negative moods
            VStack(alignment: .leading, spacing: 8) {
                Text("Negative")
                    .font(AppTextStyles.body3)
                    .foregroundColor(AppColors.textMedium)
                
                moodCategoryGrid(moods: PredefinedMoods.negative)
            }
            .padding(.bottom, 12)
            
            // Neutral moods
            VStack(alignment: .leading, spacing: 8) {
                Text("Neutral")
                    .font(AppTextStyles.body3)
                    .foregroundColor(AppColors.textMedium)
                
                moodCategoryGrid(moods: PredefinedMoods.neutral)
            }
            .padding(.bottom, 12)
            
            // Custom mood option
            Button(action: {
                showingCustomMoodField.toggle()
                if showingCustomMoodField {
                    selectedMood = nil
                }
                AppHapticFeedback.light()
            }) {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("Custom mood")
                }
                .font(AppTextStyles.body3)
                .foregroundColor(AppColors.primary)
            }
            
            if showingCustomMoodField {
                TextField("Enter your mood", text: $customMood)
                    .font(AppTextStyles.body2)
                    .padding()
                    .background(AppColors.background)
                    .cornerRadius(AppLayout.cornerRadius / 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppLayout.cornerRadius / 2)
                            .stroke(AppColors.textLight.opacity(0.3), lineWidth: 1)
                    )
                
                Button(action: {
                    selectedMood = customMood
                    AppHapticFeedback.selection()
                }) {
                    Text("Use this mood")
                        .font(AppTextStyles.body3)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(customMood.isEmpty ? AppColors.textLight : AppColors.primary)
                        .cornerRadius(20)
                }
                .disabled(customMood.isEmpty)
            }
                        }
                        .padding()
                        .background(AppColors.cardBackground)
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
                    AppHapticFeedback.selection()
                }) {
                    Text(mood)
                        .font(AppTextStyles.body3)
                        .foregroundColor(selectedMood == mood ? .white : AppColors.textDark)
                        .frame(minWidth: 80)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(
                            selectedMood == mood ? 
                            AppColors.primary : 
                            AppColors.background
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
                                    .font(AppTextStyles.h3)
                                    .foregroundColor(AppColors.textDark)
                                
                                VStack {
                                    Slider(value: Binding(
                                        get: { Double(moodIntensity) },
                                        set: { moodIntensity = Int($0) }
                                    ), in: 1...5, step: 1)
                                    .accentColor(AppColors.primary)
                                    
                                    HStack {
                                        Text("Mild")
                                            .font(AppTextStyles.body3)
                                            .foregroundColor(AppColors.textLight)
                                        
                                        Spacer()
                                        
                                        Text("Moderate")
                                            .font(AppTextStyles.body3)
                                            .foregroundColor(AppColors.textLight)
                                        
                                        Spacer()
                                        
                                        Text("Strong")
                                            .font(AppTextStyles.body3)
                                            .foregroundColor(AppColors.textLight)
                                    }
                                }
                            }
                            .padding()
                            .background(AppColors.cardBackground)
                            .cornerRadius(AppLayout.cornerRadius)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                                .accessibilityCard(label: "Mood intensity", hint: "Select how strongly you feel this emotion from 1 to 5")
    }
                                
    // Rejection related view
    private var rejectionRelatedView: some View {
                                VStack(alignment: .leading, spacing: AppLayout.spacing) {
                                    Toggle(isOn: $isRejectionRelated) {
                Text("Is this related to a rejection experience?")
                                            .font(AppTextStyles.h3)
                                            .foregroundColor(AppColors.textDark)
                                    }
                                    .toggleStyle(SwitchToggleStyle(tint: AppColors.primary))
                                    
                                    if isRejectionRelated {
                                        Text("What triggered this feeling?")
                                            .font(AppTextStyles.body2)
                                            .foregroundColor(AppColors.textMedium)
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
                            .font(AppTextStyles.body3)
                            .foregroundColor(AppColors.textMedium)
                        
                        TextField("Describe the trigger", text: $rejectionTrigger)
                            .font(AppTextStyles.body3)
                            .padding(8)
                            .background(AppColors.background)
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
                                                            .font(AppTextStyles.body3)
                    .foregroundColor(AppColors.primary)
                }
                .padding(.top, 8)
            }
        }
                                                .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
        .animation(.easeInOut, value: isRejectionRelated)
        .accessibilityCard(label: "Rejection experience", hint: "Indicate if this mood is related to rejection and track triggers")
    }
    
    // Rejection trigger category view
    private func rejectionTriggerCategoryView(categoryName: String, triggers: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(categoryName)
                .font(AppTextStyles.body3)
                                            .foregroundColor(AppColors.textMedium)
                                        
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 10) {
                    ForEach(triggers, id: \.self) { trigger in
                                                    Button(action: {
                            rejectionTrigger = trigger
                            AppHapticFeedback.selection()
                                                    }) {
                            Text(trigger)
                                                            .font(AppTextStyles.body3)
                                .foregroundColor(rejectionTrigger == trigger ? .white : AppColors.textDark)
                                                            .padding(.horizontal, 12)
                                                            .padding(.vertical, 8)
                                                            .background(
                                    rejectionTrigger == trigger ? 
                                    AppColors.primary : 
                                                                AppColors.background
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
                                    .font(AppTextStyles.h3)
                                    .foregroundColor(AppColors.textDark)
                                
                                TextEditor(text: $moodNote)
                                    .frame(height: 100)
                                    .padding(8)
                                    .background(AppColors.background)
                                    .cornerRadius(AppLayout.cornerRadius / 2)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: AppLayout.cornerRadius / 2)
                                                .stroke(AppColors.textLight.opacity(0.3), lineWidth: 1)
                                        )
                                    
                                    // Supportive message
                                    Text("Express yourself freely. This is your private space.")
                                        .font(AppTextStyles.caption)
                                        .foregroundColor(AppColors.textLight)
        }
        .padding()
        .background(AppColors.cardBackground)
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
            .background(AppColors.secondary)
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
                CopingStrategiesLibraryView()
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
                .font(AppTextStyles.h4)
                .foregroundColor(AppColors.textDark)
            
            Spacer()
            
            // AI indicator
            if moodAnalysisEngine.aiInitialized {
                HStack(spacing: 4) {
                    Image(systemName: "brain")
                        .font(.system(size: 12))
                    Text("AI")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(AppColors.textLight)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppColors.textLight.opacity(0.2))
                .cornerRadius(12)
            }
        }
    }
    
    // Content for coping strategies
    private var copingStrategiesContent: some View {
        Group {
            if copingStrategies.isEmpty {
                Text("Select a mood to see personalized coping strategies.")
                    .font(AppTextStyles.body1)
                    .foregroundColor(AppColors.textMedium)
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
                .font(AppTextStyles.body1)
                .foregroundColor(AppColors.textDark)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            Button(action: {
                selectedCopingStrategy = strategy
                AppHapticFeedback.selection()
            }) {
                Text("Try This")
                    .font(AppTextStyles.caption)
                    .foregroundColor(AppColors.primary)
            }
        }
        .frame(width: 200, height: 120)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                .fill(AppColors.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                .stroke(selectedCopingStrategy == strategy ? AppColors.primary : Color.clear, lineWidth: 2)
        )
    }
    
    // Journal prompt section
    private var journalPromptSection: some View {
        Group {
            if let selectedMood = selectedMood, !selectedMood.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text(journalPrompt)
                        .font(AppTextStyles.body1)
                        .foregroundColor(AppColors.textDark)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(AppLayout.cornerRadius)
                    
                    // Journal button
                    Button(action: {
                        // In a real app, navigate to journal
                        NotificationCenter.default.post(
                            name: Notification.Name("openJournalWithPrompt"), 
                            object: nil,
                            userInfo: ["prompt": journalPrompt, "mood": selectedMood, "intensity": moodIntensity]
                        )
                        AppHapticFeedback.success()
                    }) {
                        HStack {
                            Image(systemName: "square.and.pencil")
                            Text("Journal with this prompt")
                        }
                        .font(AppTextStyles.button)
                        .foregroundColor(AppColors.primary)
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
                    .font(AppTextStyles.h4)
                    .foregroundColor(AppColors.textDark)
                
                Spacer()
                
                // AI indicator
                if moodAnalysisEngine.aiInitialized {
                    HStack(spacing: 4) {
                        Image(systemName: "brain")
                            .font(.system(size: 12))
                        Text("AI")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(AppColors.textLight)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.textLight.opacity(0.2))
                    .cornerRadius(12)
                }
            }
            
            if let mood = selectedMood, mood.isEmpty {
                Text("Select a mood to see a personalized journal prompt.")
                    .font(AppTextStyles.body1)
                    .foregroundColor(AppColors.textMedium)
                    .padding(.vertical, 8)
            } else {
                Text(journalPrompt)
                    .font(AppTextStyles.body1)
                    .foregroundColor(AppColors.textDark)
                    .fixedSize(horizontal: false, vertical: true)
                                .padding()
                                .background(AppColors.cardBackground)
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
                    AppHapticFeedback.success()
                }) {
                    HStack {
                        Image(systemName: "square.and.pencil")
                        Text("Journal with this prompt")
                    }
                    .font(AppTextStyles.button)
                    .foregroundColor(AppColors.primary)
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
                                        .font(AppTextStyles.h3)
                                        .foregroundColor(AppColors.textDark)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        showingHistory = false
                                    }) {
                                        Text("Close")
                                            .font(AppTextStyles.body3)
                                            .foregroundColor(AppColors.primary)
                                    }
                                }
                                
                                Divider()
                                    .background(AppColors.textLight.opacity(0.3))
                                
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
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
        .accessibilityCard(label: "Mood history", hint: "View your past mood entries")
    }
    
    // Empty history view
    private var emptyHistoryView: some View {
                                    VStack(spacing: 16) {
                                        Image(systemName: "calendar.badge.clock")
                                            .font(.system(size: 40))
                                            .foregroundColor(AppColors.textLight)
                                        
                                        Text("No mood entries yet")
                                            .font(AppTextStyles.h4)
                                            .foregroundColor(AppColors.textDark)
                                        
                                        Text("Start tracking your moods to see your history here")
                                            .font(AppTextStyles.body3)
                                            .foregroundColor(AppColors.textMedium)
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
                    .font(AppTextStyles.h4)
                    .foregroundColor(colorForMood(entry.mood))
                
                Spacer()
                
                Text(formattedDate(entry.date))
                    .font(AppTextStyles.body3)
                    .foregroundColor(AppColors.textMedium)
            }
            
            HStack {
                Text("Intensity:")
                    .font(AppTextStyles.body3)
                    .foregroundColor(AppColors.textMedium)
                
                // Intensity indicator
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { i in
                        Circle()
                            .fill(i <= entry.intensity ? colorForMood(entry.mood) : AppColors.textLight.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                
                Spacer()
                
                if entry.rejectionTrigger != nil {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(AppColors.warning)
                        .font(.system(size: 14))
                    
                    Text("Rejection")
                        .font(AppTextStyles.caption)
                        .foregroundColor(AppColors.warning)
                }
            }
            
            if let note = entry.note, !note.isEmpty {
                Text(note)
                    .font(AppTextStyles.body3)
                    .foregroundColor(AppColors.textDark)
                    .lineLimit(3)
                    .padding(.top, 4)
            }
            
            if let trigger = entry.rejectionTrigger {
                HStack {
                    Text("Trigger:")
                        .font(AppTextStyles.caption)
                        .foregroundColor(AppColors.textMedium)
                    
                    Text(trigger)
                        .font(AppTextStyles.caption)
                        .foregroundColor(AppColors.textDark)
                }
                .padding(.top, 2)
            }
            
            if let strategy = entry.copingStrategy {
                HStack {
                    Text("Coping:")
                        .font(AppTextStyles.caption)
                        .foregroundColor(AppColors.textMedium)
                    
                    Text(strategy)
                        .font(AppTextStyles.caption)
                        .foregroundColor(AppColors.textDark)
                }
                .padding(.top, 2)
                                }
                            }
                            .padding()
        .background(AppColors.background)
        .cornerRadius(AppLayout.cornerRadius / 2)
        .padding(.vertical, 4)
    }
    
    // Insights view
    private var insightsView: some View {
                            VStack(alignment: .leading, spacing: AppLayout.spacing) {
                                HStack {
                                    Text("Mood Insights")
                                    .font(AppTextStyles.h3)
                                    .foregroundColor(AppColors.textDark)
                                
                                    Spacer()
                                    
                                    Button(action: {
                                        showingInsights = false
                                    }) {
                                        Text("Close")
                                            .font(AppTextStyles.body3)
                                            .foregroundColor(AppColors.primary)
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
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
        .accessibilityCard(label: "Mood insights", hint: "View analytics about your mood patterns")
    }
    
    // Mood distribution analysis
    private var moodDistributionView: some View {
                                VStack(alignment: .leading, spacing: 8) {
            Text("Mood Distribution")
                                        .font(AppTextStyles.h4)
                                        .foregroundColor(AppColors.textDark)
                                    
            let distribution = moodStore.getMoodDistribution(timeframe: selectedTimeFrame)
            
            if distribution.isEmpty {
                Text("No data for this time period")
                    .font(AppTextStyles.body3)
                    .foregroundColor(AppColors.textMedium)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppColors.background)
                    .cornerRadius(AppLayout.cornerRadius / 2)
            } else {
                VStack(spacing: 12) {
                    ForEach(distribution.sorted(by: { $0.value > $1.value }), id: \.key) { category, count in
                        HStack {
                            Text(category)
                                .font(AppTextStyles.body2)
                                .foregroundColor(AppColors.textDark)
                            
                            Spacer()
                            
                            // Progress bar
                            GeometryReader { geometry in
                                let maxCount = distribution.values.max() ?? 1
                                let width = geometry.size.width * CGFloat(count) / CGFloat(maxCount)
                                
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(AppColors.textLight.opacity(0.2))
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
                                            .font(AppTextStyles.body3)
                                            .foregroundColor(AppColors.textMedium)
                                .frame(width: 30, alignment: .trailing)
                        }
                        .padding()
                                            .background(AppColors.background)
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
                                        .font(AppTextStyles.h4)
                                        .foregroundColor(AppColors.textDark)
                                    
            let triggerDistribution = moodStore.getRejectionTriggerDistribution(timeframe: selectedTimeFrame)
                                    
            if triggerDistribution.isEmpty {
                                        Text("No rejection-related entries in this time period")
                                            .font(AppTextStyles.body3)
                                            .foregroundColor(AppColors.textMedium)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(AppColors.background)
                                            .cornerRadius(AppLayout.cornerRadius / 2)
                                    } else {
                                        VStack(spacing: 12) {
                    ForEach(triggerDistribution.sorted(by: { $0.value > $1.value }).prefix(3), id: \.key) { category, count in
                                                HStack {
                            Text(category)
                                                        .font(AppTextStyles.body2)
                                                        .foregroundColor(AppColors.textDark)
                                                    
                                                    Spacer()
                                                    
                                                    Text("\(count) time\(count == 1 ? "" : "s")")
                                                        .font(AppTextStyles.body3)
                                                        .foregroundColor(AppColors.textMedium)
                                                }
                                                .padding()
                                                .background(AppColors.background)
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
                                        .font(AppTextStyles.h4)
                                        .foregroundColor(AppColors.textDark)
                                    
            let strategyCounts = moodStore.getEffectiveCopingStrategies(timeframe: selectedTimeFrame)
                                    
            if strategyCounts.isEmpty {
                                        Text("No coping strategies recorded in this time period")
                                            .font(AppTextStyles.body3)
                                            .foregroundColor(AppColors.textMedium)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(AppColors.background)
                                            .cornerRadius(AppLayout.cornerRadius / 2)
                                    } else {
                                        VStack(spacing: 12) {
                                            ForEach(strategyCounts.sorted(by: { $0.value > $1.value }).prefix(3), id: \.key) { strategy, count in
                                                HStack {
                                                    Text(strategy)
                                                        .font(AppTextStyles.body2)
                                                        .foregroundColor(AppColors.textDark)
                                                    
                                                    Spacer()
                                                    
                                                    Text("\(count) time\(count == 1 ? "" : "s")")
                                                        .font(AppTextStyles.body3)
                                                        .foregroundColor(AppColors.textMedium)
                                                }
                                                .padding()
                                                .background(AppColors.background)
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
                                        .font(AppTextStyles.h4)
                                        .foregroundColor(AppColors.textDark)
                                    
            let average = moodStore.getAverageIntensity(timeframe: selectedTimeFrame)
                                    
            if average == 0 {
                Text("No data for this time period")
                    .font(AppTextStyles.body3)
                                        .foregroundColor(AppColors.textMedium)
                                        .padding()
                    .frame(maxWidth: .infinity)
                                        .background(AppColors.background)
                                        .cornerRadius(AppLayout.cornerRadius / 2)
            } else {
                HStack(spacing: 20) {
                    // Circular progress indicator
                    ZStack {
                        Circle()
                            .stroke(
                                AppColors.textLight.opacity(0.2),
                                lineWidth: 10
                            )
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(average) / 5.0)
                            .stroke(
                                AppColors.primary,
                                style: StrokeStyle(
                                    lineWidth: 10,
                                    lineCap: .round
                                )
                            )
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-90))
                        
                        Text(String(format: "%.1f", average))
                            .font(AppTextStyles.h3)
                    .foregroundColor(AppColors.textDark)
                    }
            
            VStack(alignment: .leading, spacing: 4) {
                        Text("Out of 5")
                    .font(AppTextStyles.body3)
                    .foregroundColor(AppColors.textMedium)
                        
                        // Interpretation
                        Text(intensityInterpretation(average))
                    .font(AppTextStyles.body3)
                            .foregroundColor(AppColors.textDark)
                    }
                }
                .padding()
                .background(AppColors.background)
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
                .font(AppTextStyles.h4)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
        .padding()
                .background(AppColors.primary)
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
        
        // Reset form
        self.selectedMood = nil
        self.customMood = ""
        self.showingCustomMoodField = false
        self.moodIntensity = initialIntensity
        self.moodNote = ""
        self.isRejectionRelated = false
        self.rejectionTrigger = ""
        self.copingStrategy = ""
        self.journalPrompt = ""
        self.copingStrategies = []
        self.selectedCopingStrategy = nil
        
        // Show success toast
        withAnimation {
            showSavedConfirmation = true
        }
        
        // Haptic feedback
        AppHapticFeedback.success()
        
        // Hide toast after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showSavedConfirmation = false
            }
        }
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
            return AppColors.primary
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
            let libraryStrategies = CopingStrategiesLibrary.shared.recommendStrategies(
                for: selectedMood,
                intensity: moodIntensity,
                trigger: isRejectionRelated ? rejectionTrigger : nil
            )
            
            // Convert to simple string format for backward compatibility
            copingStrategies = CopingStrategiesLibrary.getSimpleStrategyStrings(from: libraryStrategies)
        } else {
            // For milder reactions, use AI-powered or fallback strategies
            copingStrategies = moodAnalysisEngine.getCopingStrategiesForMood(
                selectedMood, 
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
        
        // Use AI-powered journal prompt
        journalPrompt = moodAnalysisEngine.getJournalPromptForMood(
            selectedMood, 
            trigger: isRejectionRelated ? rejectionTrigger : nil
        )
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
}

// MARK: - Preview Provider
struct MoodView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let moodStore = MoodStore(context: context)
        let moodAnalysisEngine = MoodAnalysisEngine(moodStore: moodStore)
        
        return MoodView(context: context, moodAnalysisEngine: moodAnalysisEngine)
            .environment(\.managedObjectContext, context)
    }
} 