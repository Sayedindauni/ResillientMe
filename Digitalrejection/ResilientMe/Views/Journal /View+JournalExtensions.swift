import SwiftUI

// MARK: - View Extensions for Journal Feature

// These extensions provide common modifiers used within the Journal views.
// Consider moving them to a more general location if used across the app.

extension View {
    /// Wraps the view in a ZStack to ensure a minimum touch target size (default 44x44).
    @ViewBuilder func withMinTouchArea(size: CGFloat = 44) -> some View {
        // Use a GeometryReader to ensure the touch area centers on the original view
        // if the original view is smaller than the minimum size.
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                Color.clear
                    .frame(width: max(size, geometry.size.width), height: max(size, geometry.size.height))
                    .contentShape(Rectangle())
                
                self
            }
            // Center the ZStack within the geometry reader space
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        // Ensure the overall frame reflects the original view's size
        // This prevents the touch area from disrupting layout.
        .frame(width: nil, height: nil) 
    }
    
    /// Adds accessibility label and hint, combining existing elements.
    /// - Parameters:
    ///   - label: The accessibility label.
    ///   - hint: The accessibility hint (optional).
    func makeAccessible(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .ifLet(hint) { view, hintValue in // Use conditional modifier for hint
                view.accessibilityHint(hintValue)
            }
    }
    
    /// Constrains the view's dynamic type size range to avoid excessively large text.
    func withDynamicTypeSize() -> some View {
        return self
            .dynamicTypeSize(...DynamicTypeSize.accessibility3) // Common upper limit
    }
}

// Helper extension for conditional modifiers (often useful)
extension View {
    /// Applies a transformation conditionally.
    @ViewBuilder
    func ifLet<T, Content: View>(_ value: T?, transform: (Self, T) -> Content) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }
} 