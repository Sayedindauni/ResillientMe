//
//  NotificationManager.swift
//  ResilientMe
//
//  Created by Team on 23.03.2025.
//

import Foundation
import UserNotifications
import SwiftUI

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published var settings: UNNotificationSettings?
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestPermission() {
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
    func setupNotificationCategories() {
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
        
        // Register the category
        UNUserNotificationCenter.current().setNotificationCategories([recommendationCategory])
    }
    
    // Send a recommendation notification
    func sendRecommendationNotification(title: String, body: String) {
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
    
    func scheduleReminderNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Daily Check-in"
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
    func scheduleImmediateNotification(title: String, body: String) {
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
    func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // UNUserNotificationCenterDelegate methods
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
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
            
        default:
            break
        }
        
        completionHandler()
    }
} 