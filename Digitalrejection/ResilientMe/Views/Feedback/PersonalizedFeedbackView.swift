//
//  PersonalizedFeedbackView.swift
//  ResilientMe
//
//  Created by Sayed Mohamed on 21.03.25.
//

import SwiftUI

struct PersonalizedFeedbackView: View {
    @ObservedObject var analysisEngine: MoodAnalysisEngine
    @Environment(\.dismiss) private var dismiss
    @State private var selectedRecommendation: MoodRecommendation?
    @State private var selectedStrategy: CopingStrategy?
    @State private var selectedResource: RecommendedResource?
    @State private var showingStrategyDetail = false
    @State private var showingResourceDetail = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with AI badge
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 24))
                            .foregroundColor(Color("Primary"))
                        
                        Text("AI-Powered Insights")
                            .font(.title2)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        // AI badge
                        Text("AI")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("Primary").opacity(0.9))
                            )
                    }
                    .padding(.horizontal)
                    
                    // Recommendations list
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Personalized Recommendations")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(analysisEngine.currentRecommendations) { recommendation in
                                    recommendationCard(recommendation)
                                        .onTapGesture {
                                            withAnimation {
                                                if selectedRecommendation?.id == recommendation.id {
                                                    selectedRecommendation = nil
                                                } else {
                                                    selectedRecommendation = recommendation
                                                }
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                        }
                    }
                    
                    // Selected recommendation details
                    if let recommendation = selectedRecommendation {
                        recommendationDetails(recommendation)
                    }
                }
                .padding(.vertical)
                .sheet(isPresented: $showingStrategyDetail) {
                    if let strategy = selectedStrategy {
                        StrategyDetailView(strategy: strategy)
                    }
                }
                .sheet(isPresented: $showingResourceDetail) {
                    if let resource = selectedResource {
                        ResourceDetailView(resource: resource)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    // MARK: - Recommendation Card
    
    private func recommendationCard(_ recommendation: MoodRecommendation) -> some View {
        return VStack(alignment: .leading, spacing: 8) {
            // Title with confidence indicator
            HStack {
                Text(recommendation.title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Spacer()
                
                // Confidence dots
                HStack(spacing: 2) {
                    ForEach(0..<5) { index in
                        Circle()
                            .fill(index < Int(recommendation.confidenceLevel * 5) ? Color("Primary") : Color.gray.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                }
                .accessibilityLabel("Confidence level: \(Int(recommendation.confidenceLevel * 100))%")
            }
            
            // Detected pattern and description
            if !recommendation.triggerPattern.isEmpty {
                Text("Pattern: \(recommendation.triggerPattern)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Text(recommendation.description)
                .font(.footnote)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            // Indicator of whether this is selected
            HStack {
                Text("Strategies: \(recommendation.strategies.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Resources: \(recommendation.resources.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(width: 280)
        .background(
            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                .fill(selectedRecommendation?.id == recommendation.id ? 
                      Color("Primary").opacity(0.1) : Color("CardBackground"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                .stroke(selectedRecommendation?.id == recommendation.id ? 
                        Color("Primary") : Color.clear, lineWidth: 2)
        )
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Recommendation: \(recommendation.title)")
        .accessibilityHint("Double tap to expand for strategies and resources")
    }
    
    // MARK: - Recommendation Details
    
    private func recommendationDetails(_ recommendation: MoodRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            // Recommendation description
            VStack(alignment: .leading, spacing: 8) {
                Text("About This Pattern")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                
                Text(recommendation.description)
                    .font(.body)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
            }
            
            // Coping strategies
            VStack(alignment: .leading, spacing: 12) {
                Text("Recommended Strategies")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(recommendation.strategies) { strategy in
                            strategyCard(strategy)
                                .onTapGesture {
                                    selectedStrategy = strategy
                                    showingStrategyDetail = true
                                }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // Resources
            if !recommendation.resources.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Helpful Resources")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(recommendation.resources) { resource in
                                resourceCard(resource)
                                    .onTapGesture {
                                        selectedResource = resource
                                        showingResourceDetail = true
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            // Feedback buttons
            VStack(spacing: 16) {
                Text("Was this recommendation helpful?")
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 24) {
                    Button(action: {
                        analysisEngine.markRecommendationAsUnhelpful(recommendation)
                        dismiss()
                    }) {
                        Label("Not Helpful", systemImage: "hand.thumbsdown")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.secondary.opacity(0.2))
                            .cornerRadius(AppLayout.cornerRadius)
                    }
                    
                    Button(action: {
                        analysisEngine.markRecommendationAsHelpful(recommendation)
                        dismiss()
                    }) {
                        Label("Helpful", systemImage: "hand.thumbsup")
                            .font(.body)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color("Primary"))
                            .cornerRadius(AppLayout.cornerRadius)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color("CardBackground"))
            .cornerRadius(AppLayout.cornerRadius)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Strategy Card
    
    private func strategyCard(_ strategy: CopingStrategy) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category badge
            HStack {
                Image(systemName: strategy.category.iconName)
                    .font(.system(size: 16))
                    .foregroundColor(strategy.category.color)
                
                Text(strategy.category.rawValue)
                    .font(.caption)
                    .foregroundColor(strategy.category.color)
                
                Spacer()
                
                Text(strategy.timeToComplete)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Strategy title
            Text(strategy.title)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            // Brief description
            Text(strategy.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                
            // "View Details" button
            HStack {
                Spacer()
                
                Button(action: {
                    selectedStrategy = strategy
                    showingStrategyDetail = true
                }) {
                    Text("View Details")
                        .font(.caption)
                        .foregroundColor(Color("Primary"))
                }
            }
        }
        .padding()
        .frame(width: 280, height: 180)
        .background(Color("CardBackground"))
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Resource Card
    
    private func resourceCard(_ resource: RecommendedResource) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Resource type badge
            HStack {
                Label(
                    title: { Text(resource.type.rawValue) },
                    icon: { Image(systemName: resource.type.iconName) }
                )
                    .font(.caption)
                    .foregroundColor(typeColor(for: resource.type))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(typeColor(for: resource.type).opacity(0.1))
                    .cornerRadius(10)
                
                Spacer()
            }
            
            // Resource title
            Text(resource.title)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            // Brief description
            Text(resource.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            // "View Resource" button
            Button(action: {
                selectedResource = resource
                showingResourceDetail = true
            }) {
                Text("View Resource")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(typeColor(for: resource.type))
                    .cornerRadius(AppLayout.cornerRadius)
            }
        }
        .padding()
        .frame(width: 280, height: 200)
        .background(Color("CardBackground"))
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func typeColor(for type: AppResourceType) -> Color {
        switch type {
        case .article: return Color("Primary")
        case .video: return Color("Joy")
        case .audio: return Color("Calm")
        case .app: return Color("Accent1")
        case .book: return Color("Secondary")
        case .exercise: return Color("Accent3")
        }
    }
}

// MARK: - Strategy Detail View

struct StrategyDetailView: View {
    let strategy: CopingStrategy
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header with category and time
                    HStack {
                        Label(
                            title: { Text(strategy.category.rawValue) },
                            icon: { Image(systemName: strategy.category.iconName) }
                        )
                            .font(.caption)
                            .foregroundColor(strategy.category.color)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(strategy.category.color.opacity(0.1))
                            .cornerRadius(16)
                        
                        Spacer()
                        
                        Label(
                            title: { Text(strategy.timeToComplete) },
                            icon: { Image(systemName: "clock") }
                        )
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Strategy title and description
                    Text(strategy.title)
                        .font(.title)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(strategy.description)
                        .font(.body)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Steps
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Steps")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        ForEach(Array(strategy.steps.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: 16) {
                                Text("\(index + 1)")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .frame(width: 30, height: 30)
                                    .background(strategy.category.color)
                                    .clipShape(Circle())
                                
                                Text(step)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(.top, 8)
                    
                    // Try now button
                    Button(action: {
                        // In a real app, this would perhaps start a timer or guide
                        dismiss()
                    }) {
                        Text("Try This Now")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(strategy.category.color)
                            .cornerRadius(AppLayout.cornerRadius)
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

// MARK: - Resource Detail View

struct ResourceDetailView: View {
    let resource: RecommendedResource
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Resource type badge
                    HStack {
                        Label(
                            title: { Text(resource.type.rawValue) },
                            icon: { Image(systemName: resource.type.iconName) }
                        )
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(16)
                        
                        Spacer()
                    }
                    
                    // Resource title and description
                    Text(resource.title)
                        .font(.title)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(resource.description)
                        .font(.body)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.vertical, 8)
                    
                    // Image if available
                    if let imageURL = resource.imageURL {
                        AsyncImage(url: imageURL) { phase in
                            switch phase {
                            case .empty:
                                Rectangle()
                                    .fill(Color.secondary.opacity(0.2))
                                    .frame(height: 200)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 200)
                                    .cornerRadius(AppLayout.cornerRadius)
                            case .failure:
                                Rectangle()
                                    .fill(Color.secondary.opacity(0.2))
                                    .frame(height: 200)
                                    .overlay(
                                        Image(systemName: "photo")
                                            .font(.system(size: 40))
                                            .foregroundColor(Color.secondary)
                                    )
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .cornerRadius(AppLayout.cornerRadius)
                    }
                    
                    // Open resource button
                    if let url = resource.url {
                        Button(action: {
                            openURL(url)
                        }) {
                            Label("Open Resource", systemImage: "arrow.up.forward.app")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("Primary"))
                                .cornerRadius(AppLayout.cornerRadius)
                        }
                    } else {
                        // Fallback for resources without URLs
                        Text("This resource will be available in a future update.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(AppLayout.cornerRadius)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

// MARK: - Preview Provider

struct PersonalizedFeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock MoodStore and MoodAnalysisEngine with sample data
        let mockMoodStore = MoodStore(context: PersistenceController.preview.container.viewContext)
        let mockAnalysisEngine = MoodAnalysisEngine(moodStore: mockMoodStore)
        
        // Add a mock recommendation for preview
        let mockStrategy = CopingStrategy(
            title: "Grounding Technique",
            description: "A simple mindfulness exercise to reduce anxiety by connecting with your senses.",
            timeToComplete: "5 minutes",
            steps: [
                "Find a comfortable position and take a slow, deep breath.",
                "Notice 5 things you can see around you.",
                "Acknowledge 4 things you can touch or feel.",
                "Listen for 3 sounds in your environment.",
                "Identify 2 things you can smell.",
                "Notice 1 thing you can taste."
            ],
            category: .mindfulness
        )
        
        let mockResource = RecommendedResource(
            title: "The Science Behind Anxiety After Rejection",
            type: .article,
            description: "Learn how rejection triggers anxiety responses in the brain and research-backed techniques to manage these feelings.",
            url: URL(string: "https://www.psychologytoday.com"),
            imageURL: nil
        )
        
        // Return preview with mock data
        return PersonalizedFeedbackView(analysisEngine: mockAnalysisEngine)
    }
} 