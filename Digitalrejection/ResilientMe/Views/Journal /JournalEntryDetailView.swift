import SwiftUI

// MARK: - Detail View

struct JournalEntryDetailView: View {
    let entry: JournalEntryModel // Assumes JournalEntryModel is available
    let onUpdate: (JournalEntryModel?) -> Void // Callback for when editing is done
    
    @State private var isEditing = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header info
                    detailHeader
                    
                    // Title
                    Text(entry.title)
                        .font(AppTextStyles.h1) // Assumes AppTextStyles is available
                        .foregroundColor(AppColors.textDark) // Assumes AppColors is available
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Tags
                    if !entry.tags.isEmpty {
                        tagsScrollView
                    }
                    
                    // Content
                    Text(entry.content)
                        .font(AppTextStyles.body1)
                        .foregroundColor(AppColors.textDark)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Reflection Section (Optional)
                    // reflectionSection 
                    
                    Spacer(minLength: 30)
                }
                .padding()
            }
            .background(AppColors.background.edgesIgnoringSafeArea(.all))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline) // Keep title small
            #endif
            .navigationTitle(entry.title) // Set navbar title to entry title
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") { isEditing = true }
                }
            }
            .sheet(isPresented: $isEditing) {
                // Present the editor view
                JournalEntryEditorView( // Assumes JournalEntryEditorView is available
                    isNewEntry: false,
                    initialPrompt: entry.content, // Use content as prompt for editing
                    initialTitle: entry.title,
                    initialTags: entry.tags,
                    initialMood: entry.mood,
                    initialMoodIntensity: Double(entry.moodIntensity ?? 5),
                    onSave: { updatedEntry in
                        if let updatedEntry = updatedEntry {
                            onUpdate(updatedEntry) // Pass back the updated entry
                        }
                        isEditing = false // Close the sheet
                    }
                )
                // .withDynamicTypeSize() // Apply if View+JournalExtensions is available
            }
        }
        // Apply dynamic type size to the whole NavigationView
        // .withDynamicTypeSize() // Apply if View+JournalExtensions is available
    }
    
    // MARK: - Subviews

    private var detailHeader: some View {
        HStack {
            // Use Date extension for formatting
            Text(entry.date.formatted(format: "EEEE, MMMM d, yyyy"))
                .font(AppTextStyles.captionText)
                .foregroundColor(AppColors.textMedium)
                        
            Spacer()
                        
            if let mood = entry.mood {
                moodBadge(for: mood)
            }
        }
    }

    private func moodBadge(for mood: JournalMood) -> some View {
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
        // Use moodColor() helper from JournalMood
        .background(mood.moodColor().opacity(0.1)) 
        .cornerRadius(16)
    }

    private var tagsScrollView: some View {
         ScrollView(.horizontal, showsIndicators: false) {
             HStack(spacing: 8) {
                 ForEach(entry.tags, id: \.self) { tag in
                     // Use TagView from JournalSupportingViews.swift
                     TagView(tag: tag) 
                 }
             }
         }
    }
    
    // MARK: - Reflection Section (Example)
    
    // This section can be kept or removed based on requirements
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
        // Apply makeAccessible if View+JournalExtensions is available
        // .accessibleCard(
        //     label: "Reflection prompt",
        //     hint: prompt
        // )
    }
    
    // This helper was originally inside JournalEntryDetailView in the monolithic file
    // It's better placed within JournalMood enum itself (added it there in JournalModels.swift)
    /*
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
    */
}

// Need to adjust JournalEntryEditorView init to accept existing content and entry ID
// This requires modifying JournalEntryEditorView.swift
/*
 extension JournalEntryEditorView {
     init(isNewEntry: Bool, 
          initialPrompt: String, 
          initialTitle: String = "", 
          initialContent: String = "", // Added initialContent
          initialTags: [String] = [], 
          initialMood: JournalMood? = nil, 
          initialMoodIntensity: Double = 5.0, 
          entryToEdit: JournalEntryModel? = nil, // Added entryToEdit
          onSave: @escaping (JournalEntryModel?) -> Void) {
         
         self.isNewEntry = isNewEntry
         self.initialPrompt = initialPrompt
         self.onSave = onSave
         self.entryBeingEdited = entryToEdit // Store the entry being edited
         
         _title = State(initialValue: initialTitle)
         // If editing, use initialContent, otherwise use prompt
         _content = State(initialValue: entryToEdit != nil ? initialContent : (isNewEntry ? initialPrompt : "")) 
         _selectedTags = State(initialValue: initialTags)
         _selectedMood = State(initialValue: initialMood)
         _moodIntensity = State(initialValue: initialMoodIntensity)
         _isPromptVisible = State(initialValue: !initialPrompt.isEmpty && entryToEdit == nil)
         _isRequestingMoodIntensity = State(initialValue: initialMood != nil && initialMood != .neutral)
     }

     // Need to modify saveEntry to update existing ID if editing
     private func saveEntry() {
         guard isValidEntry() else { return }
         
         let entryId = entryBeingEdited?.id ?? UUID().uuidString // Use existing ID or generate new

         let entry = JournalEntryModel(
             id: entryId, 
             date: entryBeingEdited?.date ?? Date(), // Use existing date or new
             title: title.trimmingCharacters(in: .whitespacesAndNewlines),
             content: content.trimmingCharacters(in: .whitespacesAndNewlines),
             tags: selectedTags,
             mood: selectedMood,
             moodIntensity: selectedMood != nil && selectedMood != .neutral ? Int(moodIntensity) : nil
         )
         
         onSave(entry)
         // ... rest of saveEntry ...
     }
 }
*/

// Assuming JournalEntryModel, JournalMood, AppTextStyles, AppColors, AppLayout, 
// JournalEntryEditorView, TagView, Date formatting extension are accessible. 