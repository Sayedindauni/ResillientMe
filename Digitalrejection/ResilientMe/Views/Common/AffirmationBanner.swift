import SwiftUI

struct AffirmationBanner: View {
    let affirmation: String
    @State private var isExpanded: Bool = true
    @AppStorage("lastAffirmationDate") private var lastAffirmationDate: Double = Date().timeIntervalSince1970
    
    var body: some View {
        VStack(spacing: 0) {
            if isExpanded {
                VStack(spacing: 8) {
                    HStack {
                        Text("Daily Affirmation")
                            .font(AppTextStyles.h4)
                            .foregroundColor(AppColors.textDark)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.easeInOut) {
                                isExpanded = false
                            }
                            HapticFeedback.light()
                        }) {
                            Image(systemName: "chevron.up")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppColors.textLight)
                        }
                        .accessibilityLabel("Collapse affirmation banner")
                    }
                    
                    Text(affirmation)
                        .font(AppTextStyles.body2)
                        .foregroundColor(AppColors.textDark)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            refreshAffirmation()
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textLight)
                        }
                        .accessibilityLabel("Get new affirmation")
                    }
                }
                .padding()
                .background(AppColors.accent1.opacity(0.3))
                .cornerRadius(AppLayout.cornerRadius)
                .padding(.horizontal)
                .padding(.top)
                .accessibleCard(label: "Daily affirmation", hint: "An affirmation to boost your resilience")
            } else {
                Button(action: {
                    withAnimation(.easeInOut) {
                        isExpanded = true
                    }
                    HapticFeedback.light()
                }) {
                    HStack {
                        Image(systemName: "quote.bubble")
                            .font(.system(size: 14))
                        
                        Text("Show Daily Affirmation")
                            .font(AppTextStyles.body3)
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(AppColors.textMedium)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(AppColors.background)
                    .cornerRadius(AppLayout.cornerRadius)
                }
                .padding(.top, 8)
                .accessibilityLabel("Expand affirmation banner")
            }
        }
    }
    
    private func refreshAffirmation() {
        // In a real app, this would fetch a new affirmation
        // and update the storage. For now, we just notify the parent
        // via NotificationCenter to refresh
        HapticFeedback.light()
        NotificationCenter.default.post(
            name: Notification.Name("refreshAffirmation"),
            object: nil
        )
        
        // Update the last affirmation date
        lastAffirmationDate = Date().timeIntervalSince1970
    }
}

// MARK: - Preview
struct AffirmationBanner_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AffirmationBanner(affirmation: "Your worth is not determined by external validation.")
            Spacer()
        }
        .background(AppColors.background)
    }
} 