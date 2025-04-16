import SwiftUI
import ResilientMe
import UIKit

// Add extension for accessibility card
extension View {
    func accessibleCard(label: String, hint: String) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityHint(hint)
    }
}

struct OnboardingScreenView: View {
    @Binding var isPresented: Bool
    @Binding var hasCompletedOnboarding: Bool
    
    @State private var currentPage = 0
    private let totalPages = 4
    
    // Onboarding content - explicitly using ResilientMe.AppOnboardingMessage instead of OnboardingMessage
    private let onboardingContent = [
        ResilientMe.AppOnboardingMessage(
            title: "Welcome to ResilientMe",
            subtitle: "Your personal resilience building companion",
            message: "This app is designed to help you develop coping strategies, track your mood, and build resilience in the face of rejection experiences."
        ),
        ResilientMe.AppOnboardingMessage(
            title: "Track Your Emotions",
            subtitle: "Understand your patterns",
            message: "Log your moods and feelings to identify patterns over time. Recognizing emotional trends is the first step toward building emotional resilience."
        ),
        ResilientMe.AppOnboardingMessage(
            title: "Journal Your Experiences",
            subtitle: "Process through reflection",
            message: "Use the journal to reflect on your experiences, both positive and challenging. Regular reflection helps develop self-awareness and growth."
        ),
        ResilientMe.AppOnboardingMessage(
            title: "Connect and Grow",
            subtitle: "You're not alone",
            message: "Join our supportive community to share experiences and strategies. Building connections is a key part of developing resilience."
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            ResilientMe.AppColors.background
                .ignoresSafeArea()
            
            VStack {
                // Skip button
                HStack {
                    Spacer()
                    
                    Button(action: {
                        self.completeOnboarding()
                    }) {
                        Text("Skip")
                            .font(ResilientMe.AppTextStyles.body3)
                            .foregroundColor(ResilientMe.AppColors.textMedium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(ResilientMe.AppColors.background)
                            .cornerRadius(ResilientMe.AppLayout.cornerRadius)
                    }
                    .accessibilityLabel("Skip onboarding")
                }
                .padding()
                
                Spacer()
                
                // Content
                TabView(selection: $currentPage) {
                    ForEach(0..<onboardingContent.count, id: \.self) { index in
                        onboardingPage(onboardingContent[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<onboardingContent.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? ResilientMe.AppColors.primary : ResilientMe.AppColors.textLight.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.vertical)
                
                // Navigation buttons
                HStack {
                    // Back button (hidden on first page)
                    if currentPage > 0 {
                        Button(action: {
                            currentPage -= 1
                            ResilientMe.LocalHapticFeedback.light()
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .font(ResilientMe.AppTextStyles.body1)
                            .foregroundColor(ResilientMe.AppColors.textMedium)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(ResilientMe.AppColors.background)
                            .cornerRadius(ResilientMe.AppLayout.cornerRadius)
                        }
                        .accessibilityLabel("Go to previous page")
                    }
                    
                    Spacer()
                    
                    // Next/Get Started button
                    Button(action: {
                        if currentPage < totalPages - 1 {
                            currentPage += 1
                            ResilientMe.LocalHapticFeedback.light()
                        } else {
                            self.completeOnboarding()
                        }
                    }) {
                        HStack {
                            Text(currentPage < totalPages - 1 ? "Next" : "Get Started")
                            
                            if currentPage < totalPages - 1 {
                                Image(systemName: "chevron.right")
                            }
                        }
                        .font(ResilientMe.AppTextStyles.body1)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(ResilientMe.AppColors.primary)
                        .cornerRadius(ResilientMe.AppLayout.cornerRadius)
                    }
                    .accessibilityLabel(currentPage < totalPages - 1 ? "Go to next page" : "Complete onboarding")
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .transition(.opacity)
    }
    
    private func onboardingPage(_ content: ResilientMe.AppOnboardingMessage) -> some View {
        VStack(spacing: 25) {
            // Icon/image placeholder
            ZStack {
                Circle()
                    .fill(ResilientMe.AppColors.accent3.opacity(0.2))
                    .frame(width: 160, height: 160)
                
                Image(systemName: self.getIconForPage(currentPage))
                    .font(.system(size: 60))
                    .foregroundColor(ResilientMe.AppColors.primary)
            }
            .padding(.bottom, 10)
            
            // Text content
            VStack(spacing: 16) {
                Text(content.title)
                    .font(ResilientMe.AppTextStyles.h2)
                    .foregroundColor(ResilientMe.AppColors.textDark)
                    .multilineTextAlignment(.center)
                
                Text(content.subtitle)
                    .font(ResilientMe.AppTextStyles.h4)
                    .foregroundColor(ResilientMe.AppColors.primary)
                    .multilineTextAlignment(.center)
                
                Text(content.message)
                    .font(ResilientMe.AppTextStyles.body2)
                    .foregroundColor(ResilientMe.AppColors.textMedium)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
        .padding()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(content.title)
        .accessibilityHint(content.message)
    }
    
    // Renamed to avoid potential conflicts
    private func getIconForPage(_ page: Int) -> String {
        switch page {
        case 0:
            return "heart.circle.fill"
        case 1:
            return "chart.bar.fill"
        case 2:
            return "book.fill"
        case 3:
            return "person.3.fill"
        default:
            return "heart.fill"
        }
    }
    
    private func completeOnboarding() {
        withAnimation {
            hasCompletedOnboarding = true
            isPresented = false
        }
        ResilientMe.LocalHapticFeedback.success()
    }
}

// MARK: - Preview
struct OnboardingScreenView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingScreenView(
            isPresented: .constant(true),
            hasCompletedOnboarding: .constant(false)
        )
    }
} 