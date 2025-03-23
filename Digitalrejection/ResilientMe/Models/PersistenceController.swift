//
//  PersistenceController.swift
//  ResilientMe
//
//  Created by Sayed Mohamed on 21.03.25.
//

import Foundation
import CoreData

// MARK: - Persistence Controller for Core Data
struct PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample mood entries for preview
        for i in 0..<5 {
            let newItem = MoodEntryEntity(context: viewContext)
            newItem.id = UUID().uuidString
            newItem.date = Date(timeIntervalSinceNow: Double(-i * 86400))
            newItem.mood = ["Happy", "Sad", "Anxious", "Calm", "Angry"][i % 5]
            newItem.intensity = Int16(i % 5 + 1)
            newItem.note = "Sample note for entry \(i+1)"
            newItem.rejectionRelated = i % 2 == 0
            if i % 2 == 0 {
                newItem.rejectionTrigger = "Sample trigger \(i+1)"
                newItem.copingStrategy = "Sample strategy \(i+1)"
            }
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return result
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ResilientMeModel")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
} 