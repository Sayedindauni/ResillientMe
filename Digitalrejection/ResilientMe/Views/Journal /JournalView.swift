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

// Use local HapticFeedback directly rather than ResilientMe.LocalHapticFeedback

// MARK: - Data Types

// Type aliases for backward compatibility
// typealias CopingStrategyDetail = ResilientMe.CoreStrategyDetail // Moved to JournalModels.swift
// typealias CopingStrategyCategory = ResilientMe.CoreCopingCategory // Moved to JournalModels.swift
// typealias StrategyDuration = ResilientMe.CoreStrategyDuration // Moved to JournalModels.swift

// Add a JournalMood enum to avoid ambiguity
// enum JournalMood: String, CaseIterable, Identifiable { ... } // Moved to JournalModels.swift

// Define the JournalEntryModel type directly in this file
// struct JournalEntryModel: Identifiable, Equatable { ... } // Moved to JournalModels.swift

/// The main Journal view that displays a searchable, filterable list of journal entries
/// and provides navigation to create, view, and edit entries.
struct JournalView: View {
    // MARK: - Properties
    
    @State private var showingNewEntry = false
    @State private var selectedEntry: JournalEntryModel? = nil
    @State private var searchText = ""
    @State private var filterOption: FilterOption = .all
    
    #if DEBUG
    // Use sample data for previews and development
    @State private var journalEntries: [JournalEntryModel] = SampleData.journalEntries
    #else
    // Use empty array for production, entries will be loaded from data store
    @State private var journalEntries: [JournalEntryModel] = []
    #endif
    
    // Properties to handle mood tracking integration
    var initialPromptData: [String: Any]?
    var showNewEntryOnAppear: Bool
    
    // MARK: - Initializers
    
    /// Initialize without parameters for standard journal view
    init() {
        self.initialPromptData = nil
        self.showNewEntryOnAppear = false
    }
    
    /// Initialize with prompt data for mood tracking integration
    init(initialPromptData: [String: Any]?, showNewEntryOnAppear: Bool) {
        self.initialPromptData = initialPromptData
        self.showNewEntryOnAppear = showNewEntryOnAppear
    }
    
    // MARK: - Computed Properties
    
    /// Filtered journal entries based on search text and selected filter
    private var filteredEntries: [JournalEntryModel] {
        var entries = journalEntries
        
        // Apply search
        if !searchText.isEmpty {
            entries = entries.filter { 
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply filter by tag
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
    
    // MARK: - Body
    
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
                        LocalHapticFeedback.success()
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
    
    // MARK: - Subviews
    
    /// Search bar and filter buttons
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
    
    /// List of journal entries
    private var entriesList: some View {
        List {
            ForEach(filteredEntries) { entry in
                JournalEntryRow(entry: entry)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedEntry = entry
                    }
                    // Replacing custom makeAccessible with standard .accessibilityElement
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(entry.title)
                    .accessibilityHint("Journal entry from \(entry.date.formatted(format: "MMMM d"))")
                    .listRowBackground(AppColors.cardBackground)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
        }
        .listStyle(.plain)
    }
    
    /// Empty state view when no entries match the current filter/search
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
    
    /// Get the prompt content from initialPromptData
    private func getPromptContent() -> String {
        if let promptData = initialPromptData, let prompt = promptData["prompt"] as? String {
            return prompt
        }
        return AppCopy.randomJournalPrompt()
    }
    
    /// Get the title from initialPromptData
    private func getPromptTitle() -> String {
        if let promptData = initialPromptData, let title = promptData["title"] as? String {
            return title
        }
        return ""
    }
    
    /// Get suggested tags from initialPromptData
    private func getPromptTags() -> [String] {
        if let promptData = initialPromptData, let tags = promptData["tags"] as? [String] {
            return tags
        }
        return []
    }
    
    /// Get mood from initialPromptData
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
    
    /// Get mood intensity from initialPromptData
    private func getPromptMoodIntensity() -> Double {
        if let promptData = initialPromptData, let intensity = promptData["moodIntensity"] as? Int {
            // Convert 1-5 scale to 1-10 scale
            return Double(intensity) * 2
        }
        return 5.0
    }
}

// MARK: - Editor View

// struct JournalEntryEditorView: View { ... } // Moved to JournalEntryEditorView.swift

// MARK: - Data Models

// enum FilterOption: String, CaseIterable, Identifiable { ... } // Moved to JournalModels.swift

// MARK: - Helper Functions

// func formatDate(_ date: Date, format: String) -> String { ... } // Moved to Date+Formatting.swift

// MARK: - Sample Data (Debug Only)

#if DEBUG
/// Sample data for previews and development
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
        ),
        // Additional entries can be added here for testing
        JournalEntryModel(
            id: "entry3",
            date: Date().addingTimeInterval(-259200), // 3 days ago
            title: "Morning Gratitude",
            content: "Today I'm grateful for the peaceful morning walk I had. The weather was perfect and I took time to notice little details in nature that I usually miss.",
            tags: ["Gratitude", "Personal"],
            mood: JournalMood.good,
            moodIntensity: 8
        ),
        JournalEntryModel(
            id: "entry4",
            date: Date().addingTimeInterval(-345600), // 4 days ago
            title: "New Exercise Habit",
            content: "Started a morning yoga routine that's only 10 minutes. It seems small but I think building consistency with a short practice will be more sustainable than trying to do too much at once.",
            tags: ["Habit", "Health"],
            mood: JournalMood.great,
            moodIntensity: 9
        )
    ]
}

struct JournalView_Previews: PreviewProvider {
    static var previews: some View {
        JournalView()
    }
}
#endif

// MARK: - Journal Analysis for Coping Strategies

// Everything below this line should have been moved to other files already
