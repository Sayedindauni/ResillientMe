//
//  JournalView.swift
//  ResillientMe
//
//  Created by Sayed Mohamed on 21.03.25.
//

import SwiftUI
import Foundation

// Add extension for dynamic type size accessibility
extension View {
    /// Sets the appropriate text sizes based on Dynamic Type settings
    func withDynamicTypeSize() -> some View {
        return self
            .dynamicTypeSize(...DynamicTypeSize.accessibility3)
    }
}

// Types are defined in AppTypes.swift but don't need explicit import within the same module

// MARK: - Data Types

// Define the JournalEntryModel type directly in this file
struct JournalEntryModel: Identifiable, Equatable {
    let id: String
    let date: Date
    let title: String
    let content: String
    let tags: [String]
    let mood: Mood?
    let moodIntensity: Int?
    
    static func == (lhs: JournalEntryModel, rhs: JournalEntryModel) -> Bool {
        return lhs.id == rhs.id
    }
}

struct JournalView: View {
    @State private var showingNewEntry = false
    @State private var selectedEntry: JournalEntryModel? = nil
    @State private var searchText = ""
    @State private var filterOption: FilterOption = .all
    @State private var journalEntries: [JournalEntryModel] = SampleData.journalEntries
    
    // Properties to handle mood tracking integration
    var initialPromptData: [String: Any]?
    var showNewEntryOnAppear: Bool
    
    // Initialize without parameters for backward compatibility
    init() {
        self.initialPromptData = nil
        self.showNewEntryOnAppear = false
    }
    
    // Initialize with prompt data for mood tracking integration
    init(initialPromptData: [String: Any]?, showNewEntryOnAppear: Bool) {
        self.initialPromptData = initialPromptData
        self.showNewEntryOnAppear = showNewEntryOnAppear
    }
    
