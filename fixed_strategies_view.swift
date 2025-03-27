import SwiftUI
import Foundation
#if canImport(UIKit)
import UIKit
#endif
// Remove problematic imports that can't be resolved
// import MoodStore

// Temporary solution: Include minimal required Theme components directly
// This is a workaround until the module import is fixed
// private struct InlineAppTextStyles {
//    static let h1 = Font.system(size: 30, weight: .bold)
//    static let h2 = Font.system(size: 24, weight: .bold)
//    static let h3 = Font.system(size: 20, weight: .semibold)
//    static let h4 = Font.system(size: 18, weight: .semibold)
//    static let body1 = Font.system(size: 16, weight: .regular)
//    static let body2 = Font.system(size: 14, weight: .regular)
//    static let body3 = Font.system(size: 12, weight: .regular)
//    static let caption = Font.system(size: 12, weight: .regular)
//    static let button = Font.system(size: 16, weight: .medium)
//}
// private struct InlineAppLayout {
//    static let cornerRadius: CGFloat = 12.0
//    static let spacing: CGFloat = 16.0
//}
// private struct InlinePredefinedMoods {
//    static let positive = ["Happy", "Calm", "Excited", "Grateful", "Proud", "Motivated", "Confident"]
//    static let negative = ["Sad", "Anxious", "Angry", "Discouraged", "Frustrated", "Disappointed", "Embarrassed", "Overwhelmed"]
//    static let neutral = ["Neutral", "Tired", "Confused", "Surprised", "Curious"]
//    
//    static var all: [String] {
//        positive + negative + neutral
//    }
//    
//    static func categoryFor(mood: String) -> String {
//        if positive.contains(mood) { return "Positive" }
//        if negative.contains(mood) { return "Negative" }
//        return "Neutral"
//    }
//}

// Fix type alias scope issues
// Error: Type alias must be declared private or fileprivate
// private typealias AppTextStyles = InlineAppTextStyles
// private typealias AppLayout = InlineAppLayout
// Add alias for the renamed PredefinedMoods
// private typealias PredefinedMoods = InlinePredefinedMoods

// Local declarations of types
// Fallback declarations

// Rename to avoid redeclaration of 'StrategyEffectivenessStore'
// Error: Invalid redeclaration of 'StrategyEffectivenessStore'
class LocalStrategyEffectivenessStore: ObservableObject {
    static let shared = LocalStrategyEffectivenessStore()
    
    @Published var ratingData: [StrategyRating] = []
    
    struct StrategyRating: Codable, Identifiable {
        let id: UUID
        let strategy: String
        let rating: Int
        let timestamp: Date
        let moodBefore: String?
        let moodAfter: String?
        let moodImpact: String?
        let notes: String?
        let completionTime: TimeInterval?
    }
    
    func getCompletionCount(for strategy: String) -> Int {
        return ratingData.filter { $0.strategy == strategy }.count
    }
    
    func getAverageRating(for strategy: String) -> Double {
        let ratings = ratingData.filter { $0.strategy == strategy }.map { $0.rating }
        guard !ratings.isEmpty else { return 0 }
        return Double(ratings.reduce(0, +)) / Double(ratings.count)
    }
    
    func getMostEffectiveStrategies() -> [(strategy: String, rating: Double)] {
        var strategyRatings: [String: [Int]] = [:]
        
        // Group ratings by strategy
        for rating in ratingData {
            if strategyRatings[rating.strategy] == nil {
                strategyRatings[rating.strategy] = []
            }
            strategyRatings[rating.strategy]?.append(rating.rating)
        }
        
        // Calculate average rating for each strategy
        let averages = strategyRatings.map { (strategy, ratings) in
            (strategy: strategy, rating: Double(ratings.reduce(0, +)) / Double(ratings.count))
        }
        
        // Sort by rating and return top 5
        return averages.sorted { $0.rating > $1.rating }.prefix(5).map { $0 }
    }
    
