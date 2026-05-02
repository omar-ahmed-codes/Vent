import SwiftUI
import Charts

/// Mood line chart using Swift Charts.
/// Features thin strokes, soft gradient area fill, minimal gridlines,
/// and smooth animated transitions.
struct MoodChartView: View {
    let dataPoints: [MoodDataPoint]
    let timeRange: TimeRange
    
    @State private var animateChart = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // Section header
            Text("Mood Over Time")
                .font(DesignSystem.Typography.sectionHeader)
                .foregroundStyle(.primary)
            
            if dataPoints.isEmpty {
                emptyState
            } else {
                chartView
            }
        }
    }
    
    // MARK: - Chart
    
    private var chartView: some View {
        Chart {
            ForEach(dataPoints) { point in
                // Area fill under the line
                AreaMark(
                    x: .value("Date", point.date),
                    y: .value("Mood", animateChart ? point.score : 0)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            DesignSystem.Colors.chartGradientTop,
                            DesignSystem.Colors.chartGradientBottom
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
                
                // Line stroke
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Mood", animateChart ? point.score : 0)
                )
                .foregroundStyle(DesignSystem.Colors.chartLine)
                .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                .interpolationMethod(.catmullRom)
                
                // Data points
                PointMark(
                    x: .value("Date", point.date),
                    y: .value("Mood", animateChart ? point.score : 0)
                )
                .foregroundStyle(pointColor(for: point.score))
                .symbolSize(30)
            }
            
            // Zero line (neutral baseline)
            RuleMark(y: .value("Neutral", 0))
                .foregroundStyle(.secondary.opacity(0.3))
                .lineStyle(StrokeStyle(lineWidth: 0.5, dash: [5, 5]))
        }
        .chartYScale(domain: -1.0...1.0)
        .chartYAxis {
            AxisMarks(values: [-1.0, -0.5, 0, 0.5, 1.0]) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3))
                    .foregroundStyle(.secondary.opacity(0.2))
                AxisValueLabel {
                    if let v = value.as(Double.self) {
                        Text(yAxisLabel(for: v))
                            .font(DesignSystem.Typography.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: xAxisCount)) { _ in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3))
                    .foregroundStyle(.secondary.opacity(0.1))
                AxisValueLabel(format: xAxisFormat)
                    .font(DesignSystem.Typography.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(height: 220)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .onAppear {
            withAnimation(DesignSystem.Animations.chartAppear) {
                animateChart = true
            }
        }
        .onChange(of: dataPoints.count) {
            animateChart = false
            withAnimation(DesignSystem.Animations.chartAppear) {
                animateChart = true
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 40))
                .foregroundStyle(.tertiary)
            
            Text("No data yet")
                .font(DesignSystem.Typography.body)
                .foregroundStyle(.secondary)
            
            Text("Start journaling to see your mood trends")
                .font(DesignSystem.Typography.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(height: 220)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Helpers
    
    private func pointColor(for score: Double) -> Color {
        switch score {
        case 0.3...: return DesignSystem.Colors.positiveBadge
        case -0.3..<0.3: return DesignSystem.Colors.neutralBadge
        default: return DesignSystem.Colors.negativeBadge
        }
    }
    
    private func yAxisLabel(for value: Double) -> String {
        switch value {
        case 1.0: return "😊"
        case 0.5: return ""
        case 0.0: return "😐"
        case -0.5: return ""
        case -1.0: return "😢"
        default: return ""
        }
    }
    
    private var xAxisCount: Int {
        switch timeRange {
        case .week: return 7
        case .month: return 5
        case .all: return 6
        }
    }
    
    private var xAxisFormat: Date.FormatStyle {
        switch timeRange {
        case .week: return .dateTime.weekday(.abbreviated)
        case .month: return .dateTime.day().month(.abbreviated)
        case .all: return .dateTime.month(.abbreviated)
        }
    }
}
