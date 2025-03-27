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
            // Breaking down the complex expression into smaller parts
            ScrollView {
                VStack(spacing: 24) {
                    // Header with AI badge
                    headerView
                    
                    // Recommendations list section
                    recommendationsSection
                    
                    // Selected recommendation details
                    if let recommendation = selectedRecommendation {
                        recommendationDetails(recommendation)
                    }
                }
                .padding(.vertical)
                .sheet(isPresented: $showingStrategyDetail) {
                    if let strategy = selectedStrategy {
                        FeedbackStrategyDetailView(strategy: strategy)
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
    
    // MARK: - Component Views
    
    // Header view component
    private var headerView: some View {
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
    }
    
    // Recommendations section
    private var recommendationsSection: some View {
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
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(AppLayout.cornerRadius)
                    }
                    
                    Button(action: {
                        analysisEngine.markRecommendationAsHelpful(recommendation)
                        dismiss()
                    }) {
                        Label("Helpful", systemImage: "hand.thumbsup")
                            .font(.body)
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                            .background(Color.green.opacity(0.8))
                            .cornerRadius(AppLayout.cornerRadius)
                    }
                }
            }
            .padding()
            .background(Color("CardBackground"))
            .cornerRadius(AppLayout.cornerRadius)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Strategy Card
    
    private func strategyCard(_ strategy: CopingStrategy) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category and time
            HStack {
                Label(
                    title: { Text(strategy.category.rawValue) },
                    icon: { Image(systemName: strategy.category.iconName) }
                )
                    .font(.caption)
                    .foregroundColor(strategy.category.color)
                
                Spacer()
                
                Text(strategy.timeToComplete)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Title and description
            Text(strategy.title)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(2)
            
            Text(strategy.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            Spacer()
            
            // View details button
            HStack {
                Spacer()
                
                Label("View", systemImage: "chevron.right")
                    .font(.caption)
                    .foregroundColor(strategy.category.color)
            }
        }
        .padding()
        .frame(width: 240, height: 180)
        .background(Color("CardBackground"))
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Resource Card
    
    private func resourceCard(_ resource: RecommendedResource) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Resource type badge
            HStack {
                Label(
                    title: { Text(resource.type.rawValue) },
                    icon: { Image(systemName: resource.type.iconName) }
                )
                    .font(.caption)
                    .foregroundColor(resource.type.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(resource.type.color.opacity(0.1))
                    .cornerRadius(8)
                
                Spacer()
                
                // New or updated badge
                if resource.isNew {
                    Text("NEW")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue)
                        .cornerRadius(4)
                }
            }
            
            // Title and source
            Text(resource.title)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(2)
            
            if !resource.source.isEmpty {
                Text(resource.source)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // View button
            HStack {
                Spacer()
                
                Label("View", systemImage: "chevron.right")
                    .font(.caption)
                    .foregroundColor(resource.type.color)
            }
        }
        .padding()
        .frame(width: 240, height: 150)
        .background(Color("CardBackground"))
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Strategy Detail View
// Renamed to avoid conflict with CopingStrategiesLibraryView

struct FeedbackStrategyDetailView: View {
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
                        
                        ForEach(0..<strategy.steps.count, id: \.self) { index in
                            HStack(alignment: .top) {
                                Text("\(index + 1).")
                                    .font(.body.bold())
                                    .foregroundColor(strategy.category.color)
                                    .frame(width: 24, alignment: .center)
                                
                                Text(strategy.steps[index])
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitle("Strategy Details", displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            )
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
                    Label(
                        title: { Text(resource.type.rawValue) },
                        icon: { Image(systemName: resource.type.iconName) }
                    )
                        .font(.subheadline)
                        .foregroundColor(resource.type.color)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(resource.type.color.opacity(0.1))
                        .cornerRadius(16)
                    
                    // Title and source
                    Text(resource.title)
                        .font(.title)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if !resource.source.isEmpty {
                        Text("Source: \(resource.source)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Description
                    Text(resource.description)
                        .font(.body)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // External link if available
                    if !resource.url.isEmpty {
                        Button(action: {
                            if let url = URL(string: resource.url) {
                                openURL(url)
                            }
                        }) {
                            Label("Open External Resource", systemImage: "link")
                                .font(.body)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(resource.type.color)
                                .cornerRadius(AppLayout.cornerRadius)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitle("Resource Details", displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            )
        }
    }
}

// MARK: - Preview
struct PersonalizedFeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        let moodStore = MoodStore(context: PersistenceController.preview.container.viewContext)
        let analysisEngine = MoodAnalysisEngine(moodStore: moodStore)
        
        return PersonalizedFeedbackView(analysisEngine: analysisEngine)
    }
} 