    private var filteredEntries: [JournalEntryModel] {
        var entries = journalEntries
        
        // Apply search
        if !searchText.isEmpty {
            entries = entries.filter { 
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply filter
        switch filterOption {
        case .all:
            return entries
        case .rejections:
            return entries.filter { $0.tags.contains("Rejection") }
        case .insights:
            return entries.filter { $0.tags.contains("Insight") }
        case .gratitude:
            return entries.filter { $0.tags.contains("Gratitude") }
        case .habits:
            return entries.filter { $0.tags.contains("Habit") }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter
                searchAndFilterBar
                
                // Journal entries list
                if filteredEntries.isEmpty {
                    emptyState
                } else {
                    entriesList
                }
            }
            .background(AppColors.background.edgesIgnoringSafeArea(.all))
            .navigationTitle("Journal")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewEntry = true }) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .makeAccessible(
                        label: "New journal entry", 
                        hint: "Create a new journal entry"
                    )
                }
            }
            .sheet(isPresented: $showingNewEntry) {
                JournalEntryEditorView(
                    isNewEntry: true,
                    initialPrompt: getPromptContent(),
                    initialTitle: getPromptTitle(),
                    initialTags: getPromptTags(),
                    initialMood: getPromptMood(),
                    initialMoodIntensity: getPromptMoodIntensity()
                ) { newEntry in
                    // Add new entry to journal
                    if let newEntry = newEntry {
                        journalEntries.insert(newEntry, at: 0)
                        HapticFeedback.success()
                    }
                }
                .withDynamicTypeSize()
            }
            .sheet(item: $selectedEntry) { entry in
                JournalEntryDetailView(entry: entry) { updatedEntry in
                    // Update entry in collection
                    if let updatedEntry = updatedEntry, 
                       let index = journalEntries.firstIndex(where: { $0.id == updatedEntry.id }) {
                        journalEntries[index] = updatedEntry
                    }
                }
                .withDynamicTypeSize()
            }
            .onAppear {
                // If showNewEntryOnAppear is true, we should trigger a new entry
                // with the provided prompt data
                if showNewEntryOnAppear, initialPromptData != nil {
                    // Slight delay to ensure view is ready
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showingNewEntry = true
                    }
                }
            }
        }
    }
    
    // MARK: - Search and Filter Bar
    
    private var searchAndFilterBar: some View {
        VStack(spacing: 12) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppColors.textMedium)
                
                TextField("Search entries", text: $searchText)
                    .font(AppTextStyles.body1)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColors.textMedium)
                    }
                    .withMinTouchArea()
                }
            }
            .padding(10)
            .background(AppColors.cardBackground)
            .cornerRadius(AppLayout.smallCornerRadius)
            .padding(.horizontal)
            .makeAccessible(
                label: "Search journal entries",
                hint: "Enter keywords to search your journal"
            )
            
            // Filter options
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(FilterOption.allCases) { option in
                        FilterButton(
                            title: option.title,
                            isSelected: filterOption == option,
                            action: { filterOption = option }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(AppColors.background)
    }
    
    // MARK: - Entries List
    
    private var entriesList: some View {
        List {
            ForEach(filteredEntries) { entry in
                JournalEntryRow(entry: entry)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedEntry = entry
                    }
                    .accessibleCard(
                        label: entry.title,
                        hint: "Journal entry from \(formatDate(entry.date, format: "MMMM d"))"
                    )
                    .listRowBackground(AppColors.cardBackground)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
        }
        .listStyle(.plain)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "book.fill")
                .font(.system(size: 60))
                .foregroundColor(AppColors.primary.opacity(0.5))
            
            Text("No journal entries found")
                .font(AppTextStyles.h3)
                .foregroundColor(AppColors.textDark)
                .multilineTextAlignment(.center)
            
            if !searchText.isEmpty {
                Text("Try changing your search terms")
                    .font(AppTextStyles.body1)
                    .foregroundColor(AppColors.textMedium)
                    .multilineTextAlignment(.center)
                
                Button(action: { searchText = "" }) {
                    Text("Clear Search")
                        .font(AppTextStyles.buttonFont)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(AppColors.primary)
                        .cornerRadius(AppLayout.cornerRadius)
                }
                .withMinTouchArea()
            } else {
                Text("Start journaling to process your feelings and build resilience")
                    .font(AppTextStyles.body1)
                    .foregroundColor(AppColors.textMedium)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Button(action: { showingNewEntry = true }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("New Entry")
                    }
                    .font(AppTextStyles.buttonFont)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppColors.primary)
                    .cornerRadius(AppLayout.cornerRadius)
                }
                .withMinTouchArea()
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    // MARK: - Helper Methods for Prompt Data
    
    // Get the prompt content from initialPromptData
    private func getPromptContent() -> String {
        if let promptData = initialPromptData, let prompt = promptData["prompt"] as? String {
            return prompt
        }
        return AppCopy.randomJournalPrompt()
    }
    
    // Get the title from initialPromptData
    private func getPromptTitle() -> String {
        if let promptData = initialPromptData, let title = promptData["title"] as? String {
            return title
        }
        return ""
    }
    
    // Get suggested tags from initialPromptData
    private func getPromptTags() -> [String] {
        if let promptData = initialPromptData, let tags = promptData["tags"] as? [String] {
            return tags
        }
        return []
    }
    
    // Get mood from initialPromptData
    private func getPromptMood() -> Mood? {
        if let promptData = initialPromptData, let moodString = promptData["mood"] as? String {
            // Map the mood string to Mood enum if possible
            if moodString == "Happy" || moodString == "Excited" || moodString == "Proud" {
                return .joyful
            } else if moodString == "Calm" {
                return .content
            } else if moodString == "Sad" || moodString == "Discouraged" {
                return .sad
            } else if moodString == "Anxious" || moodString == "Overwhelmed" {
                return .stressed
            } else if moodString == "Angry" || moodString == "Frustrated" {
                return .frustrated
            } else if moodString == "Neutral" {
                return .neutral
            }
        }
        return nil
    }
    
    // Get mood intensity from initialPromptData
    private func getPromptMoodIntensity() -> Double {
        if let promptData = initialPromptData, let intensity = promptData["moodIntensity"] as? Int {
            // Convert 1-5 scale to 1-10 scale
            return Double(intensity) * 2
        }
        return 5.0
    }
}

// MARK: - Supporting Views

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTextStyles.body2)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .foregroundColor(isSelected ? .white : AppColors.primary)
                .background(isSelected ? AppColors.primary : Color.clear)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(AppColors.primary, lineWidth: isSelected ? 0 : 1)
                )
        }
        .makeAccessible(
            label: title,
            hint: "Filter journal entries to show \(title.lowercased()) entries"
        )
    }
}

