//
//  NotificationManager.swift
//  ResilientMe
//
//  Created by Team on 23.03.2025.
//

import Foundation
import UserNotifications
import SwiftUI

public class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published public var settings: UNNotificationSettings?
    
    public override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    public func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]) { granted, error in
                if granted == true && error == nil {
                    print("Notifications permission granted")
                    self.scheduleReminderNotification()
                } else {
                    print("Notifications permission denied")
                }
            }
    }
    
    // Set up notification categories for actionable notifications
    public func setupNotificationCategories() {
        // Define the recommendation view action
        let viewAction = UNNotificationAction(
            identifier: "VIEW_ACTION",
            title: "View Details",
            options: .foreground
        )
        
        // Define the dismiss action
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS_ACTION",
            title: "Dismiss",
            options: .destructive
        )
        
        // Create the recommendation category
        let recommendationCategory = UNNotificationCategory(
            identifier: "RECOMMENDATION_CATEGORY",
            actions: [viewAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Define follow-up action buttons for coping strategies
        let helpfulAction = UNNotificationAction(
            identifier: "HELPFUL_ACTION",
            title: "Yes, it helped",
            options: .foreground
        )
        
        let notHelpfulAction = UNNotificationAction(
            identifier: "NOT_HELPFUL_ACTION",
            title: "No, not really",
            options: .foreground
        )
        
        let remindLaterAction = UNNotificationAction(
            identifier: "REMIND_LATER_ACTION",
            title: "Remind me later",
            options: .destructive
        )
        
        // Create the coping strategy follow-up category
        let followupCategory = UNNotificationCategory(
            identifier: "COPING_FOLLOWUP_CATEGORY",
            actions: [helpfulAction, notHelpfulAction, remindLaterAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Register both categories
        UNUserNotificationCenter.current().setNotificationCategories([recommendationCategory, followupCategory])
    }
    
    // Send a recommendation notification
    public func sendRecommendationNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = "RECOMMENDATION_CATEGORY"
        
        // Schedule for 2 seconds from now to ensure it's not too immediate
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        
        // Create the request with a unique identifier
        let request = UNNotificationRequest(
            identifier: "recommendation-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        // Add the request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending recommendation notification: \(error)")
            } else {
                print("Recommendation notification scheduled")
            }
        }
    }
    
    public func scheduleReminderNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Daily Mood Check-in"
        content.body = "How are you feeling today? Taking a moment to track your mood helps build emotional resilience."
        content.sound = .default
        
        // Configure trigger for 8pm daily
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create the request
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        // Add the request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Daily reminder notification scheduled")
            }
        }
    }
    
    // Schedule an immediate notification
    public func scheduleImmediateNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        // Schedule for now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        // Create the request
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        // Add the request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    // Clear all pending notifications
    public func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // UNUserNotificationCenterDelegate methods
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification response
        switch response.actionIdentifier {
        case "VIEW_ACTION":
            // In a real app, you'd navigate to the recommendations view
            print("User tapped View Details")
            NotificationCenter.default.post(name: NSNotification.Name("showRecommendations"), object: nil)
            
        case UNNotificationDefaultActionIdentifier:
            // User tapped the notification itself
            print("User tapped the notification")
            NotificationCenter.default.post(name: NSNotification.Name("showRecommendations"), object: nil)
            
        case UNNotificationDismissActionIdentifier, "DISMISS_ACTION":
            // User dismissed the notification or tapped Dismiss
            print("User dismissed the notification")
            
        // Handle coping strategy follow-up actions
        case "HELPFUL_ACTION":
            // Notify that the strategy was helpful
            if let strategy = response.notification.request.content.userInfo["strategy"] as? String {
                print("User found strategy '\(strategy)' helpful")
                NotificationCenter.default.post(
                    name: NSNotification.Name("copingStrategyFollowUp"),
                    object: nil,
                    userInfo: ["strategy": strategy, "wasHelpful": true]
                )
            }
            
        case "NOT_HELPFUL_ACTION":
            // Notify that the strategy was not helpful
            if let strategy = response.notification.request.content.userInfo["strategy"] as? String {
                print("User found strategy '\(strategy)' not helpful")
                NotificationCenter.default.post(
                    name: NSNotification.Name("copingStrategyFollowUp"),
                    object: nil,
                    userInfo: ["strategy": strategy, "wasHelpful": false]
                )
            }
            
        case "REMIND_LATER_ACTION":
            // Reschedule the follow-up for later
            if let strategy = response.notification.request.content.userInfo["strategy"] as? String {
                print("Rescheduling follow-up for strategy '\(strategy)'")
                // Reschedule for 3 hours later
                let content = UNMutableNotificationContent()
                content.title = "How did it go?"
                content.body = "Did the '\(strategy)' strategy help improve your mood?"
                content.sound = .default
                content.categoryIdentifier = "COPING_FOLLOWUP_CATEGORY"
                content.userInfo = ["strategy": strategy]
                
                // Schedule for 3 hours from now
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3 * 60 * 60, repeats: false)
                
                // Create the request
                let request = UNNotificationRequest(
                    identifier: "coping-followup-reminder-\(UUID().uuidString)",
                    content: content,
                    trigger: trigger
                )
                
                // Add the request to the notification center
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error scheduling reminder notification: \(error)")
                    }
                }
            }
            
        default:
            break
        }
        
        completionHandler()
    }
    
    // Context-aware notifications for coping strategies
    public func scheduleContextAwareStrategyNotification(moodData: [MoodData], preferredTimes: [Date]? = nil) {
        guard !moodData.isEmpty else { return }
        
        // 1. Analyze mood patterns
        let recentHighAnxietyEntries = moodData.filter { 
            $0.mood.lowercased().contains("anxiety") && $0.intensity > 6 && 
            Calendar.current.isDateInToday($0.date) 
        }
        
        let recentSadnessEntries = moodData.filter { 
            $0.mood.lowercased().contains("sad") && $0.intensity > 5 &&
            Calendar.current.isDateInToday($0.date) 
        }
        
        // 2. Determine best time for notification
        var scheduledTime: Date
        
        if let times = preferredTimes, !times.isEmpty {
            // Use user's preferred times
            scheduledTime = times.randomElement()!
        } else {
            // Default timing logic - suggest strategies during common stress periods
            let calendar = Calendar.current
            let now = Date()
            let hour = calendar.component(.hour, from: now)
            
            if hour >= 21 || hour <= 5 {
                // Evening/night - suggest relaxation for sleep
                let dateComponents = DateComponents(hour: 21, minute: 30)
                scheduledTime = calendar.nextDate(after: now, matching: dateComponents, matchingPolicy: .nextTime)!
            } else if hour >= 7 && hour <= 9 {
                // Morning - suggest energizing strategies
                let dateComponents = DateComponents(hour: 8, minute: 15)
                scheduledTime = calendar.nextDate(after: now, matching: dateComponents, matchingPolicy: .nextTime)!
            } else {
                // Mid-day check-in
                let dateComponents = DateComponents(hour: 12, minute: 30)
                scheduledTime = calendar.nextDate(after: now, matching: dateComponents, matchingPolicy: .nextTime)!
            }
        }
        
        // 3. Determine content based on detected patterns
        let content = UNMutableNotificationContent()
        content.badge = 1
        content.sound = .default
        content.categoryIdentifier = "COPING_SUGGESTION_CATEGORY"
        
        if !recentHighAnxietyEntries.isEmpty {
            content.title = "Anxiety Management"
            content.body = "You've been feeling anxious today. Would you like to try a quick grounding exercise?"
            content.userInfo = ["strategyType": "grounding", "moodTrigger": "anxiety"]
        } else if !recentSadnessEntries.isEmpty {
            content.title = "Mood Lift Suggestion"
            content.body = "We noticed you've been feeling down. A brief self-compassion exercise might help."
            content.userInfo = ["strategyType": "selfCompassion", "moodTrigger": "sadness"]
        } else {
            // General resilience building
            content.title = "Build Your Resilience"
            content.body = "Taking a few minutes for a coping strategy can help you stay emotionally strong."
            content.userInfo = ["strategyType": "general", "moodTrigger": "prevention"]
        }
        
        // 4. Schedule the notification
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: scheduledTime),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling context-aware notification: \(error)")
            }
        }
    }
} 