import SwiftUI
import ResilientMe
import UIKit
import Foundation

// Add typealias to use the central haptic feedback implementation
typealias HapticFeedback = LocalHapticFeedback

// Define the missing enums
enum CopingBreathingPhase: String, Identifiable, CaseIterable {
    case inhale
    case hold
    case exhale
    case holdAfterExhale
    case complete
    
    var id: String { rawValue }
    
    var instruction: String {
        switch self {
        case .inhale: return "Breathe In"
        case .hold: return "Hold"
        case .exhale: return "Breathe Out"
        case .holdAfterExhale: return "Hold"
        case .complete: return "Complete"
        }
    }
    
    // Change to a computed property with private backing storage
    private static var _timeRemaining: [CopingBreathingPhase: Double] = [:]
    
    var timeRemaining: Double {
        get { CopingBreathingPhase._timeRemaining[self] ?? 0.0 }
        set { CopingBreathingPhase._timeRemaining[self] = newValue }
    }
}

enum CopingBreathingPattern: String, CaseIterable, Identifiable {
    case fourSevenEight = "4-7-8 Breathing"
    case boxBreathing = "Box Breathing"
    case deepBreathing = "Deep Breathing"
    case calmingBreath = "Calming Breath"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .fourSevenEight:
            return "Inhale for 4 seconds, hold for 7 seconds, exhale for 8 seconds"
        case .boxBreathing:
            return "Inhale for 4 seconds, hold for 4 seconds, exhale for 4 seconds, hold for 4 seconds"
        case .deepBreathing:
            return "Inhale deeply for 5 seconds, exhale slowly for 5 seconds"
        case .calmingBreath:
            return "Inhale for 3 seconds, hold for 2 seconds, exhale for 4 seconds"
        }
    }
    
    var inhaleTime: Double {
        switch self {
        case .fourSevenEight: return 4.0
        case .boxBreathing: return 4.0
        case .deepBreathing: return 5.0
        case .calmingBreath: return 3.0
        }
    }
    
    var holdTime: Double {
        switch self {
        case .fourSevenEight: return 7.0
        case .boxBreathing: return 4.0
        case .deepBreathing: return 0.0
        case .calmingBreath: return 2.0
        }
    }
    
    var exhaleTime: Double {
        switch self {
        case .fourSevenEight: return 8.0
        case .boxBreathing: return 4.0
        case .deepBreathing: return 5.0
        case .calmingBreath: return 4.0
        }
    }
    
    var holdAfterExhaleTime: Double {
        switch self {
        case .fourSevenEight: return 0.0
        case .boxBreathing: return 4.0
        case .deepBreathing: return 0.0
        case .calmingBreath: return 0.0
        }
    }
    
    var totalCycleTime: Double {
        return inhaleTime + holdTime + exhaleTime + holdAfterExhaleTime
    }
}

// These enums are now defined in the Dashboard file
// For simplicity, define the same type aliases here
typealias BreathingPhase = CopingBreathingPhase
typealias BreathingPattern = CopingBreathingPattern

// MARK: - Strategy Effectiveness Store
class LocalStrategyEffectivenessStore: ObservableObject {
    static let shared = LocalStrategyEffectivenessStore()
    
    struct StrategyRating: Identifiable {
        let id = UUID()
        let strategy: String
        let rating: Int
        let date: Date
        let notes: String?
    }
    
    @Published private var ratings: [StrategyRating] = []
    
    private init() {
        // Load sample data for demo
        loadSampleData()
    }
    
    func addRating(for strategy: String, rating: Int, notes: String? = nil) {
        let newRating = StrategyRating(
            strategy: strategy,
            rating: rating,
            date: Date(),
            notes: notes
        )
        
        ratings.append(newRating)
        objectWillChange.send()
    }
    
    func getCompletionCount(for strategy: String) -> Int {
        return ratings.filter { $0.strategy == strategy }.count
    }
    
    func getAverageRating(for strategy: String) -> Double {
        let strategyRatings = ratings.filter { $0.strategy == strategy }
        
        if strategyRatings.isEmpty {
            return 0
        }
        
        let sum = strategyRatings.reduce(0) { $0 + $1.rating }
        return Double(sum) / Double(strategyRatings.count)
    }
    
    func getRatingHistory(for strategy: String) -> [StrategyRating] {
        return ratings
            .filter { $0.strategy == strategy }
            .sorted(by: { $0.date > $1.date })
    }
    
    func getMostEffectiveStrategies() -> [(strategy: String, rating: Double)] {
        // Get strategies with at least one rating
        let strategiesWithRatings = Set(ratings.map { $0.strategy })
        
        // Calculate average rating for each strategy
        let averageRatings = strategiesWithRatings.map { strategy in
            (strategy: strategy, rating: getAverageRating(for: strategy))
        }
        
        // Sort by rating (highest first) and return top results
        return averageRatings.sorted { $0.rating > $1.rating }
    }
    
    private func loadSampleData() {
        // Add some sample ratings for demo
        let sampleRatings: [(strategy: String, rating: Int, daysAgo: Int)] = [
            ("5-4-3-2-1 Grounding Technique", 4, 12),
            ("5-4-3-2-1 Grounding Technique", 5, 6),
            ("5-4-3-2-1 Grounding Technique", 4, 2),
            ("Mindful Self-Compassion Break", 3, 8),
            ("Mindful Self-Compassion Break", 4, 4),
            ("Release Tension Walk", 5, 7),
            ("Release Tension Walk", 5, 3),
            ("Release Tension Walk", 4, 1),
            ("Values Reconnection", 3, 5)
        ]
        
        let calendar = Calendar.current
        for (strategy, rating, daysAgo) in sampleRatings {
            if let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) {
                ratings.append(StrategyRating(
                    strategy: strategy,
                    rating: rating,
                    date: date,
                    notes: nil
                ))
            }
        }
    }
}

// Extension for StrategyIntensity to classify strategies
extension LocalCopingStrategyDetail {
    enum StrategyIntensity {
        case quick, moderate, intensive
        
        var color: Color {
            switch self {
            case .quick: return Color.themeInit(hex: "41C0C0")  // Teal
            case .moderate: return Color.themeInit(hex: "5F95E8")  // Blue
            case .intensive: return Color.themeInit(hex: "8A6FE8")  // Purple
            }
        }
    }
    
    var intensity: StrategyIntensity {
        // Determine intensity based on timeToComplete string
        let time = timeToComplete.lowercased()
        if time.contains("minute") {
            let minutes = time.components(separatedBy: CharacterSet.decimalDigits.inverted)
                .joined()
            if let minutes = Int(minutes), minutes <= 5 {
                return .quick
            } else if let minutes = Int(minutes), minutes <= 15 {
                return .moderate
            }
        }
        
        if time.contains("3-5") || time.contains("5 min") || time.contains("2-3") {
            return .quick
        } else if time.contains("10-15") || time.contains("5-10") {
            return .moderate
        }
        
        return .intensive
    }
}

