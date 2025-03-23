//
//  AppStyles.swift
//  ResilientMe
//
//  Created by Team on 23.03.2025.
//

import SwiftUI

// This file imports styles from Theme.swift
// Do not define duplicate structs here
// To avoid "Invalid redeclaration" errors

// The following types are defined in Theme.swift:
// - struct AppColors
// - struct AppTextStyles
// - struct AppLayout (aliased to ThemeLayout)

// If you need to use these types, import them from Theme.swift

// Extension to modify UI components with the styles
extension View {
    // Apply standard card styling
    func styleAsCard() -> some View {
        self
            .padding(AppLayout.spacing)
            .background(AppColors.cardBackground)
            .cornerRadius(AppLayout.cornerRadius)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
    
    // Apply standard button styling
    func styleAsButton(isPrimary: Bool = true) -> some View {
        self
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .background(isPrimary ? AppColors.primary : AppColors.background)
            .foregroundColor(isPrimary ? .white : AppColors.textDark)
            .cornerRadius(AppLayout.smallCornerRadius)
            .shadow(color: isPrimary ? AppColors.primary.opacity(0.3) : Color.clear, 
                   radius: 4, x: 0, y: 2)
    }
    
    // Apply text style
    func styleAsHeading1() -> some View {
        self.font(AppTextStyles.h1)
            .foregroundColor(AppColors.textDark)
    }
    
    func styleAsHeading2() -> some View {
        self.font(AppTextStyles.h2)
            .foregroundColor(AppColors.textDark)
    }
    
    func styleAsBody() -> some View {
        self.font(AppTextStyles.body1)
            .foregroundColor(AppColors.textDark)
    }
    
    func styleAsCaption() -> some View {
        self.font(AppTextStyles.captionText)
            .foregroundColor(AppColors.textMedium)
    }
} 