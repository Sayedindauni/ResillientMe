import SwiftUI
// Import ResilientMe first to ensure its definitions take precedence
import ResilientMe
import UIKit

/// A specialized card view for displaying activities on the dashboard
struct ActivityCardView: View {
    let title: String
    let description: String
    let iconName: String
    let color: Color
    let action: () -> Void
    let accessibilityHint: String?
    
    init(
        title: String,
        description: String,
        iconName: String,
        color: Color = ResilientMe.AppColors.primary,
        accessibilityHint: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.description = description
        self.iconName = iconName
        self.color = color
        self.accessibilityHint = accessibilityHint
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action()
            ResilientMe.LocalHapticFeedback.light()
        }) {
            HStack(spacing: 16) {
                // Icon container
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 22))
                        .foregroundColor(color)
                }
                .accessibility(hidden: true)
                
                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(ResilientMe.AppTextStyles.h4)
                        .foregroundColor(ResilientMe.AppColors.textDark)
                    
                    Text(description)
                        .font(ResilientMe.AppTextStyles.body3)
                        .foregroundColor(ResilientMe.AppColors.textMedium)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Chevron indicator
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(ResilientMe.AppColors.textLight)
                    .accessibility(hidden: true)
            }
            .padding()
            .background(ResilientMe.AppColors.cardBackground)
            .cornerRadius(ResilientMe.AppLayout.cornerRadius)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: ResilientMe.AppLayout.cornerRadius)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityHint(accessibilityHint ?? description)
        .accessibilityAddTraits([.isButton])
    }
}

/// A specialized card for displaying quick action buttons
struct QuickActionCardView: View {
    let title: String
    let iconName: String
    let color: Color
    let action: () -> Void
    
    init(
        title: String,
        iconName: String,
        color: Color = ResilientMe.AppColors.primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.iconName = iconName
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action()
            ResilientMe.LocalHapticFeedback.light()
        }) {
            VStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
                .accessibility(hidden: true)
                
                // Title
                Text(title)
                    .font(ResilientMe.AppTextStyles.body2)
                    .foregroundColor(ResilientMe.AppColors.textDark)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(minWidth: 100)
            .padding()
            .background(ResilientMe.AppColors.cardBackground)
            .cornerRadius(ResilientMe.AppLayout.cornerRadius)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel(title)
        .accessibilityHint("Tap to \(title.lowercased())")
        .accessibilityAddTraits([.isButton])
    }
}

// MARK: - Preview
struct ActivityCardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ActivityCardView(
                title: "Daily Check-in",
                description: "Take a moment to reflect on your day",
                iconName: "calendar.badge.clock",
                color: ResilientMe.AppColors.primary,
                action: { print("Activity tapped") }
            )
            
            QuickActionCardView(
                title: "Track Mood",
                iconName: "chart.bar.fill",
                color: ResilientMe.AppColors.primary,
                action: { print("Quick action tapped") }
            )
        }
        .padding()
        .background(ResilientMe.AppColors.background)
    }
} 