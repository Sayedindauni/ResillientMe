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
                        Text("Today's Affirmation")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.easeInOut) {
                                isExpanded = false
                            }
                            // Haptic feedback would go here
                        }) {
                            Image(systemName: "chevron.up")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        .accessibilityLabel("Collapse affirmation banner")
                    }
                    
                    Text(affirmation)
                        .font(.body)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            refreshAffirmation()
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .accessibilityLabel("Get new affirmation")
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 5)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Daily affirmation")
                .accessibilityHint("An affirmation to boost your resilience")
            } else {
                Button(action: {
                    withAnimation(.easeInOut) {
                        isExpanded = true
                    }
                    // Haptic feedback would go here
                }) {
                    HStack {
                        Image(systemName: "quote.bubble")
                            .font(.system(size: 14))
                        
                        Text("Show Today's Affirmation")
                            .font(.subheadline)
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .accessibilityLabel("Expand affirmation banner")
            }
        }
    }
    
    private func refreshAffirmation() {
        // In a real app, this would fetch a new affirmation
        // and update the storage. For now, we just notify the parent
        // via NotificationCenter to refresh
        NotificationCenter.default.post(
            name: Notification.Name("refreshAffirmation"),
            object: nil
        )
        
        // Update the last affirmation date
        lastAffirmationDate = Date().timeIntervalSince1970
    }
}

#if DEBUG
// MARK: - Preview
struct AffirmationBanner_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AffirmationBanner(affirmation: "Your worth is not determined by external validation.")
            Spacer()
        }
        .background(Color.gray.opacity(0.1))
    }
}
#endif