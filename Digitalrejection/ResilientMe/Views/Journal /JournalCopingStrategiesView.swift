import SwiftUI

// MARK: - Recommended Strategies View

// Environment object to track presentation state of recommendations
class RecommendedStrategiesState: ObservableObject, Identifiable {
    public let id = UUID()
    @Published var strategies: [ExportCopingStrategyDetail]
    
    init(strategies: [ExportCopingStrategyDetail]) {
        self.strategies = strategies
    }
}

struct JournalCopingStrategiesView: View {
    // Use @ObservedObject if the state is created and passed by the parent view
    // Use @StateObject if this view creates and owns the state object
    @ObservedObject var recommendationsState: RecommendedStrategiesState 
    @Environment(\.dismiss) private var dismiss
    
    // State for presenting the detail view of a selected strategy
    @State private var selectedStrategy: ExportCopingStrategyDetail? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                headerText
                
                // Strategy list
                strategyList
                
                // Footer with additional guidance
                footerText
            }
            .padding(.top)
            .background(AppColors.background.edgesIgnoringSafeArea(.all))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Recommended For You")
                        .font(AppTextStyles.h3)
                        .foregroundColor(AppColors.textDark)
                }
            }
            // Use .sheet(item: ...) to present the detail view modally
            .sheet(item: $selectedStrategy) { strategy in
                // Pass the selected strategy to the detail view
                JournalStrategyDetailView(strategy: strategy)
                    // .withDynamicTypeSize() // Apply if View+JournalExtensions is available
            }
        }
        // Apply dynamic type size to the whole NavigationView
        // .withDynamicTypeSize() // Apply if View+JournalExtensions is available
    }
    
    // MARK: - Subviews
    
    private var headerText: some View {
        Text("Based on your journal entry, we recommend these coping strategies:")
            .font(AppTextStyles.h3)
            .foregroundColor(AppColors.textDark)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
    
    private var strategyList: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(recommendationsState.strategies) { strategy in
                    strategyCard(for: strategy)
                        .onTapGesture {
                            selectedStrategy = strategy // Set the strategy to show details
                        }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var footerText: some View {
        Text("Tap any strategy to view details and get started")
            .font(AppTextStyles.body2)
            .foregroundColor(AppColors.textMedium)
            .padding(.bottom)
    }
    
    private func strategyCard(for strategy: ExportCopingStrategyDetail) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category badge
            categoryBadge(for: strategy.category)
                
            // Strategy title
            Text(strategy.title)
                .font(AppTextStyles.h3)
                .foregroundColor(AppColors.textDark)
                .fixedSize(horizontal: false, vertical: true)
                
            // Strategy description
            Text(strategy.description)
                .font(AppTextStyles.body1)
                .foregroundColor(AppColors.textMedium)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            // Footer with time and button
            HStack {
                timeLabel(for: strategy.timeToComplete)
                Spacer()
                viewStrategyButton(for: strategy.category)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(strategy.title). Category: \(strategy.category.displayName). Time: \(strategy.timeToComplete).")
        .accessibilityHint("Tap to view details.")
        .accessibilitySortPriority(1)
    }
    
    private func categoryBadge(for category: ExportCopingStrategyCategory) -> some View {
        Text(category.displayName)
            .font(AppTextStyles.buttonFont)
            .foregroundColor(category.color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(category.color.opacity(0.1))
            .cornerRadius(16)
    }
    
    private func timeLabel(for timeString: String) -> some View {
        Label(
            title: { Text(timeString) },
            icon: { Image(systemName: "clock") }
        )
        .font(AppTextStyles.captionText)
        .foregroundColor(AppColors.textMedium)
    }
    
    private func viewStrategyButton(for category: ExportCopingStrategyCategory) -> some View {
        Text("View Strategy")
            .font(AppTextStyles.buttonFont)
            .foregroundColor(category.color)
    }
}

// MARK: - Strategy Detail View

struct JournalStrategyDetailView: View {
    let strategy: ExportCopingStrategyDetail
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Text(strategy.title)
                            .font(AppTextStyles.h1)
                            .foregroundColor(AppColors.textDark)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Category and time needed
                        HStack(spacing: 16) {
                            categoryBadge(for: strategy.category)
                            timeLabel(for: strategy.timeToComplete)
                        }
                    }
                    .frame(maxWidth: .infinity)
                        
                    // Steps section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("How to do it")
                            .font(AppTextStyles.h2)
                            .foregroundColor(AppColors.textDark)
                            
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(Array(strategy.steps.enumerated()), id: \.offset) { index, step in
                                stepView(index: index, text: step, category: strategy.category)
                            }
                        }
                    }
                    
                    // Start button
                    Button(action: { /* TODO: Implement start strategy action */ }) {
                        Text("Start Now")
                            .font(AppTextStyles.buttonFont)
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
            .background(AppColors.background.edgesIgnoringSafeArea(.all))
            .navigationTitle("Strategy Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func categoryBadge(for category: ExportCopingStrategyCategory) -> some View {
        Text(category.displayName)
            .font(AppTextStyles.captionText)
            .foregroundColor(category.color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(category.color.opacity(0.1))
            .cornerRadius(16)
    }

    private func timeLabel(for timeString: String) -> some View {
        Label(
            title: { Text(timeString) },
            icon: { Image(systemName: "clock") }
        )
        .font(AppTextStyles.captionText)
        .foregroundColor(AppColors.textMedium)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    private func stepView(index: Int, text: String, category: ExportCopingStrategyCategory) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Text("\(index + 1)")
                .font(AppTextStyles.h3)
                .foregroundColor(.white)
                .frame(width: 28, height: 28, alignment: .center)
                .background(category.color)
                .clipShape(Circle())
                            
            Text(text)
                .font(AppTextStyles.body1)
                .foregroundColor(AppColors.textDark)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// Assuming ExportCopingStrategyDetail, ExportCopingStrategyCategory, AppColors, 
// AppTextStyles, AppLayout are accessible. 