    func getMostUsedStrategies() -> [(strategy: String, count: Int)] {
        var strategyCounts: [String: Int] = [:]
        
        // Count each strategy use
        for rating in ratingData {
            strategyCounts[rating.strategy, default: 0] += 1
        }
        
        // Convert to array of tuples and sort
        return strategyCounts.map { (strategy: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
            .prefix(5)
            .map { $0 }
    }
    
    func getStrategyTrend(for strategy: String) -> [Double] {
        let ratings = ratingData.filter { $0.strategy == strategy }
            .sorted(by: { $0.timestamp > $1.timestamp })
            .map { Double($0.rating) }
        
        // Pad with zeros if we have fewer than 5 ratings
        var trend = Array(ratings.prefix(5))
        if trend.count < 5 {
            trend += Array(repeating: 0, count: 5 - trend.count)
        }
        
        return trend
    }
    
    func getRatingHistory(for strategy: String) -> [(date: Date, rating: Int)] {
        return ratingData.filter { $0.strategy == strategy }
            .map { (date: $0.timestamp, rating: $0.rating) }
            .sorted(by: { $0.date > $1.date })
    }
    
    // Add a method to add a rating
    func addRating(for strategy: String, rating: Int, moodBefore: String? = nil, moodAfter: String? = nil, moodImpact: String? = nil, notes: String? = nil) {
        let newRating = StrategyRating(
            id: UUID(),
            strategy: strategy,
            rating: rating,
            timestamp: Date(),
            moodBefore: moodBefore,
            moodAfter: moodAfter,
            moodImpact: moodImpact,
            notes: notes,
            completionTime: nil
        )
        
        ratingData.append(newRating)
    }
}

// Import all necessary model types from external sources without duplicate definitions
// This is a simplified mock that will be replaced by the actual implementation
class LocalCopingStrategiesLibrary {
    static let shared = LocalCopingStrategiesLibrary()
    var strategies: [LocalCopingStrategyDetail] = []
    
    // Convert global CopingStrategyDetail to local
    func convertToLocal(_ global: AppCopingStrategyDetail) -> LocalCopingStrategyDetail {
        return LocalCopingStrategyDetail(
            id: global.id,
            title: global.title,
            description: global.description,
            category: mapCategory(global.category),
            timeToComplete: global.timeToComplete,
            steps: global.steps,
            intensity: mapIntensity(global.intensity),
            moodTargets: global.moodTargets,
            tips: global.tips,
            resources: global.resources
        )
    }
    
    // Convert global category to local
    func mapCategory(_ category: AppCopingStrategyCategory) -> LocalCopingStrategyCategory {
        switch category {
        case .mindfulness: return .mindfulness
        case .physical: return .physical
        case .cognitive: return .cognitive
        case .selfCare: return .selfCare
        case .social: return .social
        case .creative: return .creative
        }
    }
    
    // Convert global intensity to local
    func mapIntensity(_ intensity: AppCopingStrategyDetail.StrategyIntensity) -> LocalCopingStrategyDetail.StrategyIntensity {
        switch intensity {
        case .quick: return .quick
        case .moderate: return .moderate
        case .intensive: return .intensive
        }
    }
    
    func getStrategies(for category: LocalCopingStrategyCategory) -> [LocalCopingStrategyDetail] {
        return strategies.filter { $0.category == category }
    }
    
    var categories: [LocalCopingStrategyCategory] {
        return Array(Set(strategies.map { $0.category })).sorted(by: { $0.rawValue < $1.rawValue })
    }
    
    // Map from local to global category
    func mapToGlobalCategory(_ category: LocalCopingStrategyCategory) -> AppCopingStrategyCategory {
        switch category {
        case .mindfulness: return .mindfulness
        case .physical: return .physical
        case .cognitive: return .cognitive
        case .selfCare: return .selfCare
        case .social: return .social
        case .creative: return .creative
        }
    }
    
    // Load strategies from global library
    func loadFromGlobal() {
        let globalStrategies = AppCopingStrategiesLibrary.shared.strategies
        strategies = globalStrategies.map { convertToLocal($0) }
    }
    
    // Add missing methods
    
    // Recommend strategies based on mood and trigger
    func recommendStrategies(for mood: String, intensity: Int, trigger: String? = nil) -> [LocalCopingStrategyDetail] {
        // Use global library to get recommendations, then convert to local format
        let globalStrategies = AppCopingStrategiesLibrary.shared.recommendStrategies(for: mood, intensity: intensity, trigger: trigger)
        return globalStrategies.map { convertToLocal($0) }
    }
    
    // Convert detailed strategies to simple strings (for backward compatibility)
    static func getSimpleStrategyStrings(from strategies: [LocalCopingStrategyDetail]) -> [String] {
        return strategies.map { $0.title }
    }
}

// MARK: - App Haptic Feedback
struct LocalHapticFeedback {
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}

// MARK: - Simple Coping Strategies Library for local use

// MARK: - Coping Strategy Categories

enum LocalCopingStrategyCategory: String, CaseIterable, Identifiable {
    case mindfulness = "Mindfulness"
    case cognitive = "Cognitive"
    case physical = "Physical"
    case social = "Social"
    case creative = "Creative"
    case selfCare = "Self-Care"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .mindfulness: return "brain.head.profile"
        case .cognitive: return "lightbulb"
        case .physical: return "figure.walk"
        case .social: return "person.2"
        case .creative: return "paintpalette"
        case .selfCare: return "heart.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .mindfulness: return Color("Calm")
        case .cognitive: return Color("Primary")
        case .physical: return Color(red: 0.2, green: 0.8, blue: 0.4)
        case .social: return Color(red: 0.6, green: 0.4, blue: 0.8)
        case .creative: return Color(red: 0.9, green: 0.3, blue: 0.5)
        case .selfCare: return Color(red: 0.9, green: 0.4, blue: 0.4)
        }
    }
}

// MARK: - Coping Strategy Detail

struct LocalCopingStrategyDetail: Identifiable {
    public let id: String
    public let title: String
    public let description: String
    public let category: LocalCopingStrategyCategory
    public let timeToComplete: String
    public let steps: [String]
    public let intensity: StrategyIntensity
    public let moodTargets: [String]
    
    // Optional additional fields
    public var tips: [String]?
    public var resources: [String]?
    
    // Enum for strategy intensity
    public enum StrategyIntensity: String, Codable {
        case quick = "Quick"
        case moderate = "Moderate"
        case intensive = "Intensive"
        
        var color: Color {
            switch self {
            case .quick: return Color.green
            case .moderate: return Color.blue
            case .intensive: return Color.purple
            }
        }
    }
    
    // Add conversion method to transform local to global type
    public func toGlobal() -> AppCopingStrategyDetail {
        let globalCategory: AppCopingStrategyCategory
        switch category {
        case .mindfulness: globalCategory = .mindfulness
        case .cognitive: globalCategory = .cognitive
        case .physical: globalCategory = .physical
        case .social: globalCategory = .social
        case .creative: globalCategory = .creative
        case .selfCare: globalCategory = .selfCare
        }
        
        let globalIntensity: AppCopingStrategyDetail.StrategyIntensity
        switch intensity {
        case .quick: globalIntensity = .quick
        case .moderate: globalIntensity = .moderate
        case .intensive: globalIntensity = .intensive
        }
        
        return AppCopingStrategyDetail(
            id: id,
            title: title,
            description: description,
            category: globalCategory,
            timeToComplete: timeToComplete,
            steps: steps,
            intensity: globalIntensity,
            moodTargets: moodTargets,
            tips: tips,
            resources: resources
        )
    }
}

struct CopingStrategiesLibraryView: View {
    // Access the library - update reference to use renamed library
    private let copingStrategiesLibrary = LocalCopingStrategiesLibrary.shared
    
