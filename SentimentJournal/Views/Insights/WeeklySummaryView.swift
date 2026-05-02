import SwiftUI
import Charts

/// Weekly summary card showing a compact overview of mood for a given week.
/// Includes average mood, entry count, dominant emotion, and a sparkline.
struct WeeklySummaryView: View {
    let summaries: [WeeklySummary]
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Weekly Summary")
                .font(DesignSystem.Typography.sectionHeader)
                .foregroundStyle(.primary)
            
            if summaries.isEmpty {
                Text("No weekly data yet")
                    .font(DesignSystem.Typography.body)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(summaries) { summary in
                    WeeklySummaryCard(summary: summary)
                }
            }
        }
    }
}

/// Individual weekly summary card
struct WeeklySummaryCard: View {
    let summary: WeeklySummary
    
    @State private var isAppeared = false
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Mood emoji
            Text(summary.moodEmoji)
                .font(.system(size: 32))
            
            // Details
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(summary.weekLabel)
                    .font(DesignSystem.Typography.captionMedium)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: DesignSystem.Spacing.md) {
                    // Average score
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Mood")
                            .font(DesignSystem.Typography.caption)
                            .foregroundStyle(.tertiary)
                        Text(summary.moodLabel)
                            .font(DesignSystem.Typography.bodyMedium)
                            .foregroundStyle(.primary)
                    }
                    
                    // Entry count
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Entries")
                            .font(DesignSystem.Typography.caption)
                            .foregroundStyle(.tertiary)
                        Text("\(summary.entryCount)")
                            .font(DesignSystem.Typography.bodyMedium)
                            .foregroundStyle(.primary)
                    }
                    
                    // Dominant emotion
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Feeling")
                            .font(DesignSystem.Typography.caption)
                            .foregroundStyle(.tertiary)
                        Text(summary.dominantEmotion.capitalized)
                            .font(DesignSystem.Typography.bodyMedium)
                            .foregroundStyle(.primary)
                    }
                }
            }
            
            Spacer()
            
            // Mini sparkline
            if summary.dataPoints.count >= 2 {
                miniSparkline
                    .frame(width: 60, height: 30)
            }
        }
        .cardStyle()
        .opacity(isAppeared ? 1 : 0)
        .offset(y: isAppeared ? 0 : 10)
        .onAppear {
            withAnimation(DesignSystem.Animations.defaultSpring.delay(0.1)) {
                isAppeared = true
            }
        }
    }
    
    /// Small sparkline chart for the week
    private var miniSparkline: some View {
        Chart(summary.dataPoints) { point in
            LineMark(
                x: .value("Date", point.date),
                y: .value("Score", point.score)
            )
            .foregroundStyle(sparklineColor)
            .lineStyle(StrokeStyle(lineWidth: 1.5, lineCap: .round))
            .interpolationMethod(.catmullRom)
        }
        .chartYScale(domain: -1...1)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
    }
    
    private var sparklineColor: Color {
        switch summary.averageScore {
        case 0.3...: return DesignSystem.Colors.positiveBadge
        case -0.3..<0.3: return DesignSystem.Colors.neutralBadge
        default: return DesignSystem.Colors.negativeBadge
        }
    }
}
