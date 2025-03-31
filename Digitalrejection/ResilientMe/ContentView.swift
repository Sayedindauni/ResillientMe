//
//  ContentView.swift
//  ResillientMe
//
//  Created by Sayed Mohamed on 21.03.25.
//

import SwiftUI
import CoreData

// Add typealias to maintain compatibility with existing code
typealias AppCopy = LocalAppCopy
typealias AppHapticFeedback = LocalAppHapticFeedback

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var dailyAffirmation = LocalAppCopy.randomAffirmation()
    
    // Add initializer to accept context parameter
    init(context: NSManagedObjectContext) {
        // The context is passed but not directly stored
        // as we're using @Environment for it
    }
    
    var body: some View {
        TabView {
            VStack {
                Text(dailyAffirmation)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding()
                
                Text("Dashboard")
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            
            Text("Journal")
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Journal")
                }
            
            Text("Mood Tracking")
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Mood")
                }
            
            Text("Community")
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Community")
                }
            
            Text("Profile")
                .tabItem {
                    Image(systemName: "person.circle.fill")
                    Text("Profile")
                }
            
            Text("Insights")
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
