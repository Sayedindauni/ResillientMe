import Foundation
import CoreData
import SwiftUI

// MARK: - MoodData for view use
struct MoodData: Identifiable, Hashable {
    let id: String
    let date: Date
    let mood: String
    let intensity: Int
    let note: String?
    let rejectionRelated: Bool
    let rejectionTrigger: String?
    let copingStrategy: String?
    
    static func == (lhs: MoodData, rhs: MoodData) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - MoodStore for CoreData interactions
class MoodStore: ObservableObject {
    @Published var moodEntries: [MoodData] = []
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchMoodEntries()
    }
    
    func fetchMoodEntries() {
        let request = NSFetchRequest<MoodEntryEntity>(entityName: "MoodEntryEntity")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MoodEntryEntity.date, ascending: false)]
        
        do {
            let entries = try context.fetch(request)
            self.moodEntries = entries.map { entity in
                return MoodData(
                    id: entity.id ?? UUID().uuidString,
                    date: entity.date ?? Date(),
                    mood: entity.mood ?? "Unknown",
                    intensity: Int(entity.intensity),
                    note: entity.note,
                    rejectionRelated: entity.rejectionRelated,
                    rejectionTrigger: entity.rejectionTrigger,
                    copingStrategy: entity.copingStrategy
                )
            }
        } catch {
            print("Error fetching mood entries: \(error)")
        }
    }
    
    func saveMoodEntry(entry: MoodData) {
        let newEntry = MoodEntryEntity(context: context)
        newEntry.id = entry.id
        newEntry.date = entry.date
        newEntry.mood = entry.mood
        newEntry.intensity = Int16(entry.intensity)
        newEntry.note = entry.note
        newEntry.rejectionRelated = entry.rejectionRelated
        newEntry.rejectionTrigger = entry.rejectionTrigger
        newEntry.copingStrategy = entry.copingStrategy
        
        do {
            try context.save()
            fetchMoodEntries()
            print("Mood entry saved successfully")
        } catch {
            print("Error saving mood entry: \(error)")
        }
    }
    
    // Original method for backward compatibility
    func saveMoodEntry(mood: String, intensity: Int, note: String? = nil, 
                      rejectionRelated: Bool = false, rejectionTrigger: String? = nil, 
                      copingStrategy: String? = nil) {
        let newEntry = MoodEntryEntity(context: context)
        newEntry.id = UUID().uuidString
        newEntry.date = Date()
        newEntry.mood = mood
        newEntry.intensity = Int16(intensity)
        newEntry.note = note
        newEntry.rejectionRelated = rejectionRelated
        newEntry.rejectionTrigger = rejectionTrigger
        newEntry.copingStrategy = copingStrategy
        
        do {
            try context.save()
            fetchMoodEntries()
            print("Mood entry saved successfully")
        } catch {
            print("Error saving mood entry: \(error)")
        }
    }
    
    func deleteMoodEntry(id: String) {
        let request = NSFetchRequest<MoodEntryEntity>(entityName: "MoodEntryEntity")
        request.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let entries = try context.fetch(request)
            if let entry = entries.first {
                context.delete(entry)
                try context.save()
                fetchMoodEntries()
                print("Mood entry deleted successfully")
            }
        } catch {
            print("Error deleting mood entry: \(error)")
        }
    }
    
    func getMoodEntriesForTimeframe(_ timeframe: MoodView.TimeFrame) -> [MoodData] {
        let calendar = Calendar.current
        let now = Date()
        let startDate: Date
        
        switch timeframe {
        case .day:
            startDate = calendar.startOfDay(for: now)
        case .week:
            if let date = calendar.date(byAdding: .day, value: -7, to: now) {
                startDate = date
            } else {
                startDate = calendar.startOfDay(for: now)
            }
        case .month:
            if let date = calendar.date(byAdding: .month, value: -1, to: now) {
                startDate = date
            } else {
                startDate = calendar.startOfDay(for: now)
            }
        }
        
        return moodEntries.filter { $0.date >= startDate }
    }
} 