import SwiftUI
import Foundation

// Clean up imports/typealias declarations to avoid redeclarations
// Don't use conditional imports for modules that should be in the same project
#if !canImport(GlobalCopingStrategiesLibrary)
// Only define this if it's not already defined elsewhere
public typealias GlobalCopingStrategiesLibrary = AppCopingStrategiesLibrary
#endif

// Add this import to access LocalCopingStrategyDetail from the right place
// Since this might be in a different module or file structure, use conditional import
#if canImport(CopingStrategiesLibraryView)
import CopingStrategiesLibraryView
#endif

// Import necessary types without creating conflicts

struct ForumPost: Identifiable {
    let id: String
    let author: String
    let title: String
    let content: String
    let date: Date
    let likes: Int
    let comments: Int
    let tags: [String]
    let sharedStrategy: AppCopingStrategyDetail?
}

// New struct for sharing strategies
struct StrategyShareView: View {
    let strategy: AppCopingStrategyDetail
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var tags: [String] = []
    @Environment(\.presentationMode) var presentationMode
    @State private var isShowingSuccessAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Strategy card
                    VStack(alignment: .leading, spacing: 12) {
                        Text(strategy.title)
                            .font(AppTextStyles.h3)
                            .foregroundColor(Color(AppColors.textDark))
                        
                        Text(strategy.description)
                            .font(AppTextStyles.body2)
                            .foregroundColor(Color(AppColors.textMedium))
                        
                        HStack {
                            let categoryText = strategy.category.rawValue
                            let intensityColorOpacity = strategy.intensity.color.opacity(0.1)
                            let intensityColor = strategy.intensity.color
                            
                            Text(categoryText)
                                .font(Font.system(size: 12, weight: .regular))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(intensityColorOpacity))
                                .foregroundColor(Color(intensityColor))
                                .cornerRadius(8)
                            
                            Spacer()
                            
                            Text(strategy.timeToComplete)
                                .font(Font.system(size: 12, weight: .regular))
                                .foregroundColor(Color(AppColors.textMedium))
                        }
                    }
                    .padding()
                    .background(Color(AppColors.cardBackground))
                    .cornerRadius(AppLayout.cornerRadius)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                    
                    // Share form
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Share with Community")
                            .font(AppTextStyles.h3)
                            .foregroundColor(Color(AppColors.textDark))
                        
                        TextField("Title", text: $title)
                            .font(AppTextStyles.body2)
                            .padding()
                            .background(Color(AppColors.cardBackground))
                            .cornerRadius(AppLayout.cornerRadius)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                        
                        TextEditor(text: $content)
                            .font(AppTextStyles.body2)
                            .padding()
                            .frame(height: 150)
                            .background(Color(AppColors.cardBackground))
                            .cornerRadius(AppLayout.cornerRadius)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                            .overlay(
                                Group {
                                    if content.isEmpty {
                                        Text("Share your experience with this strategy...")
                                            .font(AppTextStyles.body2)
                                            .foregroundColor(Color(AppColors.textLight))
                                            .padding()
                                            .allowsHitTesting(false)
                                    }
                                }
                            )
                        
                        // Tags
                        Text("Tags")
                            .font(AppTextStyles.h4)
                            .foregroundColor(Color(AppColors.textDark))
                        
                        // Default tags based on strategy
                        HStack {
                            ForEach([strategy.category.rawValue.lowercased(), strategy.intensity.rawValue.lowercased(), "strategy"], id: \.self) { tag in
                                Button(action: {
                                    if tags.contains(tag) {
                                        tags.removeAll { $0 == tag }
                                    } else {
                                        tags.append(tag)
                                    }
                                }) {
                                    Text("#\(tag)")
                                        .font(AppTextStyles.body3)
                                        .foregroundColor(tags.contains(tag) ? Color.white : Color(AppColors.primary))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(tags.contains(tag) ? Color(AppColors.primary) : Color(AppColors.primary.opacity(0.1)))
                                        .cornerRadius(12)
                                }
                            }
                        }
                        
                        Button(action: {
                            // Here we would actually post to the community
                            isShowingSuccessAlert = true
                        }) {
                            Text("Share with Community")
                                .font(AppTextStyles.buttonFont)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(AppColors.primary))
                                .cornerRadius(AppLayout.cornerRadius)
                        }
                    }
                }
                .padding()
            }
            .background(Color(AppColors.background))
            .navigationTitle("Share Strategy")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $isShowingSuccessAlert) {
                Alert(
                    title: Text("Strategy Shared"),
                    message: Text("Your strategy has been shared with the community!"),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// Challenge Detail View
struct ChallengeDetailView: View {
    let challenge: CommunityChallenges.Challenge
    @ObservedObject private var challengesModel = CommunityChallenges.shared
    @State private var showingStrategyPicker = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(challenge.title)
                        .font(AppTextStyles.h2)
                        .foregroundColor(Color(AppColors.textDark))
                    
                    Text(challenge.description)
                        .font(AppTextStyles.body2)
                        .foregroundColor(Color(AppColors.textMedium))
                        .padding(.bottom, 8)
                    
                    // Challenge status/metadata
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("PARTICIPANTS")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(AppColors.textLight))
                            
                            Text("\(challenge.participants)")
                                .font(AppTextStyles.h3)
                                .foregroundColor(Color(AppColors.primary))
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("TIME LEFT")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(AppColors.textLight))
                            
                            Text("\(challengesModel.getDaysRemaining(for: challenge)) days")
                                .font(AppTextStyles.h3)
                                .foregroundColor(Color(AppColors.primary))
                        }
                    }
                }
                .padding()
                .background(Color(AppColors.cardBackground))
                .cornerRadius(AppLayout.cornerRadius)
                
                // Participation button
                Button(action: {
                    if challenge.userParticipating {
                        challengesModel.leaveChallenge(id: challenge.id)
                    } else {
                        if challenge.title.contains("Share Your Go-To") {
                            showingStrategyPicker = true
                        } else {
                            challengesModel.joinChallenge(id: challenge.id)
                        }
                    }
                }) {
                    Text(challenge.userParticipating ? "Leave Challenge" : "Join Challenge")
                        .font(AppTextStyles.buttonFont)
                        .foregroundColor(challenge.userParticipating ? Color(AppColors.textDark) : Color.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(challenge.userParticipating ? Color.gray.opacity(0.1) : Color(AppColors.primary))
                        .cornerRadius(AppLayout.cornerRadius)
                }
                
                // If strategy sharing challenge
                if challenge.title.contains("Strategy") {
                    // Strategy sharing section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Shared Strategies")
                            .font(AppTextStyles.h3)
                            .foregroundColor(Color(AppColors.textDark))
                        
                        ForEach(0..<3) { i in
                            let mockUser = ["Alex", "Jordan", "Sam"][i % 3]
                            let mockStrategy = GlobalCopingStrategiesLibrary.shared.strategies[i % GlobalCopingStrategiesLibrary.shared.strategies.count]
                            
                            HStack(alignment: .top, spacing: 12) {
                                // User avatar
                                Circle()
                                    .fill(Color(AppColors.primary.opacity(0.2)))
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Text(String(mockUser.prefix(1)))
                                            .font(Font.system(size: 16, weight: .medium))
                                            .foregroundColor(Color(AppColors.primary))
                                    )
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(mockUser)
                                        .font(AppTextStyles.h4)
                                        .foregroundColor(Color(AppColors.textDark))
                                    
                                    Text(mockStrategy.title)
                                        .font(AppTextStyles.body3)
                                        .foregroundColor(Color(AppColors.textDark))
                                    
                                    Text(mockStrategy.description.prefix(80) + "...")
                                        .font(AppTextStyles.body3)
                                        .foregroundColor(Color(AppColors.textMedium))
                                }
                            }
                            .padding()
                            .background(Color(AppColors.cardBackground))
                            .cornerRadius(AppLayout.cornerRadius)
                        }
                        
                        if challenge.userParticipating {
                            Button(action: {
                                showingStrategyPicker = true
                            }) {
                                Text("Share Your Strategy")
                                    .font(AppTextStyles.buttonFont)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(AppColors.primary))
                                    .cornerRadius(AppLayout.cornerRadius)
                            }
                        }
                    }
                    .padding()
                    .background(Color(AppColors.background.opacity(0.5)))
                    .cornerRadius(AppLayout.cornerRadius)
                }
                
                // If mindfulness challenge
                if challenge.title.contains("Mindfulness") {
                    // Progress section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Progress")
                            .font(AppTextStyles.h3)
                            .foregroundColor(Color(AppColors.textDark))
                        
                        // Progress bar
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Days completed")
                                    .font(AppTextStyles.body3)
                                    .foregroundColor(Color(AppColors.textMedium))
                                
                                Spacer()
                                
                                Text(challenge.userParticipating ? "2/7" : "0/7")
                                    .font(AppTextStyles.body3)
                                    .foregroundColor(Color(AppColors.textDark))
                            }
                            
                            // Progress bar
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: geometry.size.width, height: 8)
                                        .cornerRadius(4)
                                    
                                    Rectangle()
                                        .fill(Color(AppColors.primary))
                                        .frame(width: challenge.userParticipating ? geometry.size.width * 0.28 : 0, height: 8)
                                        .cornerRadius(4)
                                }
                            }
                            .frame(height: 8)
                        }
                        
                        // Day trackers
                        HStack {
                            ForEach(1...7, id: \.self) { day in
                                VStack {
                                    Circle()
                                        .fill(challenge.userParticipating && day <= 2 ? Color(AppColors.primary) : Color.gray.opacity(0.2))
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Text("\(day)")
                                                .font(Font.system(size: 14, weight: .medium))
                                                .foregroundColor(challenge.userParticipating && day <= 2 ? Color.white : Color(AppColors.textMedium))
                                        )
                                    
                                    Text("Day \(day)")
                                        .font(Font.system(size: 12))
                                        .foregroundColor(Color(AppColors.textLight))
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(AppColors.background.opacity(0.5)))
                    .cornerRadius(AppLayout.cornerRadius)
                }
            }
            .padding()
        }
        .background(Color(AppColors.background))
        .navigationTitle("Challenge Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingStrategyPicker) {
            // Strategy picker
            strategySelectorSheet
        }
    }
    
    private var strategySelectorSheet: some View {
        NavigationView {
            StrategySelectorContent(
                showingPicker: $showingStrategyPicker,
                challenge: challenge,
                challengesModel: challengesModel
            )
        }
    }
    
    private struct StrategySelectorContent: View {
        @Binding var showingPicker: Bool
        let challenge: CommunityChallenges.Challenge
        let challengesModel: CommunityChallenges
        
        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Select a Strategy to Share")
                        .font(AppTextStyles.h2)
                        .foregroundColor(Color(AppColors.textDark))
                        .padding(.horizontal)
                    
                    strategyButtonsList
                }
                .padding(.vertical)
            }
            .background(Color(AppColors.background))
            .navigationTitle("Select Strategy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingPicker = false
                    }
                }
            }
        }
        
        private var strategyButtonsList: some View {
            VStack(spacing: 12) {
                // Use a typealias to help break down the types
                let strategies = GlobalCopingStrategiesLibrary.shared.strategies.prefix(3)
                
                ForEach(Array(strategies), id: \.id) { strategy in
                    strategyButton(for: strategy)
                }
            }
        }
        
        private func strategyButton(for strategy: AppCopingStrategyDetail) -> some View {
            Button(action: {
                // Select this strategy and share
                challengesModel.joinChallenge(id: challenge.id)
                showingPicker = false
            }) {
                strategySummaryRow(strategy)
            }
        }
        
        private func strategySummaryRow(_ strategy: AppCopingStrategyDetail) -> some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(strategy.title)
                    .font(AppTextStyles.h3)
                    .foregroundColor(Color(AppColors.textDark))
                
                Text(strategy.description)
                    .font(AppTextStyles.body3)
                    .foregroundColor(Color(AppColors.textMedium))
                    .lineLimit(2)
                
                HStack {
                    Text(strategy.category.rawValue)
                        .font(Font.system(size: 12, weight: .regular))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(strategy.intensity.color.opacity(0.1)))
                        .foregroundColor(Color(strategy.intensity.color))
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color(AppColors.textLight))
                }
            }
            .padding()
            .background(Color(AppColors.cardBackground))
            .cornerRadius(AppLayout.cornerRadius)
            .padding(.horizontal)
        }
    }
}

