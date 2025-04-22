//
//  ContentView.swift
//  ResillientMe
//
//  Created by Sayed Mohamed on 21.03.25.
//

import SwiftUI
import CoreData
import ResilientMe

// Import all necessary views
import struct ResilientMe.CommunityView
import struct ResilientMe.ProfileView
import struct ResilientMe.InsightsView
import class ResilientMe.MoodAnalysisEngine
import class ResilientMe.CoreDataMoodStore

// Add typealias to maintain compatibility with existing code
typealias AppCopy = LocalAppCopy
typealias AppHapticFeedback = LocalAppHapticFeedback

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var dailyAffirmation = LocalAppCopy.randomAffirmation()
    @StateObject private var moodStore: ResilientMe.CoreDataMoodStore
    @StateObject private var moodAnalysisEngine: ResilientMe.MoodAnalysisEngine
    @StateObject private var navigationCoordinator = NavigationCoordinator()
    
    // Add initializer to accept context parameter
    init(context: NSManagedObjectContext) {
        // The context is passed but not directly stored
        // as we're using @Environment for it
        let moodStore = ResilientMe.CoreDataMoodStore(context: context)
        _moodStore = StateObject(wrappedValue: moodStore)
        _moodAnalysisEngine = StateObject(wrappedValue: ResilientMe.MoodAnalysisEngine(moodStore: moodStore))
    }
    
    var body: some View {
        TabView(selection: $navigationCoordinator.selectedTab) {
            DashboardView()
                .environmentObject(moodStore)
                .environmentObject(navigationCoordinator)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            // Combined MoodJournalView replacing separate Journal and Mood tabs
            MoodJournalView(moodAnalysisEngine: moodAnalysisEngine)
                .environmentObject(navigationCoordinator)
                .environmentObject(moodStore)
                .environmentObject(moodAnalysisEngine)
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Journal & Mood")
                }
                .tag(1)
            
            CommunityView()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Community")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle.fill")
                    Text("Profile")
                }
                .tag(3)
        }
    }
    
    private func refreshAffirmation() {
        withAnimation {
            dailyAffirmation = LocalAppCopy.randomAffirmation()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        ContentView(context: context)
            .environment(\.managedObjectContext, context)
    }
}
