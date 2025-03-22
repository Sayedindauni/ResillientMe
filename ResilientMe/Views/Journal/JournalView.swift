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
                    initialPrompt: AppCopy.randomJournalPrompt()
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
                        .font(AppTextStyles.button)
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
                    .font(AppTextStyles.button)
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
                    .font(AppTextStyles.caption)
                    .foregroundColor(AppColors.textMedium)
                
                Spacer()
                
                if !entry.tags.isEmpty {
                    ForEach(entry.tags.prefix(2), id: \.self) { tag in
                        TagView(tag: tag)
                    }
                    
                    if entry.tags.count > 2 {
                        Text("+\(entry.tags.count - 2)")
                            .font(AppTextStyles.caption)
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
                        .font(AppTextStyles.caption)
                    
                    if let intensity = entry.moodIntensity {
                        Text("(\(intensity)/10)")
                            .font(AppTextStyles.caption)
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
            .font(AppTextStyles.caption)
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
    let onSave: (JournalEntryModel?) -> Void
    
    @State private var title = ""
    @State private var content = ""
    @State private var selectedTags: [String] = []
    @State private var selectedMood: Mood?
    @State private var moodIntensity: Double = 5
    @State private var showingPrompt = true
    @State private var showingTagPicker = false
    @State private var showingMoodPicker = false
    @Environment(\.dismiss) private var dismiss
    
    private let availableTags = ["Rejection", "Insight", "Gratitude", "Habit", "Growth"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Editor fields
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Writing prompt card (collapsible)
                        if showingPrompt {
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
                                        .font(AppTextStyles.button)
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
                                                        .font(AppTextStyles.caption)
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
                }
            }
            .background(AppColors.background)
            .navigationTitle(isNewEntry ? "New Entry" : "Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                        onSave(nil)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEntry()
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
        }
    }
    
    // MARK: - Prompt Card
    
    private var promptCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(AppColors.accent1)
                    .font(.system(size: 16))
                
                Text("Journal Prompt")
                    .font(AppTextStyles.h4)
                    .foregroundColor(AppColors.textDark)
                
                Spacer()
                
                Button(action: { 
                    withAnimation {
                        showingPrompt = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textMedium)
                        .padding(8)
                }
                .withMinTouchArea()
            }
            
            Text(initialPrompt)
                .font(AppTextStyles.body1)
                .foregroundColor(AppColors.textMedium)
                .fixedSize(horizontal: false, vertical: true)
            
            Button(action: {
                // Use the prompt
                if title.isEmpty {
                    title = initialPrompt.prefix(30).appending("...")
                }
                if content.isEmpty {
                    content = initialPrompt + "\n\n"
                }
            }) {
                Text("Use This Prompt")
                    .font(AppTextStyles.button)
                    .foregroundColor(AppColors.primary)
            }
            .makeAccessible(
                label: "Use this prompt",
                hint: "Start writing based on this prompt"
            )
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                .stroke(AppColors.accent1.opacity(0.3), lineWidth: 1)
        )
        .transition(.opacity)
        .animation(.easeInOut, value: showingPrompt)
        .accessibleCard(
            label: "Journal prompt",
            hint: initialPrompt
        )
    }
    
    // MARK: - Save Entry
    
    private func saveEntry() {
        // Create new entry from form data
        let newEntry = JournalEntryModel(
            id: UUID().uuidString,
            date: Date(),
            title: title,
            content: content,
            tags: selectedTags,
            mood: selectedMood,
            moodIntensity: selectedMood != nil && selectedMood != .neutral ? Int(moodIntensity) : nil
        )
        
        onSave(newEntry)
        dismiss()
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
                            .font(AppTextStyles.body2)
                            .foregroundColor(AppColors.textMedium)
                        
                        Spacer()
                        
                        if let mood = entry.mood {
                            HStack(spacing: 6) {
                                Text(mood.emoji)
                                    .font(.system(size: 16))
                                
                                Text("Feeling \(mood.name)")
                                    .font(AppTextStyles.caption)
                                    .foregroundColor(AppColors.textMedium)
                                
                                if let intensity = entry.moodIntensity, mood != .neutral {
                                    Text("(\(intensity)/10)")
                                        .font(AppTextStyles.caption)
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