struct JournalEntryRow: View {
    let entry: JournalEntryModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Date and tags
            HStack {
                Text(formatDate(entry.date, format: "MMM d, yyyy"))
                    .font(AppTextStyles.captionText)
                    .foregroundColor(AppColors.textMedium)
                
                Spacer()
                
                if !entry.tags.isEmpty {
                    ForEach(entry.tags.prefix(2), id: \.self) { tag in
                        TagView(tag: tag)
                    }
                    
                    if entry.tags.count > 2 {
                        Text("+\(entry.tags.count - 2)")
                            .font(AppTextStyles.captionText)
                            .foregroundColor(AppColors.textMedium)
                    }
                }
            }
            
            // Title
            Text(entry.title)
                .font(AppTextStyles.h4)
                .foregroundColor(AppColors.textDark)
                .lineLimit(1)
            
            // Preview content
            Text(entry.content.prefix(100) + (entry.content.count > 100 ? "..." : ""))
                .font(AppTextStyles.body1)
                .foregroundColor(AppColors.textMedium)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            // Associated mood if present
            if entry.mood != nil {
                HStack(spacing: 4) {
                    Image(systemName: "face.smiling")
                        .font(.system(size: 12))
                    Text("Feeling: \(entry.mood?.name ?? "Unknown")")
                        .font(AppTextStyles.captionText)
                    
                    if let intensity = entry.moodIntensity {
                        Text("(\(intensity)/10)")
                            .font(AppTextStyles.captionText)
                    }
                }
                .foregroundColor(AppColors.textMedium)
                .padding(.top, 4)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct TagView: View {
    let tag: String
    
    private var tagColor: Color {
        switch tag {
        case "Rejection":
            return AppColors.sadness
        case "Insight":
            return AppColors.accent2
        case "Gratitude":
            return AppColors.joy
        case "Habit":
            return AppColors.secondary
        case "Growth":
            return AppColors.calm
        default:
            return AppColors.textMedium
        }
    }
    
    var body: some View {
        Text(tag)
            .font(AppTextStyles.captionText)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(tagColor.opacity(0.2))
            .foregroundColor(tagColor)
            .cornerRadius(12)
    }
}

// MARK: - Editor View

struct JournalEntryEditorView: View {
    let isNewEntry: Bool
    let initialPrompt: String
    let initialTitle: String
    let initialTags: [String]
    let initialMood: Mood?
    let initialMoodIntensity: Double
    let onSave: (JournalEntryModel?) -> Void
    
    @State private var title: String
    @State private var content: String
    @State private var selectedTags: [String] = []
    @State private var selectedMood: Mood?
    @State private var moodIntensity: Double
    @State private var showingPrompt = true
    @State private var showingTagPicker = false
    @State private var showingMoodPicker = false
    @State private var recommendedStrategiesState: RecommendedStrategiesState?
    @Environment(\.dismiss) private var dismiss
    
    private let availableTags = ["Rejection", "Insight", "Gratitude", "Habit", "Growth"]
    
    // Initialize state with initial values
    init(isNewEntry: Bool, initialPrompt: String, initialTitle: String = "", initialTags: [String] = [], initialMood: Mood? = nil, initialMoodIntensity: Double = 5.0, onSave: @escaping (JournalEntryModel?) -> Void) {
        self.isNewEntry = isNewEntry
        self.initialPrompt = initialPrompt
        self.initialTitle = initialTitle
        self.initialTags = initialTags
        self.initialMood = initialMood
        self.initialMoodIntensity = initialMoodIntensity
        self.onSave = onSave
        
        // Initialize state
        _title = State(initialValue: initialTitle)
        _content = State(initialValue: "") // We'll set this separately if coming from a prompt
        _selectedTags = State(initialValue: initialTags)
        _selectedMood = State(initialValue: initialMood)
        _moodIntensity = State(initialValue: initialMoodIntensity)
        
        // Show tag picker if initial tags are provided
        _showingTagPicker = State(initialValue: !initialTags.isEmpty)
        
        // Show mood picker if mood is provided
        _showingMoodPicker = State(initialValue: initialMood != nil)
    }
    
    // Computed property to determine if save button should be enabled
    private var isSaveButtonEnabled: Bool {
        return !title.isEmpty && !content.isEmpty
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Editor fields
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Writing prompt card (collapsible)
                        if showingPrompt && !initialPrompt.isEmpty {
                            promptCard
                        }
                        
                        // Title field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(AppTextStyles.body2)
                                .foregroundColor(AppColors.textMedium)
                            
                            TextField("Enter a title...", text: $title)
                                .font(AppTextStyles.h3)
                                .padding()
                                .background(AppColors.cardBackground)
                                .cornerRadius(AppLayout.cornerRadius)
                                .makeAccessible(
                                    label: "Journal entry title",
                                    hint: "Enter a title for your journal entry"
                                )
                        }
                        
                        // Content field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("What's on your mind?")
                                .font(AppTextStyles.body2)
                                .foregroundColor(AppColors.textMedium)
                            
                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $content)
                                    .font(AppTextStyles.body1)
                                    .padding()
                                    .frame(minHeight: 200)
                                    .background(AppColors.cardBackground)
                                    .cornerRadius(AppLayout.cornerRadius)
                                    .makeAccessible(
                                        label: "Journal entry content",
                                        hint: "Write your thoughts and reflections"
                                    )
                                
                                if content.isEmpty {
                                    Text("Start writing here...")
                                        .font(AppTextStyles.body1)
                                        .foregroundColor(AppColors.textLight)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 24)
                                        .allowsHitTesting(false)
                                }
                            }
                        }
                        
                        // Tags section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Tags")
                                    .font(AppTextStyles.body2)
                                    .foregroundColor(AppColors.textMedium)
                                
                                Spacer()
                                
                                Button(action: { showingTagPicker.toggle() }) {
                                    Text(showingTagPicker ? "Done" : "Edit")
                                        .font(AppTextStyles.buttonFont)
                                        .foregroundColor(AppColors.primary)
                                }
                                .makeAccessible(
                                    label: showingTagPicker ? "Done selecting tags" : "Edit tags",
                                    hint: "Toggle tag selection mode"
                                )
                            }
                            
                            if showingTagPicker {
                                // Tag selection grid
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                                    ForEach(availableTags, id: \.self) { tag in
                                        TagSelectionButton(
                                            tag: tag,
                                            isSelected: selectedTags.contains(tag),
                                            action: {
                                                if selectedTags.contains(tag) {
                                                    selectedTags.removeAll { $0 == tag }
                                                } else {
                                                    selectedTags.append(tag)
                                                }
                                                HapticFeedback.light()
                                            }
                                        )
                                    }
                                }
                                .padding(.vertical, 4)
                            } else {
                                // Selected tags display
                                if selectedTags.isEmpty {
                                    Text("Tap edit to add tags")
                                        .font(AppTextStyles.body1)
                                        .foregroundColor(AppColors.textLight)
                                        .padding(.vertical, 4)
                                } else {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(selectedTags, id: \.self) { tag in
                                                TagView(tag: tag)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Mood section
                        VStack(alignment: .leading, spacing: 12) {
                            Button(action: { showingMoodPicker.toggle() }) {
                                HStack {
                                    Text("How do you feel after writing?")
                                        .font(AppTextStyles.body2)
                                        .foregroundColor(AppColors.textMedium)
                                    
                                    Spacer()
                                    
                                    Image(systemName: showingMoodPicker ? "chevron.up" : "chevron.down")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppColors.textMedium)
                                }
                            }
                            .withMinTouchArea()
                            .makeAccessible(
                                label: "Toggle mood selection",
                                hint: "Select how you're feeling after writing"
                            )
                            
                            if showingMoodPicker {
                                // Mood selection
                                VStack(spacing: 16) {
                                    // Mood buttons
                                    HStack(spacing: 16) {
                                        ForEach(Mood.allCases) { mood in
                                            Button(action: {
                                                selectedMood = mood
                                                HapticFeedback.light()
                                            }) {
                                                VStack(spacing: 8) {
                                                    Text(mood.emoji)
                                                        .font(.system(size: 30))
                                                    
                                                    Text(mood.name)
                                                        .font(AppTextStyles.captionText)
                                                        .foregroundColor(AppColors.textDark)
                                                }
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 8)
                                                .background(selectedMood == mood ? AppColors.primary.opacity(0.1) : Color.clear)
                                                .cornerRadius(AppLayout.smallCornerRadius)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: AppLayout.smallCornerRadius)
                                                        .stroke(selectedMood == mood ? AppColors.primary : Color.clear, lineWidth: 1)
                                                )
                                            }
                                            .buttonStyle(.plain)
                                            .makeAccessible(
                                                label: mood.name,
                                                hint: "Select if you're feeling \(mood.name)"
                                            )
                                        }
                                    }
                                    
                                    // Intensity slider (if mood selected)
                                    if selectedMood != nil && selectedMood != .neutral {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Intensity: \(Int(moodIntensity))/10")
                                                .font(AppTextStyles.body2)
                                                .foregroundColor(AppColors.textMedium)
                                            
                                            Slider(value: $moodIntensity, in: 1...10, step: 1)
                                                .accentColor(AppColors.primary)
                                                .makeAccessible(
                                                    label: "Emotion intensity",
                                                    hint: "Rate the intensity from 1 to 10"
                                                )
                                        }
                                        .padding(.top, 8)
                                    }
                                }
                                .padding()
                                .background(AppColors.cardBackground)
                                .cornerRadius(AppLayout.cornerRadius)
                            } else if let mood = selectedMood {
                                // Selected mood display
                                HStack(spacing: 12) {
                                    Text(mood.emoji)
                                        .font(.system(size: 24))
                                    
                                    Text("Feeling \(mood.name)")
                                        .font(AppTextStyles.body1)
                                        .foregroundColor(AppColors.textDark)
                                    
                                    if mood != .neutral {
                                        Text("(\(Int(moodIntensity))/10)")
                                            .font(AppTextStyles.body2)
                                            .foregroundColor(AppColors.textMedium)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: { selectedMood = nil }) {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 12))
                                            .foregroundColor(AppColors.textMedium)
                                            .padding(8)
                                    }
                                    .withMinTouchArea()
                                }
                                .padding(.vertical, 8)
                            }
                        }
                    }
                    .padding()
                    .onAppear {
                        // If we have an initial prompt and this is a new entry,
                        // automatically populate the content with a starter text
                        if !initialPrompt.isEmpty && isNewEntry && content.isEmpty {
                            content = "Prompt: \(initialPrompt)\n\nMy thoughts:\n"
                        }
                    }
                }
            }
            .background(AppColors.background)
            .navigationTitle(isNewEntry ? "New Journal Entry" : "Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEntry()
                    }
                    .font(AppTextStyles.buttonFont)
                    .foregroundColor(isSaveButtonEnabled ? AppColors.primary : AppColors.textLight)
                    .disabled(!isSaveButtonEnabled)
                }
            }
            // Add sheet presentation for coping strategies
            .sheet(item: $recommendedStrategiesState) { state in
                JournalCopingStrategiesView(recommendationsState: state)
            }
        }
    }
    
    private var promptCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Writing Prompt")
                    .font(AppTextStyles.h4)
                    .foregroundColor(AppColors.textDark)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        showingPrompt = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColors.textLight)
                }
                .makeAccessible(
                    label: "Close prompt",
                    hint: "Hide the writing prompt"
                )
            }
            
            Text(initialPrompt)
                .font(AppTextStyles.body1)
                .foregroundColor(AppColors.textDark)
                .padding(.vertical, 4)
            
            if initialPrompt.contains("rejection") || selectedTags.contains("Rejection") {
                Text("💡 Tip: Writing about rejection experiences can help reduce their emotional impact and build resilience.")
                    .font(AppTextStyles.captionText)
                    .foregroundColor(AppColors.textMedium)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    // Save the journal entry
    private func saveEntry() {
        let entry = JournalEntryModel(
            id: UUID().uuidString,
            date: Date(),
            title: title,
            content: content,
            tags: selectedTags,
            mood: selectedMood,
            moodIntensity: showingMoodPicker && selectedMood != nil ? Int(moodIntensity) : nil
        )
        
        // First save the entry
        onSave(entry)
        
        // Then analyze the journal content for strategies
        let recommendedStrategies = analyzeJournalContentForStrategies(content)
        
        // If we have recommendations, present them
        if !recommendedStrategies.isEmpty {
            recommendedStrategiesState = RecommendedStrategiesState(strategies: recommendedStrategies)
        } else {
            // If no recommendations, dismiss the view
            dismiss()
        }
    }
}

