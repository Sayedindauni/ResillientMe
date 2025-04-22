import SwiftUI

// MARK: - Supporting Views

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTextStyles.body2)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .foregroundColor(isSelected ? .white : AppColors.primary)
                .background(isSelected ? AppColors.primary : Color.clear)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(AppColors.primary, lineWidth: isSelected ? 0 : 1)
                )
        }
        // Applying makeAccessible from View+JournalExtensions.swift
        // .makeAccessible(
        //     label: title,
        //     hint: "Filter journal entries to show \(title.lowercased()) entries"
        // )
    }
}

struct JournalEntryRow: View {
    let entry: JournalEntryModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Date and tags
            HStack {
                // Using formatDate from Date+Formatting.swift
                // Text(formatDate(entry.date, format: "MMM d, yyyy"))
                Text(entry.date.formatted(format: "MMM d, yyyy")) // Assuming Date extension is available
                    .font(AppTextStyles.captionText)
                    .foregroundColor(AppColors.textMedium)
                
                Spacer()
                
                if !entry.tags.isEmpty {
                    ForEach(entry.tags.prefix(2), id: \.self) { tag in
                        TagView(tag: tag)
                    }
                    
                    if entry.tags.count > 2 {
                        Text("+\(entry.tags.count - 2)")
                            .font(AppTextStyles.captionText)
                            .foregroundColor(AppColors.textMedium)
                    }
                }
            }
            
            // Title
            Text(entry.title)
                .font(AppTextStyles.h4)
                .foregroundColor(AppColors.textDark)
                .lineLimit(1)
            
            // Preview content
            Text(entry.content.prefix(100) + (entry.content.count > 100 ? "..." : ""))
                .font(AppTextStyles.body1)
                .foregroundColor(AppColors.textMedium)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            // Associated mood if present
            if let mood = entry.mood {
                HStack(spacing: 4) {
                    // Using emoji from JournalMood
                    Text(mood.emoji)
                         .font(.system(size: 12))
                    Text("Feeling: \(mood.name)")
                        .font(AppTextStyles.captionText)
                    
                    if let intensity = entry.moodIntensity {
                        Text("(\(intensity)/10)")
                            .font(AppTextStyles.captionText)
                    }
                }
                .foregroundColor(AppColors.textMedium)
                .padding(.top, 4)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct TagView: View {
    let tag: String
    
    private var tagColor: Color {
        // Simplified color logic, consider moving to a central theme manager if complex
        switch tag {
        case "Rejection": return AppColors.sadness
        case "Insight": return AppColors.accent2
        case "Gratitude": return AppColors.joy
        case "Habit": return AppColors.secondary
        case "Growth": return AppColors.calm
        case "Career": return .blue // Example color
        case "Digital": return .cyan // Example color
        case "Personal": return .orange // Example color
        case "Work": return .pink // Example color
        case "Health": return .teal // Example color
        case "Learning": return .indigo // Example color
        default: return AppColors.textMedium
        }
    }
    
    var body: some View {
        Text(tag)
            .font(AppTextStyles.captionText)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(tagColor.opacity(0.2))
            .foregroundColor(tagColor)
            .cornerRadius(12)
    }
}

// Assuming AppColors, AppTextStyles, AppLayout, JournalEntryModel, JournalMood 
// and Date formatting extensions are accessible from other files. 