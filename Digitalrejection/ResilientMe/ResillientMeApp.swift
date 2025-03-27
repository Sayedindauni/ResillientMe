// Import NotificationManager from Services directory
//
//  ResillientMeApp.swift
//  ResillientMe
//
//  Created by Sayed Mohamed on 21.03.25.
//

import SwiftUI
import UserNotifications
import FirebaseCore
import CoreData

// No need to import a Services module, as the NotificationManager is part of the same target

// Community Challenge Model
class CommunityChallenges: ObservableObject {
    static let shared = CommunityChallenges()
    
    struct Challenge: Identifiable, Codable {
        let id: String
        let title: String
        let description: String
        let startDate: Date
        let endDate: Date
        let category: String
        var participants: Int
        var completed: Bool = false
        var userParticipating: Bool = false
    }
    
    @Published var activeChallenges: [Challenge] = []
    @Published var pastChallenges: [Challenge] = []
    
    init() {
        loadMockChallenges()
    }
    
    func loadMockChallenges() {
        let now = Date()
        let calendar = Calendar.current
        
        // Create some mock active challenges
        activeChallenges = [
            Challenge(
                id: "c1",
                title: "Share Your Go-To Anxiety Strategy",
                description: "Share a coping strategy that has helped you manage anxiety, and see what works for others in the community.",
                startDate: calendar.date(byAdding: .day, value: -3, to: now) ?? now,
                endDate: calendar.date(byAdding: .day, value: 3, to: now) ?? now,
                category: "Anxiety",
                participants: 42
            ),
            Challenge(
                id: "c2",
                title: "7-Day Mindfulness Streak",
                description: "Practice mindfulness for at least 5 minutes each day for 7 days straight.",
                startDate: calendar.date(byAdding: .day, value: -1, to: now) ?? now,
                endDate: calendar.date(byAdding: .day, value: 6, to: now) ?? now,
                category: "Mindfulness",
                participants: 78
            )
        ]
        
        // Create some mock past challenges
        pastChallenges = [
            Challenge(
                id: "p1",
                title: "Journal Reflection Week",
                description: "Complete a journal entry every day for a week reflecting on your emotions.",
                startDate: calendar.date(byAdding: .day, value: -14, to: now) ?? now,
                endDate: calendar.date(byAdding: .day, value: -7, to: now) ?? now,
                category: "Journaling",
                participants: 103,
                completed: true,
                userParticipating: true
            ),
            Challenge(
                id: "p2",
                title: "Share a Success Story",
                description: "Share a personal success story about overcoming rejection or building resilience.",
                startDate: calendar.date(byAdding: .day, value: -21, to: now) ?? now,
                endDate: calendar.date(byAdding: .day, value: -14, to: now) ?? now,
                category: "Sharing",
                participants: 67,
                completed: false,
                userParticipating: true
            )
        ]
    }
    
    func joinChallenge(id: String) {
        if let index = activeChallenges.firstIndex(where: { $0.id == id }) {
            activeChallenges[index].userParticipating = true
            activeChallenges[index].participants += 1
        }
    }
    
    func leaveChallenge(id: String) {
        if let index = activeChallenges.firstIndex(where: { $0.id == id }) {
            activeChallenges[index].userParticipating = false
            activeChallenges[index].participants -= 1
        }
    }
    
    func completeChallenge(id: String) {
        if let index = activeChallenges.firstIndex(where: { $0.id == id }) {
            activeChallenges[index].completed = true
        }
    }
    
    func getChallengesByCategory(category: String) -> [Challenge] {
        return activeChallenges.filter { $0.category == category }
    }
    
    func getDaysRemaining(for challenge: Challenge) -> Int {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day], from: now, to: challenge.endDate)
        return components.day ?? 0
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct ResillientMeApp: App {
    // Set up any global app dependencies here
    @StateObject private var appState = AppState()
    @StateObject private var notificationManager = NotificationManager()
    
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // Add environment for Core Data
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView(context: persistenceController.container.viewContext)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appState)
                .environmentObject(notificationManager)
                .preferredColorScheme(.light) // Force light mode for now
                .onAppear {
                    // Request notification permissions
                    notificationManager.requestPermission()
                }
        }
    }
}

// Global app state for sharing data between views
class AppState: ObservableObject {
    // This object would contain shared data and settings
    // that need to persist across the app
    
    // App theme settings
    @Published var useSystemTheme: Bool = true
    
    // User preferences
    @Published var enableNotifications: Bool = true
    @Published var reminderTime: Date = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
    
    // App metrics for tracking usage
    @Published var journalEntryCount: Int = 0
    @Published var moodEntryCount: Int = 0
    @Published var streakDays: Int = 0
    
    // Initialize with default values
    init() {
        // In a real app, you would load saved preferences from UserDefaults
        // or other persistence mechanism
    }
}