struct TagSelectionButton: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void
    
    private var tagColor: Color {
        switch tag {
        case "Rejection":
            return AppColors.sadness
        case "Insight":
            return AppColors.accent2
        case "Gratitude":
            return AppColors.joy
        case "Habit":
            return AppColors.secondary
        case "Growth":
            return AppColors.calm
        default:
            return AppColors.textMedium
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(tag)
                .font(AppTextStyles.body2)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .foregroundColor(isSelected ? .white : tagColor)
                .background(isSelected ? tagColor : tagColor.opacity(0.1))
                .cornerRadius(16)
        }
        .buttonStyle(.plain)
        .makeAccessible(
            label: tag,
            hint: isSelected ? "Selected tag \(tag)" : "Select tag \(tag)"
        )
    }
}

// MARK: - Detail View

struct JournalEntryDetailView: View {
    let entry: JournalEntryModel
    let onUpdate: (JournalEntryModel?) -> Void
    
    @State private var isEditing = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header info
                    HStack {
                        Text(formatDate(entry.date, format: "EEEE, MMMM d, yyyy"))
                            .font(AppTextStyles.captionText)
                            .foregroundColor(AppColors.textMedium)
                        
                        Spacer()
                        
                        if let mood = entry.mood {
                            HStack(spacing: 6) {
                                Text(mood.emoji)
                                    .font(.system(size: 16))
                                
                                Text("Feeling \(mood.name)")
                                    .font(AppTextStyles.captionText)
                                    .foregroundColor(AppColors.textMedium)
                                
                                if let intensity = entry.moodIntensity, mood != .neutral {
                                    Text("(\(intensity)/10)")
                                        .font(AppTextStyles.captionText)
                                        .foregroundColor(AppColors.textMedium)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(moodColor(for: mood).opacity(0.1))
                            .cornerRadius(16)
                        }
                    }
                    
                    // Title
                    Text(entry.title)
                        .font(AppTextStyles.h2)
                        .foregroundColor(AppColors.textDark)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Tags
                    if !entry.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(entry.tags, id: \.self) { tag in
                                    TagView(tag: tag)
                                }
                            }
                        }
                    }
                    
                    // Content
                    Text(entry.content)
                        .font(AppTextStyles.body1)
                        .foregroundColor(AppColors.textDark)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 8)
                    
                    // Reflection prompts
                    reflectionSection
                }
                .padding()
            }
            .background(AppColors.background.edgesIgnoringSafeArea(.all))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isEditing = true }) {
                        Text("Edit")
                    }
                }
            }
            .sheet(isPresented: $isEditing) {
                JournalEntryEditorView(
                    isNewEntry: false,
                    initialPrompt: "",
                    initialTitle: "",
                    initialTags: [],
                    initialMood: nil,
                    initialMoodIntensity: 5,
                    onSave: onUpdate
                )
            }
        }
    }
    
    // MARK: - Reflection Section
    
    private var reflectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reflection Prompts")
                .font(AppTextStyles.h3)
                .foregroundColor(AppColors.textDark)
            
            VStack(spacing: 16) {
                reflectionPromptCard(
                    prompt: "What did you learn from this experience?",
                    icon: "lightbulb.fill",
                    color: AppColors.accent2
                )
                
                reflectionPromptCard(
                    prompt: "How might this help you grow stronger?",
                    icon: "arrow.up.forward",
                    color: AppColors.calm
                )
                
                reflectionPromptCard(
                    prompt: "What would you tell a friend going through this?",
                    icon: "heart.fill",
                    color: AppColors.joy
                )
            }
        }
        .padding(.top, 16)
    }
    
    private func reflectionPromptCard(prompt: String, icon: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(prompt)
                .font(AppTextStyles.body1)
                .foregroundColor(AppColors.textDark)
            
            Spacer()
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
        .accessibleCard(
            label: "Reflection prompt",
            hint: prompt
        )
    }
    
    private func moodColor(for mood: Mood) -> Color {
        switch mood {
        case .joyful: return AppColors.joy
        case .content: return AppColors.calm
        case .neutral: return AppColors.secondary
        case .sad: return AppColors.sadness
        case .frustrated: return AppColors.frustration
        case .stressed: return AppColors.error
        case .rejected: return AppColors.sadness
        case .angry: return AppColors.frustration
        case .happy: return AppColors.joy
        default: return AppColors.textMedium // Add a default case to handle any future additions to the Mood enum
        }
    }
}

