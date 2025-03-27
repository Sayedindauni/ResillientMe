//
//  MoodEntryExtensions.swift
//  ResilientMe
//
//  Created by Team on 23.03.2025.
//

import Foundation
import CoreData

// Extension to create a MoodEntryEntity object from ContentView
extension MoodEntryEntity {
    // Factory method to create a MoodEntryEntity with the contentView parameters
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
        entry.id = id
        entry.date = date
        entry.mood = mood
        entry.intensity = Int16(intensity)
        entry.note = note
        entry.rejectionTrigger = rejectionTrigger
        entry.copingStrategy = copingStrategy
        entry.rejectionRelated = (rejectionTrigger != nil)
        entry.journalPromptShown = false
        
        return entry
    }
    
    // Add mock array support for in-memory testing
    static func create(fromArray entries: [MoodEntryEntity]) -> [MoodEntryEntity] {
        return entries
    }
}
