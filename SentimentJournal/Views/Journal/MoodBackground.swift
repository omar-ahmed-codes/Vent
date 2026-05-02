import SwiftUI

/// View modifier that applies a dynamic gradient background
/// that smoothly transitions based on the current sentiment score.
struct MoodBackground: ViewModifier {
    let sentimentScore: Double
    
    func body(content: Content) -> some View {
        let colors = DesignSystem.Colors.moodGradient(for: sentimentScore)
        
        content
            .background(
                LinearGradient(
                    colors: [colors.start, colors.end],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .animation(DesignSystem.Animations.moodTransition, value: sentimentScore)
            )
    }
}

extension View {
    /// Applies a mood-based gradient background
    func moodBackground(score: Double) -> some View {
        modifier(MoodBackground(sentimentScore: score))
    }
}
