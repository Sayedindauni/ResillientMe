//
//  MoodEntryExtensions.swift
//  ResilientMe
//
//  Created by Team on 23.03.2025.
//

import Foundation
import CoreData
import ResilientMe

// Extension to create a MoodEntryEntity object from ContentView
// Use direct extension with fully-qualified CoreData module path
extension MoodEntryEntity {
    // Factory method to create a MoodEntryEntity with the contentView parameters
    @discardableResult
    static func create(
        withID id: String,
        date: Date,
        mood: String,
        intensity: Int,
        note: String?,
        rejectionTrigger: String?,
        copingStrategy: String?,
        in context: NSManagedObjectContext
    ) -> MoodEntryEntity {
        let entry = MoodEntryEntity(context: context)
        // Use setValue to avoid direct property access issues
        entry.setValue(id, forKey: "id")
        entry.setValue(date, forKey: "date")
        entry.setValue(mood, forKey: "mood")
        entry.setValue(Int16(intensity), forKey: "intensity")
        entry.setValue(note, forKey: "note")
        entry.setValue(rejectionTrigger, forKey: "rejectionTrigger")
        entry.setValue(copingStrategy, forKey: "copingStrategy")
        entry.setValue(rejectionTrigger != nil, forKey: "rejectionRelated")
        entry.setValue(false, forKey: "journalPromptShown")
        
        return entry
    }
    
    // Add mock array support for in-memory testing
    static func create(fromArray entries: [MoodEntryEntity]) -> [MoodEntryEntity] {
        return entries
    }
}
