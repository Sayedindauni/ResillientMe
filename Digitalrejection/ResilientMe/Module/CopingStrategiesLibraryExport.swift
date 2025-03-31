// MARK: - CopingStrategiesLibrary Module Export
// This file provides public exports for the CopingStrategiesLibraryView module

import SwiftUI
// Remove the problematic import
// import ResilientMe

// Re-export the views and types directly with new names to avoid conflicts
public struct ExportCopingStrategyDetail: Identifiable, Hashable, Codable {
    public let id: String
    public let title: String
    public let description: String
    public let category: ExportCopingStrategyCategory
    public let timeToComplete: String
    public let steps: [String]
    public let intensity: StrategyIntensity
    public let moodTargets: [String]
    public let tips: [String]?
    public let resources: [String]?
    
    public enum StrategyIntensity: String, Codable, CaseIterable, Identifiable {
        case quick = "Quick Relief"
        case moderate = "Moderate Effort"
        case intensive = "Deep Healing"
        
        public var id: String { rawValue }
        
        public var color: Color {
            switch self {
            case .quick: return Color.green
            case .moderate: return Color.orange
            case .intensive: return Color.red
            }
        }
    }
    
    // Hashable conformance
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Constructor with all fields
    public init(id: String, title: String, description: String, category: ExportCopingStrategyCategory,
                timeToComplete: String, steps: [String], intensity: StrategyIntensity,
                moodTargets: [String], tips: [String]? = nil, resources: [String]? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.timeToComplete = timeToComplete
        self.steps = steps
        self.intensity = intensity
        self.moodTargets = moodTargets
        self.tips = tips
        self.resources = resources
    }
}

public enum ExportCopingStrategyCategory: String, CaseIterable, Identifiable, Codable {
    case mindfulness = "Mindfulness"
    case physical = "Physical"
    case cognitive = "Cognitive"
    case selfCare = "Self-Care"
    case social = "Social"
    case creative = "Creative"
    
    public var id: String { rawValue }
    
    public var color: Color {
        switch self {
        case .mindfulness: return Color.blue
        case .physical: return Color.green
        case .cognitive: return Color.purple
        case .selfCare: return Color.orange
        case .social: return Color.pink
        case .creative: return Color.indigo
        }
    }
    
    public var iconName: String {
        switch self {
        case .mindfulness: return "brain.head.profile"
        case .physical: return "figure.walk"
        case .cognitive: return "lightbulb"
        case .selfCare: return "heart.fill"
        case .social: return "person.2"
        case .creative: return "paintpalette"
        }
    }
}

// Create a simple CopingStrategiesLibrary class
public class ExportCopingStrategiesLibrary {
    public static let shared = ExportCopingStrategiesLibrary()
    
    public var strategies: [ExportCopingStrategyDetail] = []
    
    private init() {
        loadSampleStrategies()
    }
    
    private func loadSampleStrategies() {
        strategies = [
            ExportCopingStrategyDetail(
                id: "mind1",
                title: "Mindful Breathing",
                description: "Focus on your breath to calm your mind and reduce stress",
                category: .mindfulness,
                timeToComplete: "5 minutes",
                steps: [
                    "Find a quiet place to sit comfortably",
                    "Close your eyes and take a deep breath",
                    "Focus on your breathing, noticing the sensation",
                    "If your mind wanders, gently bring it back to your breath",
                    "Continue for 5 minutes"
                ],
                intensity: .quick,
                moodTargets: ["anxiety", "stress", "overwhelmed", "rejected"]
            ),
            ExportCopingStrategyDetail(
                id: "phys1",
                title: "Quick Walk Outside",
                description: "Taking a brief walk outdoors can shift your perspective",
                category: .physical,
                timeToComplete: "10 minutes",
                steps: [
                    "Put on comfortable shoes",
                    "Step outside and walk at a comfortable pace",
                    "Notice the environment around you",
                    "Focus on physical sensations rather than thoughts",
                    "Return feeling refreshed"
                ],
                intensity: .moderate,
                moodTargets: ["sadness", "frustration", "rejected", "stuck"]
            ),
            ExportCopingStrategyDetail(
                id: "cog1",
                title: "Reframing Rejection",
                description: "Change your perspective on rejection to see opportunities",
                category: .cognitive,
                timeToComplete: "15 minutes",
                steps: [
                    "Write down the rejection you experienced",
                    "List what you learned from this experience",
                    "Identify potential opportunities that may arise",
                    "Write down 3 strengths you still possess",
                    "Create an action plan for moving forward"
                ],
                intensity: .intensive,
                moodTargets: ["rejected", "discouraged", "disappointed"]
            )
        ]
    }
    
    public func getStrategiesForCategory(_ category: ExportCopingStrategyCategory) -> [ExportCopingStrategyDetail] {
        return strategies.filter { $0.category == category }
    }
    
    public func getStrategiesForMood(_ mood: String) -> [ExportCopingStrategyDetail] {
        return strategies.filter { strategy in
            strategy.moodTargets.contains { $0.lowercased().contains(mood.lowercased()) }
        }
    }
}

