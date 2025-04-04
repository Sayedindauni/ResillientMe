import SwiftUI
// Removed UIKit import as we'll use SwiftUI alternatives

// MARK: - App Colors
public struct ThemeColors {
    // Primary application colors
    public static let primary = Color("AppPrimary") // Blue
    public static let secondary = Color.themeInit(hex: "94B49F") // Sage green
    public static let accent = Color.themeInit(hex: "D7A9E3") // Lavender
    
    // Additional accent colors for variety
    public static let accent1 = Color.themeInit(hex: "FFE5B4") // Soft peach
    public static let accent2 = Color.themeInit(hex: "D7A9E3") // Lavender
    public static let accent3 = Color.themeInit(hex: "8FC1D4") // Powder blue
    
    // Text colors
    public static let textDark = Color.themeInit(hex: "3A3A3A") // Dark gray
    public static let textLight = Color.themeInit(hex: "9F9F9F") // Light gray
    public static let textMuted = Color.themeInit(hex: "C0C0C0") // Muted gray
    public static let textMedium = Color.themeInit(hex: "696969") // Medium gray
    
    // Background colors
    public static let background = Color.themeInit(hex: "F8F7F4") // Off-white
    public static let cardBackground = Color.themeInit(hex: "FFFFFF") // White
    
    // Mood colors
    public static let joyful = Color.themeInit(hex: "FFE5B4") // Soft peach
    public static let content = Color.themeInit(hex: "A7C5EB") // Calm blue
    public static let neutral = Color.themeInit(hex: "E0E0E0") // Light gray
    public static let sad = Color.themeInit(hex: "B5C7D3") // Muted blue-gray
    public static let frustrated = Color.themeInit(hex: "D3B5BD") // Muted mauve
    public static let stressed = Color.themeInit(hex: "F5B7B1") // Soft red
    
    // Emotional state colors - for backward compatibility
    public static let calm = Color.themeInit(hex: "A7C5EB") // Calm blue
    public static let joy = Color.themeInit(hex: "FFDBC5") // Soft orange/peach
    public static let sadness = Color.themeInit(hex: "B5C7D3") // Muted blue-gray
    public static let frustration = Color.themeInit(hex: "D3B5BD") // Muted mauve
    
    // Semantic colors
    public static let success = Color.themeInit(hex: "9BDEAC") // Soft green
    public static let warning = Color.themeInit(hex: "FFE084") // Muted yellow
    public static let error = Color.themeInit(hex: "F5B7B1") // Soft red
    public static let info = Color.themeInit(hex: "AED6F1") // Light blue
    
    // Other utility colors
    
    // Helper method to create a color from hex code (public interface)
    static func fromHex(_ hex: String) -> Color {
        return Color.themeInit(hex: hex)
    }
    
    // For accessibility and dark mode using SwiftUI environment
    static func adaptiveColor(light: Color, dark: Color) -> Color {
        return Color.adaptiveDarkLight(light: light, dark: dark)
    }
}

// NOTE: The type aliases (AppColors, AppTextStyles, AppLayout) have been moved
// to AppThemeBridge.swift to avoid redeclaration errors.
// Please import AppThemeBridge.swift instead of defining type aliases here.

// Extension to create colors from hex values
extension Color {
    // This is a static helper method instead of an initializer to avoid conflicts
    static func themeInit(hex: String) -> Color {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        return Color(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // SwiftUI-based adaptive color helper
    static func adaptiveDarkLight(light: Color, dark: Color) -> Color {
        // For compilation purposes, just return the light color
        // In a real app, this would use ColorScheme environment
        return light
    }
}

// MARK: - Text Styles
public struct ThemeTextStyles {
    // Legacy text styles
    public static let h1 = Font.system(size: 30, weight: .bold)
    public static let h2 = Font.system(size: 24, weight: .bold)
    public static let h3 = Font.system(size: 20, weight: .semibold)
    public static let h4 = Font.system(size: 18, weight: .semibold)
    public static let h5 = Font.system(size: 16, weight: .semibold)
    
    public static let body1 = Font.system(size: 16, weight: .regular)
    public static let body2 = Font.system(size: 14, weight: .regular)
    public static let body3 = Font.system(size: 12, weight: .regular)
    
    public static let quote = Font.system(size: 18, weight: .light, design: .serif)
    public static let journalEntry = Font.system(size: 16, weight: .regular, design: .serif)
    public static let buttonFont = Font.system(size: 16, weight: .medium)
    public static let captionText = Font.system(size: 12, weight: .regular)
}

// MARK: - App Layout
public struct ThemeLayout {
    // Core layout metrics
    public static let cornerRadius: CGFloat = 12.0
    public static let smallCornerRadius: CGFloat = 8.0
    public static let spacing: CGFloat = 16.0
    public static let smallSpacing: CGFloat = 8.0
    public static let largeSpacing: CGFloat = 24.0
    
    // Additional layout elements
    public static let cardElevation: CGFloat = 2.0
    public static let cardShadowOpacity: CGFloat = 0.1
}

// MARK: - Shadow
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Animation
struct AppAnimation {
    static let standard = Animation.easeInOut(duration: 0.3)
    static let slow = Animation.easeInOut(duration: 0.5)
    static let fast = Animation.easeInOut(duration: 0.2)
    
    // Special animations
    static let gentleBounce = Animation.spring(response: 0.5, dampingFraction: 0.7)
    static let breathe = Animation.easeInOut(duration: 3).repeatForever(autoreverses: true)
}

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(ThemeTextStyles.buttonFont)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(configuration.isPressed ? ThemeColors.primary.opacity(0.8) : ThemeColors.primary)
            .cornerRadius(ThemeLayout.cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct OutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(ThemeTextStyles.buttonFont)
            .foregroundColor(ThemeColors.primary)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.clear)
            .cornerRadius(ThemeLayout.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: ThemeLayout.cornerRadius)
                    .stroke(ThemeColors.primary, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

// Add any additional styles below this line

// End of Theme.swift 