    // State variables
    @State private var selectedCategory: LocalCopingStrategyCategory?
    @State private var selectedStrategy: LocalCopingStrategyDetail?
    @State private var showingStrategyDetail = false
    @State private var searchText = ""
    @State private var isShowingSuccessAlert = false
    @ObservedObject private var strategyStore = LocalStrategyEffectivenessStore.shared
    @State private var showingRatingSheet = false
    @State private var selectedMoodBefore: String? = nil
    @State private var selectedMoodAfter: String? = nil
    @State private var ratingValue: Int = 0
    @State private var moodImpactNote: String = ""
    @State private var showCompletionBanner = false
    
    // Computed properties
    private var categories: [LocalCopingStrategyCategory] {
        LocalCopingStrategyCategory.allCases
    }
    
    private var filteredStrategies: [LocalCopingStrategyDetail] {
        var strategies: [LocalCopingStrategyDetail]
        
        // Filter by category if selected
        if let category = selectedCategory {
            strategies = copingStrategiesLibrary.getStrategies(for: category)
        } else {
            strategies = copingStrategiesLibrary.strategies
        }
        
        // Then filter by search text if any
        if !searchText.isEmpty {
            strategies = strategies.filter { strategy in
                strategy.title.lowercased().contains(searchText.lowercased()) ||
                strategy.description.lowercased().contains(searchText.lowercased()) ||
                strategy.category.rawValue.lowercased().contains(searchText.lowercased())
            }
        }
        
        return strategies
    }
    
    // Group strategies by intensity
    private var quickStrategies: [LocalCopingStrategyDetail] {
        return filteredStrategies.filter { $0.intensity == .quick }
    }
    
    private var moderateStrategies: [LocalCopingStrategyDetail] {
        return filteredStrategies.filter { $0.intensity == .moderate }
    }
    