// All Challenges View
struct AllChallengesView: View {
    @ObservedObject private var challengesModel = CommunityChallenges.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Community Challenges")
                            .font(AppTextStyles.h1)
                            .foregroundColor(Color(AppColors.textDark))
                        
                        Text("Join challenges to build resilience together")
                            .font(AppTextStyles.body2)
                            .foregroundColor(Color(AppColors.textMedium))
                    }
                    .padding(.horizontal)
                    
                    // Active challenges
                    VStack(alignment: .leading, spacing: 16) {
                        Text("ACTIVE CHALLENGES")
                            .font(Font.system(size: 14, weight: .medium))
                            .foregroundColor(Color(AppColors.textLight))
                            .padding(.horizontal)
                        
                        ForEach(challengesModel.activeChallenges) { challenge in
                            NavigationLink(destination: ChallengeDetailView(challenge: challenge)) {
                                challengeCard(challenge: challenge)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    // Past challenges
                    if !challengesModel.pastChallenges.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("PAST CHALLENGES")
                                .font(Font.system(size: 14, weight: .medium))
                                .foregroundColor(Color(AppColors.textLight))
                                .padding(.horizontal)
                            
                            ForEach(challengesModel.pastChallenges) { challenge in
                                NavigationLink(destination: ChallengeDetailView(challenge: challenge)) {
                                    challengeCard(challenge: challenge, isPast: true)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color(AppColors.background))
            .navigationBarHidden(true)
        }
    }
    
    private func challengeCard(challenge: CommunityChallenges.Challenge, isPast: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Challenge type & days remaining
            HStack {
                Text(challenge.category.uppercased())
                    .font(Font.system(size: 12, weight: .medium))
                    .foregroundColor(Color(AppColors.primary))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(AppColors.primary.opacity(0.1)))
                    .cornerRadius(12)
                
                Spacer()
                
                if isPast {
                    Text("COMPLETED")
                        .font(Font.system(size: 12, weight: .medium))
                        .foregroundColor(challenge.completed ? Color.green : Color(AppColors.textLight))
                } else {
                    Text("\(challengesModel.getDaysRemaining(for: challenge)) DAYS LEFT")
                        .font(Font.system(size: 12, weight: .medium))
                        .foregroundColor(Color(AppColors.textDark))
                }
            }
            
            // Challenge title
            Text(challenge.title)
                .font(AppTextStyles.h3)
                .foregroundColor(Color(AppColors.textDark))
            
            // Challenge description
            Text(challenge.description)
                .font(AppTextStyles.body3)
                .foregroundColor(Color(AppColors.textMedium))
                .lineLimit(2)
            
            // Participants
            HStack {
                Image(systemName: "person.3.fill")
                    .foregroundColor(Color(AppColors.textLight))
                
                Text("\(challenge.participants) participants")
                    .font(AppTextStyles.body3)
                    .foregroundColor(Color(AppColors.textLight))
                
                Spacer()
                
                if challenge.userParticipating {
                    Text("You're participating")
                        .font(AppTextStyles.body3)
                        .foregroundColor(Color(AppColors.primary))
                }
            }
        }
        .padding()
        .background(Color(AppColors.cardBackground))
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct CommunityView: View {
    @State private var selectedForum: String = "Anxiety"
    @State private var searchText: String = ""
    @State private var showingStrategyShare = false
    @State private var strategyToShare: AppCopingStrategyDetail?
    @State private var showingAllChallenges = false
    @ObservedObject private var challengesModel = CommunityChallenges.shared
    
    private let forums = ["Anxiety", "Depression", "Stress", "Relationships", "Work", "Self-Care", "Strategies"]
    
    // Mock forum posts
    private let forumPosts: [ForumPost] = [
        ForumPost(
            id: "1", 
            author: "Alex", 
            title: "Handled rejection without spiraling", 
            content: "For the first time, I was able to receive a job rejection without it causing a serious anxiety spiral. Here's what helped me...", 
            date: Calendar.current.date(byAdding: .hour, value: -3, to: Date()) ?? Date(), 
            likes: 24, 
            comments: 8,
            tags: ["success", "anxiety", "work"],
            sharedStrategy: nil as AppCopingStrategyDetail?
        ),
        ForumPost(
            id: "2", 
            author: "Taylor", 
            title: "Mindfulness techniques that actually work", 
            content: "I've tried many different approaches to mindfulness over the years. These are the three techniques that have consistently helped my anxiety...", 
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), 
            likes: 56, 
            comments: 15,
            tags: ["mindfulness", "anxiety", "tips"],
            sharedStrategy: nil as AppCopingStrategyDetail?
        ),
        ForumPost(
            id: "3", 
            author: "Jordan", 
            title: "Need advice: How to set boundaries with family", 
            content: "I struggle with setting healthy boundaries with my parents. They often trigger my anxiety. Has anyone successfully navigated this?", 
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(), 
            likes: 32, 
            comments: 27,
            tags: ["family", "boundaries", "help"],
            sharedStrategy: nil as AppCopingStrategyDetail?
        ),
        ForumPost(
            id: "4", 
            author: "Sam", 
            title: "This breathing technique changed everything", 
            content: "I wanted to share this breathing strategy that helped me overcome a panic attack during a job interview. It's simple but effective!", 
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), 
            likes: 45, 
            comments: 12,
            tags: ["strategy", "anxiety", "breathing"],
            sharedStrategy: GlobalCopingStrategiesLibrary.shared.strategies.first(where: { $0.id == "mind1" })
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Community")
                        .font(AppTextStyles.h1)
                        .foregroundColor(Color(AppColors.textDark))
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            showingAllChallenges = true
                        }) {
                            Image(systemName: "trophy.fill")
                                .font(Font.system(size: 18, weight: .medium))
                                .foregroundColor(Color(AppColors.primary))
                                .frame(width: 36, height: 36)
                                .background(Color(AppColors.primary.opacity(0.1)))
                                .cornerRadius(18)
                        }
                        
                        Button(action: {
                            // Create new post
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(Color(AppColors.primary))
                                .cornerRadius(18)
                        }
                    }
                }
                .padding()
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color(AppColors.textLight))
                    
                    TextField("Search community...", text: $searchText)
                        .font(AppTextStyles.body3)
                }
                .padding()
                .background(Color(AppColors.background))
                .cornerRadius(AppLayout.cornerRadius)
                .padding(.horizontal)
                
                // Categories horizontal scroll
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(forums, id: \.self) { forum in
                            categoryButton(forum)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                
                // Posts
                ScrollView {
                    VStack(spacing: AppLayout.spacing) {
                        // Challenge Banner - only show when "Strategies" is selected
                        if selectedForum == "Strategies" {
                            communityChallengeCard
                        }
                        
                        // Filtered posts based on selected forum
                        let filteredPosts = selectedForum == "Strategies" 
                            ? forumPosts.filter { $0.sharedStrategy != nil }
                            : forumPosts.filter { $0.tags.contains(selectedForum.lowercased()) || selectedForum == "Anxiety" }
                        
                        ForEach(filteredPosts) { post in
                            forumPostCard(post)
                                .onTapGesture {
                                    // Navigate to post detail
                                }
                        }
                    }
                    .padding()
                }
            }
            .background(Color(AppColors.background))
            .ignoresSafeArea(edges: .all)
            .navigationBarHidden(true)
            .sheet(isPresented: $showingStrategyShare) {
                if let strategy = strategyToShare {
                    StrategyShareView(strategy: strategy)
                }
            }
            .sheet(isPresented: $showingAllChallenges) {
                AllChallengesView()
            }
        }
    }
    
    // Community Challenge Banner
    private var communityChallengeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(Color(AppColors.primary))
                
                Text("COMMUNITY CHALLENGE")
                    .font(Font.system(size: 14, weight: .bold))
                    .foregroundColor(Color(AppColors.primary))
                
                Spacer()
                
                Text("3 DAYS LEFT")
                    .font(Font.system(size: 12, weight: .medium))
                    .foregroundColor(Color(AppColors.primary))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(AppColors.primary.opacity(0.1)))
                    .cornerRadius(12)
            }
            
            Text("Share Your Go-To Anxiety Strategy")
                .font(AppTextStyles.h3)
                .foregroundColor(Color(AppColors.textDark))
            
            Text("Join 42 members who have shared their favorite strategies for managing anxiety this week.")
                .font(AppTextStyles.body3)
                .foregroundColor(Color(AppColors.textMedium))
            
            Button(action: {
                // Select a strategy to share
                let strategies = GlobalCopingStrategiesLibrary.shared.strategies
                if let strategy = strategies.filter({ $0.category == .mindfulness }).first {
                    strategyToShare = strategy as? AppCopingStrategyDetail
                    showingStrategyShare = true
                }
            }) {
                Text("Share Your Strategy")
                    .font(AppTextStyles.buttonFont)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(AppColors.primary))
                    .cornerRadius(AppLayout.cornerRadius)
            }
        }
        .padding()
        .background(Color(AppColors.cardBackground))
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
    
    // Category button
    private func categoryButton(_ forum: String) -> some View {
        let isSelected = selectedForum == forum
        
        return Button(action: {
            selectedForum = forum
        }) {
            Text(forum)
                .font(AppTextStyles.body3)
                .foregroundColor(isSelected ? Color.white : Color(AppColors.textDark))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ? Color(AppColors.primary) : Color(AppColors.cardBackground)
                )
                .cornerRadius(AppLayout.cornerRadius)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
    
    // Forum post card
    private func forumPostCard(_ post: ForumPost) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Author and date
            HStack {
                Circle()
                    .fill(Color(AppColors.primary.opacity(0.2)))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(post.author.prefix(1)))
                            .font(Font.system(size: 16, weight: .medium))
                            .foregroundColor(Color(AppColors.primary))
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.author)
                        .font(AppTextStyles.h4)
                        .foregroundColor(Color(AppColors.textDark))
                    
                    Text(timeAgo(from: post.date))
                        .font(AppTextStyles.body3)
                        .foregroundColor(Color(AppColors.textLight))
                }
                
                Spacer()
                
                Button(action: {
                    // More options
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(Color(AppColors.textLight))
                }
            }
            
            // Title and content
            Text(post.title)
                .font(AppTextStyles.h3)
                .foregroundColor(Color(AppColors.textDark))
                .lineLimit(2)
            
            Text(post.content)
                .font(AppTextStyles.body3)
                .foregroundColor(Color(AppColors.textMedium))
                .lineLimit(3)
                .padding(.bottom, 4)
                
            // Shared strategy card (if any)
            if let strategy = post.sharedStrategy {
                sharedStrategyView(strategy)
            }
            
            // Tags
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(post.tags, id: \.self) { tag in
                        Text("#\(tag)")
                            .font(AppTextStyles.body3)
                            .foregroundColor(Color(AppColors.primary))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(AppColors.primary.opacity(0.1)))
                            .cornerRadius(12)
                    }
                }
            }
            .padding(.bottom, 4)
            
            // Likes and comments
            HStack {
                Button(action: {
                    // Like post
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "heart")
                            .font(Font.system(size: 16))
                        Text("\(post.likes)")
                            .font(AppTextStyles.body3)
                    }
                    .foregroundColor(Color(AppColors.textLight))
                }
                
                Spacer()
                
                Button(action: {
                    // View comments
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                            .font(Font.system(size: 16))
                        Text("\(post.comments)")
                            .font(AppTextStyles.body3)
                    }
                    .foregroundColor(Color(AppColors.textLight))
                }
                
                Spacer()
                
                Button(action: {
                    // Share post
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                            .font(Font.system(size: 16))
                    }
                    .foregroundColor(Color(AppColors.textLight))
                }
            }
        }
        .padding()
        .background(Color(AppColors.cardBackground))
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
    
    // Shared strategy view
    private func sharedStrategyView(_ strategy: AppCopingStrategyDetail) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "hands.sparkles.fill")
                    .foregroundColor(Color(strategy.intensity.color))
                
                Text("Shared Strategy")
                    .font(Font.system(size: 12, weight: .medium))
                    .foregroundColor(Color(strategy.intensity.color))
                
                Spacer()
                
                Text(strategy.timeToComplete)
                    .font(Font.system(size: 12))
                    .foregroundColor(Color(AppColors.textLight))
            }
            
            Text(strategy.title)
                .font(AppTextStyles.h4)
                .foregroundColor(Color(AppColors.textDark))
            
            Button(action: {
                // Try this strategy
                strategyToShare = strategy
                showingStrategyShare = true
            }) {
                Text("Try This")
                    .font(Font.system(size: 14, weight: .medium))
                    .foregroundColor(Color(AppColors.primary))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(AppColors.primary.opacity(0.1)))
                    .cornerRadius(16)
            }
        }
        .padding()
        .background(Color(AppColors.background.opacity(0.5)))
        .cornerRadius(AppLayout.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                .stroke(Color(strategy.intensity.color.opacity(0.3)), lineWidth: 1)
        )
    }
    
    // Helper functions
    private func timeAgo(from date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day], from: date, to: now)
        
        if let day = components.day, day > 0 {
            return day == 1 ? "Yesterday" : "\(day) days ago"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour) hour\(hour == 1 ? "" : "s") ago"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute) minute\(minute == 1 ? "" : "s") ago"
        } else {
            return "Just now"
        }
    }
    
    // Simplified version of shareLocalStrategy to avoid ambiguity with type references
    func shareLocalStrategy(_ localStrategy: Any) {
        if let convertedStrategy = localStrategy as? AppCopingStrategyDetail {
            // Direct assignment if it's already AppCopingStrategyDetail
            strategyToShare = convertedStrategy
            showingStrategyShare = true
        }
        // If we need to handle CopingStrategiesLibraryView.LocalCopingStrategyDetail,
        // we can add that case here if needed
    }
}

struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView()
    }
} 