// MARK: - Enhanced Coping Strategies Library View
struct EnhancedCopingStrategiesLibraryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var strategiesLibrary = LocalCopingStrategiesLibrary.shared
    @StateObject private var strategyStore = LocalStrategyEffectivenessStore.shared
    
    @State private var searchText = ""
    @State private var selectedCategory: LocalCopingStrategyCategory?
    @State private var selectedStrategy: LocalCopingStrategyDetail?
    @State private var showingStrategyDetail = false
    @State private var showingFilterOptions = false
    @State private var intensityFilter: LocalCopingStrategyDetail.StrategyIntensity?
    @State private var showingAllStrategies = false
    @State private var allStrategiesTitle = ""
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                AppColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Main content
                    ScrollView {
                        VStack(spacing: AppLayout.spacing) {
                            // Strategy categories
                            categoriesView
                            
                            // Quick relief section
                            strategySection(
                                title: "Quick Relief",
                                description: "Strategies that take 5 minutes or less",
                                strategies: quickStrategies,
                                color: LocalCopingStrategyDetail.StrategyIntensity.quick.color
                            )
                            
                            // Moderate strategies section
                            strategySection(
                                title: "Moderate Practice",
                                description: "Strategies that take 5-15 minutes",
                                strategies: moderateStrategies,
                                color: LocalCopingStrategyDetail.StrategyIntensity.moderate.color
                            )
                            
                            // Intensive strategies section
                            strategySection(
                                title: "In-Depth Process",
                                description: "Strategies that take more than 15 minutes",
                                strategies: intensiveStrategies,
                                color: LocalCopingStrategyDetail.StrategyIntensity.intensive.color
                            )
                            
                            // Most effective section
                            mostEffectiveSection
                            
                            // Spacer for bottom padding
                            Spacer(minLength: 50)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .sheet(item: $selectedStrategy) { strategy in
                EnhancedStrategyDetailView(strategy: strategy, onClose: {
                    selectedStrategy = nil
                })
            }
            .sheet(isPresented: $showingAllStrategies) {
                StrategyListView(
                    title: allStrategiesTitle,
                    strategies: filteredStrategiesByIntensity(for: intensityFilter),
                    onStrategySelected: { strategy in
                        selectedStrategy = strategy
                        showingAllStrategies = false
                    }
                )
            }
            .navigationBarHidden(true)
            .onAppear {
                // No need to explicitly load strategies - the shared instance
                // should already have strategies loaded via its initializer
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Coping Strategies")
                    .font(AppTextStyles.h1)
                    .foregroundColor(AppColors.textDark)
                
                Spacer()
                
                Button(action: {
                    showingFilterOptions.toggle()
                }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.textDark)
                }
                .padding(8)
                .background(AppColors.cardBackground)
                .cornerRadius(8)
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppColors.textLight)
                
                TextField("Search strategies...", text: $searchText)
                    .font(AppTextStyles.body2)
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(AppLayout.cornerRadius)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Categories View
    private var categoriesView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All categories button
                categoryButton(nil, title: "All")
                
                // Individual category buttons
                ForEach(LocalCopingStrategyCategory.allCases) { category in
                    categoryButton(category)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
        }
    }
    
    // MARK: - Most Effective Section
    private var mostEffectiveSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Most Effective For You")
                .font(AppTextStyles.h3)
                .foregroundColor(AppColors.textDark)
            
            let effectiveStrategies = strategyStore.getMostEffectiveStrategies()
            
            if effectiveStrategies.isEmpty {
                emptyEffectiveStrategiesView
            } else {
                ForEach(effectiveStrategies.prefix(3), id: \.strategy) { item in
                    if let strategy = strategiesLibrary.strategies.first(where: { $0.title == item.strategy }) {
                        effectiveStrategyRow(strategy: strategy, rating: item.rating)
                    }
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    private var emptyEffectiveStrategiesView: some View {
        VStack(spacing: 12) {
            Image(systemName: "star")
                .font(.system(size: 36))
                .foregroundColor(AppColors.textLight)
            
            Text("Try strategies and rate them to see which work best for you")
                .font(AppTextStyles.body2)
                .foregroundColor(AppColors.textMedium)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    // MARK: - Helper Views
    private func categoryButton(_ category: LocalCopingStrategyCategory?, title: String? = nil) -> some View {
        let isSelected = selectedCategory == category
        let buttonTitle = title ?? category?.displayName ?? "All"
        let iconName = category?.iconName ?? "square.grid.2x2"
        
        return Button(action: {
            withAnimation {
                selectedCategory = category
            }
        }) {
            HStack {
                Image(systemName: iconName)
                    .font(.system(size: 14))
                Text(buttonTitle)
                    .font(AppTextStyles.body2)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? AppColors.primary : AppColors.cardBackground)
            .foregroundColor(isSelected ? .white : AppColors.textDark)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
        }
    }
    
    private func strategySection(title: String, description: String, strategies: [LocalCopingStrategyDetail], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppTextStyles.h3)
                        .foregroundColor(AppColors.textDark)
                    
                    Text(description)
                        .font(AppTextStyles.body3)
                        .foregroundColor(AppColors.textMedium)
                }
                
                Spacer()
                
                Button(action: {
                    // Show all strategies in this category
                    if title == "Quick Relief" {
                        intensityFilter = .quick
                    } else if title == "Moderate Practice" {
                        intensityFilter = .moderate
                    } else if title == "In-Depth Process" {
                        intensityFilter = .intensive
                    }
                    allStrategiesTitle = title
                    showingAllStrategies = true
                }) {
                    Text("View All")
                        .font(AppTextStyles.body3)
                        .foregroundColor(AppColors.primary)
                }
            }
            
            // Strategy cards
            if strategies.isEmpty {
                emptyStrategiesView
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(strategies) { strategy in
                            strategyCard(strategy, color: color)
                                .onTapGesture {
                                    selectedStrategy = strategy
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    private var emptyStrategiesView: some View {
        Text("No matching strategies found")
            .font(AppTextStyles.body2)
            .foregroundColor(AppColors.textMedium)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
    }
    
    private func strategyCard(_ strategy: LocalCopingStrategyDetail, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category and time
            HStack {
                Text(strategy.category.displayName)
                    .font(AppTextStyles.body3)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(strategy.category.color)
                    .cornerRadius(8)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                    Text(strategy.timeToComplete)
                        .font(AppTextStyles.body3)
                }
                .foregroundColor(AppColors.textMedium)
            }
            
            // Title
            Text(strategy.title)
                .font(AppTextStyles.h4)
                .foregroundColor(AppColors.textDark)
                .lineLimit(2)
                .frame(height: 48, alignment: .top)
            
            // Description
            Text(strategy.description)
                .font(AppTextStyles.body3)
                .foregroundColor(AppColors.textMedium)
                .lineLimit(3)
                .frame(height: 54, alignment: .top)
            
            // Usage stats
            HStack {
                if strategyStore.getCompletionCount(for: strategy.title) > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 12))
                        Text("Used \(strategyStore.getCompletionCount(for: strategy.title)) times")
                            .font(AppTextStyles.body3)
                    }
                    .foregroundColor(AppColors.textLight)
                    
                    if strategyStore.getAverageRating(for: strategy.title) > 0 {
                        Spacer()
                        
                        HStack(spacing: 2) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= Int(strategyStore.getAverageRating(for: strategy.title).rounded()) ? "star.fill" : "star")
                                    .font(.system(size: 10))
                                    .foregroundColor(star <= Int(strategyStore.getAverageRating(for: strategy.title).rounded()) ? .yellow : AppColors.textLight)
                            }
                        }
                    }
                } else {
                    Text("Try this strategy")
                        .font(AppTextStyles.body3)
                        .foregroundColor(AppColors.primary)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
        .frame(width: 250)
    }
    
    private func effectiveStrategyRow(strategy: LocalCopingStrategyDetail, rating: Double) -> some View {
        HStack(spacing: 12) {
            // Strategy icon
            Circle()
                .fill(strategy.category.color.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: strategy.category.iconName)
                        .font(.system(size: 18))
                        .foregroundColor(strategy.category.color)
                )
            
            // Strategy info
            VStack(alignment: .leading, spacing: 4) {
                Text(strategy.title)
                    .font(AppTextStyles.body1)
                    .foregroundColor(AppColors.textDark)
                
                Text("\(strategyStore.getCompletionCount(for: strategy.title)) uses • \(strategy.timeToComplete)")
                    .font(AppTextStyles.body3)
                    .foregroundColor(AppColors.textMedium)
            }
            
            Spacer()
            
            // Rating stars
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= Int(rating.rounded()) ? "star.fill" : "star")
                        .font(.system(size: 12))
                        .foregroundColor(star <= Int(rating.rounded()) ? .yellow : AppColors.textLight)
                }
            }
        }
        .padding(12)
        .background(AppColors.cardBackground.opacity(0.5))
        .cornerRadius(12)
        .onTapGesture {
            selectedStrategy = strategy
        }
    }
    
    // MARK: - Strategy Filtering
    private var filteredStrategies: [LocalCopingStrategyDetail] {
        var strategies = strategiesLibrary.strategies
        
        // Apply category filter
        if let category = selectedCategory {
            strategies = strategies.filter { $0.category == category }
        }
        
        // Apply intensity filter
        if let intensity = intensityFilter {
            strategies = strategies.filter { $0.intensity == intensity }
        }
        
        // Apply search text filter
        if !searchText.isEmpty {
            strategies = strategies.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.category.displayName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return strategies
    }
    
    private var quickStrategies: [LocalCopingStrategyDetail] {
        filteredStrategies.filter { $0.intensity == .quick }
    }
    
    private var moderateStrategies: [LocalCopingStrategyDetail] {
        filteredStrategies.filter { $0.intensity == .moderate }
    }
    
    private var intensiveStrategies: [LocalCopingStrategyDetail] {
        filteredStrategies.filter { $0.intensity == .intensive }
    }
    
    // Helper method to get strategies filtered by intensity
    private func filteredStrategiesByIntensity(for intensity: LocalCopingStrategyDetail.StrategyIntensity?) -> [LocalCopingStrategyDetail] {
        guard let intensity = intensity else { return [] }
        
        var strategies = strategiesLibrary.strategies
        
        // Apply category filter if selected
        if let category = selectedCategory {
            strategies = strategies.filter { $0.category == category }
        }
        
        // Filter by intensity
        strategies = strategies.filter { $0.intensity == intensity }
        
        return strategies
    }
}

