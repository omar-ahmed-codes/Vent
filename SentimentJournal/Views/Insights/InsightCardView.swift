import SwiftUI

/// Individual insight display card.
/// Shows an icon, insight text, and subtle background tint
/// based on the insight category.
struct InsightCardView: View {
    let insight: Insight
    
    @State private var isAppeared = false
    
    var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
            // Icon
            Image(systemName: insight.icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(iconColor)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(iconColor.opacity(0.12))
                )
            
            // Text
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(categoryLabel)
                    .font(DesignSystem.Typography.caption)
                    .foregroundStyle(iconColor)
                    .textCase(.uppercase)
                    .tracking(0.5)
                
                Text(insight.text)
                    .font(DesignSystem.Typography.insightText)
                    .foregroundStyle(.primary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
        .opacity(isAppeared ? 1 : 0)
        .offset(y: isAppeared ? 0 : 15)
        .onAppear {
            withAnimation(DesignSystem.Animations.defaultSpring.delay(0.05)) {
                isAppeared = true
            }
        }
    }
    
    // MARK: - Helpers
    
    private var iconColor: Color {
        switch insight.category {
        case .pattern:
            return DesignSystem.Colors.accent
        case .trend:
            return Color(hue: 0.55, saturation: 0.6, brightness: 0.7)
        case .suggestion:
            return Color(hue: 0.1, saturation: 0.5, brightness: 0.8)
        case .milestone:
            return Color(hue: 0.13, saturation: 0.7, brightness: 0.85)
        }
    }
    
    private var categoryLabel: String {
        switch insight.category {
        case .pattern: return "Pattern"
        case .trend: return "Trend"
        case .suggestion: return "Suggestion"
        case .milestone: return "Milestone"
        }
    }
}