    private var intensiveStrategies: [LocalCopingStrategyDetail] {
        return filteredStrategies.filter { $0.intensity == .intensive }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    headerView
                    
                    // Search bar
                    searchBar
                    
                    // Category selection
                    categorySelectionView
                    
                    // Quick relief section
                    if !quickStrategies.isEmpty {
                        strategySection(title: "Quick Relief", strategies: quickStrategies, color: LocalCopingStrategyDetail.StrategyIntensity.quick.color)
                    }
                    
                    // Moderate practice section
                    if !moderateStrategies.isEmpty {
                        strategySection(title: "Moderate Practice", strategies: moderateStrategies, color: LocalCopingStrategyDetail.StrategyIntensity.moderate.color)
                    }
                    
                    // Intensive practice section
                    if !intensiveStrategies.isEmpty {
                        strategySection(title: "In-Depth Process", strategies: intensiveStrategies, color: LocalCopingStrategyDetail.StrategyIntensity.intensive.color)
                    }
                    
                    // No results
                    if filteredStrategies.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundColor(Color("TextMedium"))
                            
                            Text("No strategies found")
                                .font(AppTextStyles.h4)
                                .foregroundColor(Color("TextMedium"))
                            
                            Text("Try a different search term or category")
                                .font(AppTextStyles.body2)
                                .foregroundColor(Color("TextMedium"))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    }
                }
                .padding()
            }
            .background(Color("Background"))
            .navigationTitle("Coping Strategies")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Show info about strategies
                    }) {
                        Label("Info", systemImage: "info.circle")
                            .labelStyle(.iconOnly)
                            .foregroundColor(Color("Primary"))
                    }
                }
            }
            .sheet(isPresented: $showingStrategyDetail) {
                if let strategy = selectedStrategy {
                    LocalStrategyDetailView(strategy: strategy)
                }
            }
        }
        .onAppear {
            // Load strategies from global library
            copingStrategiesLibrary.loadFromGlobal()
        }
    }
    
    // MARK: - Component Views
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Coping Strategies Library")
                .font(AppTextStyles.h2)
                .foregroundColor(Color("TextDark"))
            
            Text("Tools for emotional resilience when facing rejection")
                .font(AppTextStyles.body2)
                .foregroundColor(Color("TextMedium"))
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color("TextMedium"))
            
            TextField("Search strategies", text: $searchText)
                .font(AppTextStyles.body2)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color("TextMedium"))
                }
            }
        }
        .padding()
        .background(Color("CardBackground"))
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    private var categorySelectionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Categories section
            VStack(alignment: .leading, spacing: 8) {
                Text("Categories")
                    .font(AppTextStyles.h3)
                    .foregroundColor(Color("TextDark"))
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // All categories option
                        categoryButton(nil, title: "All")
                        
                        // Category buttons
                        ForEach(categories) { category in
                            categoryButton(category)
                        }
                    }
                }
            }
            
            // Emotional states section
            VStack(alignment: .leading, spacing: 8) {
                Text("For emotional states")
                    .font(AppTextStyles.h3)
                    .foregroundColor(Color("TextDark"))
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        emotionFilterButton("Anxiety", icon: "heart.fill", color: .orange)
                        emotionFilterButton("Sadness", icon: "cloud.rain", color: .blue)
                        emotionFilterButton("Stress", icon: "exclamationmark.triangle", color: .red)
                        emotionFilterButton("Anger", icon: "flame", color: .red)
                        emotionFilterButton("Low Confidence", icon: "person.fill.questionmark", color: .purple)
                    }
                }
            }
        }
    }
    
    private func categoryButton(_ category: LocalCopingStrategyCategory?, title: String? = nil) -> some View {
        let isSelected = category == selectedCategory
        let displayTitle = title ?? category?.rawValue ?? "All"
        let iconName = category?.iconName ?? "rectangle.grid.2x2"
        let color = category?.color ?? Color("Primary")
        
        return Button(action: {
            withAnimation {
                if selectedCategory == category {
                    // Deselect if tapping the same category
                    selectedCategory = nil
                } else {
                    selectedCategory = category
                }
            }
            LocalHapticFeedback.selection()
        }) {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.system(size: 14))
                
                Text(displayTitle)
                    .font(AppTextStyles.body3)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? color.opacity(0.2) : Color("CardBackground"))
            .foregroundColor(isSelected ? color : Color("TextDark"))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 1)
            )
        }
    }
    
    // Helper for emotion-based filter buttons
    private func emotionFilterButton(_ emotion: String, icon: String, color: Color) -> some View {
        Button(action: {
            // Filter strategies that target this emotion
            searchText = emotion
            LocalHapticFeedback.selection()
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                
                Text(emotion)
                    .font(AppTextStyles.body3)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(searchText == emotion ? color.opacity(0.2) : Color("CardBackground"))
            .foregroundColor(searchText == emotion ? color : Color("TextDark"))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(searchText == emotion ? color : Color.clear, lineWidth: 1)
            )
        }
    }
    
    private func strategySection(title: String, strategies: [LocalCopingStrategyDetail], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(AppTextStyles.h3)
                    .foregroundColor(Color("TextDark"))
                
                Spacer()
                
                Text("\(strategies.count) strategies")
                    .font(AppTextStyles.caption)
                    .foregroundColor(Color("TextMedium"))
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(strategies) { strategy in
                    strategyCard(strategy, color: color)
                }
            }
        }
    }
    
    private func strategyCard(_ strategy: LocalCopingStrategyDetail, color: Color) -> some View {
        Button(action: {
            selectedStrategy = strategy
            showingStrategyDetail = true
            LocalHapticFeedback.selection()
            markStrategyAsUsed(strategy)
        }) {
            VStack(alignment: .leading, spacing: 8) {
                // Category and time
                HStack {
                    Image(systemName: strategy.category.iconName)
                        .font(.system(size: 12))
                        .foregroundColor(color)
                    
                    Text(strategy.category.rawValue)
                        .font(AppTextStyles.caption)
                        .foregroundColor(color)
                    
                    Spacer()
                    
                    Text(strategy.timeToComplete)
                        .font(AppTextStyles.caption)
                        .foregroundColor(Color("TextMedium"))
                }
                
                // Title
                Text(strategy.title)
                    .font(AppTextStyles.h4)
                    .foregroundColor(Color("TextDark"))
                    .lineLimit(2)
                
                Spacer()
                
                // Description
                Text(strategy.description)
                    .font(AppTextStyles.body3)
                    .foregroundColor(Color("TextMedium"))
                    .lineLimit(2)
                
                Spacer()
                
                // View button
                HStack {
                    Spacer()
                    
                    Text("View")
                        .font(AppTextStyles.caption)
                        .foregroundColor(color)
                }
            }
            .padding()
            .frame(height: 150)
            .background(Color("CardBackground"))
            .cornerRadius(AppLayout.cornerRadius)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Action when user marks a strategy as used
    private func markStrategyAsUsed(_ strategy: LocalCopingStrategyDetail) {
        // Provide haptic feedback
        LocalHapticFeedback.success()
        
        // Display confirmation message
        isShowingSuccessAlert = true
        
        // Record that this strategy was used for tracking
        let now = Date()
        
        // Schedule follow-up to check if the strategy was helpful
        NotificationCenter.default.post(
            name: NSNotification.Name("strategyApplied"),
            object: nil,
            userInfo: ["strategy": strategy.title, "timestamp": now]
        )
    }
    
    // Strategy completion and tracking section for StrategyDetailView
    private func progressCompletionView(strategy: LocalCopingStrategyDetail) -> some View {
        VStack(spacing: 16) {
            Divider()
                .background(Color.gray.opacity(0.3))
                .padding(.vertical, 8)
            
            Text("Track Your Progress")
                .font(.headline)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Rate this strategy after using it to track which strategies work best for you")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Usage count
            if strategyStore.getCompletionCount(for: strategy.title) > 0 {
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Times Used")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(strategyStore.getCompletionCount(for: strategy.title))")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Average Rating")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            Text(String(format: "%.1f", strategyStore.getAverageRating(for: strategy.title)))
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 8)
            }
            
            Button(action: {
                selectedStrategy = strategy
                selectedMoodBefore = nil
                selectedMoodAfter = nil
                ratingValue = 0
                moodImpactNote = ""
                showingRatingSheet = true
            }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Mark as Complete")
                }
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color("Primary"))
                .cornerRadius(10)
            }
        }
        .padding(.top, 8)
    }
    
    // Strategy rating sheet
    private func strategyRatingView(strategy: LocalCopingStrategyDetail) -> some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Title of strategy
                    Text(strategy.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Mood before
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How were you feeling before?")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        moodSelectionGrid(selection: $selectedMoodBefore)
                    }
                    .padding()
                    .background(Color("CardBackground"))
                    .cornerRadius(12)
                    
                    // Mood after
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How are you feeling now?")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        moodSelectionGrid(selection: $selectedMoodAfter)
                    }
                    .padding()
                    .background(Color("CardBackground"))
                    .cornerRadius(12)
                    
                    // Rating
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How effective was this strategy?")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        starRatingView(ratingValue: $ratingValue)
                    }
                    .padding()
                    .background(Color("CardBackground"))
                    .cornerRadius(12)
                    
                    // Notes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Notes (optional)")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("How did this strategy help you?", text: $moodImpactNote)
                            .padding()
                            .background(Color("Background"))
                            .cornerRadius(8)
                    }
                    .padding()
                    .background(Color("CardBackground"))
                    .cornerRadius(12)
                    
                    // Submit button
                    Button(action: {
                        saveStrategyRating(strategy: strategy)
                    }) {
                        Text("Save Progress")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isFormValid ? Color("Primary") : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(!isFormValid)
                    .padding(.top, 12)
                }
                .padding()
            }
            .navigationBarTitle("Rate Strategy", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingRatingSheet = false
                    }
                }
            }
        }
    }
    
    // Check if rating form is valid for submission
    private var isFormValid: Bool {
        selectedStrategy != nil && 
        selectedMoodBefore != nil && 
        selectedMoodAfter != nil && 
        ratingValue > 0
    }
    
    // Strategy completion success banner
    private var completionBanner: some View {
        VStack {
            HStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Progress Tracked!")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Your strategy effectiveness has been saved")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    showCompletionBanner = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color("CardBackground"))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .zIndex(1)
    }
    
    // Save strategy rating
    func saveStrategyRating(strategy: LocalCopingStrategyDetail) {
        // Determine mood impact
        var moodImpact: String? = nil
        if let before = selectedMoodBefore, let after = selectedMoodAfter {
            let beforeCategory = PredefinedMoods.categoryFor(mood: before)
            let afterCategory = PredefinedMoods.categoryFor(mood: after)
            
            if beforeCategory == "Negative" && afterCategory == "Positive" {
                moodImpact = "Major improvement"
            } else if beforeCategory == "Negative" && afterCategory == "Neutral" {
                moodImpact = "Slight improvement"
            } else if beforeCategory == afterCategory {
                moodImpact = "Maintained mood"
            } else if beforeCategory == "Positive" && afterCategory == "Negative" {
                moodImpact = "Mood declined"
            }
        }
        
        // Save the rating
        strategyStore.addRating(
            for: strategy.title,
            rating: ratingValue,
            moodBefore: selectedMoodBefore,
            moodAfter: selectedMoodAfter,
            moodImpact: moodImpact,
            notes: moodImpactNote.isEmpty ? nil : moodImpactNote
        )
        
        // Close sheet and show success banner
        showingRatingSheet = false
        showCompletionBanner = true
        
        // Hide banner after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showCompletionBanner = false
        }
    }
}

