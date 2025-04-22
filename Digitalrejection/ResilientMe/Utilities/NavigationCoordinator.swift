import SwiftUI
import Combine

class NavigationCoordinator: ObservableObject {
    @Published var selectedTab: Int = 0 // Default to Home tab (index 0)
    @Published var journalEditingEntryId: String? = nil

    func navigateToJournal(editingEntryId: String?) {
        print("Coordinator: Navigating to Journal tab, editing ID: \(editingEntryId ?? "nil")")
        journalEditingEntryId = editingEntryId
        // Ensure tab switch happens on the main thread
        DispatchQueue.main.async {
            self.selectedTab = 1 // Index of Journal/Mood tab
        }
    }

    // Optional: Function to clear the editing ID when navigation is complete or cancelled
    func clearJournalEdit() {
        journalEditingEntryId = nil
    }
} 