import SwiftUI

/// A reusable card component for consistent styling across the app
struct CardView<Content: View>: View {
    let title: String
    let subtitle: String?
    let accessibilityHint: String?
    let content: Content
    
    @State private var isPressed: Bool = false
    
    init(
        title: String,
        subtitle: String? = nil,
        accessibilityHint: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.accessibilityHint = accessibilityHint
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppLayout.spacing) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTextStyles.h3)
                    .foregroundColor(AppColors.textDark)
                    .accessibilityAddTraits(.isHeader)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(AppTextStyles.body3)
                        .foregroundColor(AppColors.textMedium)
                }
            }
            
            // Content
            content
        }
        .padding(16)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title + (subtitle != nil ? ", " + subtitle! : ""))
        .accessibilityHint(accessibilityHint ?? "")
    }
}

/// An interactive version of CardView that responds to taps
struct InteractiveCardView<Content: View>: View {
    let title: String
    let subtitle: String?
    let accessibilityHint: String?
    let content: Content
    let action: () -> Void
    
    @State private var isPressed: Bool = false
    
    init(
        title: String,
        subtitle: String? = nil,
        accessibilityHint: String? = nil,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.accessibilityHint = accessibilityHint
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        Button(action: {
            action()
            HapticFeedback.light()
        }) {
            cardContent
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title + (subtitle != nil ? ", " + subtitle! : ""))
        .accessibilityHint(accessibilityHint ?? "")
        .accessibilityAddTraits([.isButton])
    }
    
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: AppLayout.spacing) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTextStyles.h3)
                    .foregroundColor(AppColors.textDark)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(AppTextStyles.body3)
                        .foregroundColor(AppColors.textMedium)
                }
            }
            
            // Content
            content
        }
        .padding(16)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
}

// Custom button style for press effect
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview
struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            CardView(
                title: "Basic Card",
                subtitle: "A simple card component"
            ) {
                Text("This is the card content.")
                    .font(AppTextStyles.body2)
                    .foregroundColor(AppColors.textMedium)
            }
            
            InteractiveCardView(
                title: "Interactive Card",
                subtitle: "Tap me!",
                action: { 
                    print("Card tapped")
                }
            ) {
                Text("This card responds to taps.")
                    .font(AppTextStyles.body2)
                    .foregroundColor(AppColors.textMedium)
            }
        }
        .padding()
        .background(AppColors.background)
    }
} 