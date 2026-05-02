import SwiftUI
import SwiftData

/// Interactive mood check-in flow inspired by wellness apps.
/// Full-screen purple/lavender themed with smooth page transitions.
/// Features: day rating slider with animated face, emotion picker, optional note.
struct MoodCheckInView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentPage = 0
    @State private var dayRating: Double = 0.5
    @State private var selectedEmotion: String? = nil
    @State private var noteText: String = ""
    @State private var isAppeared = false
    
    // Determine time of day for the greeting
    private var timeOfDay: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12: return "morning"
        case 12..<17: return "afternoon"
        default: return "night"
        }
    }
    
    private var greetingQuestion: String {
        switch timeOfDay {
        case "morning": return "How are you\nfeeling this morning?"
        case "afternoon": return "How's your\nafternoon going?"
        default: return "How was\nyour day today?"
        }
    }
    
    // MARK: - Emotion Options
    
    private let emotions: [(name: String, icon: String, label: String)] = [
        ("happy", "hand.thumbsup.fill", "Happy"),
        ("good", "hand.raised.fill", "Good"),
        ("calm", "leaf.fill", "Calm"),
        ("stressed", "flame.fill", "Stressed"),
        ("sad", "cloud.rain.fill", "Sad"),
        ("angry", "bolt.fill", "Angry"),
        ("anxious", "wind", "Anxious"),
        ("tired", "moon.zzz.fill", "Tired"),
        ("excited", "star.fill", "Excited"),
    ]
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Full-screen lavender/purple gradient background
            backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar with avatar and close
                topBar
                
                // Page content
                TabView(selection: $currentPage) {
                    // Page 1: Rate your day slider
                    dayRatingPage
                        .tag(0)
                    
                    // Page 2: How did you feel?
                    emotionPickerPage
                        .tag(1)
                    
                    // Page 3: Optional note
                    notePage
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(DesignSystem.Animations.defaultSpring, value: currentPage)
                
                // Page dots + navigation
                bottomControls
            }
        }
        .opacity(isAppeared ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                isAppeared = true
            }
        }
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(hue: 0.72, saturation: 0.35, brightness: 0.85),  // Lavender
                Color(hue: 0.75, saturation: 0.30, brightness: 0.78),  // Deeper purple
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Top Bar
    
    private var topBar: some View {
        HStack {
            // Cute avatar face
            ZStack {
                Circle()
                    .fill(.white)
                    .frame(width: 44, height: 44)
                
                Text(avatarFace)
                    .font(.system(size: 20))
            }
            
            Spacer()
            
            // Close button
            Button {
                withAnimation(.easeOut(duration: 0.2)) {
                    isAppeared = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    dismiss()
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(.white.opacity(0.15)))
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.top, DesignSystem.Spacing.md)
    }
    
    /// Dynamic avatar face based on current rating
    private var avatarFace: String {
        switch dayRating {
        case 0.8...: return "😄"
        case 0.6..<0.8: return "😊"
        case 0.4..<0.6: return "😐"
        case 0.2..<0.4: return "😔"
        default: return "😢"
        }
    }
    
    // MARK: - Page 1: Day Rating
    
    private var dayRatingPage: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()
            
            // Question
            Text(greetingQuestion)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DesignSystem.Spacing.lg)
            
            Spacer()
            
            // Large animated face
            Text(ratingFace)
                .font(.system(size: 80))
                .animation(DesignSystem.Animations.defaultSpring, value: dayRating)
            
            // Rating label
            Text(ratingLabel)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
                .animation(DesignSystem.Animations.quickFade, value: dayRating)
            
            Spacer()
            
            // Slider
            VStack(spacing: DesignSystem.Spacing.sm) {
                Slider(value: $dayRating, in: 0...1)
                    .tint(.white)
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                
                HStack {
                    Text("REALLY TERRIBLE")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                    Spacer()
                    Text("AMAZING")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
            }
            
            Spacer()
        }
    }
    
    private var ratingFace: String {
        switch dayRating {
        case 0.85...: return "🤩"
        case 0.7..<0.85: return "😊"
        case 0.55..<0.7: return "🙂"
        case 0.45..<0.55: return "😐"
        case 0.3..<0.45: return "😕"
        case 0.15..<0.3: return "😔"
        default: return "😢"
        }
    }
    
    private var ratingLabel: String {
        switch dayRating {
        case 0.85...: return "Amazing!"
        case 0.7..<0.85: return "Pretty Good"
        case 0.55..<0.7: return "Good"
        case 0.45..<0.55: return "Okay"
        case 0.3..<0.45: return "Not Great"
        case 0.15..<0.3: return "Bad"
        default: return "Really Terrible"
        }
    }
    
    // MARK: - Page 2: Emotion Picker
    
    private var emotionPickerPage: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()
            
            Text("How did you feel\nthroughout the day?")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DesignSystem.Spacing.lg)
            
            Spacer()
            
            // Emotion grid (3x3)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 20) {
                ForEach(emotions, id: \.name) { emotion in
                    emotionButton(emotion)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            
            Spacer()
            Spacer()
        }
    }
    
    private func emotionButton(_ emotion: (name: String, icon: String, label: String)) -> some View {
        Button {
            withAnimation(DesignSystem.Animations.snappySpring) {
                selectedEmotion = emotion.name
            }
            HapticManager.shared.selection()
        } label: {
            VStack(spacing: DesignSystem.Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(selectedEmotion == emotion.name ? .white : .white.opacity(0.15))
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: emotion.icon)
                        .font(.system(size: 26))
                        .foregroundStyle(
                            selectedEmotion == emotion.name
                            ? Color(hue: 0.72, saturation: 0.5, brightness: 0.7)
                            : .white
                        )
                }
                .scaleEffect(selectedEmotion == emotion.name ? 1.1 : 1.0)
                
                Text(emotion.label)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(selectedEmotion == emotion.name ? .white : .white.opacity(0.6))
            }
        }
        .animation(DesignSystem.Animations.snappySpring, value: selectedEmotion)
    }
    
    // MARK: - Page 3: Note
    
    private var notePage: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()
            
            Text("Anything else on\nyour mind?")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DesignSystem.Spacing.lg)
            
            // Text field
            TextField("Write a short note (optional)...", text: $noteText, axis: .vertical)
                .font(.system(size: 17, design: .rounded))
                .foregroundStyle(.white)
                .tint(.white)
                .lineLimit(3...6)
                .padding(DesignSystem.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.Radius.large)
                        .fill(.white.opacity(0.12))
                )
                .padding(.horizontal, DesignSystem.Spacing.lg)
            
            Spacer()
            
            // Summary
            if let emotion = selectedEmotion {
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Text("Your check-in")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                    
                    HStack(spacing: DesignSystem.Spacing.md) {
                        Text(ratingFace)
                            .font(.system(size: 32))
                        Text(ratingLabel)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("•")
                            .foregroundStyle(.white.opacity(0.3))
                        Text(emotion.capitalized)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
            
            Spacer()
        }
    }
    
    // MARK: - Bottom Controls
    
    private var bottomControls: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Page dots
            HStack(spacing: 8) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(currentPage == index ? .white : .white.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .scaleEffect(currentPage == index ? 1.2 : 1.0)
                        .animation(DesignSystem.Animations.snappySpring, value: currentPage)
                }
            }
            
            // Next / Submit button
            Button {
                if currentPage < 2 {
                    withAnimation(DesignSystem.Animations.defaultSpring) {
                        currentPage += 1
                    }
                    HapticManager.shared.light()
                } else {
                    saveCheckIn()
                }
            } label: {
                Text(currentPage == 2 ? "Save Check-In" : "Next")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hue: 0.72, saturation: 0.5, brightness: 0.6))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(.white)
                    )
            }
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .pressEffect()
            .disabled(currentPage == 1 && selectedEmotion == nil)
            .opacity(currentPage == 1 && selectedEmotion == nil ? 0.5 : 1.0)
            
            // Back button (if not on first page)
            if currentPage > 0 {
                Button {
                    withAnimation(DesignSystem.Animations.defaultSpring) {
                        currentPage -= 1
                    }
                } label: {
                    Text("Back")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                }
                .transition(.opacity)
            }
        }
        .padding(.bottom, DesignSystem.Spacing.xl)
        .animation(DesignSystem.Animations.stateTransition, value: currentPage)
    }
    
    // MARK: - Save
    
    private func saveCheckIn() {
        let checkIn = MoodCheckIn(
            timeOfDay: timeOfDay,
            dayRating: dayRating,
            selectedEmotion: selectedEmotion ?? "neutral",
            note: noteText
        )
        modelContext.insert(checkIn)
        try? modelContext.save()
        
        HapticManager.shared.success()
        
        withAnimation(.easeOut(duration: 0.2)) {
            isAppeared = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            dismiss()
        }
    }
}

#Preview {
    MoodCheckInView()
        .modelContainer(for: [MoodCheckIn.self], inMemory: true)
}
