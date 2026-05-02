import SwiftUI
import SwiftData

/// The insights and analytics screen.
/// Contains a mood chart, stats overview, weekly summaries, and generated insights.
/// Uses a segmented time range picker and smooth scroll layout.
struct InsightsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = InsightsViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // Time range picker
                    timeRangePicker
                    
                    // Stats overview
                    statsOverview
                    
                    // Mood chart
                    MoodChartView(
                        dataPoints: viewModel.moodDataPoints,
                        timeRange: viewModel.selectedTimeRange
                    )
                    .cardStyle()
                    
                    // Weekly summaries
                    WeeklySummaryView(summaries: viewModel.weeklySummaries)
                    
                    // Insights
                    insightsSection
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.bottom, DesignSystem.Spacing.xxl)
            }
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
            .onAppear {
                let service = PersistenceService(modelContext: modelContext)
                viewModel.configure(with: service)
                viewModel.refresh()
            }
            .onChange(of: viewModel.selectedTimeRange) {
                viewModel.refresh()
            }
        }
    }
    
    // MARK: - Time Range Picker
    
    private var timeRangePicker: some View {
        Picker("Time Range", selection: $viewModel.selectedTimeRange) {
            ForEach(TimeRange.allCases) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, DesignSystem.Spacing.sm)
    }
    
    // MARK: - Stats Overview
    
    private var statsOverview: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            StatCard(
                title: "Average Mood",
                value: moodEmoji(for: viewModel.overallAverageScore),
                subtitle: String(format: "%+.2f", viewModel.overallAverageScore)
            )
            
            StatCard(
                title: "Total Entries",
                value: "\(viewModel.totalEntries)",
                subtitle: "journal entries"
            )
            
            StatCard(
                title: "Streak",
                value: "\(viewModel.currentStreak)",
                subtitle: viewModel.currentStreak == 1 ? "day" : "days"
            )
        }
    }
    
    // MARK: - Insights Section
    
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("Insights")
                    .font(DesignSystem.Typography.sectionHeader)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.yellow)
            }
            
            ForEach(viewModel.insights) { insight in
                InsightCardView(insight: insight)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func moodEmoji(for score: Double) -> String {
        switch score {
        case 0.5...: return "😊"
        case 0.1..<0.5: return "🙂"
        case -0.1..<0.1: return "😐"
        case -0.5..<(-0.1): return "😔"
        default: return "😢"
        }
    }
}

// MARK: - Stat Card Component

/// A compact stat display card used in the overview section
struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text(title)
                .font(DesignSystem.Typography.caption)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(DesignSystem.Typography.largeNumber)
                .foregroundStyle(.primary)
            
            Text(subtitle)
                .font(DesignSystem.Typography.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
}

#Preview {
    InsightsView()
        .modelContainer(for: [JournalEntry.self, MoodRecord.self], inMemory: true)
}