// MARK: - Data Models

enum FilterOption: String, CaseIterable, Identifiable {
    case all
    case rejections
    case insights
    case gratitude
    case habits
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .all: return "All"
        case .rejections: return "Rejections"
        case .insights: return "Insights"
        case .gratitude: return "Gratitude"
        case .habits: return "Habits"
        }
    }
}

// MARK: - Helper Functions

func formatDate(_ date: Date, format: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    return formatter.string(from: date)
}

// MARK: - Sample Data

struct SampleData {
    static let journalEntries = [
        JournalEntryModel(
            id: "1",
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            title: "Processing my Instagram post rejection",
            content: "Today I posted a photo I was really proud of on Instagram. I spent hours editing it and writing a thoughtful caption, but it got barely any engagement. I felt so rejected seeing other similar posts get hundreds of likes while mine just sat there. I'm trying to remind myself that social media isn't a reflection of my worth and that algorithms are unpredictable. Still, it stings to put yourself out there and feel invisible.",
            tags: ["Rejection", "Growth"],
            mood: .sad,
            moodIntensity: 7
        ),
        JournalEntryModel(
            id: "2",
            date: Date(),
            title: "Finding gratitude in small connections",
            content: "Despite feeling down about yesterday's rejection, I noticed something important today. A friend sent me a message saying they appreciated my honesty in a recent conversation. It was a small gesture but made me feel truly seen. I'm grateful for these authentic connections that matter so much more than superficial validation.",
            tags: ["Gratitude", "Insight"],
            mood: .content,
            moodIntensity: 6
        ),
        JournalEntryModel(
            id: "3",
            date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
            title: "Building a healthier relationship with social media",
            content: "I'm committing to a new habit today. I'll set a 30-minute timer for social media use and when it's done, I'll put my phone away. I noticed how much my mood depends on external validation, and I want to break that pattern. I deserve peace that doesn't depend on likes and comments.",
            tags: ["Habit", "Growth"],
            mood: .neutral,
            moodIntensity: nil
        )
    ]
}

