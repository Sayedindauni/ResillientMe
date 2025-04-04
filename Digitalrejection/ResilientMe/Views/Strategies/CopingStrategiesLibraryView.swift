import SwiftUI
import ResilientMe
import UIKit

// MARK: - Haptic Feedback
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
                    // View all in this category
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
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header section with title, category, time
                    headerSection
                    
                    // Description section
                    descriptionSection
                    
                    // Guided mode toggle
                    guidedModeToggle
                    
                    // Steps section
                    stepsSection
                    
                    // Timer section if applicable
                    timerSection
                    
                    // Usage section
                    usageSection
                    
                    // Button to complete
                    Button(action: {
                        LocalHapticFeedback.medium()
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
                        LocalHapticFeedback.light()
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
                estimateTimerDuration()
                // Show mood check-in when strategy detail is first shown
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showingMoodCheckIn = true
                }
            }
        }
        .onDisappear {
            stopTimer()
        }
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
                        LocalHapticFeedback.selection()
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
                        LocalHapticFeedback.selection()
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
                LocalHapticFeedback.medium()
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
            LocalHapticFeedback.light()
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
                                LocalHapticFeedback.medium()
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
                                LocalHapticFeedback.medium()
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
                                LocalHapticFeedback.medium()
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
                            LocalHapticFeedback.selection()
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
                LocalHapticFeedback.success()
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
        LocalHapticFeedback.selection()
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
        LocalHapticFeedback.medium()
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
                LocalHapticFeedback.light()
            } else if secondsElapsed == estimatedSeconds {
                LocalHapticFeedback.success()
            } else if secondsElapsed > estimatedSeconds && secondsElapsed % 60 == 0 {
                LocalHapticFeedback.warning()
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
}

// MARK: - Preview Provider
struct EnhancedCopingStrategiesLibraryView_Previews: PreviewProvider {
    static var previews: some View {
        EnhancedCopingStrategiesLibraryView()
    }
} 