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
import struct ResilientMe.DashboardView
import struct ResilientMe.JournalView
import struct ResilientMe.MoodView
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
    @StateObject private var moodStore: CoreDataMoodStore
    @StateObject private var moodAnalysisEngine: MoodAnalysisEngine
    
    // Add initializer to accept context parameter
    init(context: NSManagedObjectContext) {
        // The context is passed but not directly stored
        // as we're using @Environment for it
        let moodStore = CoreDataMoodStore(context: context)
        _moodStore = StateObject(wrappedValue: moodStore)
        _moodAnalysisEngine = StateObject(wrappedValue: MoodAnalysisEngine(moodStore: moodStore))
    }
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            JournalView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Journal")
                }
            
            MoodView(context: viewContext, moodAnalysisEngine: moodAnalysisEngine)
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Mood")
                }
            
            CommunityView()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Community")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle.fill")
                    Text("Profile")
                }
            
            InsightsView(moodAnalysisEngine: moodAnalysisEngine)
                .tabItem {
                    Image(systemName: "chart.bar.xaxis")
                    Text("Insights")
                }
            
            Text("Coping Strategies")
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("Strategies")
                }
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
