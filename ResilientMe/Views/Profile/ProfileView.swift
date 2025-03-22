import SwiftUI

struct ProfileView: View {
    // User profile information
    @State private var username: String = "Alex Johnson"
    @State private var email: String = "alex.johnson@example.com"
    @State private var notifications: Bool = true
    @State private var darkMode: Bool = false
    @State private var shareData: Bool = true
    
    // Mock profile data
    private let joinDate = Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()
    private let streakDays = 12
    private let journalEntries = 24
    private let moodEntries = 36
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppLayout.spacing * 1.5) {
                    // Profile header
                    VStack(spacing: AppLayout.spacing) {
                        // Avatar
                        Circle()
                            .fill(AppColors.primary.opacity(0.2))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text(String(username.prefix(1)))
                                    .font(.system(size: 40, weight: .medium))
                                    .foregroundColor(AppColors.primary)
                            )
                            .padding(.bottom, 8)
                        
                        // Name
                        Text(username)
                            .font(AppTextStyles.h2)
                            .foregroundColor(AppColors.textDark)
                        
                        // Join date
                        Text("Member since \(formatDate(joinDate))")
                            .font(AppTextStyles.body3)
                            .foregroundColor(AppColors.textLight)
                        
                        // Stats
                        HStack(spacing: 24) {
                            statItem(value: "\(streakDays)", label: "Day Streak")
                            statItem(value: "\(journalEntries)", label: "Journal Entries")
                            statItem(value: "\(moodEntries)", label: "Mood Logs")
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(AppLayout.cornerRadius)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                    
                    // Account settings
                    VStack(alignment: .leading, spacing: AppLayout.spacing) {
                        Text("Account Settings")
                            .font(AppTextStyles.h3)
                            .foregroundColor(AppColors.textDark)
                            .padding(.bottom, 8)
                        
                        // Username setting
                        settingRow(icon: "person.fill", title: "Username") {
                            Text(username)
                                .font(AppTextStyles.body3)
                                .foregroundColor(AppColors.textLight)
                        }
                        
                        Divider()
                        
                        // Email setting
                        settingRow(icon: "envelope.fill", title: "Email") {
                            Text(email)
                                .font(AppTextStyles.body3)
                                .foregroundColor(AppColors.textLight)
                        }
                        
                        Divider()
                        
                        // Password setting
                        settingRow(icon: "lock.fill", title: "Change Password") {
                            Image(systemName: "chevron.right")
                                .foregroundColor(AppColors.textLight)
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(AppLayout.cornerRadius)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                    
                    // App settings
                    VStack(alignment: .leading, spacing: AppLayout.spacing) {
                        Text("App Settings")
                            .font(AppTextStyles.h3)
                            .foregroundColor(AppColors.textDark)
                            .padding(.bottom, 8)
                        
                        // Notifications toggle
                        settingRow(icon: "bell.fill", title: "Notifications") {
                            Toggle("", isOn: $notifications)
                                .labelsHidden()
                        }
                        
                        Divider()
                        
                        // Dark mode toggle
                        settingRow(icon: "moon.fill", title: "Dark Mode") {
                            Toggle("", isOn: $darkMode)
                                .labelsHidden()
                        }
                        
                        Divider()
                        
                        // Data sharing toggle
                        settingRow(icon: "chart.bar.fill", title: "Share Anonymous Data") {
                            Toggle("", isOn: $shareData)
                                .labelsHidden()
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(AppLayout.cornerRadius)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                    
                    // About & Legal
                    VStack(alignment: .leading, spacing: AppLayout.spacing) {
                        Text("About & Legal")
                            .font(AppTextStyles.h3)
                            .foregroundColor(AppColors.textDark)
                            .padding(.bottom, 8)
                        
                        // About
                        settingRow(icon: "info.circle.fill", title: "About ResilientMe") {
                            Image(systemName: "chevron.right")
                                .foregroundColor(AppColors.textLight)
                        }
                        
                        Divider()
                        
                        // Terms
                        settingRow(icon: "doc.text.fill", title: "Terms of Service") {
                            Image(systemName: "chevron.right")
                                .foregroundColor(AppColors.textLight)
                        }
                        
                        Divider()
                        
                        // Privacy
                        settingRow(icon: "hand.raised.fill", title: "Privacy Policy") {
                            Image(systemName: "chevron.right")
                                .foregroundColor(AppColors.textLight)
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(AppLayout.cornerRadius)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                    
                    // Logout button
                    Button(action: {
                        // Log out user
                    }) {
                        HStack {
                            Spacer()
                            Text("Log Out")
                                .font(AppTextStyles.h4)
                                .foregroundColor(AppColors.error)
                            Spacer()
                        }
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(AppLayout.cornerRadius)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                    }
                }
                .padding()
            }
            .background(AppColors.background)
            .ignoresSafeArea(edges: .all)
            .navigationBarHidden(true)
        }
    }
    
    // Helper views
    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(AppTextStyles.h3)
                .foregroundColor(AppColors.primary)
            
            Text(label)
                .font(AppTextStyles.body3)
                .foregroundColor(AppColors.textLight)
        }
    }
    
    @ViewBuilder
    private func settingRow<Content: View>(icon: String, title: String, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(AppColors.primary)
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(AppTextStyles.body2)
                .foregroundColor(AppColors.textDark)
            
            Spacer()
            
            content()
        }
        .padding(.vertical, 6)
    }
    
    // Helper functions
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
} 