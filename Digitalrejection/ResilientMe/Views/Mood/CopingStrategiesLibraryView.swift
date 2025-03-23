import SwiftUI

struct CopingStrategiesLibraryView: View {
    // Access the library
    private let copingStrategiesLibrary = CopingStrategiesLibrary.shared
    
    // State variables
    @State private var selectedCategory: CopingStrategyCategory?
    @State private var selectedStrategy: CopingStrategyDetail?
    @State private var showingStrategyDetail = false
    @State private var searchText = ""
    
    // Computed properties
    private var categories: [CopingStrategyCategory] {
        CopingStrategyCategory.allCases
    }
    
    private var filteredStrategies: [CopingStrategyDetail] {
        var strategies: [CopingStrategyDetail]
        
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
    private var quickStrategies: [CopingStrategyDetail] {
        return filteredStrategies.filter { $0.intensity == .quick }
    }
    
    private var moderateStrategies: [CopingStrategyDetail] {
        return filteredStrategies.filter { $0.intensity == .moderate }
    }
    
    private var intensiveStrategies: [CopingStrategyDetail] {
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
                        strategySection(title: "Quick Relief", strategies: quickStrategies, color: StrategyIntensity.quick.color)
                    }
                    
                    // Moderate practice section
                    if !moderateStrategies.isEmpty {
                        strategySection(title: "Moderate Practice", strategies: moderateStrategies, color: StrategyIntensity.moderate.color)
                    }
                    
                    // Intensive practice section
                    if !intensiveStrategies.isEmpty {
                        strategySection(title: "In-Depth Process", strategies: intensiveStrategies, color: StrategyIntensity.intensive.color)
                    }
                    
                    // No results
                    if filteredStrategies.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundColor(AppColors.textMedium)
                            
                            Text("No strategies found")
                                .font(AppTextStyles.h4)
                                .foregroundColor(AppColors.textMedium)
                            
                            Text("Try a different search term or category")
                                .font(AppTextStyles.body2)
                                .foregroundColor(AppColors.textMedium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    }
                }
                .padding()
            }
            .background(AppColors.background)
            .navigationTitle("Coping Strategies")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Show info about strategies
                    }) {
                        Label("Info", systemImage: "info.circle")
                            .labelStyle(.iconOnly)
                            .foregroundColor(AppColors.primary)
                    }
                }
            }
            .sheet(isPresented: $showingStrategyDetail) {
                if let strategy = selectedStrategy {
                    StrategyDetailView(strategy: strategy)
                }
            }
        }
    }
    
    // MARK: - Component Views
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Coping Strategies Library")
                .font(AppTextStyles.h2)
                .foregroundColor(AppColors.textDark)
            
            Text("Tools for emotional resilience when facing rejection")
                .font(AppTextStyles.body2)
                .foregroundColor(AppColors.textMedium)
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppColors.textMedium)
            
            TextField("Search strategies", text: $searchText)
                .font(AppTextStyles.body2)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColors.textMedium)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    private var categorySelectionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Categories")
                .font(AppTextStyles.h3)
                .foregroundColor(AppColors.textDark)
            
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
    }
    
    private func categoryButton(_ category: CopingStrategyCategory?, title: String? = nil) -> some View {
        let isSelected = category == selectedCategory
        let displayTitle = title ?? category?.rawValue ?? "All"
        let iconName = category?.iconName ?? "rectangle.grid.2x2"
        let color = category?.color ?? AppColors.primary
        
        return Button(action: {
            withAnimation {
                if selectedCategory == category {
                    // Deselect if tapping the same category
                    selectedCategory = nil
                } else {
                    selectedCategory = category
                }
            }
            AppHapticFeedback.selection()
        }) {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.system(size: 14))
                
                Text(displayTitle)
                    .font(AppTextStyles.body3)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? color.opacity(0.2) : AppColors.cardBackground)
            .foregroundColor(isSelected ? color : AppColors.textDark)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 1)
            )
        }
    }
    
    private func strategySection(title: String, strategies: [CopingStrategyDetail], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(AppTextStyles.h3)
                    .foregroundColor(AppColors.textDark)
                
                Spacer()
                
                Text("\(strategies.count) strategies")
                    .font(AppTextStyles.caption)
                    .foregroundColor(AppColors.textMedium)
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(strategies) { strategy in
                    strategyCard(strategy, color: color)
                }
            }
        }
    }
    
    private func strategyCard(_ strategy: CopingStrategyDetail, color: Color) -> some View {
        Button(action: {
            selectedStrategy = strategy
            showingStrategyDetail = true
            AppHapticFeedback.selection()
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
                        .foregroundColor(AppColors.textMedium)
                }
                
                // Title
                Text(strategy.title)
                    .font(AppTextStyles.h4)
                    .foregroundColor(AppColors.textDark)
                    .lineLimit(2)
                
                Spacer()
                
                // Description
                Text(strategy.description)
                    .font(AppTextStyles.body3)
                    .foregroundColor(AppColors.textMedium)
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
            .background(AppColors.cardBackground)
            .cornerRadius(AppLayout.cornerRadius)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Strategy Detail View

struct StrategyDetailView: View {
    let strategy: CopingStrategyDetail
    @Environment(\.dismiss) private var dismiss
    @State private var selectedStep: Int = 0
    @State private var timerRunning = false
    @State private var timerSeconds = 0
    @State private var timer: Timer? = nil
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                headerView
                
                // Description
                descriptionView
                
                // Steps
                stepsView
                
                // Simple timer
                timerView
                
                // Resources (if any)
                if let resources = strategy.resources, !resources.isEmpty {
                    resourcesView(resources)
                }
                
                // Related moods
                relatedMoodsView
            }
            .padding()
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(AppColors.textDark)
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text("Strategy Details")
                    .font(AppTextStyles.h3)
                    .foregroundColor(AppColors.textDark)
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
                .foregroundColor(AppColors.textDark)
                .padding(.top, 8)
        }
    }
    
    private var descriptionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About This Strategy")
                .font(AppTextStyles.h3)
                .foregroundColor(AppColors.textDark)
            
            Text(strategy.description)
                .font(AppTextStyles.body1)
                .foregroundColor(AppColors.textMedium)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    private var stepsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Steps to Follow")
                .font(AppTextStyles.h3)
                .foregroundColor(AppColors.textDark)
            
            VStack(spacing: 16) {
                ForEach(0..<strategy.steps.count, id: \.self) { index in
                    stepView(index: index, step: strategy.steps[index])
                }
            }
        }
    }
    
    private func stepView(index: Int, step: String) -> some View {
        let isSelected = selectedStep == index
        
        return Button(action: {
            withAnimation {
                selectedStep = isSelected ? -1 : index
            }
            AppHapticFeedback.selection()
        }) {
            HStack(alignment: .top, spacing: 16) {
                // Step number
                ZStack {
                    Circle()
                        .fill(isSelected ? strategy.category.color : AppColors.cardBackground)
                        .frame(width: 30, height: 30)
                    
                    Text("\(index + 1)")
                        .font(AppTextStyles.body3.bold())
                        .foregroundColor(isSelected ? .white : AppColors.textDark)
                }
                
                // Step content
                VStack(alignment: .leading, spacing: 4) {
                    Text(step)
                        .font(AppTextStyles.body2)
                        .foregroundColor(AppColors.textDark)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                // Checkmark if selected
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(strategy.category.color)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                    .fill(isSelected ? strategy.category.color.opacity(0.1) : AppColors.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                    .stroke(isSelected ? strategy.category.color : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var timerView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Simple Timer")
                .font(AppTextStyles.h3)
                .foregroundColor(AppColors.textDark)
            
            VStack(spacing: 16) {
                // Timer display
                HStack {
                    Spacer()
                    
                    Text(formatTime(timerSeconds))
                        .font(.system(size: 48, weight: .medium, design: .monospaced))
                        .foregroundColor(timerRunning ? strategy.category.color : AppColors.textDark)
                    
                    Spacer()
                }
                
                // Timer controls
                HStack(spacing: 20) {
                    Spacer()
                    
                    // Reset button
                    Button(action: {
                        resetTimer()
                        AppHapticFeedback.light()
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.textMedium)
                            .frame(width: 50, height: 50)
                            .background(AppColors.cardBackground)
                            .cornerRadius(25)
                    }
                    
                    // Start/stop button
                    Button(action: {
                        toggleTimer()
                        AppHapticFeedback.selection()
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
            .background(AppColors.cardBackground)
            .cornerRadius(AppLayout.cornerRadius)
        }
    }
    
    private func resourcesView(_ resources: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Resources")
                .font(AppTextStyles.h3)
                .foregroundColor(AppColors.textDark)
            
            VStack(spacing: 8) {
                ForEach(resources, id: \.self) { url in
                    Link(destination: URL(string: url) ?? URL(string: "https://apple.com")!) {
                        HStack {
                            Image(systemName: "link")
                                .foregroundColor(strategy.category.color)
                            
                            Text(url)
                                .font(AppTextStyles.body3)
                                .foregroundColor(AppColors.primary)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.textMedium)
                        }
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(AppLayout.cornerRadius)
                    }
                }
            }
        }
    }
    
    private var relatedMoodsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Helpful For")
                .font(AppTextStyles.h3)
                .foregroundColor(AppColors.textDark)
            
            // Mood tags
            FlowLayout(spacing: 8) {
                ForEach(strategy.moodTargets, id: \.self) { mood in
                    Text(mood)
                        .font(AppTextStyles.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppColors.background)
                        .foregroundColor(AppColors.textMedium)
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(AppColors.textLight, lineWidth: 1)
                        )
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    // Timer functions
    
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
}

// MARK: - Helper Views

/// Flow layout that arranges items in rows
struct FlowLayout: Layout {
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