// MARK: - Enhanced Strategy Detail View
struct EnhancedStrategyDetailView: View {
    let strategy: LocalCopingStrategyDetail
    let onClose: () -> Void
    
    @StateObject private var strategyStore = LocalStrategyEffectivenessStore.shared
    @State private var selectedStep = 0
    @State private var showingCompletionSheet = false
    @State private var rating = 0
    @State private var completionNotes = ""
    @State private var timer: Timer?
    @State private var secondsElapsed = 0
    @State private var isTimerRunning = false
    @State private var guidedModeActive = false
    @State private var showingMoodCheckIn = false
    @State private var moodBefore: String = ""
    @State private var moodIntensityBefore: Double = 3
    @State private var showingProgressIndicator = false
    @State private var stepProgress: CGFloat = 0
    
    // Timer progress variables
    @State private var estimatedSeconds: Int = 0
    @State private var timerProgress: CGFloat = 0
    
    // Breathing exercise variables
    @State private var showingBreathingExercise = false
    @State private var breathingPhase: BreathingPhase = .inhale
    @State private var breathingCycleCount = 0
    @State private var breathingPattern: BreathingPattern = .fourSevenEight
    @State private var breathingScale: CGFloat = 1.0
    @State private var breathingOpacity: Double = 0.8
    
    // Grounding exercise variables
    @State private var groundingItems: [GroundingItem] = []
    @State private var showingGroundingExercise = false
    @State private var groundingStep = 0
    
    // Journaling variables
    @State private var journalText = ""
    @State private var showingJournalExercise = false
    @State private var journalPrompts: [String] = []
    @State private var currentJournalPrompt = 0
    