struct JournalView_Previews: PreviewProvider {
    static var previews: some View {
        JournalView()
    }
}

// MARK: - Journal Analysis for Coping Strategies

/// Analyzes journal content to extract emotional keywords and recommend coping strategies
func analyzeJournalContentForStrategies(_ text: String) -> [CopingStrategyDetail] {
    // Define emotional keywords and their associated categories
    let emotionalKeywords: [String: CopingStrategyCategory] = [
        // Anxiety-related
        "anxious": .mindfulness,
        "worried": .mindfulness,
        "nervous": .mindfulness,
        "stressed": .mindfulness,
        "overwhelmed": .selfCare,
        "panic": .mindfulness,
        "fear": .cognitive,
        
        // Depression-related
        "sad": .selfCare,
        "depressed": .selfCare,
        "hopeless": .cognitive,
        "lonely": .social,
        "isolated": .social,
        "alone": .social,
        "empty": .creative,
        
        // Anger-related
        "angry": .physical,
        "frustrated": .physical,
        "irritated": .physical,
        "annoyed": .cognitive,
        "resentful": .cognitive,
        
        // Positive emotions (for maintenance)
        "happy": .creative,
        "joyful": .creative,
        "grateful": .mindfulness,
        "content": .mindfulness,
        "peaceful": .mindfulness,
        
        // Relationship-related
        "rejected": .social,
        "betrayed": .social,
        "dismissed": .social,
        "misunderstood": .cognitive
    ]
    
    // Normalize the text
    let normalizedText = text.lowercased()
    
    // Find matching keywords
    var matchedCategories = Set<CopingStrategyCategory>()
    
    for (keyword, category) in emotionalKeywords {
        if normalizedText.contains(keyword) {
            matchedCategories.insert(category)
        }
    }
    
    // If we didn't find any specific matches, default to some general recommendations
    if matchedCategories.isEmpty {
        matchedCategories = [.selfCare, .mindfulness]
    }
    
    // Get recommended strategies
    let copingStrategiesLibrary = LocalCopingStrategiesLibrary.shared
    let allStrategies = copingStrategiesLibrary.strategies
    
    // Filter strategies based on matched categories
    let recommendedStrategies = allStrategies.filter { strategy in
        // Convert local category to global category for comparison
        let globalCategory = copingStrategiesLibrary.mapToGlobalCategory(strategy.category)
        return matchedCategories.contains(globalCategory)
    }
    
    // Return up to 5 strategies (shuffled for variety)
    let localStrategies = Array(recommendedStrategies.shuffled().prefix(5))
    
    // Convert local strategies to global strategies
    return localStrategies.map { $0.toGlobal() }
}

