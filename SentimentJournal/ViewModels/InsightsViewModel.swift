import Foundation
import SwiftUI

/// Data point for mood chart visualization
struct MoodDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let score: Double
    let label: String
    
    /// Formatted date for chart axis
    var dateLabel: String {
        DateFormatters.shortDate.string(from: date)
    }
}

/// Weekly summary data for the weekly overview cards
struct WeeklySummary: Identifiable {
    let id = UUID()
    let weekStart: Date
    let averageScore: Double
    let entryCount: Int
    let dominantEmotion: String
    let dataPoints: [MoodDataPoint]
    
    var weekLabel: String {
        let end = weekStart.addingDays(6)
        return "\(DateFormatters.shortDate.string(from: weekStart)) – \(DateFormatters.shortDate.string(from: end))"
    }
    
    var moodLabel: String {
        switch averageScore {
        case 0.3...: return "Good"
        case -0.3..<0.3: return "Okay"
        default: return "Tough"
        }
    }
    
    var moodEmoji: String {
        switch averageScore {
        case 0.5...: return "😊"
        case 0.1..<0.5: return "🙂"
        case -0.1..<0.1: return "😐"
        case -0.5..<(-0.1): return "😔"
        default: return "😢"
        }
    }
}

/// Time range options for the chart
enum TimeRange: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case all = "All"
    
    var id: String { rawValue }
    
    var days: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .all: return 365
        }
    }
}

/// ViewModel for the Insights/Analytics screen.
/// Manages mood data, chart data points, weekly summaries, and insights.
@Observable
@MainActor
final class InsightsViewModel {
    
    // MARK: - Published State
    
    /// Chart data points for the mood line graph
    var moodDataPoints: [MoodDataPoint] = []
    
    /// Weekly summary cards
    var weeklySummaries: [WeeklySummary] = []
    
    /// Generated insights
    var insights: [Insight] = []
    
    /// Currently selected time range
    var selectedTimeRange: TimeRange = .month
    
    /// Overall average mood score
    var overallAverageScore: Double = 0.0
    
    /// Total number of entries
    var totalEntries: Int = 0
    
    /// Current streak count (consecutive days with entries)
    var currentStreak: Int = 0
    
    /// Whether data is loading
    var isLoading: Bool = false
    
    // MARK: - Dependencies
    
    private var persistenceService: PersistenceService?
    private let insightsService = InsightsService()
    
    // MARK: - Initialization
    
    init() {}
    
    func configure(with persistenceService: PersistenceService) {
        self.persistenceService = persistenceService
    }
    
    // MARK: - Data Loading
    
    /// Refreshes all data for the current time range
    func refresh() {
        guard let persistenceService else { return }
        isLoading = true
        
        let entries = persistenceService.fetchRecentEntries(days: selectedTimeRange.days)
        let allEntries = persistenceService.fetchAllEntries()
        
        // Generate mood data points
        moodDataPoints = entries
            .sorted { $0.date < $1.date }
            .map { entry in
                MoodDataPoint(
                    date: entry.date,
                    score: entry.sentimentScore,
                    label: entry.sentimentLabel
                )
            }
        
        // Compute overall stats
        overallAverageScore = allEntries.map(\.sentimentScore).average
        totalEntries = allEntries.count
        currentStreak = computeStreak(from: allEntries)
        
        // Generate weekly summaries
        weeklySummaries = generateWeeklySummaries(from: entries)
        
        // Generate insights
        insights = insightsService.generateInsights(from: allEntries)
        
        isLoading = false
    }
    
    // MARK: - Private Helpers
    
    /// Generates weekly summary data from entries
    private func generateWeeklySummaries(from entries: [JournalEntry]) -> [WeeklySummary] {
        // Group entries by week
        var weeklyGroups: [Date: [JournalEntry]] = [:]
        
        for entry in entries {
            let weekStart = entry.date.startOfWeek
            weeklyGroups[weekStart, default: []].append(entry)
        }
        
        return weeklyGroups
            .sorted { $0.key > $1.key }
            .map { weekStart, weekEntries in
                let scores = weekEntries.map(\.sentimentScore)
                let allTones = weekEntries.flatMap(\.emotionalTones)
                let dominantTone = allTones.isEmpty ? "neutral" : mostFrequent(in: allTones)
                
                let dataPoints = weekEntries
                    .sorted { $0.date < $1.date }
                    .map { MoodDataPoint(date: $0.date, score: $0.sentimentScore, label: $0.sentimentLabel) }
                
                return WeeklySummary(
                    weekStart: weekStart,
                    averageScore: scores.average,
                    entryCount: weekEntries.count,
                    dominantEmotion: dominantTone,
                    dataPoints: dataPoints
                )
            }
    }
    
    /// Computes the current streak of consecutive days with entries
    private func computeStreak(from entries: [JournalEntry]) -> Int {
        let uniqueDays = Set(entries.map { Calendar.current.startOfDay(for: $0.date) })
        var streak = 0
        var checkDate = Calendar.current.startOfDay(for: .now)
        
        while uniqueDays.contains(checkDate) {
            streak += 1
            checkDate = checkDate.addingDays(-1)
        }
        
        return streak
    }
    
    /// Returns the most frequent string in an array
    private func mostFrequent(in array: [String]) -> String {
        var counts: [String: Int] = [:]
        for item in array {
            counts[item, default: 0] += 1
        }
        return counts.max(by: { $0.value < $1.value })?.key ?? "neutral"
    }
}
