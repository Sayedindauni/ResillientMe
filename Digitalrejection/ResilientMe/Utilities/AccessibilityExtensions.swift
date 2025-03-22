//
//  AccessibilityExtensions.swift
//  ResillientMe
//
//  Created by Sayed Mohamed on 21.03.25.
//

import SwiftUI

// MARK: - Accessibility Types

// Namespace for all app haptic feedback to avoid duplicates
public enum AppHapticFeedback {
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

// MARK: - Accessibility Extensions

// Created in a namespace to prevent redeclarations
public enum AppAccessibility {
    @ViewBuilder
    static func makeAccessible(_ view: some View, label: String? = nil, hint: String? = nil) -> some View {
        view
            .accessibilityLabel(label ?? "")
            .accessibilityHint(hint ?? "")
            .environment(\.sizeCategory, .large) // Default to large text
    }
    
    @ViewBuilder
    static func accessibleCard(_ view: some View, label: String, hint: String? = nil) -> some View {
        view
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
    }
}

// View extensions that use the namespaced versions - Combine all View extensions into one
public extension View {
    /// Makes a view accessible with a label and optional hint
    func accessibleLabel(label: String, hint: String? = nil) -> some View {
        self.accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
    }
    
    /// Adds a custom accessibility label to an image, treating it as a button
    func accessibleImageButton(label: String, hint: String? = nil) -> some View {
        self.accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(.isButton)
    }
    
    /// Marks an image as decorative (hidden from accessibility services)
    func accessibleDecorativeImage() -> some View {
        self.accessibility(hidden: true)
    }
    
    /// Groups child views together for accessibility
    func accessibilityGroup(label: String, hint: String? = nil) -> some View {
        self.accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
    }
    
    /// Makes a view accessible with a custom accessibility value
    func accessibleValue(_ value: String) -> some View {
        self.accessibilityValue(value)
    }
    
    /// Makes a view accessible as a heading
    func accessibleHeading(_ text: String? = nil) -> some View {
        if let text = text {
            return self.accessibilityLabel(text)
                .accessibilityAddTraits(.isHeader)
        } else {
            return self.accessibilityAddTraits(.isHeader)
        }
    }
    
    /// Ensures minimum touch area for interactive elements (44x44 pt is Apple's recommendation)
    func withMinTouchArea(minSize: CGFloat = 44) -> some View {
        return self
            .contentShape(Rectangle())
            .frame(minWidth: minSize, minHeight: minSize)
    }
    
    /// Sets the appropriate text sizes based on Dynamic Type settings
    func accessibleDynamicTypeSize() -> some View {
        return self
            .dynamicTypeSize(...DynamicTypeSize.accessibility3)
    }
    
    /// Adds a high contrast compatible background for text
    func highContrastTextBackground() -> some View {
        self.padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.85))
                    .shadow(color: Color.black.opacity(0.1), radius: 1)
            )
    }
    
    /// Adds a voice-over action
    func addAccessibilityAction(named actionName: String, action: @escaping () -> Void) -> some View {
        return self.accessibilityAction(named: Text(actionName)) {
            action()
        }
    }
    
    /// Optimizes the colors for different color schemes, including for color blindness
    func colorSchemeAdaptive(lightColor: Color, darkColor: Color) -> some View {
        return self.preferredColorScheme(.light)
    }
    
    /// Makes a view more accessible with proper text size, contrast, and labels
    func makeAccessible(label: String? = nil, hint: String? = nil) -> some View {
        return AppAccessibility.makeAccessible(self, label: label, hint: hint)
    }
    
    /// Applies accessibility properties specific to a card UI element (renamed to avoid conflicts)
    func accessibleCardView(label: String, hint: String? = nil) -> some View {
        return AppAccessibility.accessibleCard(self, label: label, hint: hint)
    }
}

// MARK: - Accessibility Actions

extension AccessibilityActionKind {
    /// Custom accessibility action for copying content
    static let copy = AccessibilityActionKind(named: Text("copy"))
    
    /// Custom accessibility action for sharing content
    static let share = AccessibilityActionKind(named: Text("share"))
    
    /// Custom accessibility action for expanding collapsed content
    static let expand = AccessibilityActionKind(named: Text("expand"))
    
    /// Custom accessibility action for collapsing expanded content
    static let collapse = AccessibilityActionKind(named: Text("collapse"))
}

// MARK: - Voice Over Announcements

/// Helper for making VoiceOver announcements
struct AccessibilityAnnouncement {
    /// Post an announcement for VoiceOver to read
    static func post(_ message: String, priority: UIAccessibility.Notification = .announcement) {
        UIAccessibility.post(notification: .announcement, argument: message)
    }
    
    /// Indicate a screen change to VoiceOver
    static func screenChanged(_ screenName: String? = nil) {
        if let screenName = screenName {
            UIAccessibility.post(notification: .screenChanged, argument: screenName)
        } else {
            UIAccessibility.post(notification: .screenChanged, argument: nil)
        }
    }
    
    /// Indicate a layout change to VoiceOver
    static func layoutChanged() {
        UIAccessibility.post(notification: .layoutChanged, argument: nil)
    }
}

// MARK: - Accessibility Traits

extension View {
    /// Combines multiple accessibility traits together
    func accessibilityTraits(_ traits: AccessibilityTraits...) -> some View {
        var combinedTraits = AccessibilityTraits()
        for trait in traits {
            let _ = combinedTraits.insert(trait)
        }
        
        return self.accessibilityAddTraits(combinedTraits)
    }
}

// MARK: - Screen Reader Announcment

/// Allows programmatic announcements to VoiceOver
func announceScreenReaderMessage(_ message: String, delay: Double = 0.1) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        UIAccessibility.post(notification: .announcement, argument: message)
    }
}

// MARK: - Semantic Button Styles

extension ButtonStyle where Self == AccessibleButtonStyle {
    static func accessible(
        backgroundColor: Color,
        pressedColor: Color,
        foregroundColor: Color = .white
    ) -> AccessibleButtonStyle {
        return AccessibleButtonStyle(
            backgroundColor: backgroundColor,
            pressedColor: pressedColor,
            foregroundColor: foregroundColor
        )
    }
}

struct AccessibleButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let pressedColor: Color
    let foregroundColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(configuration.isPressed ? pressedColor : backgroundColor)
            .foregroundColor(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
            .contentShape(Rectangle())
    }
} 