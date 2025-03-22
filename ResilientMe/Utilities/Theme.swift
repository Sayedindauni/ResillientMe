import SwiftUI

// MARK: - App Colors
struct AppColors {
    // Primary application colors
    static let primary = Color(hex: "5B9BD5") // Blue
    static let secondary = Color(hex: "94B49F") // Sage green
    static let accent = Color(hex: "D7A9E3") // Lavender
    
    // Additional accent colors for variety
    static let accent1 = Color(hex: "FFE5B4") // Soft peach
    static let accent2 = Color(hex: "D7A9E3") // Lavender
    static let accent3 = Color(hex: "8FC1D4") // Powder blue
    
    // Text colors
    static let textDark = Color(hex: "3A3A3A") // Dark gray
    static let textLight = Color(hex: "9F9F9F") // Light gray
    static let textMuted = Color(hex: "C0C0C0") // Muted gray
    static let textMedium = Color(hex: "696969") // Medium gray
    
    // Background colors
    static let background = Color(hex: "F8F7F4") // Off-white
    static let cardBackground = Color(hex: "FFFFFF") // White
    
    // Mood colors
    static let joyful = Color(hex: "FFE5B4") // Soft peach
    static let content = Color(hex: "A7C5EB") // Calm blue
    static let neutral = Color(hex: "E0E0E0") // Light gray
    static let sad = Color(hex: "B5C7D3") // Muted blue-gray
    static let frustrated = Color(hex: "D3B5BD") // Muted mauve
    static let stressed = Color(hex: "F5B7B1") // Soft red
    
    // Emotional state colors - for backward compatibility
    static let calm = Color(hex: "A7C5EB") // Calm blue
    static let joy = Color(hex: "FFDBC5") // Soft orange/peach
    static let sadness = Color(hex: "B5C7D3") // Muted blue-gray
    static let frustration = Color(hex: "D3B5BD") // Muted mauve
    
    // Semantic colors
    static let success = Color(hex: "9BDEAC") // Soft green
    static let warning = Color(hex: "FFE084") // Muted yellow
    static let error = Color(hex: "F5B7B1") // Soft red
    static let info = Color(hex: "AED6F1") // Light blue
    
    // For accessibility and dark mode
    static func adaptiveColor(light: Color, dark: Color) -> Color {
        return Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

// Extension to create colors from hex values
extension Color {
    init(hex: String) {
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