// MARK: - Recommended Strategies View

// Environment object to track presentation state of recommendations
class RecommendedStrategiesState: ObservableObject, Identifiable {
    var id: UUID = UUID()
    @Published var isPresented: Bool = false
    let strategies: [CopingStrategyDetail]
    
    init(strategies: [CopingStrategyDetail]) {
        self.strategies = strategies
    }
}

struct JournalCopingStrategiesView: View {
    @ObservedObject var recommendationsState: RecommendedStrategiesState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                Text("Based on your journal entry, we recommend these coping strategies:")
                    .font(AppTextStyles.h3)
                    .foregroundColor(AppColors.textDark)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Strategy list
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(recommendationsState.strategies) { strategy in
                            strategyCard(for: strategy)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Footer with additional guidance
                Text("Tap any strategy to view details and get started")
                    .font(AppTextStyles.body2)
                    .foregroundColor(AppColors.textMedium)
                    .padding(.bottom)
            }
            .padding(.top)
            .background(AppColors.background.edgesIgnoringSafeArea(.all))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Recommended For You")
                        .font(AppTextStyles.h3)
                        .foregroundColor(AppColors.textDark)
                }
            }
        }
    }
    
    // Strategy card view
    private func strategyCard(for strategy: CopingStrategyDetail) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with title and category
            HStack {
                Text(strategy.title)
                    .font(AppTextStyles.h3)
                    .foregroundColor(AppColors.textDark)
                Spacer()
                Text(strategy.category.rawValue)
                    .font(AppTextStyles.captionText)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(strategy.category.color)
                    .cornerRadius(12)
            }
            
            // Description
            Text(strategy.description)
                .font(AppTextStyles.body2)
                .foregroundColor(AppColors.textMedium)
                .multilineTextAlignment(.leading)
            
            // Time and intensity
            HStack {
                Label(strategy.timeToComplete, systemImage: "clock")
                    .font(AppTextStyles.captionText)
                    .foregroundColor(AppColors.textMedium)
                
                Spacer()
                
                Text(strategy.intensity.rawValue)
                    .font(AppTextStyles.captionText)
                    .foregroundColor(strategy.intensity.color)
            }
            
            // Get started button
            NavigationLink(destination: strategyDetailView(for: strategy)) {
                Text("Get Started")
                    .font(AppTextStyles.body2.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppColors.primary)
                    .cornerRadius(AppLayout.cornerRadius)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // Create a strategy detail view
    private func strategyDetailView(for strategy: CopingStrategyDetail) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Category badge
                Text(strategy.category.rawValue)
                    .font(AppTextStyles.captionText)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(strategy.category.color)
                    .cornerRadius(12)
                
                // Title
                Text(strategy.title)
                    .font(AppTextStyles.h2)
                    .foregroundColor(AppColors.textDark)
                
                // Description
                Text(strategy.description)
                    .font(AppTextStyles.body1)
                    .foregroundColor(AppColors.textMedium)
                    .padding(.bottom, 10)
                
                // Time and intensity
                HStack(spacing: 16) {
                    VStack(alignment: .leading) {
                        Text("TIME")
                            .font(AppTextStyles.captionText)
                            .foregroundColor(AppColors.textMedium)
                        Label(strategy.timeToComplete, systemImage: "clock")
                            .font(AppTextStyles.body2)
                            .foregroundColor(AppColors.textDark)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("INTENSITY")
                            .font(AppTextStyles.captionText)
                            .foregroundColor(AppColors.textMedium)
                        Text(strategy.intensity.rawValue)
                            .font(AppTextStyles.body2)
                            .foregroundColor(strategy.intensity.color)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 10)
                
                // Steps section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Steps to Follow")
                        .font(AppTextStyles.h3)
                        .foregroundColor(AppColors.textDark)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(Array(strategy.steps.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: 16) {
                                Text("\(index + 1)")
                                    .font(AppTextStyles.h3)
                                    .foregroundColor(.white)
                                    .frame(width: 30, height: 30)
                                    .background(AppColors.primary)
                                    .cornerRadius(15)
                                
                                Text(step)
                                    .font(AppTextStyles.body1)
                                    .foregroundColor(AppColors.textDark)
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 10)
            
            // Tips section if available
            if let tips = strategy.tips, !tips.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Helpful Tips")
                        .font(AppTextStyles.h3)
                        .foregroundColor(AppColors.textDark)
                    
                    ForEach(tips, id: \.self) { tip in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(AppColors.accent2)
                            
                            Text(tip)
                                .font(AppTextStyles.body2)
                                .foregroundColor(AppColors.textMedium)
                        }
                    }
                }
                .padding(.vertical, 10)
            }
            
            // Start now button
            Button(action: {
                // Add tracking logic for strategy use
                dismiss()
            }) {
                Text("I've Completed This")
                    .font(AppTextStyles.body1.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppColors.primary)
                    .cornerRadius(AppLayout.cornerRadius)
            }
            .padding(.top, 20)
        }
        .padding()
    }
} 