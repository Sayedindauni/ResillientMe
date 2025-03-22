import SwiftUI

struct ForumPost: Identifiable {
    let id: String
    let author: String
    let title: String
    let content: String
    let date: Date
    let likes: Int
    let comments: Int
    let tags: [String]
}

struct CommunityView: View {
    @State private var selectedForum: String = "Anxiety"
    @State private var searchText: String = ""
    
    private let forums = ["Anxiety", "Depression", "Stress", "Relationships", "Work", "Self-Care"]
    
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
            tags: ["success", "anxiety", "work"]
        ),
        ForumPost(
            id: "2", 
            author: "Taylor", 
            title: "Mindfulness techniques that actually work", 
            content: "I've tried many different approaches to mindfulness over the years. These are the three techniques that have consistently helped my anxiety...", 
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), 
            likes: 56, 
            comments: 15,
            tags: ["mindfulness", "anxiety", "tips"]
        ),
        ForumPost(
            id: "3", 
            author: "Jordan", 
            title: "Need advice: How to set boundaries with family", 
            content: "I struggle with setting healthy boundaries with my parents. They often trigger my anxiety. Has anyone successfully navigated this?", 
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(), 
            likes: 32, 
            comments: 27,
            tags: ["family", "boundaries", "help"]
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Community")
                        .font(AppTextStyles.h1)
                        .foregroundColor(AppColors.textDark)
                    
                    Spacer()
                    
                    Button(action: {
                        // Create new post
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(AppColors.primary)
                            .cornerRadius(18)
                    }
                }
                .padding()
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppColors.textLight)
                    
                    TextField("Search community...", text: $searchText)
                        .font(AppTextStyles.body3)
                }
                .padding()
                .background(AppColors.background)
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
                        ForEach(forumPosts) { post in
                            forumPostCard(post)
                                .onTapGesture {
                                    // Navigate to post detail
                                }
                        }
                    }
                    .padding()
                }
            }
            .background(AppColors.background)
            .ignoresSafeArea(edges: .all)
            .navigationBarHidden(true)
        }
    }
    
    // Category button
    private func categoryButton(_ forum: String) -> some View {
        let isSelected = selectedForum == forum
        
        return Button(action: {
            selectedForum = forum
        }) {
            Text(forum)
                .font(AppTextStyles.body3)
                .foregroundColor(isSelected ? .white : AppColors.textDark)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ? AppColors.primary : AppColors.cardBackground
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
                    .fill(AppColors.primary.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(post.author.prefix(1)))
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AppColors.primary)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.author)
                        .font(AppTextStyles.h4)
                        .foregroundColor(AppColors.textDark)
                    
                    Text(timeAgo(from: post.date))
                        .font(AppTextStyles.body3)
                        .foregroundColor(AppColors.textLight)
                }
                
                Spacer()
                
                Button(action: {
                    // More options
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(AppColors.textLight)
                }
            }
            
            // Title and content
            Text(post.title)
                .font(AppTextStyles.h3)
                .foregroundColor(AppColors.textDark)
                .lineLimit(2)
            
            Text(post.content)
                .font(AppTextStyles.body3)
                .foregroundColor(AppColors.textMedium)
                .lineLimit(3)
                .padding(.bottom, 4)
            
            // Tags
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(post.tags, id: \.self) { tag in
                        Text("#\(tag)")
                            .font(AppTextStyles.body3)
                            .foregroundColor(AppColors.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppColors.primary.opacity(0.1))
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
                            .font(.system(size: 16))
                        Text("\(post.likes)")
                            .font(AppTextStyles.body3)
                    }
                    .foregroundColor(AppColors.textLight)
                }
                
                Spacer()
                
                Button(action: {
                    // View comments
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 16))
                        Text("\(post.comments)")
                            .font(AppTextStyles.body3)
                    }
                    .foregroundColor(AppColors.textLight)
                }
                
                Spacer()
                
                Button(action: {
                    // Share post
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16))
                    }
                    .foregroundColor(AppColors.textLight)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
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
}

struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView()
    }
} 