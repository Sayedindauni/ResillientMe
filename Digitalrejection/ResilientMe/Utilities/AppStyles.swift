//
//  AppStyles.swift
//  ResilientMe
//
//  Created by Team on 23.03.2025.
//

import SwiftUI

// This file uses styles from Theme.swift
// - AppLayout (instead of AppLayout)

// Style functions instead of extensions to avoid ambiguity issues
struct AppStyle {
    // Apply standard card styling
    static func cardStyle<T: View>(_ content: T) -> some View {
        content
            .padding(AppLayout.spacing)
            .background(Color.white)
            .cornerRadius(AppLayout.cornerRadius)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
    
    // Apply standard button styling
    static func buttonStyle<T: View>(_ content: T, isPrimary: Bool = true) -> some View {
        content
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .background(isPrimary ? Color.blue : Color.white)
            .foregroundColor(isPrimary ? Color.white : Color.black)
            .cornerRadius(AppLayout.smallCornerRadius)
            .shadow(color: isPrimary ? Color.blue.opacity(0.3) : Color.clear, 
                   radius: 4, x: 0, y: 2)
    }
    
    // Apply text style
    static func heading1Style<T: View>(_ content: T) -> some View {
        content
            .font(AppTextStyles.h1)
            .foregroundColor(Color.black)
    }
    
    static func heading2Style<T: View>(_ content: T) -> some View {
        content
            .font(AppTextStyles.h2)
            .foregroundColor(Color.black)
    }
    
    static func bodyStyle<T: View>(_ content: T) -> some View {
        content
            .font(AppTextStyles.body1)
            .foregroundColor(Color.black)
    }
    
    static func captionStyle<T: View>(_ content: T) -> some View {
        content
            .font(AppTextStyles.captionText)
            .foregroundColor(Color.gray)
    }
}

// Extension methods that use the static functions
extension View {
    func styleAsCard() -> some View {
        AppStyle.cardStyle(self)
    }
    
    func styleAsButton(isPrimary: Bool = true) -> some View {
        AppStyle.buttonStyle(self, isPrimary: isPrimary)
    }
    
    func styleAsHeading1() -> some View {
        AppStyle.heading1Style(self)
    }
    
    func styleAsHeading2() -> some View {
        AppStyle.heading2Style(self)
    }
    
    func styleAsBody() -> some View {
        AppStyle.bodyStyle(self)
    }
    
    func styleAsCaption() -> some View {
        AppStyle.captionStyle(self)
    }
}

// MARK: - App Colors
