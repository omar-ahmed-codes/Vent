import SwiftUI

/// A small, elegant pill showing the current sentiment result.
/// Displays an emoji, label, and confidence score.
/// Appears with a spring animation and fades when the editor is focused.
struct SentimentIndicator: View {
    let result: SentimentResult
    let isAnalyzing: Bool
    let isSaved: Bool
    
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            // Sentiment emoji
            if isAnalyzing {
                ProgressView()
                    .scaleEffect(0.7)
                    .tint(.secondary)
            } else {
                Text(sentimentEmoji)
                    .font(.system(size: 18))
            }
            
            // Label and score
            VStack(alignment: .leading, spacing: 1) {
                Text(result.label.capitalized)
                    .font(DesignSystem.Typography.captionMedium)
                    .foregroundStyle(.primary)
                
                Text(scoreText)
                    .font(DesignSystem.Typography.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Save indicator
            if isSaved {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.green)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(
                    color: DesignSystem.Shadows.cardShadowColor,
                    radius: 8,
                    y: 2
                )
        )
        .scaleEffect(isVisible ? 1.0 : 0.8)
        .opacity(isVisible ? 1.0 : 0.0)
        .onAppear {
            withAnimation(DesignSystem.Animations.defaultSpring) {
                isVisible = true
            }
        }
        .animation(DesignSystem.Animations.snappySpring, value: isSaved)
        .animation(DesignSystem.Animations.quickFade, value: isAnalyzing)
    }
    
    // MARK: - Computed Properties
    
    private var sentimentEmoji: String {
        switch result.score {
        case 0.5...:  return "😊"
        case 0.1..<0.5: return "🙂"
        case -0.1..<0.1: return "😐"
        case -0.5..<(-0.1): return "😔"
        default: return "😢"
        }
    }
    
    private var scoreText: String {
        let sign = result.score >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", result.score))"
    }
}

// MARK: - Emotional Tone Pills

/// Displays emotional tones as small, colored pills
struct EmotionalTonePills: View {
    let tones: [String]
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(tones, id: \.self) { tone in
                Text(tone.capitalized)
                    .font(DesignSystem.Typography.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, DesignSystem.Spacing.sm)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                    )
            }
        }
    }
}
