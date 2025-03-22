//
//  ResillientMeApp.swift
//  ResillientMe
//
//  Created by Sayed Mohamed on 21.03.25.
//

import SwiftUI
import FirebaseCore


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
    
    // register app delegate for Firebase setup
      @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(.light) // Force light mode for now
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
