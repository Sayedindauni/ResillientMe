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

// No need to explicitly import NotificationManager as it's part of the same module

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
