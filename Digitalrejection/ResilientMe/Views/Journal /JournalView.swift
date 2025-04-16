//
//  JournalView.swift
//  ResillientMe
//
//  Created by Sayed Mohamed on 21.03.25.
//

import SwiftUI
import Foundation
import ResilientMe
import UIKit

// MARK: - Extensions

typealias HapticFeedback = ResilientMe.LocalHapticFeedback

extension View {
    @ViewBuilder func withMinTouchArea(size: CGFloat = 44) -> some View {
        ZStack {
            self
            Color.clear
                .frame(width: size, height: size)
                .contentShape(Rectangle())
        }
    }
    
    func makeAccessible(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
    }
    
    func withDynamicTypeSize() -> some View {
        return self
            .dynamicTypeSize(...DynamicTypeSize.accessibility3)
    }
}

// MARK: - Data Types

// Type aliases for backward compatibility
typealias CopingStrategyDetail = ResilientMe.CoreStrategyDetail
typealias CopingStrategyCategory = ResilientMe.CoreCopingCategory
typealias StrategyDuration = ResilientMe.CoreStrategyDuration

// Add a JournalMood enum to avoid ambiguity
enum JournalMood: String, CaseIterable, Identifiable {
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

// Define the JournalEntryModel type directly in this file
struct JournalEntryModel: Identifiable, Equatable {
    let id: String
    let date: Date
    let title: String
    let content: String
    let tags: [String]
    let mood: JournalMood?
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
                    .padding(8)
                    .contentShape(Rectangle())
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
                .padding(8)
                .contentShape(Rectangle())
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
                .padding(8)
                .contentShape(Rectangle())
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
    private func getPromptMood() -> JournalMood? {
        guard let promptData = initialPromptData,
              let moodString = promptData["mood"] as? String else {
            return nil
        }
        
        // Convert string to Mood
        switch moodString.lowercased() {
        case "sad": return .sad
        case "anxious": return .anxious
        case "angry": return .angry
        case "overwhelmed": return .overwhelmed
        case "good": return .good
        case "great": return .great
        case "neutral": return .neutral
        default: return nil
        }
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
    @State private var selectedMood: JournalMood?
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
    init(isNewEntry: Bool, initialPrompt: String, initialTitle: String = "", initialTags: [String] = [], initialMood: JournalMood? = nil, initialMoodIntensity: Double = 5.0, onSave: @escaping (JournalEntryModel?) -> Void) {
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
                                        ForEach(JournalMood.allCases) { mood in
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
    
    private func moodColor(for mood: JournalMood) -> Color {
        switch mood {
        case .great: return AppColors.joy
        case .good: return AppColors.calm
        case .neutral: return AppColors.secondary
        case .sad: return AppColors.sadness
        case .anxious: return AppColors.error
        case .angry: return AppColors.frustration
        case .overwhelmed: return AppColors.error
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
    static let journalEntries: [JournalEntryModel] = [
        JournalEntryModel(
            id: "entry1",
            date: Date().addingTimeInterval(-86400), // Yesterday
            title: "Job Interview Rejection",
            content: "I received a rejection email from the company I interviewed with last week. It's disappointing, but I need to remember that this doesn't define my worth or abilities.",
            tags: ["Rejection", "Career"],
            mood: JournalMood.sad,
            moodIntensity: 7
        ),
        JournalEntryModel(
            id: "entry2",
            date: Date().addingTimeInterval(-172800), // 2 days ago
            title: "Social Media Perspective",
            content: "I've been thinking about how social media impacts my self-esteem. When I see others' successes, I often feel inadequate. I need to remember that people only share their highlights.",
            tags: ["Insight", "Digital"],
            mood: JournalMood.neutral,
            moodIntensity: nil
        )
        // Additional entries can be added here
    ]
}

struct JournalView_Previews: PreviewProvider {
    static var previews: some View {
        JournalView()
    }
}

// MARK: - Journal Analysis for Coping Strategies

/// Analyzes journal content to extract emotional keywords and recommend coping strategies
func analyzeJournalContentForStrategies(_ text: String) -> [LocalCopingStrategyDetail] {
    let emotionalKeywords: [String: ResilientMe.CoreCopingCategory] = [
        "anxious": .cognitive,
        "sad": .selfCare,
        "stress": .mindfulness,
        "lonely": .social,
        "angry": .physical,
        "rejected": .selfCare,
        "calm": .mindfulness,
        "happy": .creative
    ]
    
    let normalizedText = text.lowercased()
    var matchedCategories = Set<ResilientMe.CoreCopingCategory>()
    
    for (keyword, category) in emotionalKeywords {
        if normalizedText.contains(keyword) {
            matchedCategories.insert(category)
        }
    }
    
    if matchedCategories.isEmpty {
        matchedCategories = [.selfCare, .mindfulness]
    }
    
    let copingStrategiesLibrary = LocalCopingStrategiesLibrary.shared
    var recommendedStrategies: [LocalCopingStrategyDetail] = []
    
    for category in matchedCategories {
        // Convert CoreCopingCategory to LocalCopingStrategyCategory for comparison
        let localCategory = coreToLocalCategory(category)
        for strategy in copingStrategiesLibrary.strategies.filter({ $0.category == localCategory }).prefix(2) {
            recommendedStrategies.append(strategy)
        }
    }
    
    return Array(recommendedStrategies.prefix(5))
}

// Helper function to convert CoreCopingCategory to LocalCopingStrategyCategory
private func coreToLocalCategory(_ coreCategory: ResilientMe.CoreCopingCategory) -> LocalCopingStrategyCategory {
    switch coreCategory {
    case .mindfulness: return .mindfulness
    case .cognitive: return .cognitive
    case .physical: return .physical
    case .social: return .social
    case .creative: return .creative
    case .selfCare: return .selfCare
    }
}

// Helper function to convert time strings to duration enum
private func getDurationFromTimeString(_ timeString: String) -> ResilientMe.CoreStrategyDuration {
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

// Conversion function to map between engine and core strategy types
private func convertEngineToCore(_ engineCategory: ResilientMe.EngineModels.StrategyCategory) -> ResilientMe.CoreCopingCategory {
    switch engineCategory {
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
    @Published var strategies: [LocalCopingStrategyDetail]
    
    init(strategies: [LocalCopingStrategyDetail]) {
        self.strategies = strategies
    }
}

struct JournalCopingStrategiesView: View {
    @StateObject var recommendationsState: RecommendedStrategiesState
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
    
    private func strategyCard(for strategy: LocalCopingStrategyDetail) -> some View {
        Button(action: {
            // Show strategy details
        }) {
        VStack(alignment: .leading, spacing: 12) {
                // Category badge
                Text(strategy.category.displayName)
                    .font(AppTextStyles.buttonFont)
                    .foregroundColor(getCategoryColor(strategy.category))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(getCategoryColor(strategy.category).opacity(0.1))
                    .cornerRadius(16)
                
                // Strategy title
                Text(strategy.title)
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
                        title: { Text(strategy.timeToComplete) },
                        icon: { Image(systemName: "clock") }
                    )
                    .font(AppTextStyles.captionText)
                    .foregroundColor(AppColors.textMedium)
                
                    Spacer()
                
                    Text("View Strategy")
                        .font(AppTextStyles.buttonFont)
                        .foregroundColor(getCategoryColor(strategy.category))
                }
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(AppLayout.cornerRadius)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilitySortPriority(1)
    }
    
    private func strategyDetailView(for strategy: LocalCopingStrategyDetail) -> some View {
        VStack(spacing: 24) {
            // Header with title
            VStack(spacing: 16) {
                Text(strategy.title)
                    .font(AppTextStyles.h1)
                    .foregroundColor(AppColors.textDark)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Category and time needed
                HStack(spacing: 16) {
                    // Category badge
                    Label(
                        title: { Text(strategy.category.displayName) },
                        icon: { Image(systemName: getCategoryIcon(strategy.category)) }
                    )
                    .font(AppTextStyles.captionText)
                    .foregroundColor(getCategoryColor(strategy.category))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(getCategoryColor(strategy.category).opacity(0.1))
                    .cornerRadius(16)
                    
                    // Time badge
                    Label(
                        title: { Text(strategy.timeToComplete) },
                        icon: { Image(systemName: "clock") }
                    )
                    .font(AppTextStyles.captionText)
                    .foregroundColor(AppColors.textMedium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                }
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
                                .background(getCategoryColor(strategy.category))
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
            
            // Start button
            Button(action: {
                // Start the strategy
            }) {
                Text("Start Now")
                    .font(AppTextStyles.buttonFont)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(getCategoryColor(strategy.category))
                    .cornerRadius(AppLayout.cornerRadius)
            }
            .padding(.top, 8)
        }
        .padding()
    }
    
    // Helper functions for styling with the updated types
    private func getCategoryColor(_ category: LocalCopingStrategyCategory) -> Color {
        switch category {
        case .mindfulness: return .blue
        case .cognitive: return .purple
        case .physical: return .green
        case .social: return .orange
        case .creative: return .pink
        case .selfCare: return .red
        }
    }
    
    private func getCategoryIcon(_ category: LocalCopingStrategyCategory) -> String {
        switch category {
        case .mindfulness: return "brain.head.profile"
        case .cognitive: return "lightbulb"
        case .physical: return "figure.walk"
        case .social: return "person.2"
        case .creative: return "paintbrush"
        case .selfCare: return "heart"
        }
    }
}

// Add the analyzeSentiment function to fix the context inference issues with 'sad', 'content', 'neutral', and 'nil'.
private func analyzeSentiment(in text: String) -> (emotion: String, intensity: Double)? {
    // This is a simple implementation - in a real app, this would use NLP
    // Check for negative emotions
    let negativeEmotions = [
        "sad": 0.7,
        "angry": 0.8,
        "anxious": 0.75,
        "frustrated": 0.65,
        "disappointed": 0.6,
        "rejected": 0.85,
        "hurt": 0.7,
        "worried": 0.6
    ]
    
    // Check for positive emotions
    let positiveEmotions = [
        "happy": 0.8,
        "grateful": 0.85,
        "hopeful": 0.7,
        "excited": 0.9,
        "proud": 0.75,
        "peaceful": 0.6,
        "confident": 0.8,
        "loved": 0.9
    ]
    
    // Detect emotions
    let lowercasedText = text.lowercased()
    
    // Check negative first (prioritizing what might need attention)
    for (emotion, baseIntensity) in negativeEmotions {
        if lowercasedText.contains(emotion) {
            return (emotion, baseIntensity)
        }
    }
    
    // Then check positive
    for (emotion, baseIntensity) in positiveEmotions {
        if lowercasedText.contains(emotion) {
            return (emotion, baseIntensity)
        }
    }
    
    // Default to neutral if no strong emotions detected
    if text.count > 50 {
        return ("neutral", 0.5)  // Some content but no strong emotions
    }
    
    return nil  // Not enough content to determine
}

// Convert sentiment to JournalMood
private func moodFromSentiment(_ sentiment: (emotion: String, intensity: Double)?) -> JournalMood? {
    guard let sentiment = sentiment else { return nil }
    
    switch sentiment.emotion.lowercased() {
    case "sad", "disappointed", "hurt":
        return .sad
    case "angry", "frustrated":
        return .angry
    case "anxious", "worried", "stressed", "overwhelmed":
        return .anxious
    case "happy", "excited", "proud", "confident":
        return .great
    case "grateful", "peaceful", "hopeful", "loved":
        return .good
    case "neutral":
        return .neutral
    default:
        return nil
    }
}

// Only keep the extension if it's not already defined elsewhere
// Add displayName extension to LocalCopingStrategyCategory if it doesn't exist
extension LocalCopingStrategyCategory {
    var displayName: String {
        switch self {
        case .mindfulness: return "Mindfulness"
        case .cognitive: return "Cognitive"
        case .physical: return "Physical"
        case .social: return "Social"
        case .creative: return "Creative"
        case .selfCare: return "Self-Care"
        }
    }
} 