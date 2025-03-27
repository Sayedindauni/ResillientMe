import SwiftUI
import UIKit // Required for UIColor and adaptiveColor

// MARK: - App Colors
public struct AppColors {
    // Primary application colors
    public static let primary = Color("AppPrimary") // Blue
    public static let secondary = Color(hex: "94B49F") // Sage green
    public static let accent = Color(hex: "D7A9E3") // Lavender
    
    // Additional accent colors for variety
    public static let accent1 = Color(hex: "FFE5B4") // Soft peach
    public static let accent2 = Color(hex: "D7A9E3") // Lavender
    public static let accent3 = Color(hex: "8FC1D4") // Powder blue
    
    // Text colors
    public static let textDark = Color(hex: "3A3A3A") // Dark gray
    public static let textLight = Color(hex: "9F9F9F") // Light gray
    public static let textMuted = Color(hex: "C0C0C0") // Muted gray
    public static let textMedium = Color(hex: "696969") // Medium gray
    
    // Background colors
    public static let background = Color(hex: "F8F7F4") // Off-white
    public static let cardBackground = Color(hex: "FFFFFF") // White
    
    // Mood colors
    public static let joyful = Color(hex: "FFE5B4") // Soft peach
    public static let content = Color(hex: "A7C5EB") // Calm blue
    public static let neutral = Color(hex: "E0E0E0") // Light gray
    public static let sad = Color(hex: "B5C7D3") // Muted blue-gray
    public static let frustrated = Color(hex: "D3B5BD") // Muted mauve
    public static let stressed = Color(hex: "F5B7B1") // Soft red
    
    // Emotional state colors - for backward compatibility
    public static let calm = Color(hex: "A7C5EB") // Calm blue
    public static let joy = Color(hex: "FFDBC5") // Soft orange/peach
    public static let sadness = Color(hex: "B5C7D3") // Muted blue-gray
    public static let frustration = Color(hex: "D3B5BD") // Muted mauve
    
    // Semantic colors
    public static let success = Color(hex: "9BDEAC") // Soft green
    public static let warning = Color(hex: "FFE084") // Muted yellow
    public static let error = Color(hex: "F5B7B1") // Soft red
    public static let info = Color(hex: "AED6F1") // Light blue
    
    // Other utility colors
    
    // Helper method to create a color from hex code (public interface)
    static func fromHex(_ hex: String) -> Color {
        return Color(hex: hex)
    }
    
    // For accessibility and dark mode
    static func adaptiveColor(light: Color, dark: Color) -> Color {
        return Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

// Extension to create colors from hex values
extension Color {
    fileprivate init(hex: String) {
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

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Text Styles
struct AppTextStyles {
    // Legacy text styles
    static let h1 = Font.system(size: 30, weight: .bold)
    static let h2 = Font.system(size: 24, weight: .bold)
    static let h3 = Font.system(size: 20, weight: .semibold)
    static let h4 = Font.system(size: 18, weight: .semibold)
    static let h5 = Font.system(size: 16, weight: .semibold)
    
    static let body1 = Font.system(size: 16, weight: .regular)
    static let body2 = Font.system(size: 14, weight: .regular)
    static let body3 = Font.system(size: 12, weight: .regular)
    
    static let quote = Font.system(size: 18, weight: .light, design: .serif)
    static let journalEntry = Font.system(size: 16, weight: .regular, design: .serif)
    static let buttonFont = Font.system(size: 16, weight: .medium)
    static let captionText = Font.system(size: 12, weight: .regular)
}

// MARK: - App Layout
struct ThemeLayout {
    // Core layout metrics
    static let cornerRadius: CGFloat = 12.0
    static let smallCornerRadius: CGFloat = 8.0
    static let spacing: CGFloat = 16.0
    static let smallSpacing: CGFloat = 8.0
    static let largeSpacing: CGFloat = 24.0
    
    // Additional layout elements
    static let cardElevation: CGFloat = 2.0
    static let cardShadowOpacity: CGFloat = 0.1
}

// Alias for backward compatibility
typealias AppLayout = ThemeLayout

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
            .font(AppTextStyles.buttonFont)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(configuration.isPressed ? AppColors.primary.opacity(0.8) : AppColors.primary)
            .cornerRadius(ThemeLayout.cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct OutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTextStyles.buttonFont)
            .foregroundColor(AppColors.primary)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.clear)
            .cornerRadius(ThemeLayout.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: ThemeLayout.cornerRadius)
                    .stroke(AppColors.primary, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

// Add any additional styles below this line

// End of Theme.swift 