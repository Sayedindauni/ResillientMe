import SwiftUI
import ResilientMe

struct CoreCopingStrategyDetailView: View {
    var strategy: LocalCopingStrategyDetail
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(strategy.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack {
                        CategoryBadge(category: strategy.category.rawValue)
                        Spacer()
                        
                        Label(
                            title: { Text(strategy.timeToComplete) },
                            icon: { Image(systemName: "clock") }
                        )
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                    }
                }
                .padding(.bottom, 8)
                
                // Description
                if !strategy.description.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                        
                        Text(strategy.description)
                            .font(.body)
                    }
                    .padding(.bottom, 8)
                }
                
                // Steps
                if !strategy.steps.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Steps")
                            .font(.headline)
                        
                        ForEach(Array(strategy.steps.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: 8) {
                                Text("\(index + 1).")
                                    .font(.body)
                                    .fontWeight(.bold)
                                
                                Text(step)
                                    .font(.body)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(.bottom, 8)
                }
                
                // Tags
                if !strategy.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tags")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(strategy.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.secondary.opacity(0.2))
                                        .foregroundColor(.primary)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 8)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

struct CategoryBadge: View {
    var category: String
    
    var body: some View {
        Text(category.uppercased())
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(getCategoryColor(for: category))
            .foregroundColor(.white)
            .cornerRadius(4)
    }
    
    func getCategoryColor(for category: String) -> Color {
        switch category.lowercased() {
        case "mindfulness": return .blue
        case "thought work": return .purple
        case "physical activity": return .green
        case "social connection": return .orange
        case "creative expression": return .pink
        case "self-care": return .red
        default: return .gray
        }
    }
}

#if DEBUG
struct CoreCopingStrategyDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CoreCopingStrategyDetailView(
            strategy: LocalCopingStrategyDetail(
                id: UUID(),
                title: "Deep Breathing",
                description: "A simple technique to reduce stress and anxiety.",
                category: .mindfulness,
                timeToComplete: "5-10 minutes",
                difficultyLevel: "Beginner",
                steps: [
                    "Find a quiet place to sit or lie down",
                    "Breathe in slowly through your nose for a count of 4",
                    "Hold your breath for a count of 2",
                    "Exhale slowly through your mouth for a count of 6",
                    "Repeat for 5-10 minutes"
                ],
                source: "ResilientMe",
                tags: ["Breathing", "Stress Relief", "Quick"]
            )
        )
    }
}
#endif 