// MARK: - Strategy Detail View

struct LocalStrategyDetailView: View {
    let strategy: LocalCopingStrategyDetail
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedStep: Int = 0
    @State private var timerRunning = false
    @State private var timerSeconds = 0
    @State private var timer: Timer? = nil
    @State private var isShowingSuccessAlert = false
    @State private var showingShareOptions = false
    @State private var showingCommunityShare = false
    @State private var showingRatingView = false
    @State private var effectivenessRating: Int = 0
    @State private var completedAllSteps = false
    @State private var showingRatingSheet = false
    @State private var selectedMoodBefore: String? = nil
    @State private var selectedMoodAfter: String? = nil
    @State private var ratingValue: Int = 0
    @State private var moodImpactNote: String = ""
    @State private var showCompletionBanner = false
    @ObservedObject private var strategyStore = LocalStrategyEffectivenessStore.shared
    @State private var completedSteps = Set<Int>()
    
    // MARK: - Helper Properties
    
    private var isFormValid: Bool {
        return selectedMoodBefore != nil && 
               selectedMoodAfter != nil && 
               ratingValue > 0
    }
    
    var body: some View {
        ZStack {
            Color("Background").edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    headerView
                    
                    // Description
                    descriptionView
                    
                    // Steps
                    stepsView
                    
                    // Mark as Complete Button
                    if !completedAllSteps {
                        Button(action: {
                            markStrategyAsCompleted()
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Mark as Complete")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("Primary"))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Sharing options
                    Button(action: {
                        showingShareOptions = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share this Strategy")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .actionSheet(isPresented: $showingShareOptions) {
                        ActionSheet(
                            title: Text("Share Strategy"),
                            message: Text("Choose how you want to share this strategy"),
                            buttons: [
                                .default(Text("Share with Community")) {
                                    showingCommunityShare = true
                                },
                                .default(Text("Share via Message")) {
                                    // Share via message logic
                                },
                                .cancel()
                            ]
                        )
                    }
                    
                    // Timer Button
                    timerButtonView
                    
                    // Resources
                    resourcesView
                    
                    // Related Moods
                    relatedMoodsView
                    
                    // Tips
                    if !(strategy.tips?.isEmpty ?? true) {
                        tipsView
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 40)
            }
            
            // Success alert
            if isShowingSuccessAlert {
                LocalSuccessAlertView(
                    title: "Success!",
                    message: "You've completed this strategy.\nHow did it make you feel?",
                    isPresented: $isShowingSuccessAlert
                )
            }
            
            // Show completion banner at top if needed
            if showCompletionBanner {
                VStack {
                    completionBanner
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showingRatingSheet) {
            strategyRatingView(strategy: strategy)
        }
        .sheet(isPresented: $showingCommunityShare) {
            LocalShareToCommunityView(strategy: strategy)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                // Favorite button
                Button(action: {
                    // Toggle favorite status
                }) {
                    Image(systemName: "heart")
                        .foregroundColor(.primary)
                }
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .onAppear {
            // Start with first step expanded
            selectedStep = 0
        }
        .onDisappear {
            if let timer = timer {
                timer.invalidate()
            }
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Category and intensity
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: strategy.category.iconName)
                        .font(.system(size: 12))
                    
                    Text(strategy.category.rawValue)
                        .font(AppTextStyles.caption)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(strategy.category.color.opacity(0.2))
                .foregroundColor(strategy.category.color)
                .cornerRadius(10)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                    
                    Text(strategy.timeToComplete)
                        .font(AppTextStyles.caption)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(strategy.intensity.color.opacity(0.2))
                .foregroundColor(strategy.intensity.color)
                .cornerRadius(10)
            }
            
            // Title
            Text(strategy.title)
                .font(AppTextStyles.h1)
                .foregroundColor(Color("TextDark"))
                .padding(.top, 8)
        }
    }
    
    private var descriptionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About This Strategy")
                .font(AppTextStyles.h3)
                .foregroundColor(Color("TextDark"))
            
            Text(strategy.description)
                .font(AppTextStyles.body1)
                .foregroundColor(Color("TextMedium"))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color("CardBackground"))
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    private var stepsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Steps to Follow")
                .font(AppTextStyles.h3)
                .foregroundColor(Color("TextDark"))
            
            VStack(spacing: 16) {
                ForEach(0..<strategy.steps.count, id: \.self) { index in
                    stepView(index: index, step: strategy.steps[index])
                }
            }
        }
    }
    
    private func stepView(index: Int, step: String) -> some View {
        let isSelected = selectedStep == index
        let isCompleted = completedSteps.contains(index)
        
        return Button(action: {
            withAnimation {
                selectedStep = isSelected ? -1 : index
            }
            LocalHapticFeedback.selection()
        }) {
            HStack(alignment: .top, spacing: 16) {
                // Step number
                ZStack {
                    Circle()
                        .fill(isCompleted ? strategy.category.color : 
                              isSelected ? strategy.category.color.opacity(0.7) : 
                              Color("CardBackground"))
                        .frame(width: 30, height: 30)
                    
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(AppTextStyles.body3.bold())
                            .foregroundColor(.white)
                    } else {
                        Text("\(index + 1)")
                            .font(AppTextStyles.body3.bold())
                            .foregroundColor(isSelected ? .white : Color("TextDark"))
                    }
                }
                
                // Step content
                VStack(alignment: .leading, spacing: 4) {
                    Text(step)
                        .font(AppTextStyles.body2)
                        .foregroundColor(Color("TextDark"))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                // Mark as completed button
                if isSelected && !isCompleted {
                    Button(action: {
                        withAnimation {
                            completedSteps.insert(index)
                            // Provide success feedback
                            LocalHapticFeedback.success()
                            
                            // Auto-advance to next step if available
                            if index < strategy.steps.count - 1 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation {
                                        selectedStep = index + 1
                                    }
                                }
                            } else {
                                // All steps completed
                                if completedSteps.count == strategy.steps.count {
                                    completedAllSteps = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        markStrategyAsCompleted()
                                    }
                                }
                            }
                        }
                    }) {
                        Text("Complete")
                            .font(AppTextStyles.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(strategy.category.color)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                    .fill(isCompleted ? strategy.category.color.opacity(0.1) :
                          isSelected ? strategy.category.color.opacity(0.05) : 
                          Color("CardBackground"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                    .stroke(isSelected ? strategy.category.color : 
                            isCompleted ? strategy.category.color.opacity(0.5) : 
                            Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var timerButtonView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Simple Timer")
                .font(AppTextStyles.h3)
                .foregroundColor(Color("TextDark"))
            
            VStack(spacing: 16) {
                // Timer display
                HStack {
                    Spacer()
                    
                    Text(formatTime(timerSeconds))
                        .font(.system(size: 48, weight: .medium, design: .monospaced))
                        .foregroundColor(timerRunning ? strategy.category.color : Color("TextDark"))
                    
                    Spacer()
                }
                
                // Timer controls
                HStack(spacing: 20) {
                    Spacer()
                    
                    // Reset button
                    Button(action: {
                        resetTimer()
                        LocalHapticFeedback.light()
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 20))
                            .foregroundColor(Color("TextMedium"))
                            .frame(width: 50, height: 50)
                            .background(Color("CardBackground"))
                            .cornerRadius(25)
                    }
                    
                    // Start/stop button
                    Button(action: {
                        toggleTimer()
                        LocalHapticFeedback.selection()
                    }) {
                        Image(systemName: timerRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(timerRunning ? Color.red : strategy.category.color)
                            .cornerRadius(30)
                    }
                    
                    Spacer()
                }
            }
            .padding()
            .background(Color("CardBackground"))
            .cornerRadius(AppLayout.cornerRadius)
        }
    }
    
    private var resourcesView: some View {
        Group {
            if let resources = strategy.resources, !resources.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Resources")
                        .font(AppTextStyles.h3)
                        .foregroundColor(Color("TextDark"))
                    
                    VStack(spacing: 8) {
                        ForEach(resources, id: \.self) { url in
                            Link(destination: URL(string: url) ?? URL(string: "https://apple.com")!) {
                                HStack {
                                    Image(systemName: "link")
                                        .foregroundColor(strategy.category.color)
                                    
                                    Text(url)
                                        .font(AppTextStyles.body3)
                                        .foregroundColor(Color("Primary"))
                                        .lineLimit(1)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.up.right")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color("TextMedium"))
                                }
                                .padding()
                                .background(Color("CardBackground"))
                                .cornerRadius(AppLayout.cornerRadius)
                            }
                        }
                    }
                }
                .padding()
                .background(Color("CardBackground"))
                .cornerRadius(AppLayout.cornerRadius)
            }
        }
    }
    
    private var relatedMoodsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Helpful For")
                .font(AppTextStyles.h3)
                .foregroundColor(Color("TextDark"))
            
            // Mood tags
            LocalFlowLayout(spacing: 8) {
                ForEach(strategy.moodTargets, id: \.self) { mood in
                    Text(mood)
                        .font(AppTextStyles.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color("Background"))
                        .foregroundColor(Color("TextMedium"))
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color("TextLight"), lineWidth: 1)
                        )
                }
            }
        }
        .padding()
        .background(Color("CardBackground"))
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    private var tipsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tips")
                .font(AppTextStyles.h3)
                .foregroundColor(Color("TextDark"))
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(strategy.tips ?? [], id: \.self) { tip in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color("Primary"))
                            .font(.system(size: 16))
                            .frame(width: 20)
                        
