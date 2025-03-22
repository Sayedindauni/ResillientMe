import SwiftUI
import Charts // Import Charts framework for visualizations
import UIKit  // Import UIKit for feedback generators

// Fixed references to all accessibility extensions
extension View {
    func accessibilityCard(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
    }
}

// MARK: - Extensions and Utility Types

// Renamed to avoid ambiguity with the MoodEntry in AppTypes
struct MoodTrackerEntry: Identifiable, Hashable {
    let id: String
    let date: Date
    let mood: String
    let intensity: Int // 1-5
    let note: String?
    let rejectionTrigger: String? // New field to track rejection triggers
    let copingStrategy: String? // New field to track coping strategies used
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MoodTrackerEntry, rhs: MoodTrackerEntry) -> Bool {
        return lhs.id == rhs.id
    }
}

struct MoodView: View {
    @State private var selectedMood: String?
    @State private var moodIntensity: Int = 3
    @State private var moodNote: String = ""
    @State private var showingHistory: Bool = false
    @State private var selectedTimeFrame: TimeFrame = .week
    @State private var isRejectionRelated: Bool = false
    @State private var rejectionTrigger: String = ""
    @State private var copingStrategy: String = ""
    @State private var showingInsights: Bool = false
    
    // Time frames for chart filtering
    enum TimeFrame: String, CaseIterable, Identifiable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
        
