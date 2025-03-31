import SwiftUI

struct CopingStrategyDetailView: View {
    var strategy: CopingStrategyDetail
    
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
                
                // Tips
                if !strategy.tips.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tips")
                            .font(.headline)
                        
                        ForEach(strategy.tips, id: \.self) { tip in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                
                                Text(tip)
                                    .font(.body)
                            }
                            .padding(.vertical, 4)
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
        case "physical":
            return Color.blue
        case "emotional":
            return Color.pink
        case "cognitive":
            return Color.purple
        case "social":
            return Color.green
        case "spiritual":
            return Color.orange
        default:
            return Color.gray
        }
    }
}

#if DEBUG
struct CopingStrategyDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CopingStrategyDetailView(
            strategy: CopingStrategyDetail(
                id: "1",
                title: "Deep Breathing",
                description: "A simple technique to reduce stress and anxiety.",
                category: .physical,
                steps: [
                    "Find a quiet place to sit or lie down",
                    "Breathe in slowly through your nose for a count of 4",
                    "Hold your breath for a count of 2",
                    "Exhale slowly through your mouth for a count of 6",
                    "Repeat for 5-10 minutes"
                ],
                tips: [
                    "Practice daily for best results",
                    "Try combining with progressive muscle relaxation"
                ],
                iconName: "lungs"
            )
        )
    }
}
#endif 