                        Text(tip)
                            .font(AppTextStyles.body1)
                            .foregroundColor(Color("TextMedium"))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding()
        .background(Color("CardBackground"))
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    // MARK: - Helper Methods
    
    private func markStrategyAsCompleted() {
        isShowingSuccessAlert = true
        completedAllSteps = true
        
        // Schedule the rating view to appear after the success alert
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showingRatingSheet = true
        }
        
        // Track strategy completion
        NotificationCenter.default.post(
            name: NSNotification.Name("strategyCompleted"),
            object: nil,
            userInfo: [
                "strategy": strategy.title,
                "timestamp": Date(),
                "category": strategy.category.rawValue
            ]
        )
    }
    
    private func toggleTimer() {
        if timerRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }
    
    private func startTimer() {
        timerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            timerSeconds += 1
        }
    }
    
    private func stopTimer() {
        timerRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    private func resetTimer() {
        stopTimer()
        timerSeconds = 0
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    // Strategy completion success banner
    private var completionBanner: some View {
        VStack {
            HStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Progress Tracked!")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Your strategy effectiveness has been saved")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    showCompletionBanner = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color("CardBackground"))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .zIndex(1)
    }
    
    // Strategy rating view
    private func strategyRatingView(strategy: LocalCopingStrategyDetail) -> some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Title of strategy
                    Text(strategy.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Mood before
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How were you feeling before?")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        moodSelectionGrid(selection: $selectedMoodBefore)
                    }
                    .padding()
                    .background(Color("CardBackground"))
                    .cornerRadius(12)
                    
                    // Mood after
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How are you feeling now?")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        moodSelectionGrid(selection: $selectedMoodAfter)
                    }
                    .padding()
                    .background(Color("CardBackground"))
                    .cornerRadius(12)
                    
                    // Rating
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How effective was this strategy?")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        starRatingView(ratingValue: $ratingValue)
                    }
                    .padding()
                    .background(Color("CardBackground"))
                    .cornerRadius(12)
                    
                    // Notes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Notes (optional)")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("How did this strategy help you?", text: $moodImpactNote)
                            .padding()
                            .background(Color("Background"))
                            .cornerRadius(8)
                    }
                    .padding()
                    .background(Color("CardBackground"))
                    .cornerRadius(12)
                    
                    // Submit button
                    Button(action: {
                        saveStrategyRating(strategy: strategy)
                    }) {
                        Text("Save Progress")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isFormValid ? Color("Primary") : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(!isFormValid)
                    .padding(.top, 12)
                }
                .padding()
            }
            .navigationBarTitle("Rate Strategy", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingRatingSheet = false
                    }
                }
            }
        }
    }
}

