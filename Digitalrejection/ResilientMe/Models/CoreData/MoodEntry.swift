import Foundation
import CoreData

// MARK: - MoodEntry CoreData Class

@objc(MoodEntry)
public class MoodEntry: NSManagedObject, Identifiable {
    @NSManaged public var id: String?
    @NSManaged public var date: Date?
    @NSManaged public var mood: String?
    @NSManaged public var customMood: String?
    @NSManaged public var intensity: Int16
    @NSManaged public var note: String?
    @NSManaged public var rejectionRelated: Bool
    @NSManaged public var rejectionTrigger: String?
    @NSManaged public var copingStrategy: String?
    @NSManaged public var journalPromptShown: Bool
    @NSManaged public var recommendedStrategies: String?
    
    // Simpler date for UI display
    public var formattedDate: String {
        guard let date = date else { return "Unknown date" }
        return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short)
    }
} 