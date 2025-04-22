import SwiftUI
import ResilientMe // Assuming ResilientMe contains LocalCopingStrategyDetail etc.

// MARK: - Editor View

struct JournalEntryEditorView: View {
    // Entry state
    @State private var title: String
    @State private var content: String
    @State private var selectedTags: [String]
    @State private var selectedMood: JournalMood?
    @State private var moodIntensity: Double // Store as Double (1.0-10.0) for Slider
    
    // Editing state
    @State private var isPromptVisible: Bool = true
    @State private var selectedTabIndex: Int = 0
    @State private var showingTagSelector = false
    @State private var showingDiscardAlert = false
    @State private var isRequestingMoodIntensity = false
    @State private var strategiesRecommendationsState: RecommendedStrategiesState? // Defined in JournalCopingStrategiesView.swift
    
    // Environment
    @Environment(\.dismiss) private var dismiss
    
    private let isNewEntry: Bool
    private let initialPrompt: String
    private let onSave: (JournalEntryModel?) -> Void
    
    // All available tags for selection
    // Consider moving this to a configuration or constants file if used elsewhere
    private let availableTags = ["Personal", "Work", "Health", "Rejection", "Insight", "Gratitude", "Growth", "Habit", "Learning"]
    
    // Initialize with all required parameters
    init(isNewEntry: Bool, initialPrompt: String, initialTitle: String = "", initialTags: [String] = [], initialMood: JournalMood? = nil, initialMoodIntensity: Double = 5.0, onSave: @escaping (JournalEntryModel?) -> Void) {
        self.isNewEntry = isNewEntry
        self.initialPrompt = initialPrompt
        self.onSave = onSave
        
        // Initialize state variables
        _title = State(initialValue: initialTitle)
        // Use initialPrompt as content only if it's a new entry and content is empty
        _content = State(initialValue: isNewEntry && initialTitle.isEmpty ? initialPrompt : "") 
        _selectedTags = State(initialValue: initialTags)
        _selectedMood = State(initialValue: initialMood)
        _moodIntensity = State(initialValue: initialMoodIntensity)
        // Set initial visibility based on whether there's a prompt
        _isPromptVisible = State(initialValue: !initialPrompt.isEmpty)
        // Set initial intensity request based on selected mood
        _isRequestingMoodIntensity = State(initialValue: initialMood != nil && initialMood != .neutral)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab selector
                editorModeTabView
                
                ZStack(alignment: .bottom) {
                    // Main editor area
                    ScrollView {
                        VStack(spacing: 16) {
                            // Title field
                            titleField
                            
                            // Content/prompt area based on tab
                            if selectedTabIndex == 0 {
                                contentEditorSection
                            } else {
                                moodAndTagsSection
                            }
                        }
                        .padding()
                        // Add padding at the bottom to prevent overlap with save button
                        .padding(.bottom, 80) 
                    }
                    
                    // Action button overlay
                    saveButton
                        .padding()
                }
            }
            .background(AppColors.background.edgesIgnoringSafeArea(.all))
            .navigationTitle(isNewEntry ? "New Entry" : "Edit Entry")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if hasUnsavedChanges() {
                            showingDiscardAlert = true
                        } else {
                            onSave(nil) // Explicitly pass nil for cancellation
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        saveEntry()
                    }
                    .disabled(!isValidEntry())
                }
            }
            .alert("Discard Changes?", isPresented: $showingDiscardAlert) {
                Button("Discard", role: .destructive) { 
                    onSave(nil) // Explicitly pass nil for discard
                    dismiss() 
                }
                Button("Continue Editing", role: .cancel) { }
            } message: {
                Text("You have unsaved changes that will be lost.")
            }
            .sheet(isPresented: $showingTagSelector) {
                tagSelectorView
                    // .withDynamicTypeSize() // Apply this if View+JournalExtensions is imported
            }
            .sheet(item: $strategiesRecommendationsState) { state in
                JournalCopingStrategiesView(recommendationsState: state)
                     // .withDynamicTypeSize() // Apply this if View+JournalExtensions is imported
            }
        }
        // Apply dynamic type size to the whole NavigationView
        // .withDynamicTypeSize() // Apply this if View+JournalExtensions is imported
    }
    
    // MARK: - Component Views
    
    private var editorModeTabView: some View {
        HStack {
            tabButton(title: "Content", index: 0)
            tabButton(title: "Tags & Mood", index: 1)
        }
        .background(AppColors.cardBackground)
    }

    private func tabButton(title: String, index: Int) -> some View {
         Button(action: { selectedTabIndex = index }) {
             Text(title)
                 .font(AppTextStyles.body2)
                 .padding(.vertical, 12)
                 .foregroundColor(selectedTabIndex == index ? AppColors.primary : AppColors.textMedium)
                 .frame(maxWidth: .infinity)
                 .background(
                     selectedTabIndex == index ?
                         AppColors.primary.opacity(0.1) :
                         Color.clear
                 )
         }
    }
    
    private var titleField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Title")
                .font(AppTextStyles.body2)
                .foregroundColor(AppColors.textDark)
            
            TextField("Enter a title...", text: $title)
                .font(AppTextStyles.h3)
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(AppLayout.cornerRadius)
        }
    }
                        
    private var contentEditorSection: some View {
        VStack(alignment: .leading, spacing: 16) { // Increased spacing
            // Prompt if available
            if isPromptVisible && !initialPrompt.isEmpty {
                promptView
            }
            
            // Editor
            VStack(alignment: .leading, spacing: 8) { // Group label and editor
                Text("Journal Entry")
                    .font(AppTextStyles.body2)
                    .foregroundColor(AppColors.textDark)
                                
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $content)
                        .font(AppTextStyles.body1)
                        .padding(EdgeInsets(top: 12, leading: 8, bottom: 12, trailing: 8)) // Consistent padding
                        .frame(minHeight: 200, maxHeight: .infinity) // Allow vertical expansion
                        .background(AppColors.cardBackground)
                        .cornerRadius(AppLayout.cornerRadius)
                    
                    if content.isEmpty {
                        Text(isPromptVisible ? "Respond to the prompt or write freely..." : "Start writing here...")
                            .font(AppTextStyles.body1)
                            .foregroundColor(AppColors.textLight)
                            .padding(.horizontal, 12) // Match TextEditor padding
                            .padding(.vertical, 20) // Match TextEditor padding
                            .allowsHitTesting(false)
                    }
                }
            }
        }
    }
                        
    private var promptView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Writing Prompt")
                    .font(AppTextStyles.body2.bold())
                    .foregroundColor(AppColors.primary)
                                
                Spacer()
                                
                Button(action: {
                    withAnimation {
                        isPromptVisible = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColors.textMedium)
                        // .withMinTouchArea() // Apply if View+JournalExtensions is available
                }
            }
            
            Text(initialPrompt)
                .font(AppTextStyles.body1)
                .foregroundColor(AppColors.textDark)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.primary.opacity(0.05))
                .cornerRadius(AppLayout.cornerRadius)
        }
    }
    
    private var moodAndTagsSection: some View {
        VStack(spacing: 24) {
            moodSelector
            tagsSelector
        }
    }

    private var moodSelector: some View {
         VStack(alignment: .leading, spacing: 12) {
             Text("How are you feeling?")
                 .font(AppTextStyles.body2)
                 .foregroundColor(AppColors.textDark)
             
             // Mood grid
             LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 16) {
                 ForEach(JournalMood.allCases) { mood in // Assuming JournalMood is available
                     moodButton(mood: mood)
                 }
             }
             
             // Intensity slider if mood is selected and intensity requested
             if let mood = selectedMood, mood != .neutral, isRequestingMoodIntensity {
                 moodIntensitySlider
             }
         }
    }

    private func moodButton(mood: JournalMood) -> some View {
         Button(action: {
             if selectedMood == mood { // Deselecting
                 selectedMood = nil
                 isRequestingMoodIntensity = false
             } else { // Selecting
                 selectedMood = mood
                 isRequestingMoodIntensity = (mood != .neutral) // Only request intensity if not neutral
             }
         }) { 
             VStack(spacing: 8) {
                 Text(mood.emoji)
                     .font(.system(size: 32))
                 Text(mood.name)
                     .font(AppTextStyles.smallText)
                     .foregroundColor(AppColors.textDark)
             }
             .padding(.vertical, 12)
             .frame(maxWidth: .infinity)
             .background(selectedMood == mood ? AppColors.primary.opacity(0.1) : AppColors.cardBackground)
             .cornerRadius(AppLayout.cornerRadius)
             .overlay(
                 RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                     .stroke(selectedMood == mood ? AppColors.primary : Color.clear, lineWidth: 2)
             )
         }
         .buttonStyle(PlainButtonStyle())
    }

    private var moodIntensitySlider: some View {
         VStack(alignment: .leading, spacing: 8) {
             Text("How intense is this feeling? (\(Int(moodIntensity))/10)")
                 .font(AppTextStyles.body2)
                 .foregroundColor(AppColors.textDark)
                                             
             Slider(value: $moodIntensity, in: 1...10, step: 1)
                 .accentColor(AppColors.primary)
         }
         .padding()
         .background(AppColors.cardBackground)
         .cornerRadius(AppLayout.cornerRadius)
         .transition(.opacity.combined(with: .scale)) // Add animation
    }
            
    private var tagsSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Tags")
                    .font(AppTextStyles.body2)
                    .foregroundColor(AppColors.textDark)
                                    
                Spacer()
                    
                Button(action: { showingTagSelector = true }) {
                    Text(selectedTags.isEmpty ? "Add Tags" : "Edit Tags")
                        .font(AppTextStyles.buttonFont)
                        .foregroundColor(AppColors.primary)
                }
            }
                
            if selectedTags.isEmpty {
                Text("No tags selected")
                    .font(AppTextStyles.body1)
                    .foregroundColor(AppColors.textLight)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(AppColors.cardBackground)
                    .cornerRadius(AppLayout.cornerRadius)
            } else {
                selectedTagsView
            }
        }
    }

    private var selectedTagsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(selectedTags, id: \.self) { tag in
                    HStack(spacing: 4) { // Reduced spacing
                        Text(tag)
                            .font(AppTextStyles.smallText)
                            .foregroundColor(tagColor(for: tag))
                            .padding(.leading, 10) // Adjusted padding
                            .padding(.vertical, 6)
                                    
                        Button(action: { // Wrap remove button for larger tap area
                            selectedTags.removeAll { $0 == tag }
                        }) { 
                            Image(systemName: "xmark") // Use plain xmark
                                .font(.system(size: 10, weight: .bold)) // Adjust size
                                .foregroundColor(tagColor(for: tag))
                                .padding(6) // Add padding for tap area
                        }
                        .padding(.trailing, 4) // Adjust padding
                    }
                    .background(tagColor(for: tag).opacity(0.1))
                    .cornerRadius(16)
                }
            }
            .padding(8)
        }
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    private var tagSelectorView: some View {
        // This view is presented as a sheet
        NavigationView { // Add NavigationView for title and done button
            VStack(spacing: 0) {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) { // Adjusted min width
                        ForEach(availableTags, id: \.self) { tag in
                            tagSelectionButton(tag: tag)
                        }
                    }
                    .padding()
                }
                
                // Done button at the bottom (removed as it's in toolbar now)
            }
            .background(AppColors.background.edgesIgnoringSafeArea(.bottom))
            .navigationTitle("Select Tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") { showingTagSelector = false }
                }
            }
        }
    }

    private func tagSelectionButton(tag: String) -> some View {
         Button(action: {
             if selectedTags.contains(tag) {
                 selectedTags.removeAll { $0 == tag }
             } else {
                 selectedTags.append(tag)
             }
         }) { 
             Text(tag)
                 .font(AppTextStyles.body2)
                 .foregroundColor(selectedTags.contains(tag) ? .white : tagColor(for: tag))
                 .padding(.horizontal, 12)
                 .padding(.vertical, 8)
                 .frame(maxWidth: .infinity)
                 .background(selectedTags.contains(tag) ? tagColor(for: tag) : tagColor(for: tag).opacity(0.1))
                 .cornerRadius(AppLayout.cornerRadius)
                 // Add overlay for unselected state if needed
                 // .overlay(
                 //     RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                 //         .stroke(selectedTags.contains(tag) ? Color.clear : tagColor(for: tag), lineWidth: 1)
                 // )
         }
         .buttonStyle(PlainButtonStyle())
    }
    
    private var saveButton: some View {
        Button(action: saveEntry) {
            Text("Save Journal Entry")
                .font(AppTextStyles.buttonFont)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(isValidEntry() ? AppColors.primary : AppColors.textLight.opacity(0.5)) // Use opacity for disabled state
                .cornerRadius(AppLayout.cornerRadius)
                .shadow(color: AppColors.primary.opacity(isValidEntry() ? 0.3 : 0), radius: 5, y: 3) // Add shadow
        }
        .disabled(!isValidEntry())
        .padding(.horizontal) // Add horizontal padding to the container
        .padding(.bottom, 10) // Add bottom padding
        .background(AppColors.background) // Ensure background matches overall background
    }
    
    // MARK: - Helper Methods
    
    private func isValidEntry() -> Bool {
        // Title or content must not be empty
        return !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || 
               !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func hasUnsavedChanges() -> Bool {
        // Check against initial state (requires storing initial state accurately)
        // For simplicity, we check if anything is non-empty/non-default.
        // A more robust check would compare against the original entry if editing.
        if !isNewEntry {
            // TODO: Need original entry data to compare accurately for edits
            return true // Assume changes if editing for now
        } else {
            return !title.isEmpty || 
                   content != initialPrompt || 
                   !selectedTags.isEmpty || 
                   selectedMood != nil
        }
    }
    
    // This function should ideally live in a shared Theme or Color manager
    private func tagColor(for tag: String) -> Color {
        switch tag {
        case "Rejection": return AppColors.sadness // Use mood colors where appropriate
        case "Insight": return AppColors.accent2
        case "Gratitude": return AppColors.joy
        case "Habit": return AppColors.secondary // Or a specific habit color
        case "Growth": return AppColors.calm // Or a specific growth color
        case "Personal": return .orange
        case "Work": return .pink
        case "Health": return .teal
        case "Learning": return .indigo
        case "Career": return .blue // Added from supporting views
        case "Digital": return .cyan // Added from supporting views
        default: return AppColors.textMedium
        }
    }
    
    private func saveEntry() {
        // Guard against invalid state just in case
        guard isValidEntry() else { return }
        
        // Create journal entry
        let entry = JournalEntryModel(
            id: UUID().uuidString, // Consider passing ID if editing
            date: Date(),
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            content: content.trimmingCharacters(in: .whitespacesAndNewlines),
            tags: selectedTags,
            mood: selectedMood,
            moodIntensity: selectedMood != nil && selectedMood != .neutral ? Int(moodIntensity) : nil
        )
        
        // First save the entry via the callback
        onSave(entry)
        
        // Dismiss the editor *before* potentially showing recommendations
        // This provides better UX as the recommendations sheet replaces the editor
        dismiss()
        
        // Then analyze for recommendations *after* saving and dismissing
        // Perform analysis asynchronously to avoid blocking the main thread
        DispatchQueue.global(qos: .userInitiated).async {
            let analysisContent = entry.content // Use the saved content
            if analysisContent.count > 30 { // Adjusted threshold
                // Assuming analyzeJournalContentForStrategies is available globally or imported
                let recommendedStrategies = analyzeJournalContentForStrategies(analysisContent)
                
                // Update state on the main thread to present the sheet
                DispatchQueue.main.async {
                    if !recommendedStrategies.isEmpty {
                        // This part needs adjustment: We can't directly present another sheet
                        // after dismissing. The parent view (JournalView) needs to handle 
                        // presenting the recommendations based on the saved entry.
                        // 
                        // Option 1: Pass recommendations back in `onSave`.
                        // Option 2: Use a shared state/coordinator to trigger recommendations.
                        // 
                        // For now, just logging the intent.
                        print("Recommended strategies found: \(recommendedStrategies.map { $0.title })")
                        // strategiesRecommendationsState = RecommendedStrategiesState(strategies: recommendedStrategies)
                    }
                }
            } 
        }
    }
}

// Assuming JournalMood, JournalEntryModel, RecommendedStrategiesState, 
// JournalCopingStrategiesView, analyzeJournalContentForStrategies, 
// AppColors, AppTextStyles, AppLayout are accessible. 