// MARK: - Helper Views

/// View for sharing a strategy to the community
struct LocalShareToCommunityView: View {
    let strategy: LocalCopingStrategyDetail
    @Environment(\.presentationMode) var presentationMode
    @State private var personalNote: String = ""
    @State private var isSharing: Bool = false
    @State private var showingSuccessAlert: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(spacing: 24) {
                        // Strategy card
                        strategyCardView
                        
                        // Personal note
                        personalNoteView
                        
                        // Share button
                        shareButtonView
                    }
                    .padding()
                }
            }
            .navigationBarTitle("Share Strategy", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(Color("TextDark"))
                    }
                }
            }
            .alert(isPresented: $showingSuccessAlert) {
                Alert(
                    title: Text("Strategy Shared"),
                    message: Text("Your strategy has been shared with the community!"),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
    }
    
    // MARK: - Subviews
    
    private var strategyCardView: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title
            Text(strategy.title)
                .font(AppTextStyles.h3)
                .foregroundColor(Color("TextDark"))
            
            // Description
            Text(strategy.description)
                .font(AppTextStyles.body2)
                .foregroundColor(Color("TextMedium"))
            
            // Category badge
            HStack(spacing: 4) {
                Image(systemName: strategy.category.iconName)
                    .font(.system(size: 12))
                
                Text(strategy.category.rawValue)
                    .font(AppTextStyles.caption)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(strategy.category.color.opacity(0.2))
            .foregroundColor(strategy.category.color)
            .cornerRadius(10)
        }
        .padding()
        .background(Color("CardBackground"))
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    private var personalNoteView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add a personal note")
                .font(AppTextStyles.h4)
                .foregroundColor(Color("TextDark"))
            
            Text("Share how this strategy helped you (optional)")
                .font(AppTextStyles.body3)
                .foregroundColor(Color("TextMedium"))
            
            TextEditor(text: $personalNote)
                .frame(minHeight: 100)
                .padding()
                .background(Color("Background"))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("TextLight"), lineWidth: 1)
                )
        }
        .padding()
        .background(Color("CardBackground"))
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    private var shareButtonView: some View {
        Button(action: {
            shareStrategy()
        }) {
            HStack {
                if isSharing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "person.3.fill")
                    Text("Share to Community")
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color("Primary"))
            .cornerRadius(AppLayout.cornerRadius)
        }
        .disabled(isSharing)
    }
    
    private func shareStrategy() {
        isSharing = true
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isSharing = false
            showingSuccessAlert = true
            
            // Post notification for tracking
            NotificationCenter.default.post(
                name: NSNotification.Name("strategyShared"),
                object: nil,
                userInfo: [
                    "strategy": strategy.title,
                    "category": strategy.category.rawValue,
                    "timestamp": Date(),
                    "hasPersonalNote": !personalNote.isEmpty
                ]
            )
        }
    }
}

/// Success alert view for strategy completion
struct LocalSuccessAlertView: View {
    let title: String
    let message: String
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Color("Success"))
                    
                    Text(title)
                        .font(AppTextStyles.h3)
                        .foregroundColor(Color("TextDark"))
                    
                    Text(message)
                        .font(AppTextStyles.body1)
                        .foregroundColor(Color("TextDark"))
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        withAnimation {
                            isPresented = false
                        }
                    }) {
                        Text("OK")
                            .font(AppTextStyles.button)
                            .foregroundColor(.white)
                            .frame(width: 100)
                            .padding(.vertical, 12)
                            .background(Color("Primary"))
                            .cornerRadius(AppLayout.cornerRadius)
                    }
                }
                .padding(24)
                .background(Color("CardBackground"))
                .cornerRadius(AppLayout.cornerRadius)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                .padding()
                Spacer()
            }
            Spacer()
        }
        .background(Color.black.opacity(0.3))
        .edgesIgnoringSafeArea(.all)
        .transition(.opacity)
        .onAppear {
            // Auto-dismiss after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    isPresented = false
                }
            }
        }
    }
}