    // Strategy type detection
    var strategyType: StrategyType {
        let title = strategy.title.lowercased()
        let desc = strategy.description.lowercased()
        let steps = strategy.steps.joined().lowercased()
        
        if title.contains("breath") || desc.contains("breath") || 
           steps.contains("inhale") || steps.contains("exhale") {
            return .breathing
        } else if title.contains("ground") || desc.contains("ground") || 
                title.contains("5-4-3-2-1") || desc.contains("5-4-3-2-1") ||
                steps.contains("see") || steps.contains("touch") || steps.contains("hear") {
            return .grounding
        } else if title.contains("journal") || desc.contains("journal") || 
                 title.contains("writ") || desc.contains("writ") || 
                 steps.contains("write") || steps.contains("journal") {
            return .journaling
        } else if title.contains("meditat") || desc.contains("meditat") {
            return .meditation
        } else {
            return .standard
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header section with title, category, time
                    headerSection
                    
                    // Interactive exercise component based on strategy type
                    interactiveExerciseSection
                    
                    // Description section
                    descriptionSection
                    
                    // Guided mode toggle (for standard strategies)
                    if strategyType == .standard {
                        guidedModeToggle
                    }
                    
                    // Steps section
                    stepsSection
                    
                    // Timer section if applicable and not an active specialized exercise
                    if shouldShowTimer {
                        timerSection
                    }
                    
                    // Usage section
                    usageSection
                    
                    // Button to complete
                    Button(action: {
                        HapticFeedback.medium()
                        completeStrategy()
                    }) {
                        Text("Complete & Rate")
                            .font(AppTextStyles.h4)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.primary)
                            .cornerRadius(AppLayout.cornerRadius)
                    }
                    .padding(.vertical)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(strategy.title)
                        .font(AppTextStyles.h3)
                        .foregroundColor(AppColors.textDark)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .foregroundColor(AppColors.textDark)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Share the strategy
                        HapticFeedback.light()
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(AppColors.textDark)
                    }
                }
            }
            .sheet(isPresented: $showingCompletionSheet) {
                completionRatingView
            }
            .sheet(isPresented: $showingMoodCheckIn) {
                moodCheckInView
            }
            .onAppear {
                setupStrategyInteractivity()
                estimateTimerDuration()
                // Show mood check-in when strategy detail is first shown
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showingMoodCheckIn = true
                }
            }
        }
        .onDisappear {
            stopTimer()
            stopBreathingExercise()
        }
    }
    
    // Helper to determine if timer should be shown
    private var shouldShowTimer: Bool {
        if strategyType == .breathing && showingBreathingExercise { return false }
        if strategyType == .grounding && showingGroundingExercise { return false }
        if strategyType == .journaling && showingJournalExercise { return false }
        if strategyType == .meditation { return true } // Always show timer for meditation
        return strategy.timeToComplete.contains("minute")
    }
    
    // MARK: - Setup Strategy Interactivity
    private func setupStrategyInteractivity() {
        switch strategyType {
        case .grounding:
            setupGroundingExercise()
        case .journaling:
            setupJournalingExercise()
        default:
            break
        }
    }
    
    // MARK: - Interactive Exercise Section
    private var interactiveExerciseSection: some View {
        Group {
            switch strategyType {
            case .breathing:
                breathingExerciseSection
            case .grounding:
                groundingExerciseSection
            case .journaling:
                journalingExerciseSection
            case .meditation:
                meditationExerciseSection
            case .standard:
                EmptyView()
            }
        }
    }
    
    // MARK: - Grounding Exercise
    private func setupGroundingExercise() {
        // Parse strategy steps to extract grounding prompts
        if strategy.title.contains("5-4-3-2-1") || strategy.description.contains("5-4-3-2-1") {
            // 5-4-3-2-1 Grounding Technique
            groundingItems = [
                GroundingItem(sense: "See", count: 5, prompt: "Find 5 things you can see around you"),
                GroundingItem(sense: "Touch", count: 4, prompt: "Find 4 things you can touch or feel"),
                GroundingItem(sense: "Hear", count: 3, prompt: "Notice 3 things you can hear"),
                GroundingItem(sense: "Smell", count: 2, prompt: "Identify 2 things you can smell"),
                GroundingItem(sense: "Taste", count: 1, prompt: "Acknowledge 1 thing you can taste")
            ]
        } else {
            // Generic grounding - extract from steps
            var items: [GroundingItem] = []
            for (index, step) in strategy.steps.enumerated() {
                if step.lowercased().contains("see") || step.lowercased().contains("look") {
                    items.append(GroundingItem(sense: "See", count: 1, prompt: step))
                } else if step.lowercased().contains("touch") || step.lowercased().contains("feel") {
                    items.append(GroundingItem(sense: "Touch", count: 1, prompt: step))
                } else if step.lowercased().contains("hear") || step.lowercased().contains("listen") {
                    items.append(GroundingItem(sense: "Hear", count: 1, prompt: step))
                } else if step.lowercased().contains("smell") {
                    items.append(GroundingItem(sense: "Smell", count: 1, prompt: step))
                } else if step.lowercased().contains("taste") {
                    items.append(GroundingItem(sense: "Taste", count: 1, prompt: step))
                } else if index < 5 {
                    // For other steps, categorize based on position
                    let senses = ["See", "Touch", "Hear", "Smell", "Taste"]
                    if index < senses.count {
                        items.append(GroundingItem(sense: senses[index], count: 1, prompt: step))
                    }
                }
            }
            if !items.isEmpty {
                groundingItems = items
            }
        }
    }
    
    private var groundingExerciseSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Grounding Exercise")
                .font(AppTextStyles.h4)
                .foregroundColor(AppColors.textDark)
            
            if !showingGroundingExercise {
                // Preview/start view
                VStack(spacing: 16) {
                    Text("This is a grounding technique to help you connect with your surroundings and reduce anxiety or stress.")
                        .font(AppTextStyles.body2)
                        .foregroundColor(AppColors.textMedium)
                    
                    // Exercise preview
                    HStack(spacing: 12) {
                        ForEach(0..<min(5, groundingItems.count), id: \.self) { index in
                            let item = groundingItems[index]
                            Circle()
                                .fill(getGroundingSenseColor(sense: item.sense).opacity(0.2))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text("\(item.count)")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(getGroundingSenseColor(sense: item.sense))
                                )
                        }
                    }
                    .padding(.vertical, 8)
                    
                    // Start button
                    Button(action: {
                        HapticFeedback.medium()
                        startGroundingExercise()
                    }) {
                        HStack {
                            Image(systemName: "hand.tap")
                                .font(.system(size: 18))
                            Text("Start Grounding Exercise")
                                .font(AppTextStyles.h4)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(strategy.category.color)
                        .cornerRadius(AppLayout.cornerRadius)
                    }
                }
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(AppLayout.cornerRadius)
            } else {
                // Active grounding exercise
                VStack(spacing: 16) {
                    if groundingStep < groundingItems.count {
                        let item = groundingItems[groundingStep]
                        
                        // Sense icon and title
                        HStack {
                            Circle()
                                .fill(getGroundingSenseColor(sense: item.sense).opacity(0.2))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Image(systemName: getGroundingSenseIcon(sense: item.sense))
                                        .font(.system(size: 24))
                                        .foregroundColor(getGroundingSenseColor(sense: item.sense))
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.sense)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(getGroundingSenseColor(sense: item.sense))
                                
                                if item.count > 1 {
                                    Text("Find \(item.count) things")
                                        .font(AppTextStyles.body2)
                                        .foregroundColor(AppColors.textMedium)
                                }
                            }
                            .padding(.leading, 8)
                            
                            Spacer()
                            
                            Text("\(groundingStep + 1)/\(groundingItems.count)")
                                .font(AppTextStyles.body3)
                                .foregroundColor(AppColors.textMedium)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(AppColors.cardBackground)
                                .cornerRadius(12)
                        }
                        .padding(.vertical, 8)
                        
                        // Prompt
                        Text(item.prompt)
                            .font(AppTextStyles.h4)
                            .foregroundColor(AppColors.textDark)
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(getGroundingSenseColor(sense: item.sense).opacity(0.1))
                            .cornerRadius(12)
                        
                        // Progress items for multi-count senses
                        if item.count > 1 {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(1...item.count, id: \.self) { number in
                                        Text("\(number)")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.white)
                                            .frame(width: 36, height: 36)
                                            .background(getGroundingSenseColor(sense: item.sense))
                                            .cornerRadius(18)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.vertical, 8)
                        }
                        
                        Spacer(minLength: 20)
                        
                        // Navigation buttons
                        HStack {
                            // Back button (if not first step)
                            if groundingStep > 0 {
                                Button(action: {
                                    HapticFeedback.light()
                                    withAnimation {
                                        groundingStep -= 1
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                        Text("Back")
                                    }
                                    .foregroundColor(AppColors.textMedium)
                                    .padding()
                                    .background(AppColors.cardBackground)
                                    .cornerRadius(AppLayout.cornerRadius)
                                }
                            }
                            
                            Spacer()
                            
                            // Next button
                            Button(action: {
                                HapticFeedback.medium()
                                withAnimation {
                                    if groundingStep < groundingItems.count - 1 {
                                        groundingStep += 1
                                    } else {
                                        completeGroundingExercise()
                                    }
                                }
                            }) {
                                HStack {
                                    Text(groundingStep < groundingItems.count - 1 ? "Next" : "Complete")
                                    Image(systemName: groundingStep < groundingItems.count - 1 ? "chevron.right" : "checkmark")
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(strategy.category.color)
                                .cornerRadius(AppLayout.cornerRadius)
                            }
                        }
                    } else {
                        // Completion view
                        VStack(spacing: 24) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(strategy.category.color)
                            
                            Text("Exercise Complete")
                                .font(AppTextStyles.h3)
                                .foregroundColor(AppColors.textDark)
                            
                            Text("Take a moment to notice how you feel now.")
                                .font(AppTextStyles.body2)
                                .foregroundColor(AppColors.textMedium)
                                .multilineTextAlignment(.center)
                            
                            Button(action: {
                                HapticFeedback.medium()
                                completeStrategy()
                            }) {
                                Text("Rate & Complete")
                                    .font(AppTextStyles.h4)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(strategy.category.color)
                                    .cornerRadius(AppLayout.cornerRadius)
                            }
                            
                            Button(action: {
                                HapticFeedback.light()
                                resetGroundingExercise()
                            }) {
                                Text("Start Over")
                                    .font(AppTextStyles.body2)
                                    .foregroundColor(AppColors.textMedium)
                            }
                        }
                        .padding()
                    }
                }
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(AppLayout.cornerRadius)
            }
        }
        .padding(.top, 8)
    }
    
    private func startGroundingExercise() {
        withAnimation {
            showingGroundingExercise = true
            groundingStep = 0
        }
    }
    
    private func completeGroundingExercise() {
        // Exercise completed, show completion step
        withAnimation {
            groundingStep = groundingItems.count
        }
        HapticFeedback.success()
    }
    
    private func resetGroundingExercise() {
        withAnimation {
            groundingStep = 0
        }
    }
    
    private func getGroundingSenseColor(sense: String) -> Color {
        switch sense.lowercased() {
        case "see": return Color.blue
        case "touch": return Color.green
        case "hear": return Color.purple
        case "smell": return Color.orange
        case "taste": return Color.red
        default: return AppColors.primary
        }
    }
    
    private func getGroundingSenseIcon(sense: String) -> String {
        switch sense.lowercased() {
        case "see": return "eye"
        case "touch": return "hand.raised"
        case "hear": return "ear"
        case "smell": return "nose"
        case "taste": return "mouth"
        default: return "questionmark.circle"
        }
    }
    
    // MARK: - Journaling Exercise
    private func setupJournalingExercise() {
        // Extract prompts from strategy steps
        journalPrompts = strategy.steps.filter { !$0.isEmpty }
        
        if journalPrompts.isEmpty {
            // If no steps available, use generic prompts
            journalPrompts = [
                "What are you feeling right now? Describe any physical sensations or emotions.",
                "What thoughts are going through your mind?",
                "What triggered these feelings or thoughts?",
                "How can you respond to this situation with self-compassion?",
                "What's one small step you can take to move forward?"
            ]
        }
    }
    
    private var journalingExerciseSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Journaling Exercise")
                .font(AppTextStyles.h4)
                .foregroundColor(AppColors.textDark)
            
            if !showingJournalExercise {
                // Preview/start view
                VStack(spacing: 16) {
                    Text("Writing about your thoughts and feelings can help process emotions and gain clarity.")
                        .font(AppTextStyles.body2)
                        .foregroundColor(AppColors.textMedium)
                    
                    // Prompt preview
                    VStack(alignment: .leading, spacing: 8) {
                        Text("You'll reflect on:")
                            .font(AppTextStyles.body3)
                            .foregroundColor(AppColors.textDark)
                        
                        ForEach(journalPrompts.prefix(min(3, journalPrompts.count)), id: \.self) { prompt in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(AppColors.textMedium)
                                    .padding(.top, 6)
                                
                                Text(prompt)
                                    .font(AppTextStyles.body3)
                                    .foregroundColor(AppColors.textMedium)
                                    .lineLimit(1)
                            }
                        }
                        
                        if journalPrompts.count > 3 {
                            Text("+ \(journalPrompts.count - 3) more prompts")
                                .font(AppTextStyles.body3)
                                .foregroundColor(AppColors.textLight)
                                .padding(.leading, 16)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(strategy.category.color.opacity(0.1))
                    .cornerRadius(8)
                    
                    // Start button
                    Button(action: {
                        HapticFeedback.medium()
                        startJournalingExercise()
                    }) {
                        HStack {
                            Image(systemName: "pencil.and.outline")
                                .font(.system(size: 18))
                            Text("Start Journaling Exercise")
                                .font(AppTextStyles.h4)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(strategy.category.color)
                        .cornerRadius(AppLayout.cornerRadius)
                    }
                }
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(AppLayout.cornerRadius)
            } else {
                // Active journaling exercise
                VStack(spacing: 16) {
                    // Progress indicator
                    HStack {
                        Text("Prompt \(currentJournalPrompt + 1) of \(journalPrompts.count)")
                            .font(AppTextStyles.body3)
                            .foregroundColor(AppColors.textMedium)
                        
                        Spacer()
                        
                        Button(action: {
                            HapticFeedback.light()
                            saveJournalEntry()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.down.doc.fill")
                                Text("Save")
                            }
                            .font(AppTextStyles.body3)
                            .foregroundColor(strategy.category.color)
                        }
                    }
                    .padding(.horizontal, 4)
                    
                    // Prompt
                    if currentJournalPrompt < journalPrompts.count {
                        Text(journalPrompts[currentJournalPrompt])
                            .font(AppTextStyles.h4)
                            .foregroundColor(AppColors.textDark)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppColors.cardBackground.opacity(0.5))
                            .cornerRadius(12)
                    }
                    
                    // Journal text area
                    TextEditor(text: $journalText)
                        .font(AppTextStyles.body2)
                        .padding()
                        .frame(minHeight: 200)
                        .background(AppColors.cardBackground.opacity(0.5))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.textLight.opacity(0.3), lineWidth: 1)
                        )
                    
                    // Navigation buttons
                    HStack {
                        // Back button (if not first prompt)
                        if currentJournalPrompt > 0 {
                            Button(action: {
                                HapticFeedback.light()
                                moveToJournalPrompt(currentJournalPrompt - 1)
                            }) {
                                HStack {
                                    Image(systemName: "chevron.left")
                                    Text("Previous")
                                }
                                .foregroundColor(AppColors.textMedium)
                                .padding()
                                .background(AppColors.cardBackground)
                                .cornerRadius(AppLayout.cornerRadius)
                            }
                        }
                        
                        Spacer()
                        
                        // Next button
                        Button(action: {
                            HapticFeedback.medium()
                            if currentJournalPrompt < journalPrompts.count - 1 {
                                moveToJournalPrompt(currentJournalPrompt + 1)
                            } else {
                                completeJournalingExercise()
                            }
                        }) {
                            HStack {
                                Text(currentJournalPrompt < journalPrompts.count - 1 ? "Next" : "Complete")
                                Image(systemName: currentJournalPrompt < journalPrompts.count - 1 ? "chevron.right" : "checkmark")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(strategy.category.color)
                            .cornerRadius(AppLayout.cornerRadius)
                        }
                        .disabled(journalText.isEmpty)
                        .opacity(journalText.isEmpty ? 0.6 : 1)
                    }
                }
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(AppLayout.cornerRadius)
            }
        }
        .padding(.top, 8)
    }
    
    private func startJournalingExercise() {
        withAnimation {
            showingJournalExercise = true
            currentJournalPrompt = 0
            journalText = ""
        }
    }
    
    private func moveToJournalPrompt(_ promptIndex: Int) {
        if promptIndex >= 0 && promptIndex < journalPrompts.count {
            // Save current entry
            saveJournalEntry()
            
            // Move to new prompt
            withAnimation {
                currentJournalPrompt = promptIndex
                journalText = ""
            }
        }
    }
    
    private func saveJournalEntry() {
        // In a real app, this would save to a journal database
        // For now, just provide feedback
        if !journalText.isEmpty {
            HapticFeedback.success()
        }
    }
    
    private func completeJournalingExercise() {
        saveJournalEntry()
        HapticFeedback.success()
        completeStrategy()
    }
    
    // MARK: - Meditation Exercise
    private var meditationExerciseSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Meditation")
                .font(AppTextStyles.h4)
                .foregroundColor(AppColors.textDark)
            
            // Meditation timer setup
            VStack(spacing: 16) {
                // Ambience options
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ambience")
                        .font(AppTextStyles.body2)
                        .foregroundColor(AppColors.textDark)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(["None", "Rain", "Ocean", "Forest", "White Noise"], id: \.self) { sound in
                                Button(action: {
                                    HapticFeedback.light()
                                    // Would play the selected sound
                                }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: getSoundIcon(sound))
                                            .font(.system(size: 20))
                                            .foregroundColor(sound == "None" ? AppColors.textMedium : strategy.category.color)
                                        
                                        Text(sound)
                                            .font(AppTextStyles.body3)
                                    }
                                    .frame(width: 70, height: 70)
                                    .background(AppColors.cardBackground.opacity(0.5))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                
                // Interval bell options
                VStack(alignment: .leading, spacing: 8) {
                    Text("Interval Bell")
                        .font(AppTextStyles.body2)
                        .foregroundColor(AppColors.textDark)
                    
                    HStack {
                        ForEach(["None", "1 min", "3 min", "5 min"], id: \.self) { interval in
                            Button(action: {
                                HapticFeedback.light()
                                // Would set the interval bell
                            }) {
                                Text(interval)
                                    .font(AppTextStyles.body3)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(AppColors.cardBackground.opacity(0.5))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                
                // Start meditation button
                Button(action: {
                    HapticFeedback.medium()
                    startTimer()
                }) {
                    HStack {
                        Image(systemName: "moon.stars")
                            .font(.system(size: 18))
                        Text("Begin Meditation")
                            .font(AppTextStyles.h4)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(strategy.category.color)
                    .cornerRadius(AppLayout.cornerRadius)
                }
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(AppLayout.cornerRadius)
        }
        .padding(.top, 8)
    }
    
    private func getSoundIcon(_ sound: String) -> String {
        switch sound {
        case "Rain": return "cloud.rain"
        case "Ocean": return "water.waves"
        case "Forest": return "leaf"
        case "White Noise": return "waveform"
        default: return "speaker.slash"
        }
    }
    
    // MARK: - Helper Methods
    struct GroundingItem {
        let sense: String
        let count: Int
        let prompt: String
    }
    
    enum StrategyType {
        case breathing
        case grounding
        case journaling
        case meditation
        case standard
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Category pill
                Text(strategy.category.displayName)
                    .font(AppTextStyles.body3)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(strategy.category.color)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                
                Spacer()
                
                // Time info
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 14))
                    Text(strategy.timeToComplete)
                        .font(AppTextStyles.body3)
                }
                .foregroundColor(AppColors.textMedium)
            }
            
            // Usage info if used before
            if strategyStore.getCompletionCount(for: strategy.title) > 0 {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.primary)
                        .font(.system(size: 14))
                    
                    Text("You've used this \(strategyStore.getCompletionCount(for: strategy.title)) \(strategyStore.getCompletionCount(for: strategy.title) == 1 ? "time" : "times")")
                        .font(AppTextStyles.body3)
                        .foregroundColor(AppColors.textMedium)
                    
                    if strategyStore.getAverageRating(for: strategy.title) > 0 {
                        Spacer()
                        
                        // Rating
                        HStack(spacing: 2) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= Int(strategyStore.getAverageRating(for: strategy.title).rounded()) ? "star.fill" : "star")
                                    .font(.system(size: 12))
                                    .foregroundColor(star <= Int(strategyStore.getAverageRating(for: strategy.title).rounded()) ? .yellow : AppColors.textLight)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Description Section
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About This Strategy")
                .font(AppTextStyles.h4)
                .foregroundColor(AppColors.textDark)
            
            Text(strategy.description)
                .font(AppTextStyles.body2)
                .foregroundColor(AppColors.textMedium)
                .fixedSize(horizontal: false, vertical: true)
            
            // Target moods
            if !strategy.tags.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Helpful for:")
                        .font(AppTextStyles.body3)
                        .foregroundColor(AppColors.textDark)
                    
                    HStack {
                        ForEach(strategy.tags.prefix(4), id: \.self) { tag in
                            Text(tag.capitalized)
                                .font(AppTextStyles.body3)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppColors.primary.opacity(0.1))
                                .foregroundColor(AppColors.primary)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    // MARK: - Guided Mode Toggle
    private var guidedModeToggle: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Practice Mode")
                .font(AppTextStyles.h4)
                .foregroundColor(AppColors.textDark)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(guidedModeActive ? "Guided Mode Active" : "Self-Guided")
                        .font(AppTextStyles.body2)
                        .foregroundColor(AppColors.textDark)
                    
                    Text(guidedModeActive ? 
                        "We'll guide you through each step with timers" : 
                        "Go through the steps at your own pace")
                        .font(AppTextStyles.body3)
                        .foregroundColor(AppColors.textMedium)
                }
                
                Spacer()
                
                Toggle("", isOn: $guidedModeActive)
                    .labelsHidden()
                    .onChange(of: guidedModeActive) { newValue in
                        HapticFeedback.selection()
                        if newValue {
                            selectedStep = 0
                            resetTimer()
                            startStepTimer()
                        } else {
                            stopTimer()
                        }
                    }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    // MARK: - Steps Section
    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Steps to Follow")
                    .font(AppTextStyles.h4)
                    .foregroundColor(AppColors.textDark)
                
                Spacer()
                
                if guidedModeActive && strategy.steps.count > 0 {
                    Text("Step \(selectedStep + 1) of \(strategy.steps.count)")
                        .font(AppTextStyles.body3)
                        .foregroundColor(AppColors.textMedium)
                }
            }
            
            if guidedModeActive && showingProgressIndicator {
                ProgressView(value: stepProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: strategy.category.color))
                    .animation(.linear, value: stepProgress)
            }
            
            ForEach(0..<strategy.steps.count, id: \.self) { index in
                if !guidedModeActive || index <= selectedStep {
                    stepView(step: strategy.steps[index], index: index)
                        .transition(.opacity)
                }
            }
            
            if guidedModeActive && selectedStep < strategy.steps.count - 1 {
                Button(action: {
                    advanceToNextStep()
                }) {
                    Text("Next Step")
                        .font(AppTextStyles.body2)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(strategy.category.color)
                        .cornerRadius(AppLayout.cornerRadius)
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .animation(.easeInOut, value: selectedStep)
        .animation(.easeInOut, value: guidedModeActive)
    }
    
    private func stepView(step: String, index: Int) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Step number
            ZStack {
                Circle()
                    .fill(selectedStep == index ? strategy.category.color : AppColors.textLight.opacity(0.2))
                    .frame(width: 28, height: 28)
                
                if selectedStep > index {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("\(index + 1)")
                        .font(AppTextStyles.body3)
                        .foregroundColor(selectedStep == index ? .white : AppColors.textLight)
                }
            }
            
            // Step text
            Text(step)
                .font(AppTextStyles.body2)
                .foregroundColor(AppColors.textDark)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 4)
        }
        .padding(8)
        .background(selectedStep == index ? strategy.category.color.opacity(0.1) : Color.clear)
        .cornerRadius(8)
        .onTapGesture {
            HapticFeedback.light()
            if !guidedModeActive {
                withAnimation {
                    selectedStep = index
                }
            }
        }
    }
    
    // MARK: - Timer Section
    private var timerSection: some View {
        Group {
            if strategy.timeToComplete.contains("minute") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Timer")
                        .font(AppTextStyles.h4)
                        .foregroundColor(AppColors.textDark)
                    
                    VStack(spacing: 16) {
                        // Timer progress circle
                        ZStack {
                            Circle()
                                .stroke(lineWidth: 8)
                                .opacity(0.3)
                                .foregroundColor(AppColors.textLight)
                            
                            Circle()
                                .trim(from: 0.0, to: timerProgress)
                                .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                                .foregroundColor(timerProgressColor())
                                .rotationEffect(Angle(degrees: 270.0))
                                .animation(.linear, value: timerProgress)
                            
                            VStack(spacing: 4) {
                                Text(timeString(from: secondsElapsed))
                                    .font(.system(size: 36, weight: .medium, design: .monospaced))
                                    .foregroundColor(AppColors.textDark)
                                
                                if estimatedSeconds > 0 {
                                    Text("\(Int((Double(secondsElapsed) / Double(estimatedSeconds) * 100).rounded()))%")
                                        .font(AppTextStyles.body3)
                                        .foregroundColor(AppColors.textMedium)
                                }
                            }
                        }
                        .frame(height: 160)
                        .padding(.bottom, 8)
                        
                        // Timer controls
                        HStack(spacing: 24) {
                            Button(action: {
                                HapticFeedback.medium()
                                resetTimer()
                            }) {
                                VStack {
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.system(size: 20))
                                        .foregroundColor(AppColors.textMedium)
                                    
                                    Text("Reset")
                                        .font(AppTextStyles.body3)
                                        .foregroundColor(AppColors.textMedium)
                                }
                            }
                            
                            Button(action: {
                                HapticFeedback.medium()
                                if isTimerRunning {
                                    stopTimer()
                                } else {
                                    startTimer()
                                }
                            }) {
                                VStack {
                                    Image(systemName: isTimerRunning ? "pause.fill" : "play.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(AppColors.primary)
                                    
                                    Text(isTimerRunning ? "Pause" : "Start")
                                        .font(AppTextStyles.body3)
                                        .foregroundColor(AppColors.primary)
                                }
                            }
                            
                            Button(action: {
                                HapticFeedback.medium()
                                addOneMinute()
                            }) {
                                VStack {
                                    Image(systemName: "plus.circle")
                                        .font(.system(size: 20))
                                        .foregroundColor(AppColors.textMedium)
                                    
                                    Text("+1 min")
                                        .font(AppTextStyles.body3)
                                        .foregroundColor(AppColors.textMedium)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(AppLayout.cornerRadius)
                }
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(AppLayout.cornerRadius)
            }
        }
    }
    
    // MARK: - Usage Section
    private var usageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your History")
                .font(AppTextStyles.h4)
                .foregroundColor(AppColors.textDark)
            
            if strategyStore.getCompletionCount(for: strategy.title) > 0 {
                // Usage graph or history
                VStack(alignment: .leading, spacing: 8) {
                    Text("Effectiveness Trend")
                        .font(AppTextStyles.body3)
                        .foregroundColor(AppColors.textDark)
                    
                    // Simple rating history visualization
                    HStack(spacing: 4) {
                        ForEach(strategyStore.getRatingHistory(for: strategy.title).prefix(5), id: \.date) { item in
                            VStack(spacing: 2) {
                                Text("\(item.rating)")
                                    .font(AppTextStyles.body3)
                                    .foregroundColor(AppColors.textDark)
                                
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(ratingColor(for: item.rating))
                                    .frame(width: 20, height: CGFloat(item.rating) * 6)
                                
                                Text(formatDate(item.date))
                                    .font(.system(size: 8))
                                    .foregroundColor(AppColors.textLight)
                            }
                        }
                    }
                    .frame(height: 80)
                    .padding()
                }
            } else {
                // First-time user message
                HStack {
                    Image(systemName: "star")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.textLight)
                    
                    Text("Complete this strategy to track your progress")
                        .font(AppTextStyles.body3)
                        .foregroundColor(AppColors.textMedium)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    // MARK: - Completion Rating View
    private var completionRatingView: some View {
        VStack(spacing: 24) {
            // Header
            Text("Rate this Strategy")
                .font(AppTextStyles.h3)
                .foregroundColor(AppColors.textDark)
            
            Text("How helpful was this strategy for you?")
                .font(AppTextStyles.body2)
                .foregroundColor(AppColors.textMedium)
                .multilineTextAlignment(.center)
            
            // Star rating
            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .font(.system(size: 32))
                        .foregroundColor(star <= rating ? .yellow : AppColors.textLight)
                        .onTapGesture {
                            rating = star
                            HapticFeedback.selection()
                        }
                }
            }
            .padding()
            
            // Mood after practice
            VStack(alignment: .leading, spacing: 8) {
                Text("How are you feeling now?")
                    .font(AppTextStyles.body2)
                    .foregroundColor(AppColors.textDark)
                
                HStack {
                    Text(moodBefore.isEmpty ? "Before: N/A" : "Before: \(moodBefore) (\(Int(moodIntensityBefore)))")
                        .font(AppTextStyles.body3)
                        .foregroundColor(AppColors.textMedium)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right")
                        .foregroundColor(AppColors.textLight)
                    
                    Spacer()
                    
                    // Add mood after selection here
                    Menu {
                        Button("Much better (-2)", action: { updateMoodAfter(-2) })
                        Button("Better (-1)", action: { updateMoodAfter(-1) })
                        Button("Same (0)", action: { updateMoodAfter(0) })
                        Button("Worse (+1)", action: { updateMoodAfter(1) })
                        Button("Much worse (+2)", action: { updateMoodAfter(2) })
                    } label: {
                        Text(getMoodChangeText())
                            .font(AppTextStyles.body3)
                            .foregroundColor(AppColors.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppColors.primary.opacity(0.1))
                            .cornerRadius(16)
                    }
                }
            }
            .padding(.vertical, 8)
            
            // Notes field
            VStack(alignment: .leading, spacing: 8) {
                Text("Notes (optional)")
                    .font(AppTextStyles.body2)
                    .foregroundColor(AppColors.textDark)
                
                TextField("Add any comments about your experience...", text: $completionNotes)
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(8)
            }
            
            // Save button
            Button(action: {
                HapticFeedback.success()
                saveRating()
                showingCompletionSheet = false
            }) {
                Text("Save Rating")
                    .font(AppTextStyles.h4)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary)
                    .cornerRadius(AppLayout.cornerRadius)
            }
            .disabled(rating == 0)
            .opacity(rating == 0 ? 0.6 : 1)
            
            Button(action: {
                showingCompletionSheet = false
            }) {
                Text("Cancel")
                    .font(AppTextStyles.body2)
                    .foregroundColor(AppColors.textMedium)
            }
            .padding()
        }
        .padding()
    }
    
    // MARK: - Helper Methods
    @State private var moodChangeValue: Int? = nil
    
    private func getMoodChangeText() -> String {
        guard let change = moodChangeValue else {
            return "Select mood change"
        }
        
        switch change {
        case -2: return "Much better (-2)"
        case -1: return "Better (-1)"
        case 0: return "Same (0)"
        case 1: return "Worse (+1)"
        case 2: return "Much worse (+2)"
        default: return "Select mood change"
        }
    }
    
    private func updateMoodAfter(_ change: Int) {
        moodChangeValue = change
        HapticFeedback.selection()
    }
    
    private func moodIntensityColor(intensity: Double) -> Color {
        switch Int(intensity) {
        case 1, 2:
            return Color.green
        case 3:
            return Color.yellow
        case 4, 5:
            return Color.red
        default:
            return AppColors.primary
        }
    }
    
    private func timerProgressColor() -> Color {
        if timerProgress < 0.33 {
            return Color.green
        } else if timerProgress < 0.66 {
            return Color.yellow
        } else {
            return Color.red
        }
    }
    
    private func completeStrategy() {
        stopTimer()
        showingCompletionSheet = true
    }
    
    private func saveRating() {
        var notes = completionNotes
        
        // Add mood change information to notes
        if !moodBefore.isEmpty, let change = moodChangeValue {
            let moodNote = "\nMood: \(moodBefore) (\(Int(moodIntensityBefore))) → changed by \(change)"
            notes = notes.isEmpty ? moodNote : notes + moodNote
        }
        
        strategyStore.addRating(
            for: strategy.title,
            rating: rating,
            notes: notes.isEmpty ? nil : notes
        )
    }
    
    private func estimateTimerDuration() {
        // Parse the timeToComplete string to estimate duration in seconds
        let timeString = strategy.timeToComplete.lowercased()
        
        if timeString.contains("minute") {
            // Extract numbers from the string
            let numbers = timeString.components(separatedBy: CharacterSet.decimalDigits.inverted)
                .compactMap { Int($0) }
                .filter { $0 > 0 }
            
            if numbers.count == 1 {
                // Single number like "5 minutes"
                estimatedSeconds = numbers[0] * 60
            } else if numbers.count >= 2 {
                // Range like "5-10 minutes" - use the average
                estimatedSeconds = (numbers[0] + numbers[1]) / 2 * 60
            }
        }
    }
    
    private func startTimer() {
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            secondsElapsed += 1
            updateTimerProgress()
        }
    }
    
    private func startStepTimer() {
        showingProgressIndicator = true
        stepProgress = 0
        
        // Estimate time for each step
        let timePerStep = estimatedSeconds > 0 ? Double(estimatedSeconds) / Double(strategy.steps.count) : 30.0
        
        // Reset and start progress animation
        withAnimation(.linear(duration: timePerStep)) {
            stepProgress = 1.0
        }
        
        // Schedule advancing to next step
        DispatchQueue.main.asyncAfter(deadline: .now() + timePerStep) {
            if guidedModeActive && selectedStep < strategy.steps.count - 1 {
                advanceToNextStep()
            }
        }
    }
    
    private func advanceToNextStep() {
        HapticFeedback.medium()
        if selectedStep < strategy.steps.count - 1 {
            selectedStep += 1
            startStepTimer()
        }
    }
    
    private func updateTimerProgress() {
        if estimatedSeconds > 0 {
            timerProgress = min(CGFloat(secondsElapsed) / CGFloat(estimatedSeconds), 1.0)
            
            // Provide haptic feedback at certain milestones
            if secondsElapsed == estimatedSeconds / 2 {
                HapticFeedback.light()
            } else if secondsElapsed == estimatedSeconds {
                HapticFeedback.success()
            } else if secondsElapsed > estimatedSeconds && secondsElapsed % 60 == 0 {
                HapticFeedback.warning()
            }
        }
    }
    
    private func stopTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    private func resetTimer() {
        stopTimer()
        secondsElapsed = 0
        timerProgress = 0
    }
    
    private func addOneMinute() {
        if isTimerRunning {
            estimatedSeconds += 60
            updateTimerProgress()
        } else {
            estimatedSeconds += 60
        }
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
    
    private func ratingColor(for rating: Int) -> Color {
        switch rating {
        case 1, 2:
            return .red
        case 3:
            return .orange
        case 4, 5:
            return .green
        default:
            return AppColors.textLight
        }
    }
    
    // MARK: - Mood Check-In View
    private var moodCheckInView: some View {
        VStack(spacing: 24) {
            // Header
            Text("How are you feeling?")
                .font(AppTextStyles.h3)
                .foregroundColor(AppColors.textDark)
            
            Text("Before you start, let's check in with your current mood")
                .font(AppTextStyles.body2)
                .foregroundColor(AppColors.textMedium)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Mood selection
            VStack(alignment: .leading, spacing: 12) {
                Text("My mood is...")
                    .font(AppTextStyles.body2)
                    .foregroundColor(AppColors.textDark)
                
                TextField("e.g. anxious, stressed, sad", text: $moodBefore)
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(8)
                
                Text("Intensity: \(Int(moodIntensityBefore))")
                    .font(AppTextStyles.body2)
                    .foregroundColor(AppColors.textDark)
                
                // Breaking up the complex expression
                let sliderColor = moodIntensityColor(intensity: moodIntensityBefore)
                Slider(value: $moodIntensityBefore, in: 1...5, step: 1)
                    .accentColor(sliderColor)
                    .onChange(of: moodIntensityBefore) { _ in
                        HapticFeedback.selection()
                    }
                
                HStack {
                    Text("Mild")
                        .font(AppTextStyles.body3)
                        .foregroundColor(AppColors.textLight)
                    
                    Spacer()
                    
                    Text("Intense")
                        .font(AppTextStyles.body3)
                        .foregroundColor(AppColors.textLight)
                }
            }
            .padding()
            
            // Continue button
            Button(action: {
                HapticFeedback.medium()
                showingMoodCheckIn = false
            }) {
                Text("Start Strategy")
                    .font(AppTextStyles.h4)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary)
                    .cornerRadius(AppLayout.cornerRadius)
            }
            .disabled(moodBefore.isEmpty)
            .opacity(moodBefore.isEmpty ? 0.6 : 1)
            
            Button(action: {
                showingMoodCheckIn = false
            }) {
                Text("Skip")
                    .font(AppTextStyles.body2)
                    .foregroundColor(AppColors.textMedium)
            }
            .padding()
        }
        .padding()
    }
    
    // MARK: - Breathing Exercise
    private var breathingExerciseSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Guided Breathing")
                .font(AppTextStyles.h4)
                .foregroundColor(AppColors.textDark)
            
            if !showingBreathingExercise {
                // Preview/start view
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Breathing pattern")
                                .font(AppTextStyles.body2)
                                .foregroundColor(AppColors.textDark)
                            
                            // Breathing pattern selection
                            Picker("Pattern", selection: $breathingPattern) {
                                Text("4-7-8").tag(BreathingPattern.fourSevenEight)
                                Text("Box (4-4-4-4)").tag(BreathingPattern.boxBreathing)
                                Text("Deep (5-2-5)").tag(BreathingPattern.deepBreathing)
                                Text("Calming Breath").tag(BreathingPattern.calmingBreath)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .onChange(of: breathingPattern) { _ in
                                HapticFeedback.selection()
                            }
                        }
                    }
                    
                    // Pattern description
                    VStack(alignment: .leading, spacing: 4) {
                        Text(breathingPattern.description)
                            .font(AppTextStyles.body2)
                            .foregroundColor(AppColors.textDark)
                        
                        Text("Inhale for \(Int(breathingPattern.inhaleTime)) seconds, hold for \(Int(breathingPattern.holdTime)) seconds, exhale for \(Int(breathingPattern.exhaleTime)) seconds")
                            .font(AppTextStyles.body3)
                            .foregroundColor(AppColors.textMedium)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(strategy.category.color.opacity(0.1))
                    .cornerRadius(8)
                    
                    // Start button
                    Button(action: {
                        HapticFeedback.medium()
                        startBreathingExercise()
                    }) {
                        HStack {
                            Image(systemName: "lungs.fill")
                                .font(.system(size: 18))
                            Text("Start Breathing Exercise")
                                .font(AppTextStyles.h4)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(strategy.category.color)
                        .cornerRadius(AppLayout.cornerRadius)
                    }
                    .padding(.top, 8)
                }
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(AppLayout.cornerRadius)
            } else {
                // Active breathing exercise
                VStack(spacing: 20) {
                    // Breathing visualization
                    ZStack {
                        // Outer circle
                        Circle()
                            .stroke(strategy.category.color.opacity(0.3), lineWidth: 8)
                            .frame(width: 250, height: 250)
                        
                        // Animated breathing circle
                        Circle()
                            .fill(strategy.category.color.opacity(breathingOpacity))
                            .frame(width: 220, height: 220)
                            .scaleEffect(breathingScale)
                            .animation(.easeInOut(duration: 1.0), value: breathingScale)
                        
                        // Instruction text
                        VStack(spacing: 8) {
                            Text(breathingPhase.instruction)
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.bottom, 4)
                            
                            Text("\(Int(breathingPhase.timeRemaining))")
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .id(breathingPhase.id) // Force redraw when phase changes
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                    
                    // Progress indicators
                    VStack(spacing: 16) {
                        // Breath counter
                        Text("Breath \(breathingCycleCount)/\(Int(breathingPattern.totalCycleTime))")
                            .font(AppTextStyles.body2)
                            .foregroundColor(AppColors.textMedium)
                        
                        // Phase visualizer
                        HStack(spacing: 0) {
                            phaseIndicator(
                                phase: .inhale,
                                width: CGFloat(breathingPattern.inhaleTime) / CGFloat(breathingPattern.totalCycleTime)
                            )
                            
                            if breathingPattern.holdTime > 0 {
                                phaseIndicator(
                                    phase: .hold,
                                    width: CGFloat(breathingPattern.holdTime) / CGFloat(breathingPattern.totalCycleTime)
                                )
                            }
                            
                            phaseIndicator(
                                phase: .exhale,
                                width: CGFloat(breathingPattern.exhaleTime) / CGFloat(breathingPattern.totalCycleTime)
                            )
                            
                            if breathingPattern.holdAfterExhaleTime > 0 {
                                phaseIndicator(
                                    phase: .holdAfterExhale,
                                    width: CGFloat(breathingPattern.holdAfterExhaleTime) / CGFloat(breathingPattern.totalCycleTime)
                                )
                            }
                        }
                        .frame(height: 8)
                        .cornerRadius(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    // Control buttons
                    HStack(spacing: 30) {
                        // Reset button
                        Button(action: {
                            HapticFeedback.medium()
                            resetBreathingExercise()
                        }) {
                            VStack {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                
                                Text("Reset")
                                    .font(AppTextStyles.body3)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // Stop button
                        Button(action: {
                            HapticFeedback.medium()
                            stopBreathingExercise()
                        }) {
                            VStack {
                                Image(systemName: "xmark.circle")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                
                                Text("End")
                                    .font(AppTextStyles.body3)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.top, 20)
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            strategy.category.color.opacity(0.9),
                            strategy.category.color.opacity(0.7)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(AppLayout.cornerRadius)
            }
        }
        .padding(.top, 8)
    }
    
    // Helper function to create phase indicator for breathing visualization
    private func phaseIndicator(phase: BreathingPhase, width: CGFloat) -> some View {
        Rectangle()
            .fill(breathingPhase == .inhale ? Color.green : breathingPhase == .hold ? Color.yellow : breathingPhase == .exhale ? Color.blue : breathingPhase == .holdAfterExhale ? Color.orange : Color.red)
            .frame(width: max(width * 200, 20))
    }
    
    // MARK: - Breathing Exercise Functions
    private func startBreathingExercise() {
        showingBreathingExercise = true
        breathingCycleCount = 1
        startBreathingCycle()
    }
    
    private func startBreathingCycle() {
        // Start with inhale
        startBreathingPhase(.inhale)
    }
    
    private func startBreathingPhase(_ phase: BreathingPhase) {
        breathingPhase = phase
        
        // Update animation based on phase
        switch phase {
        case .inhale:
            // Expand the circle
            withAnimation(.easeIn(duration: breathingPattern.inhaleTime)) {
                breathingScale = 1.4
                breathingOpacity = 0.6
            }
            
            // Provide light haptic feedback at beginning of inhale
            HapticFeedback.light()
            
            // Schedule next phase
            scheduleNextPhase(after: breathingPattern.inhaleTime, nextPhase: breathingPattern.holdTime > 0 ? .hold : .exhale)
            
        case .hold:
            // Keep circle expanded but change opacity slightly
            withAnimation(.easeInOut(duration: 0.5)) {
                breathingOpacity = 0.7
            }
            
            // Schedule next phase
            scheduleNextPhase(after: breathingPattern.holdTime, nextPhase: .exhale)
            
        case .exhale:
            // Contract the circle
            withAnimation(.easeOut(duration: breathingPattern.exhaleTime)) {
                breathingScale = 1.0
                breathingOpacity = 0.8
            }
            
            // Provide medium haptic feedback at beginning of exhale
            HapticFeedback.light()
            
            // Schedule next phase
            if breathingPattern.holdAfterExhaleTime > 0 {
                scheduleNextPhase(after: breathingPattern.exhaleTime, nextPhase: .holdAfterExhale)
            } else {
                scheduleNextPhase(after: breathingPattern.exhaleTime, nextPhase: breathingCycleCount < Int(breathingPattern.totalCycleTime) ? .inhale : .complete)
            }
            
        case .holdAfterExhale:
            // Keep circle contracted
            withAnimation(.easeInOut(duration: 0.5)) {
                breathingOpacity = 0.9
            }
            
            // Schedule next phase
            scheduleNextPhase(after: breathingPattern.holdAfterExhaleTime, nextPhase: breathingCycleCount < Int(breathingPattern.totalCycleTime) ? .inhale : .complete)
            
        case .complete:
            // Exercise complete
            withAnimation {
                breathingOpacity = 1.0
            }
            
            // Provide success haptic feedback
            HapticFeedback.success()
            
            // End exercise after a brief pause
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                stopBreathingExercise()
            }
        }
    }
    
    private func scheduleNextPhase(after seconds: Double, nextPhase: BreathingPhase) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            if showingBreathingExercise {
                if nextPhase == .inhale && breathingCycleCount < Int(breathingPattern.totalCycleTime) {
                    breathingCycleCount += 1
                }
                
                startBreathingPhase(nextPhase)
            }
        }
    }
    
    private func resetBreathingExercise() {
        stopBreathingExercise()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            startBreathingExercise()
        }
    }
    
    private func stopBreathingExercise() {
        showingBreathingExercise = false
        breathingCycleCount = 0
        
        // Reset animation values
        withAnimation {
            breathingScale = 1.0
            breathingOpacity = 0.8
        }
    }
}

// MARK: - Strategy List View
struct StrategyListView: View {
    let title: String
    let strategies: [LocalCopingStrategyDetail]
    let onStrategySelected: (LocalCopingStrategyDetail) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var strategyStore = LocalStrategyEffectivenessStore.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                if strategies.isEmpty {
                    emptyView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(strategies) { strategy in
                                strategyListItem(strategy)
                                    .onTapGesture {
                                        onStrategySelected(strategy)
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(AppColors.textDark)
                    }
                }
            }
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(AppColors.textLight.opacity(0.5))
            
            Text("No strategies found")
                .font(AppTextStyles.h3)
                .foregroundColor(AppColors.textDark)
            
            Text("Try adjusting your filters or categories")
                .font(AppTextStyles.body2)
                .foregroundColor(AppColors.textMedium)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private func strategyListItem(_ strategy: LocalCopingStrategyDetail) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                // Category icon
                ZStack {
                    Circle()
                        .fill(strategy.category.color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: strategy.category.iconName)
                        .font(.system(size: 16))
                        .foregroundColor(strategy.category.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(strategy.title)
                        .font(AppTextStyles.h4)
                        .foregroundColor(AppColors.textDark)
                    
                    Text(strategy.description)
                        .font(AppTextStyles.body3)
                        .foregroundColor(AppColors.textMedium)
                        .lineLimit(2)
                    
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 12))
                            Text(strategy.timeToComplete)
                                .font(AppTextStyles.body3)
                        }
                        .foregroundColor(AppColors.textMedium)
                        
                        Spacer()
                        
                        if strategyStore.getAverageRating(for: strategy.title) > 0 {
                            HStack(spacing: 2) {
                                Text(String(format: "%.1f", strategyStore.getAverageRating(for: strategy.title)))
                                    .font(AppTextStyles.body3)
                                
                                Image(systemName: "star.fill")
                                    .font(.system(size: 10))
                            }
                            .foregroundColor(.yellow)
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(.leading, 8)
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.textLight)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
}

// MARK: - Preview Provider
struct EnhancedCopingStrategiesLibraryView_Previews: PreviewProvider {
    static var previews: some View {
        EnhancedCopingStrategiesLibraryView()
    }
}