        var id: String { self.rawValue }
    }
    
    // Common rejection triggers for quick selection
    private let rejectionTriggers = [
        "Social media", "Dating app", "Job application", 
        "Friend interaction", "Family interaction", "Work/School"
    ]
    
    // Common coping strategies
    private let copingStrategies = [
        "Deep breathing", "Positive self-talk", "Physical activity",
        "Mindfulness", "Talking to someone", "Creative expression"
    ]
    
    private let moods = ["Happy", "Calm", "Sad", "Anxious", "Angry", "Tired"]
    
    // Expanded mock mood history with rejection data
    @State private var moodHistory: [MoodTrackerEntry] = [
        MoodTrackerEntry(
            id: "1", 
            date: Calendar.current.date(byAdding: .hour, value: -4, to: Date()) ?? Date(), 
            mood: "Calm", 
            intensity: 4, 
            note: "Meditation session helped me feel centered.",
            rejectionTrigger: nil,
            copingStrategy: "Mindfulness"
        ),
        MoodTrackerEntry(
            id: "2", 
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), 
            mood: "Anxious", 
            intensity: 4, 
            note: "Didn't get the internship I applied for.",
            rejectionTrigger: "Job application",
            copingStrategy: "Talking to someone"
        ),
        MoodTrackerEntry(
            id: "3", 
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(), 
            mood: "Happy", 
            intensity: 5, 
            note: "Received good news from family.",
            rejectionTrigger: nil,
            copingStrategy: nil
        ),
        MoodTrackerEntry(
            id: "4", 
            date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(), 
            mood: "Sad", 
            intensity: 3, 
            note: "Friend didn't respond to my message.",
            rejectionTrigger: "Friend interaction",
            copingStrategy: "Deep breathing"
        ),
        MoodTrackerEntry(
            id: "5", 
            date: Calendar.current.date(byAdding: .day, value: -4, to: Date()) ?? Date(), 
            mood: "Angry", 
            intensity: 3, 
            note: "Negative comment on my post.",
            rejectionTrigger: "Social media",
            copingStrategy: "Physical activity"
        ),
        MoodTrackerEntry(
            id: "6", 
            date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(), 
            mood: "Anxious", 
            intensity: 4, 
            note: "No matches on dating app today.",
            rejectionTrigger: "Dating app",
            copingStrategy: "Positive self-talk"
        ),
        MoodTrackerEntry(
            id: "7", 
            date: Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date(), 
            mood: "Calm", 
            intensity: 4, 
            note: "Practiced mindfulness after a stressful day.",
            rejectionTrigger: nil,
            copingStrategy: "Mindfulness"
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with improved accessibility
                HStack {
                    Text("Mood Tracker")
                        .font(AppTextStyles.h1)
                        .foregroundColor(AppColors.textDark)
                        .accessibilityAddTraits(.isHeader)
                    
                    Spacer()
                    
                    Button(action: {
                        showingHistory.toggle()
                        AppHapticFeedback.light()
                    }) {
                        Label("History", systemImage: "clock.arrow.circlepath")
                            .labelStyle(.iconOnly)
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.textMedium)
                    }
                    .accessibilityLabel("View mood history")
                    .accessibilityHint("Shows your past mood entries")
                    
                    Button(action: {
                        showingInsights.toggle()
                        AppHapticFeedback.light()
                    }) {
                        Label("Insights", systemImage: "chart.bar.fill")
                            .labelStyle(.iconOnly)
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.textMedium)
                    }
                    .padding(.leading, 8)
                    .accessibilityLabel("View mood insights")
                    .accessibilityHint("Shows charts and patterns from your mood data")
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: AppLayout.spacing * 1.5) {
                        // Empathetic messaging
                        if !showingHistory && !showingInsights {
                            Text("Your feelings matter. Track them here in a safe space.")
                                .font(AppTextStyles.body2)
                                .foregroundColor(AppColors.textMedium)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .padding(.bottom, 8)
                                .accessibilityLabel("Supportive message about tracking your feelings")
                        }
                        
                        // MOOD ENTRY SECTION
                        if !showingHistory && !showingInsights {
                        // Current mood section
                        VStack(alignment: .leading, spacing: AppLayout.spacing) {
                            Text("How are you feeling right now?")
                                .font(AppTextStyles.h3)
                                .foregroundColor(AppColors.textDark)
                            
                            // Mood selection grid
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 16) {
                                ForEach(moods, id: \.self) { mood in
                                    moodButton(mood)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(AppLayout.cornerRadius)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Daily mood check")
                            .accessibilityHint("Record your mood for today")
                        
                        // Intensity slider (only if mood is selected)
                        if selectedMood != nil {
                            VStack(alignment: .leading, spacing: AppLayout.spacing) {
                                Text("How intense is this feeling?")
                                    .font(AppTextStyles.h3)
                                    .foregroundColor(AppColors.textDark)
                                
                                VStack {
                                    Slider(value: Binding(
                                        get: { Double(moodIntensity) },
                                        set: { moodIntensity = Int($0) }
                                    ), in: 1...5, step: 1)
                                    .accentColor(AppColors.primary)
                                    
                                    HStack {
                                        Text("Mild")
                                            .font(AppTextStyles.body3)
                                            .foregroundColor(AppColors.textLight)
                                        
                                        Spacer()
                                        
                                        Text("Moderate")
                                            .font(AppTextStyles.body3)
                                            .foregroundColor(AppColors.textLight)
                                        
                                        Spacer()
                                        
                                        Text("Strong")
                                            .font(AppTextStyles.body3)
                                            .foregroundColor(AppColors.textLight)
                                    }
                                }
                            }
                            .padding()
                            .background(AppColors.cardBackground)
                            .cornerRadius(AppLayout.cornerRadius)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                                .accessibilityCard(label: "Mood intensity", hint: "Select how strongly you feel this emotion from 1 to 5")
                                
                                // Rejection-related section
                                VStack(alignment: .leading, spacing: AppLayout.spacing) {
                                    Toggle(isOn: $isRejectionRelated) {
                                        Text("Is this mood related to a rejection experience?")
                                            .font(AppTextStyles.h3)
                                            .foregroundColor(AppColors.textDark)
                                    }
                                    .toggleStyle(SwitchToggleStyle(tint: AppColors.primary))
                                    
                                    if isRejectionRelated {
                                        Text("What triggered this feeling?")
                                            .font(AppTextStyles.body2)
                                            .foregroundColor(AppColors.textMedium)
                                            .padding(.top, 8)
                                        
                                        // Quick selection of common triggers
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 10) {
                                                ForEach(rejectionTriggers, id: \.self) { trigger in
                                                    Button(action: {
                                                        rejectionTrigger = trigger
                                                    }) {
                                                        Text(trigger)
                                                            .font(AppTextStyles.body3)
                                                            .foregroundColor(rejectionTrigger == trigger ? .white : AppColors.textDark)
                                                            .padding(.horizontal, 12)
                                                            .padding(.vertical, 8)
                                                            .background(
                                                                rejectionTrigger == trigger ? 
                                                                AppColors.primary : 
                                                                AppColors.background
                                                            )
                                                            .cornerRadius(20)
                                                    }
                                                }
                                            }
                                            .padding(.vertical, 4)
                                        }
                                        
                                        // Custom trigger input
                                        if !rejectionTriggers.contains(rejectionTrigger) && !rejectionTrigger.isEmpty {
                                            TextField("Other trigger", text: $rejectionTrigger)
                                                .padding()
                                                .background(AppColors.background)
                                                .cornerRadius(AppLayout.cornerRadius / 2)
                                        }
                                        
                                        Text("What helped you cope with this feeling?")
                                            .font(AppTextStyles.body2)
                                            .foregroundColor(AppColors.textMedium)
                                            .padding(.top, 12)
                                        
                                        // Coping strategies
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 10) {
                                                ForEach(copingStrategies, id: \.self) { strategy in
                                                    Button(action: {
                                                        copingStrategy = strategy
                                                    }) {
                                                        Text(strategy)
                                                            .font(AppTextStyles.body3)
                                                            .foregroundColor(copingStrategy == strategy ? .white : AppColors.textDark)
                                                            .padding(.horizontal, 12)
                                                            .padding(.vertical, 8)
                                                            .background(
                                                                copingStrategy == strategy ? 
                                                                AppColors.secondary : 
                                                                AppColors.background
                                                            )
                                                            .cornerRadius(20)
                                                    }
                                                }
                                            }
                                            .padding(.vertical, 4)
                                        }
                                        
                                        // Custom coping input
                                        if !copingStrategies.contains(copingStrategy) && !copingStrategy.isEmpty {
                                            TextField("Other strategy", text: $copingStrategy)
                                                .padding()
                                                .background(AppColors.background)
                                                .cornerRadius(AppLayout.cornerRadius / 2)
                                        }
                                    }
                                }
                                .padding()
                                .background(AppColors.cardBackground)
                                .cornerRadius(AppLayout.cornerRadius)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                                .animation(.easeInOut, value: isRejectionRelated)
                                .accessibilityCard(label: "Rejection experience", hint: "Indicate if this mood is related to rejection and track triggers")
                            
                            // Add note
                            VStack(alignment: .leading, spacing: AppLayout.spacing) {
                                Text("Add a note (optional)")
                                    .font(AppTextStyles.h3)
                                    .foregroundColor(AppColors.textDark)
                                
                                TextEditor(text: $moodNote)
                                    .frame(height: 100)
                                    .padding(8)
                                    .background(AppColors.background)
                                    .cornerRadius(AppLayout.cornerRadius / 2)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: AppLayout.cornerRadius / 2)
                                                .stroke(AppColors.textLight.opacity(0.3), lineWidth: 1)
                                        )
                                    
                                    // Supportive message
                                    Text("Express yourself freely. This is your private space.")
                                        .font(AppTextStyles.caption)
                                        .foregroundColor(AppColors.textLight)
                                        .padding(.bottom, 8)
                                
                                Button(action: {
                                    // Save mood entry
                                    saveMood()
                                }) {
                                    Text("Save Mood")
                                        .font(AppTextStyles.h4)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(AppColors.primary)
                                        .cornerRadius(AppLayout.cornerRadius)
                                    }
                                    .accessibilityHint("Saves your current mood entry")
                                }
                                .padding()
                                .background(AppColors.cardBackground)
                                .cornerRadius(AppLayout.cornerRadius)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                                .accessibilityCard(label: "Note and save section", hint: "Add optional notes and save your mood entry")
                            }
                        }
                        
                        // HISTORY VIEW
                        if showingHistory {
                            VStack(alignment: .leading, spacing: AppLayout.spacing) {
                                HStack {
                                    Text("Your Mood History")
                                        .font(AppTextStyles.h3)
                                        .foregroundColor(AppColors.textDark)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        showingHistory = false
                                    }) {
                                        Text("Close")
                                            .font(AppTextStyles.body3)
                                            .foregroundColor(AppColors.primary)
                                    }
                                }
                                
                                Divider()
                                    .background(AppColors.textLight.opacity(0.3))
                                
                                ForEach(moodHistory.sorted(by: { $0.date > $1.date })) { entry in
                                    moodHistoryCard(entry)
                                }
                                
                                if moodHistory.isEmpty {
                                    VStack(spacing: 16) {
                                        Image(systemName: "calendar.badge.clock")
                                            .font(.system(size: 40))
                                            .foregroundColor(AppColors.textLight)
                                        
                                        Text("No mood entries yet")
                                            .font(AppTextStyles.h4)
                                            .foregroundColor(AppColors.textDark)
                                        
                                        Text("Start tracking your moods to see your history here")
                                            .font(AppTextStyles.body3)
                                            .foregroundColor(AppColors.textMedium)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 40)
                                }
                            }
                            .padding()
                            .background(AppColors.cardBackground)
                            .cornerRadius(AppLayout.cornerRadius)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                            .accessibilityCard(label: "Mood history", hint: "View your past mood entries")
                        }
                        
                        // INSIGHTS VIEW
                        if showingInsights {
                            VStack(alignment: .leading, spacing: AppLayout.spacing) {
                                HStack {
                                    Text("Mood Insights")
                                    .font(AppTextStyles.h3)
                                    .foregroundColor(AppColors.textDark)
                                
                                    Spacer()
                                    
                                    Button(action: {
                                        showingInsights = false
                                    }) {
                                        Text("Close")
                                            .font(AppTextStyles.body3)
                                            .foregroundColor(AppColors.primary)
                                    }
                                }
                                
                                // Time frame selection
                                Picker("Time Frame", selection: $selectedTimeFrame) {
                                    ForEach(TimeFrame.allCases) { timeFrame in
                                        Text(timeFrame.rawValue).tag(timeFrame)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .padding(.vertical, 8)
                                
                                // Mood trend chart
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Mood Trends")
                                        .font(AppTextStyles.h4)
                                        .foregroundColor(AppColors.textDark)
                                    
                                    if #available(iOS 16.0, *) {
                                        Chart {
                                            ForEach(filteredMoodHistory.sorted(by: { $0.date < $1.date })) { entry in
                                                PointMark(
                                                    x: .value("Date", entry.date),
                                                    y: .value("Intensity", entry.intensity)
                                                )
                                                .foregroundStyle(colorForMood(entry.mood))
                                                
                                                LineMark(
                                                    x: .value("Date", entry.date),
                                                    y: .value("Intensity", entry.intensity)
                                                )
                                                .foregroundStyle(colorForMood(entry.mood).opacity(0.5))
                                                .lineStyle(StrokeStyle(lineWidth: 2))
                                            }
                                        }
                                        .frame(height: 200)
                                        .chartYScale(domain: 1...5)
                                        .chartXAxis {
                                            AxisMarks(values: .automatic) { _ in
                                                AxisGridLine()
                                                AxisTick()
                                                AxisValueLabel(format: .dateTime.day().month())
                                            }
                                        }
                                    } else {
                                        // Fallback for iOS 15
                                        Text("Charts require iOS 16 or later")
                                            .font(AppTextStyles.body3)
                                            .foregroundColor(AppColors.textMedium)
                                            .frame(height: 200)
                                            .frame(maxWidth: .infinity)
                                            .background(AppColors.background)
                                            .cornerRadius(AppLayout.cornerRadius / 2)
                                    }
                                }
                                .padding(.vertical, 8)
                                
                                // Rejection triggers analysis
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Common Rejection Triggers")
                                        .font(AppTextStyles.h4)
                                        .foregroundColor(AppColors.textDark)
                                    
                                    let rejectionEntries = filteredMoodHistory.filter { $0.rejectionTrigger != nil }
                                    
                                    if rejectionEntries.isEmpty {
                                        Text("No rejection-related entries in this time period")
                                            .font(AppTextStyles.body3)
                                            .foregroundColor(AppColors.textMedium)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(AppColors.background)
                                            .cornerRadius(AppLayout.cornerRadius / 2)
                                    } else {
                                        // Count triggers
                                        let triggerCounts = rejectionEntries.reduce(into: [String: Int]()) { counts, entry in
                                            if let trigger = entry.rejectionTrigger {
                                                counts[trigger, default: 0] += 1
                                            }
                                        }
                                        
                                        // Display top triggers
                                        VStack(spacing: 12) {
                                            ForEach(triggerCounts.sorted(by: { $0.value > $1.value }).prefix(3), id: \.key) { trigger, count in
                                                HStack {
                                                    Text(trigger)
                                                        .font(AppTextStyles.body2)
                                                        .foregroundColor(AppColors.textDark)
                                                    
                                                    Spacer()
                                                    
                                                    Text("\(count) time\(count == 1 ? "" : "s")")
                                                        .font(AppTextStyles.body3)
                                                        .foregroundColor(AppColors.textMedium)
                                                }
                                                .padding()
                                                .background(AppColors.background)
                                                .cornerRadius(AppLayout.cornerRadius / 2)
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical, 8)
                                
                                // Coping strategies effectiveness
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Effective Coping Strategies")
                                        .font(AppTextStyles.h4)
                                        .foregroundColor(AppColors.textDark)
                                    
                                    let copingEntries = filteredMoodHistory.filter { $0.copingStrategy != nil }
                                    
                                    if copingEntries.isEmpty {
                                        Text("No coping strategies recorded in this time period")
                                            .font(AppTextStyles.body3)
                                            .foregroundColor(AppColors.textMedium)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(AppColors.background)
                                            .cornerRadius(AppLayout.cornerRadius / 2)
                                    } else {
                                        // Count strategies
                                        let strategyCounts = copingEntries.reduce(into: [String: Int]()) { counts, entry in
                                            if let strategy = entry.copingStrategy {
                                                counts[strategy, default: 0] += 1
                                            }
                                        }
                                        
                                        // Display top strategies
                                        VStack(spacing: 12) {
                                            ForEach(strategyCounts.sorted(by: { $0.value > $1.value }).prefix(3), id: \.key) { strategy, count in
                                                HStack {
                                                    Text(strategy)
                                                        .font(AppTextStyles.body2)
                                                        .foregroundColor(AppColors.textDark)
                                                    
                                                    Spacer()
                                                    
                                                    Text("\(count) time\(count == 1 ? "" : "s")")
                                                        .font(AppTextStyles.body3)
                                                        .foregroundColor(AppColors.textMedium)
                                                }
                                                .padding()
                                                .background(AppColors.background)
                                                .cornerRadius(AppLayout.cornerRadius / 2)
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical, 8)
                                
                                // Insights and recommendations
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Personalized Insights")
                                        .font(AppTextStyles.h4)
                                        .foregroundColor(AppColors.textDark)
                                    
                                    let insight = getPersonalizedInsight()
                                    
                                    Text(insight)
                                        .font(AppTextStyles.body2)
                                        .foregroundColor(AppColors.textMedium)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(AppColors.background)
                                        .cornerRadius(AppLayout.cornerRadius / 2)
                                }
                                .padding(.vertical, 8)
                            }
                            .padding()
                            .background(AppColors.cardBackground)
                            .cornerRadius(AppLayout.cornerRadius)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                            .animation(.easeInOut, value: selectedTimeFrame)
                            .accessibilityCard(label: "Mood insights and charts", hint: "Visual representations of your mood patterns")
                        }
                    }
                    .padding()
                }
            }
            .background(AppColors.background)
            .navigationBarHidden(true)
        }
        .accentColor(AppColors.primary)
    }
    
    // MARK: - Helper Methods
    
    // Filtered mood history based on selected time frame
    private var filteredMoodHistory: [MoodTrackerEntry] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedTimeFrame {
        case .day:
            let startOfDay = calendar.startOfDay(for: now)
            return moodHistory.filter { calendar.isDate($0.date, inSameDayAs: startOfDay) }
        case .week:
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            return moodHistory.filter { $0.date >= startOfWeek }
        case .month:
            let components = calendar.dateComponents([.year, .month], from: now)
            let startOfMonth = calendar.date(from: components)!
            return moodHistory.filter { $0.date >= startOfMonth }
        }
    }
    
    // Mood selection button
    private func moodButton(_ mood: String) -> some View {
        let isSelected = selectedMood == mood
        
        return Button(action: {
            selectedMood = mood
            AppHapticFeedback.light()
        }) {
            VStack {
                Image(systemName: moodIcon(for: mood))
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? .white : moodColor(for: mood))
                    .frame(width: 60, height: 60)
                    .background(
                        isSelected ? moodColor(for: mood) : Color.white
                    )
                    .cornerRadius(30)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                
                Text(mood)
                    .font(AppTextStyles.body3)
                    .foregroundColor(AppColors.textDark)
                    .padding(.top, 4)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(mood)
        .accessibilityHint("Select this mood")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
    
    // Mood history card
    private func moodHistoryCard(_ entry: MoodTrackerEntry) -> some View {
        VStack(alignment: .leading, spacing: 16) {
        HStack(spacing: 16) {
            Image(systemName: moodIcon(for: entry.mood))
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(moodColor(for: entry.mood))
                .cornerRadius(25)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.mood)
                        .font(AppTextStyles.h4)
                        .foregroundColor(AppColors.textDark)
                    
                    Text("(\(entry.intensity)/5)")
                        .font(AppTextStyles.body3)
                        .foregroundColor(AppColors.textLight)
                }
                
                Text(formatDateTime(entry.date))
                    .font(AppTextStyles.body3)
                    .foregroundColor(AppColors.textMedium)
                }
                
                Spacer()
            }
                
                if let note = entry.note, !note.isEmpty {
                    Text(note)
                    .font(AppTextStyles.body3)
                    .foregroundColor(AppColors.textMedium)
                    .padding(.top, 2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if let trigger = entry.rejectionTrigger {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.warning)
                    
                    Text("Rejection trigger: \(trigger)")
                        .font(AppTextStyles.body3)
                        .foregroundColor(AppColors.textMedium)
                }
                .padding(.top, 4)
                }
            
            if let strategy = entry.copingStrategy {
                HStack {
                    Image(systemName: "heart.circle")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.success)
                    
                    Text("Coping strategy: \(strategy)")
                        .font(AppTextStyles.body3)
                        .foregroundColor(AppColors.textMedium)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(AppColors.background)
        .cornerRadius(AppLayout.cornerRadius)
        .padding(.vertical, 4)
        .accessibilityCard(
            label: "\(entry.mood) mood with intensity \(entry.intensity)",
            hint: "Recorded on \(formatDateTime(entry.date))"
        )
    }
    
    // Helper methods
    private func saveMood() {
        guard let selectedMood = selectedMood else { return }
        
        // Create a new entry
        let newEntry = MoodTrackerEntry(
            id: UUID().uuidString,
            date: Date(),
            mood: selectedMood,
            intensity: moodIntensity,
            note: moodNote.isEmpty ? nil : moodNote,
            rejectionTrigger: isRejectionRelated ? (rejectionTrigger.isEmpty ? nil : rejectionTrigger) : nil,
            copingStrategy: isRejectionRelated && !copingStrategy.isEmpty ? copingStrategy : nil
        )
        
        // Add to history
        moodHistory.append(newEntry)
        
        // Reset form
        self.selectedMood = nil
        moodIntensity = 3
        moodNote = ""
        isRejectionRelated = false
        rejectionTrigger = ""
        copingStrategy = ""
        
        // Show a confirmation message
        // In a real app, you would save to a database
    }
    
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func moodIcon(for mood: String) -> String {
        switch mood.lowercased() {
        case "happy": return "face.smiling"
        case "calm": return "cloud.sun"
        case "sad": return "cloud.rain"
        case "anxious": return "wind"
        case "angry": return "flame"
        case "tired": return "moon.zzz"
        default: return "questionmark.circle"
        }
    }
    
    private func moodColor(for mood: String) -> Color {
        switch mood.lowercased() {
        case "happy": return AppColors.joy
        case "calm": return AppColors.calm
        case "sad": return AppColors.sadness
        case "anxious": return AppColors.warning
        case "angry": return AppColors.frustration
        case "tired": return AppColors.textLight
        default: return AppColors.info
        }
    }
    
    private func colorForMood(_ mood: String) -> Color {
        switch mood.lowercased() {
        case "happy": return AppColors.joy
        case "calm": return AppColors.calm
        case "sad": return AppColors.sadness
        case "anxious": return AppColors.warning
        case "angry": return AppColors.frustration
        case "tired": return AppColors.textLight
        default: return AppColors.info
        }
    }
    
    private func getPersonalizedInsight() -> String {
        // In a real app, this would analyze the user's mood patterns
        // and provide tailored insights
        let rejectionEntries = moodHistory.filter { $0.rejectionTrigger != nil }
        
        if rejectionEntries.isEmpty {
            return "No rejection-related entries found yet. Continue tracking to receive personalized insights."
        }
        
        // Simple insight based on most common rejection trigger
        let triggerCounts = rejectionEntries.reduce(into: [String: Int]()) { counts, entry in
            if let trigger = entry.rejectionTrigger {
                counts[trigger, default: 0] += 1
            }
        }
        
        if let topTrigger = triggerCounts.max(by: { $0.value < $1.value })?.key {
            return "You appear to experience rejection most frequently in '\(topTrigger)' situations. Consider preparing coping strategies specifically for these scenarios."
        }
        
        return "Keep tracking your moods to receive more personalized insights about your emotional patterns."
    }
}

// Preview provider
struct MoodView_Previews: PreviewProvider {
    static var previews: some View {
        MoodView()
    }
} 