/// Flow layout that arranges items in rows
struct LocalFlowLayout: Layout {
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let width = proposal.width ?? .infinity
        var height: CGFloat = 0
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for view in subviews {
            let viewSize = view.sizeThatFits(.unspecified)
            
            if rowWidth + viewSize.width > width {
                // Start a new row
                height += rowHeight + spacing
                rowWidth = viewSize.width
                rowHeight = viewSize.height
            } else {
                // Add to the current row
                rowWidth += viewSize.width + spacing
                rowHeight = max(rowHeight, viewSize.height)
            }
        }
        
        // Add the last row
        height += rowHeight
        
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        var rowStartIndex = 0
        
        // First pass: determine rows
        for (index, view) in subviews.enumerated() {
            let viewSize = view.sizeThatFits(.unspecified)
            
            if rowWidth + viewSize.width > bounds.width && index > rowStartIndex {
                // Place the current row
                placeRow(in: bounds, from: rowStartIndex, to: index, y: rowHeight, subviews: subviews)
                
                // Start a new row
                rowWidth = viewSize.width
                rowHeight += viewSize.height + spacing
                rowStartIndex = index
            } else {
                // Add to the current row
                rowWidth += viewSize.width + (index > rowStartIndex ? spacing : 0)
            }
        }
        
        // Place the last row
        placeRow(in: bounds, from: rowStartIndex, to: subviews.count, y: rowHeight, subviews: subviews)
    }
    
    private func placeRow(in bounds: CGRect, from startIndex: Int, to endIndex: Int, y: CGFloat, subviews: Subviews) {
        var x = bounds.minX
        
        for index in startIndex..<endIndex {
            let viewSize = subviews[index].sizeThatFits(.unspecified)
            subviews[index].place(at: CGPoint(x: x, y: bounds.minY + y), proposal: ProposedViewSize(width: viewSize.width, height: viewSize.height))
            x += viewSize.width + spacing
        }
    }
}

// MARK: - Preview

struct CopingStrategiesLibraryView_Previews: PreviewProvider {
    static var previews: some View {
        CopingStrategiesLibraryView()
    }
}

// Add ActivityViewController for the standard iOS share sheet
struct LocalActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// Create private type alias for backward compatibility
private typealias ActivityViewController = LocalActivityViewController

// MARK: - StrategyDetailView Extensions

extension LocalStrategyDetailView {
    // Add the missing saveStrategyRating implementation
    func saveStrategyRating(strategy: LocalCopingStrategyDetail) {
        // Determine mood impact
        var moodImpact: String? = nil
        if let before = selectedMoodBefore, let after = selectedMoodAfter {
            let beforeCategory = PredefinedMoods.categoryFor(mood: before)
            let afterCategory = PredefinedMoods.categoryFor(mood: after)
            
            if beforeCategory == "Negative" && afterCategory == "Positive" {
                moodImpact = "Major improvement"
            } else if beforeCategory == "Negative" && afterCategory == "Neutral" {
                moodImpact = "Slight improvement"
            } else if beforeCategory == afterCategory {
                moodImpact = "Maintained mood"
            } else if beforeCategory == "Positive" && afterCategory == "Negative" {
                moodImpact = "Mood declined"
            }
        }
        
        // Save the rating
        strategyStore.addRating(
            for: strategy.title,
            rating: ratingValue,
            moodBefore: selectedMoodBefore,
            moodAfter: selectedMoodAfter,
            moodImpact: moodImpact,
            notes: moodImpactNote.isEmpty ? nil : moodImpactNote
        )
        
        // Close sheet and show success banner
        showingRatingSheet = false
        showCompletionBanner = true
        
        // Hide banner after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showCompletionBanner = false
        }
    }
}

struct LocalStrategyListView: View {
    let title: String
    let strategies: [LocalCopingStrategyDetail]
    let onSelect: (LocalCopingStrategyDetail) -> Void
    
    var body: some View {
        Text(title)
        // This is a placeholder implementation
    }
}

struct LocalCategoryFilterButton: View {
    let category: LocalCopingStrategyCategory?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category?.rawValue ?? "All")
        }
        // This is a placeholder implementation
    }
}

private func moodSelectionGrid(selection: Binding<String?>) -> some View {
    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100, maximum: 150))], spacing: 10) {
        ForEach(PredefinedMoods.all, id: \.self) { mood in
            Button(action: {
                selection.wrappedValue = mood
            }) {
                Text(mood)
                    .font(.subheadline)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .frame(minWidth: 100)
                    .background(selection.wrappedValue == mood ? Color("Primary") : Color("CardBackground"))
                    .foregroundColor(selection.wrappedValue == mood ? .white : .primary)
                    .cornerRadius(8)
            }
        }
    }
}

private func starRatingView(ratingValue: Binding<Int>) -> some View {
    VStack(spacing: 8) {
        HStack(spacing: 12) {
            ForEach(1...5, id: \.self) { rating in
                Button(action: {
                    ratingValue.wrappedValue = rating
                }) {
                    Image(systemName: rating <= ratingValue.wrappedValue ? "star.fill" : "star")
                        .font(.system(size: 32))
                        .foregroundColor(rating <= ratingValue.wrappedValue ? .yellow : .gray)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 8)
        
        // Rating labels
        HStack {
            Text("Not effective")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text("Very effective")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// Convert local CopingStrategyDetail to global CopingStrategyDetail

// Update any code that shares strategies to convert between types
private func shareStrategy(_ strategy: LocalCopingStrategyDetail) {
    // Convert to global type if needed for sharing
    let globalStrategy = strategy.toGlobal()
    // Remaining content without duplicate declarations
}

// Create private type aliases for backward compatibility
private typealias CopingStrategiesLibrary = LocalCopingStrategiesLibrary
private typealias StrategyDetailView = LocalStrategyDetailView
private typealias ShareToCommunityView = LocalShareToCommunityView
private typealias SuccessAlertView = LocalSuccessAlertView
private typealias FlowLayout = LocalFlowLayout
private typealias StrategyListView = LocalStrategyListView
private typealias CategoryFilterButton = LocalCategoryFilterButton
