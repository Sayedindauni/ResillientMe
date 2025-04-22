import SwiftUI
import CoreData
import ResilientMe
import Charts

// MARK: - MoodJournalView

struct MoodJournalView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @ObservedObject var moodAnalysisEngine: ResilientMe.MoodAnalysisEngine
    @EnvironmentObject var moodStore: ResilientMe.CoreDataMoodStore
    
    // Shared state
    @State private var activeTab: ViewTab = .journal
    @State private var showAddNewEntry = false
    
    // Journal states
    @State private var journalEntries: [JournalEntryModel] = LocalSampleData.journalEntries
    @State private var selectedEntry: JournalEntryModel? = nil
    @State private var searchText = ""
    @State private var filterOption: LocalFilterOption = .all
    
    // Mood states (used for the form)
    @State private var formSelectedMood: String? = nil
    @State private var formMoodIntensity: Int = 3
    @State private var formMoodNote: String = ""
    @State private var formIsRejectionRelated: Bool = false
    @State private var formRejectionTrigger: String = ""
    @State private var editingEntryId: String? = nil
    
    // Enum for internal tab switching
    enum ViewTab {
        case journal
        case mood
        case history
        case insights
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top tab selector
                segmentedTabSelector
                
                // Content based on selected tab
                ScrollView {
                    VStack(spacing: 16) {
                        switch activeTab {
                        case .journal:
                            journalView
                        case .mood:
                            moodEntryView
                        case .history:
                            historyView
                        case .insights:
                            insightsView
                        }
                    }
                    .padding(.bottom, 16)
                }
            }
            .navigationTitle("Journal & Mood")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        editingEntryId = nil
                        resetMoodForm()
                        showAddNewEntry = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .accessibilityLabel("Add new entry")
                }
            }
            .sheet(isPresented: $showAddNewEntry) {
                if activeTab == .journal {
                    JournalEntryEditorView(isNewEntry: true, initialPrompt: "") { newEntry in
                        if let newEntry = newEntry {
                            journalEntries.insert(newEntry, at: 0)
                        }
                        editingEntryId = nil
                    }
                } else {
                    quickMoodEntrySheet
                }
            }
            .sheet(item: $selectedEntry) { entry in
                JournalEntryDetailView(entry: entry) { updatedEntry in
                    if let updatedEntry = updatedEntry, 
                       let index = journalEntries.firstIndex(where: { $0.id == updatedEntry.id }) {
                        journalEntries[index] = updatedEntry
                    }
                }
            }
        }
        .onAppear(perform: loadEntryForEditing)
        .onChange(of: navigationCoordinator.journalEditingEntryId) { _ in
            print("Coordinator ID changed, attempting load...")
            loadEntryForEditing()
        }
    }
    
    // MARK: - Segmented Tab Selector
    
    private var segmentedTabSelector: some View {
        HStack(spacing: 0) {
            tabButton(title: "Journal", icon: "book.fill", tab: .journal)
            tabButton(title: "Mood", icon: "heart.fill", tab: .mood)
            tabButton(title: "History", icon: "clock.arrow.circlepath", tab: .history)
            tabButton(title: "Insights", icon: "chart.bar.fill", tab: .insights)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .overlay(Divider().opacity(0.3), alignment: .bottom)
    }
    
    private func tabButton(title: String, icon: String, tab: ViewTab) -> some View {
        Button(action: { activeTab = tab }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(title)
                    .font(.system(size: 12))
            }
            .foregroundColor(activeTab == tab ? Color.blue : Color.gray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                activeTab == tab ? 
                    Color.blue.opacity(0.1) : Color.clear
            )
            .cornerRadius(8)
        }
        .accessibilityLabel(title)
    }
    
    // MARK: - Journal View
    
    private var journalView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Search and filter
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color.gray)
                
                TextField("Search entries", text: $searchText)
                    .font(.system(size: 16))
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color.gray)
                    }
                    .padding(8)
                }
            }
            .padding(10)
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .padding(.horizontal)
            
            // Filter options
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(LocalFilterOption.allCases) { option in
                        LocalFilterButton(
                            title: option.title,
                            isSelected: filterOption == option,
                            action: { filterOption = option }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            // Journal entries list
            if filteredEntries.isEmpty {
                emptyEntriesView
            } else {
                entriesList
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Mood Entry View
    
    private var moodEntryView: some View {
        VStack(spacing: 24) {
            // Supportive message
            Text("How are you feeling right now?")
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
            
            // Mood selection grid
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 16) {
                ForEach(predefinedMoods, id: \.self) { mood in
                    moodButton(mood: mood)
                }
            }
            .padding(.horizontal)
            
            // Intensity slider (only if mood is selected)
            if formSelectedMood != nil {
                VStack(spacing: 8) {
                    Text("How intense is this feeling?")
                        .font(.headline)
                    
                    HStack {
                        Text("Mild")
                            .font(.callout)
                            .foregroundColor(.gray)
                        
                        Slider(value: Binding(
                            get: { Double(formMoodIntensity) },
                            set: { formMoodIntensity = Int($0) }
                        ), in: 1...5, step: 1)
                        .accentColor(.blue)
                        
                        Text("Strong")
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                    
                    Text("Intensity: \(formMoodIntensity)")
                        .font(.callout)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.5))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Rejection related
                Toggle(isOn: $formIsRejectionRelated) {
                    Text("Is this related to rejection?")
                        .font(.headline)
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.5))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Note field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Add a note (optional)")
                        .font(.headline)
                    
                    TextEditor(text: $formMoodNote)
                        .frame(minHeight: 100)
                        .padding(8)
                        .background(Color(.systemGray6).opacity(0.5))
                        .cornerRadius(8)
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.3))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Quick add to journal button
                Button(action: {
                    addMoodAndPromptForJournal()
                }) {
                    HStack {
                        Image(systemName: "arrow.right.doc.on.clipboard")
                        Text("Save and Add to Journal")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Save button
                Button(action: {
                    saveMoodEntry()
                }) {
                    Text("Save Mood")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom, 16)
    }
    
    // MARK: - History View
    
    private var historyView: some View {
        VStack(spacing: 16) {
            Text("Your Mood & Journal History")
                .font(.headline)
                .padding(.top, 8)
            
            // Combined history entries
            ForEach(combinedHistoryEntries) { entry in
                combinedHistoryEntryRow(entry: entry)
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Insights View
    
    private var insightsView: some View {
        VStack(spacing: 24) {
            Text("Your Mood & Journal Insights")
                .font(.headline)
                .padding(.top, 8)
            
            // Mood distribution chart
            VStack(alignment: .leading, spacing: 8) {
                Text("Mood Distribution")
                    .font(.headline)
                    .padding(.horizontal)
                
                if #available(iOS 16.0, *) {
                    Chart {
                        ForEach(moodDistribution, id: \.mood) { item in
                            BarMark(
                                x: .value("Mood", item.mood),
                                y: .value("Count", item.count)
                            )
                            .foregroundStyle(moodColor(for: item.mood))
                        }
                    }
                    .frame(height: 200)
                    .padding()
                } else {
                    Text("Charts available on iOS 16 and later")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .background(Color(.systemGray6).opacity(0.5))
            .cornerRadius(12)
            .padding(.horizontal)
            
            // Journal entry patterns
            VStack(alignment: .leading, spacing: 8) {
                Text("Journal Entry Patterns")
                    .font(.headline)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                        Text("Most Active Day: Friday")
                    }
                    
                    HStack {
                        Image(systemName: "tag")
                            .foregroundColor(.blue)
                        Text("Most Common Tag: Rejection")
                    }
                    
                    HStack {
                        Image(systemName: "heart")
                            .foregroundColor(.blue)
                        Text("Common Mood: Anxious")
                    }
                }
                .padding()
            }
            .background(Color(.systemGray6).opacity(0.5))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Helper Views
    
    private var entriesList: some View {
        LazyVStack(spacing: 12) {
            ForEach(filteredEntries) { entry in
                LocalJournalEntryRow(entry: entry)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedEntry = entry
                    }
                    .padding(.horizontal)
            }
        }
    }
    
    private var emptyEntriesView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "book.fill")
                .font(.system(size: 60))
                .foregroundColor(Color.blue.opacity(0.5))
            
            Text("No journal entries found")
                .font(.title3)
                .multilineTextAlignment(.center)
            
            Button(action: { showAddNewEntry = true }) {
                HStack {
                    Image(systemName: "plus")
                    Text("New Entry")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(12)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    private func moodButton(mood: String) -> some View {
        VStack {
            Text(moodEmoji(for: mood))
                .font(.system(size: 30))
            
            Text(mood)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .frame(width: 80, height: 80)
        .background(formSelectedMood == mood ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(formSelectedMood == mood ? Color.blue : Color.clear, lineWidth: 2)
        )
        .onTapGesture {
            formSelectedMood = mood
        }
    }
    
    private var quickMoodEntrySheet: some View {
        VStack(spacing: 20) {
            Text("Quick Mood Check")
                .font(.title2)
                .bold()
                .padding(.top)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 16) {
                ForEach(predefinedMoods, id: \.self) { mood in
                    moodButton(mood: mood)
                }
            }
            .padding(.horizontal)
            
            if formSelectedMood != nil {
                VStack(spacing: 16) {
                    // Intensity
                    HStack {
                        Text("Intensity:")
                            .font(.headline)
                        
                        Slider(value: Binding(
                            get: { Double(formMoodIntensity) },
                            set: { formMoodIntensity = Int($0) }
                        ), in: 1...5, step: 1)
                        .accentColor(.blue)
                        
                        Text("\(formMoodIntensity)")
                            .frame(width: 25)
                    }
                    
                    // Save buttons
                    HStack {
                        Button(action: {
                            saveMoodEntry()
                            showAddNewEntry = false
                        }) {
                            Text("Save")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            addMoodAndPromptForJournal()
                            showAddNewEntry = false
                        }) {
                            Text("Add to Journal")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
            
            Button(action: {
                showAddNewEntry = false
            }) {
                Text("Cancel")
                    .font(.headline)
                    .foregroundColor(.red)
            }
            .padding()
        }
        .padding()
    }
    
    private func combinedHistoryEntryRow(entry: CombinedHistoryEntry) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(formatDate(entry.date))
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                if entry.type == .mood && entry.mood != nil {
                    Text(moodEmoji(for: entry.mood!))
                        .font(.title3)
                } else if entry.type == .journal {
                    Image(systemName: "book.fill")
                        .foregroundColor(.blue)
                }
            }
            
            if entry.type == .journal && entry.title != nil {
                Text(entry.title!)
                    .font(.headline)
            }
            
            if entry.content != nil {
                Text(entry.content!)
                    .font(.body)
                    .lineLimit(2)
            }
            
            if entry.type == .mood && entry.mood != nil {
                HStack {
                    Text(entry.mood!)
                        .font(.headline)
                    
                    if entry.intensity != nil {
                        Text("(Intensity: \(entry.intensity!))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
    }
    
    // MARK: - Helper Methods
    
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
    
    private func saveMoodEntry() {
        guard let mood = formSelectedMood else { return }
        
        if let currentEditingId = editingEntryId {
            // --- UPDATE existing entry --- 
            let updatedEntryData = ResilientMe.MoodData(
                id: currentEditingId,
                date: Date(),
                mood: mood,
                intensity: formMoodIntensity,
                note: formMoodNote.isEmpty ? nil : formMoodNote,
                rejectionRelated: formIsRejectionRelated,
                rejectionTrigger: formIsRejectionRelated ? formRejectionTrigger : nil
            )
            
            // !!! IMPORTANT: You MUST implement updateMoodEntry in CoreDataMoodStore !!!
            // moodStore.updateMoodEntry(entry: updatedEntryData) // Commented out until implemented
            print("--- UPDATE LOGIC NEEDED in CoreDataMoodStore for ID: \(currentEditingId) ---")
            print("MoodJournalView: Would update entry ID: \(currentEditingId) with mood \(mood)")
            
        } else {
            // --- CREATE new entry --- 
            let newEntry = ResilientMe.MoodData(
                id: UUID().uuidString,
                date: Date(),
                mood: mood,
                intensity: formMoodIntensity,
                note: formMoodNote.isEmpty ? nil : formMoodNote,
                rejectionRelated: formIsRejectionRelated,
                rejectionTrigger: formIsRejectionRelated ? formRejectionTrigger : nil
            )
            moodStore.saveMoodEntry(entry: newEntry)
            print("MoodJournalView: Saved new entry ID \(newEntry.id)")
        }
        
        resetMoodForm()
    }
    
    private func addMoodAndPromptForJournal() {
        guard let mood = formSelectedMood else { return }
        var entryToUseForPrompt: ResilientMe.MoodData? = nil
        
        if let currentEditingId = editingEntryId {
            // --- UPDATE existing entry before prompting --- 
            let updatedEntryData = ResilientMe.MoodData(
                id: currentEditingId,
                date: Date(),
                mood: mood,
                intensity: formMoodIntensity,
                note: formMoodNote.isEmpty ? nil : formMoodNote,
                rejectionRelated: formIsRejectionRelated,
                rejectionTrigger: formIsRejectionRelated ? formRejectionTrigger : nil
            )
            
            // !!! IMPORTANT: You MUST implement updateMoodEntry in CoreDataMoodStore !!!
            // moodStore.updateMoodEntry(entry: updatedEntryData) // Commented out until implemented
            print("--- UPDATE LOGIC NEEDED in CoreDataMoodStore for ID: \(currentEditingId) ---")
            print("MoodJournalView: Would update entry ID \(currentEditingId) before prompting journal.")
            entryToUseForPrompt = updatedEntryData
            
        } else {
            // --- CREATE new entry before prompting --- 
            let newEntry = ResilientMe.MoodData(
                id: UUID().uuidString,
                date: Date(),
                mood: mood,
                intensity: formMoodIntensity,
                note: formMoodNote.isEmpty ? nil : formMoodNote,
                rejectionRelated: formIsRejectionRelated,
                rejectionTrigger: formIsRejectionRelated ? formRejectionTrigger : nil
            )
            moodStore.saveMoodEntry(entry: newEntry)
            print("MoodJournalView: Saved new entry ID \(newEntry.id) before prompting journal.")
            entryToUseForPrompt = newEntry
        }
        
        if let entryData = entryToUseForPrompt {
            prepareJournalPrompt(for: entryData)
        } else {
            print("Error: Could not get entry data to prepare journal prompt.")
        }
        
        resetMoodForm()
    }
    
    private func prepareJournalPrompt(for entry: ResilientMe.MoodData) {
        let (title, prompt, tags) = moodStore.getJournalPromptFor(entry: entry)
        let newJournalEntryModel = JournalEntryModel(
            id: UUID().uuidString,
            date: Date(),
            title: title,
            content: "",
            tags: tags,
            mood: JournalMood(rawValue: entry.mood) ?? .neutral,
            moodIntensity: entry.intensity
        )
        print("MoodJournalView: Preparing journal prompt: \(prompt)")
        selectedEntry = newJournalEntryModel
        
        // Potential Fix: Add a specific state to show the editor
        // @State private var showingJournalEditor = false
        // @State private var journalEditorModel: JournalEntryModel? = nil
        // ... in prepareJournalPrompt ...
        // self.journalEditorModel = newJournalEntryModel
        // self.showingJournalEditor = true
        // ... update sheet modifier to use .sheet(isPresented: $showingJournalEditor) ...
    }
    
    private func resetMoodForm() {
        print("Resetting mood form.")
        formSelectedMood = nil
        formMoodIntensity = 3
        formMoodNote = ""
        formIsRejectionRelated = false
        formRejectionTrigger = ""
        editingEntryId = nil
    }
    
    private func generateJournalPrompt(for mood: String, intensity: Int, isRejectionRelated: Bool) -> String {
        if isRejectionRelated {
            return "I'm feeling \(mood.lowercased()) (intensity: \(intensity)/5) in response to rejection. Here's what happened and how I'm processing it:"
        } else {
            return "I'm feeling \(mood.lowercased()) (intensity: \(intensity)/5) right now. What's contributing to this feeling and how can I respond to it?"
        }
    }
    
    private func moodEmoji(for mood: String) -> String {
        switch mood.lowercased() {
        case "happy", "great": return "😄"
        case "good": return "🙂"
        case "neutral", "okay": return "😐"
        case "sad": return "😢"
        case "anxious": return "😰"
        case "angry": return "😠"
        case "overwhelmed": return "😫"
        default: return "🤔"
        }
    }
    
    private func moodColor(for mood: String) -> Color {
        switch mood.lowercased() {
        case "happy", "great": return .yellow
        case "good": return .green
        case "neutral", "okay": return .blue
        case "sad": return .indigo
        case "anxious": return .purple
        case "angry": return .red
        case "overwhelmed": return .orange
        default: return .gray
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // MARK: - Data Models
    
    private var predefinedMoods: [String] {
        ["Happy", "Good", "Neutral", "Sad", "Anxious", "Angry", "Overwhelmed"]
    }
    
    // Sample mood distribution for the chart
    private var moodDistribution: [(mood: String, count: Int)] {
        [
            ("Happy", 5),
            ("Good", 8),
            ("Neutral", 10),
            ("Sad", 4),
            ("Anxious", 7),
            ("Angry", 2),
            ("Overwhelmed", 3)
        ]
    }
    
    // Combined history entry for the history view
    struct CombinedHistoryEntry: Identifiable {
        enum EntryType {
            case mood
            case journal
        }
        
        let id: String
        let date: Date
        let type: EntryType
        let title: String?
        let content: String?
        let mood: String?
        let intensity: Int?
        
        // Create from mood entry
        static func fromMood(_ moodEntry: ResilientMe.MoodData) -> CombinedHistoryEntry {
            return CombinedHistoryEntry(
                id: moodEntry.id,
                date: moodEntry.date,
                type: .mood,
                title: nil,
                content: moodEntry.note,
                mood: moodEntry.mood,
                intensity: moodEntry.intensity
            )
        }
        
        // Create from journal entry
        static func fromJournal(_ journalEntry: JournalEntryModel) -> CombinedHistoryEntry {
            return CombinedHistoryEntry(
                id: journalEntry.id,
                date: journalEntry.date,
                type: .journal,
                title: journalEntry.title,
                content: journalEntry.content,
                mood: journalEntry.mood?.name,
                intensity: journalEntry.moodIntensity
            )
        }
    }
    
    // Combined mood and journal history entries
    private var combinedHistoryEntries: [CombinedHistoryEntry] {
        var entries: [CombinedHistoryEntry] = []
        
        // Add journal entries
        for journal in journalEntries {
            entries.append(CombinedHistoryEntry.fromJournal(journal))
        }
        
        // Add mood entries
        for mood in moodStore.moodEntries {
            entries.append(CombinedHistoryEntry.fromMood(mood))
        }
        
        // Sort by date (most recent first)
        return entries.sorted(by: { $0.date > $1.date })
    }
    
    // Function to load entry data into form state
    private func loadEntryForEditing() {
        guard let entryId = navigationCoordinator.journalEditingEntryId else {
            print("loadEntryForEditing: No editing ID provided.")
            if activeTab == .mood {
                // resetMoodForm()
            }
            return
        }
        
        print("loadEntryForEditing: Loading entry ID: \(entryId)")
        if let entryToEdit = moodStore.moodEntries.first(where: { $0.id == entryId }) {
            print("loadEntryForEditing: Found entry: \(entryToEdit.mood)")
            formSelectedMood = entryToEdit.mood
            formMoodIntensity = entryToEdit.intensity
            formMoodNote = entryToEdit.note ?? ""
            formIsRejectionRelated = entryToEdit.rejectionRelated
            formRejectionTrigger = entryToEdit.rejectionTrigger ?? ""
            editingEntryId = entryId
            
            activeTab = .mood
            
            DispatchQueue.main.async {
                print("loadEntryForEditing: Clearing coordinator ID.")
                navigationCoordinator.clearJournalEdit()
            }
            
        } else {
            print("MoodJournalView: Entry ID \(entryId) not found in moodStore.moodEntries.")
            DispatchQueue.main.async {
                navigationCoordinator.clearJournalEdit()
            }
            resetMoodForm()
        }
    }
}

// MARK: - Supporting Views

// Rename to avoid conflicts with ResilientMe
// Refactored from struct to enum for proper switch exhaustiveness
enum LocalFilterOption: String, Identifiable, CaseIterable, Equatable {
    case all = "All"
    case rejections = "Rejections"
    case insights = "Insights"
    case gratitude = "Gratitude"
    case habits = "Habits"
    
    // Conform to Identifiable using rawValue
    var id: String { self.rawValue }
    
    // Computed property for display title
    var title: String {
        switch self {
        case .all: return "All"
        case .rejections: return "Rejections"
        case .insights: return "Insights"
        case .gratitude: return "Gratitude"
        case .habits: return "Habits"
        }
    }
    
    // Equatable conformance is synthesized for simple enums
}

struct LocalFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
                .foregroundColor(isSelected ? Color.blue : Color.primary)
                .cornerRadius(16)
        }
    }
}

struct LocalJournalEntryRow: View {
    let entry: JournalEntryModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(formatDate(entry.date))
                    .font(.callout)
                    .foregroundColor(.gray)
                
                Spacer()
                
                if let mood = entry.mood {
                    Text(mood.emoji)
                        .font(.title3)
                }
            }
            
            Text(entry.title)
                .font(.headline)
            
            Text(entry.content)
                .font(.body)
                .lineLimit(2)
                .foregroundColor(.secondary)
            
            if !entry.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(entry.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Sample Data

struct LocalSampleData {
    static var journalEntries: [JournalEntryModel] = [
        JournalEntryModel(
            id: "1",
            date: Date().addingTimeInterval(-86400), // Yesterday
            title: "Dealing with job rejection",
            content: "I received a rejection email from the company I interviewed with last week. It was disappointing, but I'm trying to see it as an opportunity to find a better fit.",
            tags: ["Rejection", "Career"],
            mood: .sad,
            moodIntensity: 4
        ),
        JournalEntryModel(
            id: "2",
            date: Date().addingTimeInterval(-259200), // 3 days ago
            title: "Great progress on project",
            content: "Made significant headway on my personal project today. The code is coming together and I'm feeling confident about the direction.",
            tags: ["Success", "Coding"],
            mood: .good,
            moodIntensity: 4
        ),
        JournalEntryModel(
            id: "3",
            date: Date().addingTimeInterval(-432000), // 5 days ago
            title: "Meditation insights",
            content: "During my meditation session today, I realized I've been holding onto fear of rejection. This awareness feels like the first step to moving past it.",
            tags: ["Insight", "Mindfulness"],
            mood: .neutral,
            moodIntensity: 3
        )
    ]
} 
