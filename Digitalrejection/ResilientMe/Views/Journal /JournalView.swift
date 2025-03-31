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
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
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
    // Entry state
    @State private var title: String
    @State private var content: String
    @State private var selectedTags: [String]
    @State private var selectedMood: Mood?
    @State private var moodIntensity: Double
    
    // Editing state
    @State private var isPromptVisible: Bool = true
    @State private var selectedTabIndex: Int = 0
    @State private var showingTagSelector = false
    @State private var showingDiscardAlert = false
    @State private var isRequestingMoodIntensity = false
    @State private var strategiesRecommendationsState: RecommendedStrategiesState?
    
    // Environment
    @Environment(\.dismiss) private var dismiss
    
    private let isNewEntry: Bool
    private let initialPrompt: String
    private let onSave: (JournalEntryModel?) -> Void
    
    // All available tags for selection
    private let availableTags = ["Personal", "Work", "Health", "Rejection", "Insight", "Gratitude", "Growth", "Habit", "Learning"]
    
    // Initialize with all required parameters
    init(isNewEntry: Bool, initialPrompt: String, initialTitle: String = "", initialTags: [String] = [], initialMood: Mood? = nil, initialMoodIntensity: Double = 5.0, onSave: @escaping (JournalEntryModel?) -> Void) {
        self.isNewEntry = isNewEntry
        self.initialPrompt = initialPrompt
        self.onSave = onSave
        
        // Initialize state variables
        _title = State(initialValue: initialTitle)
        _content = State(initialValue: initialPrompt)
        _selectedTags = State(initialValue: initialTags)
        _selectedMood = State(initialValue: initialMood)
        _moodIntensity = State(initialValue: initialMoodIntensity)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab selector
                editorModeTabView
                
                ZStack {
                    // Main editor area
                ScrollView {
                        VStack(spacing: 16) {
                            // Title field
                            titleField
                            
                            // Content/prompt area
                            if selectedTabIndex == 0 {
                                contentEditorSection
                            } else {
                                moodAndTagsSection
                            }
                        }
                        .padding()
                    }
                    
                    // Action button overlay
                    VStack {
                        Spacer()
                        saveButton
                    }
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
                Button("Discard", role: .destructive) { dismiss() }
                Button("Continue Editing", role: .cancel) { }
            } message: {
                Text("You have unsaved changes that will be lost.")
            }
            .sheet(isPresented: $showingTagSelector) {
                tagSelectorView
                    .withDynamicTypeSize()
            }
            .sheet(item: $strategiesRecommendationsState) { state in
                JournalCopingStrategiesView(recommendationsState: state)
                    .withDynamicTypeSize()
            }
        }
    }
    
    // MARK: - Component Views
    
    private var editorModeTabView: some View {
        HStack {
            Button(action: { selectedTabIndex = 0 }) {
                Text("Content")
                    .font(AppTextStyles.body2)
                    .padding(.vertical, 12)
                    .foregroundColor(selectedTabIndex == 0 ? AppColors.primary : AppColors.textMedium)
                    .frame(maxWidth: .infinity)
                    .background(
                        selectedTabIndex == 0 ?
                            AppColors.primary.opacity(0.1) :
                            Color.clear
                    )
            }
            
            Button(action: { selectedTabIndex = 1 }) {
                Text("Tags & Mood")
                    .font(AppTextStyles.body2)
                    .padding(.vertical, 12)
                    .foregroundColor(selectedTabIndex == 1 ? AppColors.primary : AppColors.textMedium)
                    .frame(maxWidth: .infinity)
                    .background(
                        selectedTabIndex == 1 ?
                            AppColors.primary.opacity(0.1) :
                            Color.clear
                    )
            }
        }
        .background(AppColors.cardBackground)
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
                        VStack(alignment: .leading, spacing: 8) {
            // Prompt if available
            if isPromptVisible && !initialPrompt.isEmpty {
                promptView
            }
            
            // Editor
            Text("Journal Entry")
                                .font(AppTextStyles.body2)
                .foregroundColor(AppColors.textDark)
                            
                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $content)
                                    .font(AppTextStyles.body1)
                                    .padding()
                                    .frame(minHeight: 200)
                                    .background(AppColors.cardBackground)
                                    .cornerRadius(AppLayout.cornerRadius)
                                
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
            // Mood selector
                        VStack(alignment: .leading, spacing: 12) {
                Text("How are you feeling?")
                                        .font(AppTextStyles.body2)
                    .foregroundColor(AppColors.textDark)
                
                // Mood grid
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 16) {
                                        ForEach(Mood.allCases) { mood in
                                            Button(action: {
                            selectedMood = (selectedMood == mood) ? nil : mood
                            if selectedMood != nil && selectedMood != .neutral {
                                isRequestingMoodIntensity = true
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
                }
                
                // Intensity slider if mood is selected
                if let mood = selectedMood, mood != .neutral, isRequestingMoodIntensity {
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
                }
            }
            
            // Tags selector
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
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(selectedTags, id: \.self) { tag in
                                HStack {
                                    Text(tag)
                                        .font(AppTextStyles.smallText)
                                        .foregroundColor(tagColor(for: tag))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(tagColor(for: tag).opacity(0.1))
                                        .cornerRadius(16)
                                    
                                    Button(action: {
                                        selectedTags.removeAll { $0 == tag }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(AppColors.textMedium)
                                            .font(.system(size: 14))
                                    }
                                }
                            }
                        }
                        .padding(8)
                    }
                    .background(AppColors.cardBackground)
                    .cornerRadius(AppLayout.cornerRadius)
                }
            }
        }
    }
    
    private var tagSelectorView: some View {
        VStack(spacing: 16) {
            Text("Select Tags")
                .font(AppTextStyles.h3)
                .foregroundColor(AppColors.textDark)
                .padding(.top)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 12) {
                    ForEach(availableTags, id: \.self) { tag in
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
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            
            Button("Done") {
                showingTagSelector = false
            }
            .font(AppTextStyles.buttonFont)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(AppColors.primary)
            .cornerRadius(AppLayout.cornerRadius)
            .padding()
        }
    }
    
    private var saveButton: some View {
        Button(action: saveEntry) {
            Text("Save Journal Entry")
                .font(AppTextStyles.buttonFont)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(isValidEntry() ? AppColors.primary : AppColors.textLight)
                .cornerRadius(AppLayout.cornerRadius)
        }
        .disabled(!isValidEntry())
    }
    
    // MARK: - Helper Methods
    
    private func isValidEntry() -> Bool {
        return !title.isEmpty && !content.isEmpty
    }
    
    private func hasUnsavedChanges() -> Bool {
        return !title.isEmpty || content != initialPrompt || !selectedTags.isEmpty || selectedMood != nil
    }
    
    private func tagColor(for tag: String) -> Color {
        switch tag {
        case "Rejection": return AppColors.primary
        case "Insight": return AppColors.secondary
        case "Gratitude": return .green
        case "Growth": return .blue
        case "Habit": return .purple
        case "Personal": return .orange
        case "Work": return .pink
        case "Health": return .teal
        case "Learning": return .indigo
        default: return AppColors.textMedium
        }
    }
    
    private func saveEntry() {
        // Create journal entry
        let entry = JournalEntryModel(
            id: UUID().uuidString,
            date: Date(),
            title: title,
            content: content,
            tags: selectedTags,
            mood: selectedMood,
            moodIntensity: selectedMood != nil && selectedMood != .neutral ? Int(moodIntensity) : nil
        )
        
        // First save the entry
        onSave(entry)
        
        // Then analyze for recommendations if relevant content
        if content.count > 50 {
        let recommendedStrategies = analyzeJournalContentForStrategies(content)
        
        if !recommendedStrategies.isEmpty {
                strategiesRecommendationsState = RecommendedStrategiesState(strategies: recommendedStrategies)
        } else {
            dismiss()
        }
        } else {
            dismiss()
        }
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
                        .font(AppTextStyles.h1)
                        .foregroundColor(AppColors.textDark)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Tags
                    if !entry.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(entry.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(AppTextStyles.smallText)
                                        .foregroundColor(AppColors.textMedium)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(AppColors.cardBackground)
                                        .cornerRadius(16)
                                }
                            }
                        }
                    }
                    
                    // Content
                    Text(entry.content)
                        .font(AppTextStyles.body1)
                        .foregroundColor(AppColors.textDark)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer(minLength: 30)
                }
                .padding()
            }
            .background(AppColors.background.edgesIgnoringSafeArea(.all))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") {
                        isEditing = true
                    }
                }
            }
            .sheet(isPresented: $isEditing) {
                JournalEntryEditorView(
                    isNewEntry: false,
                    initialPrompt: entry.content,  // Use entry content as prompt
                    initialTitle: entry.title,
                    initialTags: entry.tags,
                    initialMood: entry.mood,
                    initialMoodIntensity: Double(entry.moodIntensity ?? 5),
                    onSave: { updatedEntry in
                        if let updatedEntry = updatedEntry {
                            onUpdate(updatedEntry)
                        }
                        isEditing = false
                    }
                )
                .withDynamicTypeSize()
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
    // For a real implementation, this would use NLP to find strategies
    // For compilation, this is a simplified implementation
    let emotionalKeywords: [String: CopingStrategyCategory] = [
        "anxious": .cognitive,
        "sad": .selfCare,
        "stress": .mindfulness,
        "lonely": .social,
        "angry": .physical,
        "rejected": .selfCare,
        "calm": .mindfulness,
        "happy": .creative
    ]
    
    // Real implementation would be more sophisticated
    // This is just detecting keywords in the text
    let normalizedText = text.lowercased()
    var matchedCategories = Set<CopingStrategyCategory>()
    
    for (keyword, category) in emotionalKeywords {
        if normalizedText.contains(keyword) {
            matchedCategories.insert(category)
        }
    }
    
    // If no categories matched, suggest general strategies
    if matchedCategories.isEmpty {
        matchedCategories = [.selfCare, .mindfulness]
    }
    
    // Get strategies for matched categories
    let copingStrategiesLibrary = LocalCopingStrategiesLibrary.shared
    var recommendedStrategies: [CopingStrategyDetail] = []
    
    // Convert from LocalCopingStrategyDetail to CopingStrategyDetail
    for category in matchedCategories {
        // Get strategies from the library - use the conversion function
        for strategy in copingStrategiesLibrary.strategies.filter({ convertLocalToGlobalCategory($0.category) == category }).prefix(2) {
            // Convert each strategy to the new format
            let newStrategy = CopingStrategyDetail(
                name: strategy.title,
                description: strategy.description,
                category: convertLocalToGlobalCategory(strategy.category),
                duration: getDurationFromTimeString(strategy.timeToComplete),
                steps: strategy.steps,
                benefits: [],
                researchBacked: false
            )
            recommendedStrategies.append(newStrategy)
        }
    }
    
    // Limit to 5 strategies maximum
    return Array(recommendedStrategies.prefix(5))
}

