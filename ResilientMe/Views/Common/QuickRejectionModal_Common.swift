import SwiftUI

struct QuickRejectionModalCommon: View {
    @Binding var isPresented: Bool
    @State private var rejectionDescription: String = ""
    @State private var selectedTrigger: String = "Social media"
    @State private var selectedMood: String = "Anxious"
    @State private var intensity: Int = 3
    
    // Common rejection triggers
    private let rejectionTriggers = [
        "Social media", "Dating app", "Job application", 
        "Friend interaction", "Family interaction", "Work/School"
    ]
    
    // Common moods related to rejection
    private let moods = ["Anxious", "Sad", "Angry", "Frustrated"]
    
    // Callback for when a rejection is saved
    var onSave: ((String, String, String, Int) -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Quick Rejection Capture")
                    .font(AppTextStyles.h3)
                    .foregroundColor(AppColors.textDark)
                
                Spacer()
                
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.textLight)
                        .padding(8)
                        .background(AppColors.background)
                        .clipShape(Circle())
                }
                .accessibilityLabel("Close modal")
            }
            .padding()
            .background(AppColors.cardBackground)
            
            ScrollView {
                VStack(spacing: 16) {
                    // Description field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What happened?")
                            .font(AppTextStyles.h4)
                            .foregroundColor(AppColors.textDark)
                        
                        TextEditor(text: $rejectionDescription)
                            .frame(height: 80)
                            .padding(8)
                            .background(AppColors.background)
                            .cornerRadius(AppLayout.cornerRadius / 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppLayout.cornerRadius / 2)
                                    .stroke(AppColors.textLight.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    
                    // Trigger selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What triggered this experience?")
                            .font(AppTextStyles.h4)
                            .foregroundColor(AppColors.textDark)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(rejectionTriggers, id: \.self) { trigger in
                                    Button(action: {
                                        selectedTrigger = trigger
                                        HapticFeedback.light()
                                    }) {
                                        Text(trigger)
                                            .font(AppTextStyles.body3)
                                            .foregroundColor(selectedTrigger == trigger ? .white : AppColors.textDark)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(
                                                selectedTrigger == trigger ? 
                                                AppColors.primary : 
                                                AppColors.background
                                            )
                                            .cornerRadius(20)
                                    }
                                    .accessibilityLabel("\(trigger) trigger")
                                    .accessibilityAddTraits(selectedTrigger == trigger ? [.isSelected] : [])
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Mood selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How did it make you feel?")
                            .font(AppTextStyles.h4)
                            .foregroundColor(AppColors.textDark)
                        
                        HStack(spacing: 12) {
                            ForEach(moods, id: \.self) { mood in
                                Button(action: {
                                    selectedMood = mood
                                    HapticFeedback.light()
                                }) {
                                    VStack(spacing: 6) {
                                        Image(systemName: moodIcon(for: mood))
                                            .font(.system(size: 20))
                                            .foregroundColor(selectedMood == mood ? .white : moodColor(for: mood))
                                            .frame(width: 40, height: 40)
                                            .background(
                                                selectedMood == mood ? moodColor(for: mood) : Color.white
                                            )
                                            .cornerRadius(20)
                                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                                        
                                        Text(mood)
                                            .font(AppTextStyles.body3)
                                            .foregroundColor(AppColors.textDark)
                                    }
                                }
                                .accessibilityLabel("\(mood) mood")
                                .accessibilityAddTraits(selectedMood == mood ? [.isSelected] : [])
                            }
                        }
                        .padding(.vertical, 8)
                        
                        // Intensity slider
                        VStack(spacing: 4) {
                            Text("How intense was this feeling? (\(intensity))")
                                .font(AppTextStyles.body3)
                                .foregroundColor(AppColors.textMedium)
                            
                            Slider(value: Binding(
                                get: { Double(intensity) },
                                set: { intensity = Int($0) }
                            ), in: 1...5, step: 1)
                            .accentColor(AppColors.primary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Action buttons
                    HStack(spacing: 16) {
                        Button(action: {
                            isPresented = false
                        }) {
                            Text("Cancel")
                                .font(AppTextStyles.button)
                                .foregroundColor(AppColors.textDark)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.background)
                                .cornerRadius(AppLayout.cornerRadius)
                        }
                        
                        Button(action: {
                            saveRejection()
                        }) {
                            Text("Save")
                                .font(AppTextStyles.button)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.primary)
                                .cornerRadius(AppLayout.cornerRadius)
                        }
                        .disabled(rejectionDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity(rejectionDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
                    }
                    .padding()
                }
                .padding(.vertical)
            }
        }
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        .frame(maxWidth: 500)
        .padding(.horizontal)
    }
    
    private func saveRejection() {
        HapticFeedback.success()
        
        // Call the onSave callback with the rejection details
        onSave?(
            rejectionDescription,
            selectedTrigger,
            selectedMood,
            intensity
        )
        
        // Dismiss the modal
        isPresented = false
    }
    
    private func moodIcon(for mood: String) -> String {
        switch mood.lowercased() {
        case "anxious": return "wind"
        case "sad": return "cloud.rain"
        case "angry": return "flame"
        case "frustrated": return "exclamationmark.triangle"
        default: return "questionmark.circle"
        }
    }
    
    private func moodColor(for mood: String) -> Color {
        switch mood.lowercased() {
        case "anxious": return AppColors.warning
        case "sad": return AppColors.sadness
        case "angry": return AppColors.frustration
        case "frustrated": return AppColors.error
        default: return AppColors.info
        }
    }
}

// MARK: - Preview
struct QuickRejectionModalCommon_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.opacity(0.3)
                .ignoresSafeArea()
            
            QuickRejectionModalCommon(
                isPresented: .constant(true),
                onSave: { _, _, _, _ in }
            )
        }
    }
} 