// The main library view
public struct CopingStrategiesLibraryView: View {
    private let strategiesLibrary = ExportCopingStrategiesLibrary.shared
    @State private var searchText: String = ""
    @State private var selectedCategory: ExportCopingStrategyCategory? = nil
    @State private var selectedStrategy: ExportCopingStrategyDetail? = nil
    @State private var showingStrategyDetail = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search strategies", text: $searchText)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                .padding()
                
                // Category selection
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        categoryButton(nil, isSelected: selectedCategory == nil)
                        
                        ForEach(ExportCopingStrategyCategory.allCases) { category in
                            categoryButton(category, isSelected: selectedCategory == category)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Strategies list
                List {
                    ForEach(filteredStrategies) { strategy in
                        strategyRow(strategy)
                            .onTapGesture {
                                selectedStrategy = strategy
                                showingStrategyDetail = true
                            }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Coping Strategies")
            .sheet(isPresented: $showingStrategyDetail) {
                if let strategy = selectedStrategy {
                    StrategyDetailView(strategy: strategy)
                }
            }
        }
    }
    
    private var filteredStrategies: [ExportCopingStrategyDetail] {
        let strategies = selectedCategory == nil
            ? strategiesLibrary.strategies
            : strategiesLibrary.getStrategiesForCategory(selectedCategory!)
        
        if searchText.isEmpty {
            return strategies
        } else {
            return strategies.filter { strategy in
                strategy.title.lowercased().contains(searchText.lowercased()) ||
                strategy.description.lowercased().contains(searchText.lowercased()) ||
                strategy.moodTargets.contains { $0.lowercased().contains(searchText.lowercased()) }
            }
        }
    }
    
    private func categoryButton(_ category: ExportCopingStrategyCategory?, isSelected: Bool) -> some View {
        let title = category?.rawValue ?? "All"
        let bgColor = isSelected
            ? (category?.color ?? Color.gray)
            : Color.gray.opacity(0.2)
        
        return Button(action: {
            selectedCategory = category
        }) {
            Text(title)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(bgColor)
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
    
    private func strategyRow(_ strategy: ExportCopingStrategyDetail) -> some View {
        HStack {
            Image(systemName: strategy.category.iconName)
                .foregroundColor(strategy.category.color)
                .font(.system(size: 24))
                .frame(width: 40, height: 40)
                .background(strategy.category.color.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(strategy.title)
                    .font(.headline)
                
                Text(strategy.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text(strategy.timeToComplete)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(strategy.intensity.rawValue)
                        .font(.caption)
                        .foregroundColor(strategy.intensity.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(strategy.intensity.color.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding(.top, 4)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// Strategy detail view
public struct StrategyDetailView: View {
    public let strategy: ExportCopingStrategyDetail
    @Environment(\.presentationMode) private var presentationMode
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: strategy.category.iconName)
                            .foregroundColor(strategy.category.color)
                            .font(.system(size: 30))
                            .frame(width: 60, height: 60)
                            .background(strategy.category.color.opacity(0.1))
                            .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(strategy.category.rawValue)
                                .font(.subheadline)
                                .foregroundColor(strategy.category.color)
                            
                            Text(strategy.title)
                                .font(.title)
                                .bold()
                        }
                    }
                    
                    Text(strategy.description)
                        .font(.body)
                        .padding(.top, 8)
                    
                    HStack {
                        Label(strategy.timeToComplete, systemImage: "clock")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(strategy.intensity.rawValue)
                            .font(.subheadline)
                            .foregroundColor(strategy.intensity.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(strategy.intensity.color.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding(.top, 4)
                }
                
                Divider()
                
                // Steps
                VStack(alignment: .leading, spacing: 12) {
                    Text("Steps")
                        .font(.title2)
                        .bold()
                    
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(Array(strategy.steps.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 30, height: 30)
                                    .background(strategy.category.color)
                                    .cornerRadius(15)
                                
                                Text(step)
                                    .font(.body)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                
                // For which moods
                if !strategy.moodTargets.isEmpty {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Helpful For")
                            .font(.title2)
                            .bold()
                        
                        HFlow(spacing: 8, alignment: .leading) {
                            ForEach(strategy.moodTargets, id: \.self) { mood in
                                Text(mood.capitalized)
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(16)
                            }
                        }
                    }
                }
                
                // Additional tips
                if let tips = strategy.tips, !tips.isEmpty {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tips")
                            .font(.title2)
                            .bold()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(tips, id: \.self) { tip in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(.yellow)
                                    
                                    Text(tip)
                                        .font(.body)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                }
                
                // Resources
                if let resources = strategy.resources, !resources.isEmpty {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Resources")
                            .font(.title2)
                            .bold()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(resources, id: \.self) { resource in
                                HStack {
                                    Image(systemName: "link")
                                        .foregroundColor(.blue)
                                    
                                    Text(resource)
                                        .font(.body)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Strategy Details")
        #if os(iOS)
        .navigationBarTitle("", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        #else
        .toolbar {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
        }
        #endif
    }
}

// Horizontal flow layout for tags
public struct HFlow<Content: View>: View {
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    @ViewBuilder let content: () -> Content
    
    public init(spacing: CGFloat = 8, alignment: HorizontalAlignment = .center, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }
    
    public var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            HStack(spacing: spacing) {
                content()
            }
            .fixedSize(horizontal: false, vertical: true)
            .lineLimit(3)
        }
    }
} 