// Helper function to convert time strings to duration enum
private func getDurationFromTimeString(_ timeString: String) -> StrategyDuration {
    if timeString.contains("Under 2") || timeString.contains("1-2") {
        return .veryShort
    } else if timeString.contains("3-5") || timeString.contains("2-5") {
        return .short
    } else if timeString.contains("5-15") || timeString.contains("10-15") {
        return .medium
    } else {
        return .long
    }
}

// Add a compatibility function to convert between strategy types
private func convertLocalToGlobalCategory(_ localCategory: LocalCopingStrategyCategory) -> CopingStrategyCategory {
    switch localCategory {
    case .mindfulness: return .mindfulness
    case .cognitive: return .cognitive
    case .physical: return .physical
    case .social: return .social
    case .creative: return .creative
    case .selfCare: return .selfCare
    }
}

// MARK: - Recommended Strategies View

// Environment object to track presentation state of recommendations
class RecommendedStrategiesState: ObservableObject, Identifiable {
    public let id = UUID()
    @Published var strategies: [CopingStrategyDetail]
    
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
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
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
    
    private func strategyCard(for strategy: CopingStrategyDetail) -> some View {
        Button(action: {
            // Show strategy details
        }) {
        VStack(alignment: .leading, spacing: 12) {
                // Category badge
                Text(categoryCopy(for: strategy.category))
                    .font(AppTextStyles.buttonFont)
                    .foregroundColor(categoryColor(for: strategy.category))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(categoryColor(for: strategy.category).opacity(0.1))
                    .cornerRadius(16)
                
                // Strategy title
                Text(strategy.name)
                    .font(AppTextStyles.h3)
                    .foregroundColor(AppColors.textDark)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Strategy description
            Text(strategy.description)
                    .font(AppTextStyles.body1)
                .foregroundColor(AppColors.textMedium)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            
                // Footer with time and button
            HStack {
                    // Time to complete
                    Label(
                        title: { Text(getDurationText(for: strategy.duration)) },
                        icon: { Image(systemName: "clock") }
                    )
                    .font(AppTextStyles.captionText)
                    .foregroundColor(AppColors.textMedium)
                
                Spacer()
                
                    Text("View Strategy")
                        .font(AppTextStyles.buttonFont)
                        .foregroundColor(categoryColor(for: strategy.category))
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilitySortPriority(1)
    }
    
    private func strategyDetailView(for strategy: CopingStrategyDetail) -> some View {
        VStack(spacing: 24) {
            // Header with title
            VStack(spacing: 16) {
                Text(strategy.name)
                    .font(AppTextStyles.h1)
                    .foregroundColor(AppColors.textDark)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Category and time needed
                HStack(spacing: 16) {
                    // Category badge
                    Label(
                        title: { Text(categoryCopy(for: strategy.category)) },
                        icon: { Image(systemName: categoryIcon(for: strategy.category)) }
                    )
                            .font(AppTextStyles.captionText)
                    .foregroundColor(categoryColor(for: strategy.category))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(categoryColor(for: strategy.category).opacity(0.1))
                    .cornerRadius(16)
                    
                    // Time badge
                    Label(
                        title: { Text(getDurationText(for: strategy.duration)) },
                        icon: { Image(systemName: "clock") }
                    )
                            .font(AppTextStyles.captionText)
                            .foregroundColor(AppColors.textMedium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                }
                
                // Description
                Text(strategy.description)
                    .font(AppTextStyles.body1)
                    .foregroundColor(AppColors.textMedium)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
                
                // Steps section
                VStack(alignment: .leading, spacing: 16) {
                Text("How to do it")
                    .font(AppTextStyles.h2)
                        .foregroundColor(AppColors.textDark)
                    
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(strategy.steps.enumerated()), id: \.element) { index, step in
                            HStack(alignment: .top, spacing: 16) {
                            // Step number
                                Text("\(index + 1)")
                                    .font(AppTextStyles.h3)
                                    .foregroundColor(.white)
                                .frame(width: 28, height: 28)
                                .background(categoryColor(for: strategy.category))
                                .cornerRadius(14)
                            
                            // Step text
                                Text(step)
                                    .font(AppTextStyles.body1)
                                    .foregroundColor(AppColors.textDark)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            
            // Benefits section if available
            if !strategy.benefits.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Benefits")
                        .font(AppTextStyles.h2)
                        .foregroundColor(AppColors.textDark)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(strategy.benefits, id: \.self) { benefit in
                            HStack(alignment: .top, spacing: 16) {
                                // Bullet point
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(categoryColor(for: strategy.category))
                                
                                // Benefit text
                                Text(benefit)
                                    .font(AppTextStyles.body1)
                                    .foregroundColor(AppColors.textDark)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }
            
            // Start button
            Button(action: {
                // Start the strategy
            }) {
                Text("Start Now")
                    .font(AppTextStyles.buttonFont)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(categoryColor(for: strategy.category))
                    .cornerRadius(AppLayout.cornerRadius)
            }
            .padding(.top, 8)
        }
        .padding()
    }
    
    // Helper functions for styling
    private func categoryCopy(for category: CopingStrategyCategory) -> String {
        category.displayName
    }
    
    private func categoryIcon(for category: CopingStrategyCategory) -> String {
        category.iconName
    }
    
    private func categoryColor(for category: CopingStrategyCategory) -> Color {
        category.color
    }
    
    private func getDurationText(for duration: StrategyDuration) -> String {
        duration.rawValue
    }
}

// Fix the smallText in AppTextStyles
extension AppTextStyles {
    static var smallText: Font {
        .system(size: 12)
    }
} 