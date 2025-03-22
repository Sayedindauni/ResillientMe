//
//  AppLayout.swift
//  ResilientMe
//
//  Created by Sayed Mohamed on 21.03.25.
//

import SwiftUI

/* 
Commenting out AppLayout as it's defined in Theme.swift
Use the AppLayout from Theme.swift instead

/// Centralized structure for app-wide layout constants
struct AppLayout {
    // Padding and spacing
    static let spacing: CGFloat = 12.0
    static let spacingSmall: CGFloat = 8.0
    static let spacingLarge: CGFloat = 24.0
    
    // Sizing constants
    static let iconSize: CGFloat = 24.0
    static let iconSizeLarge: CGFloat = 32.0
    static let iconSizeSmall: CGFloat = 16.0
    
    // Container constants
    static let cornerRadius: CGFloat = 12.0
    static let buttonHeight: CGFloat = 48.0
    static let cardPadding: CGFloat = 16.0
    
    // Animations
    static let standardAnimation: Animation = .easeInOut(duration: 0.2)
    static let slowAnimation: Animation = .easeInOut(duration: 0.4)
    
    // Screen adaptivity - safe area insets
    static func safeAreaInsets(for geometry: GeometryProxy) -> EdgeInsets {
        return geometry.safeAreaInsets
    }
    
    // Screen adaptivity - device size category
    static func deviceSizeCategory(for geometry: GeometryProxy) -> DeviceSizeCategory {
        let size = geometry.size
        let width = min(size.width, size.height)
        
        if width <= 375 {
            return .small      // iPhone SE, mini
        } else if width <= 428 {
            return .medium     // Regular iPhones
        } else {
            return .large      // iPads, large iPhones in landscape
        }
    }
    
    // Device size categories for adaptive layout
    enum DeviceSizeCategory {
        case small
        case medium
        case large
        
        // Get appropriate spacing for device size
        var spacing: CGFloat {
            switch self {
            case .small: return AppLayout.spacing * 0.8
            case .medium: return AppLayout.spacing
            case .large: return AppLayout.spacing * 1.2
            }
        }
    }
}

// Extension for view modifications based on layout
extension View {
    // Apply standard card styling
    func standardCard() -> some View {
        self
            .padding(AppLayout.cardPadding)
            .background(AppColors.cardBackground)
            .cornerRadius(AppLayout.cornerRadius)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
    
    // Apply standard button styling
    func standardButton(isPrimary: Bool = true) -> some View {
        self
            .frame(height: AppLayout.buttonHeight)
            .frame(maxWidth: .infinity)
            .background(isPrimary ? AppColors.primary : AppColors.background)
            .foregroundColor(isPrimary ? .white : AppColors.textDark)
            .cornerRadius(AppLayout.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                    .stroke(isPrimary ? Color.clear : AppColors.textLight.opacity(0.3), lineWidth: 1)
            )
    }
    
    // Apply standard animation
    func withStandardAnimation() -> some View {
        self.animation(AppLayout.standardAnimation, value: UUID())
    }
} 
*/ 