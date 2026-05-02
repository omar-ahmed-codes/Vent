import Foundation
import SwiftData

/// Handles all SwiftData CRUD operations and aggregation queries.
/// Provides a clean API for ViewModels to interact with persisted data.
@MainActor
final class PersistenceService {
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Journal Entry Operations
    
    /// Saves a new journal entry
    func saveEntry(_ entry: JournalEntry) {
        modelContext.insert(entry)
        try? modelContext.save()
    }
    
    /// Updates an existing entry (SwiftData tracks changes automatically)
    func updateEntry() {
        try? modelContext.save()
    }
    
    /// Deletes a journal entry
    func deleteEntry(_ entry: JournalEntry) {
        modelContext.delete(entry)
        try? modelContext.save()
    }
    
    /// Fetches all entries sorted by date (newest first)
    func fetchAllEntries() -> [JournalEntry] {
        let descriptor = FetchDescriptor<JournalEntry>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    /// Fetches entries within a date range
    func fetchEntries(from startDate: Date, to endDate: Date) -> [JournalEntry] {
        let predicate = #Predicate<JournalEntry> { entry in
            entry.date >= startDate && entry.date <= endDate
        }
        let descriptor = FetchDescriptor<JournalEntry>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    /// Fetches entries for today
    func fetchTodayEntries() -> [JournalEntry] {
        let startOfDay = Calendar.current.startOfDay(for: .now)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? .now
        return fetchEntries(from: startOfDay, to: endOfDay)
    }
    
    /// Fetches entries for the past N days
    func fetchRecentEntries(days: Int) -> [JournalEntry] {
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: .now) ?? .now
        return fetchEntries(from: startDate, to: .now)
    }
    
    // MARK: - Mood Record Operations
    
    /// Updates or creates a mood record for today based on current entries
    func updateDailyMoodRecord() {
        let todayEntries = fetchTodayEntries()
        guard !todayEntries.isEmpty else { return }
        
        let averageScore = todayEntries.map(\.sentimentScore).average
        let allTones = todayEntries.flatMap(\.emotionalTones)
        let dominantEmotion = mostFrequent(in: allTones) ?? "neutral"
        
        let today = Calendar.current.startOfDay(for: .now)
        
        // Check if a record already exists for today
        let predicate = #Predicate<MoodRecord> { record in
            record.date == today
        }
        let descriptor = FetchDescriptor<MoodRecord>(predicate: predicate)
        
        if let existingRecord = try? modelContext.fetch(descriptor).first {
            existingRecord.averageScore = averageScore
            existingRecord.entryCount = todayEntries.count
            existingRecord.dominantEmotion = dominantEmotion
        } else {
            let newRecord = MoodRecord(
                date: today,
                averageScore: averageScore,
                entryCount: todayEntries.count,
                dominantEmotion: dominantEmotion
            )
            modelContext.insert(newRecord)
        }
        
        try? modelContext.save()
    }
    
    /// Fetches mood records for the past N days
    func fetchMoodRecords(days: Int) -> [MoodRecord] {
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: .now) ?? .now
        let predicate = #Predicate<MoodRecord> { record in
            record.date >= startDate
        }
        let descriptor = FetchDescriptor<MoodRecord>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    /// Fetches all mood records
    func fetchAllMoodRecords() -> [MoodRecord] {
        let descriptor = FetchDescriptor<MoodRecord>(
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    // MARK: - Aggregation Helpers
    
    /// Computes the average mood score for a given time period
    func averageMood(days: Int) -> Double {
        let entries = fetchRecentEntries(days: days)
        guard !entries.isEmpty else { return 0.0 }
        return entries.map(\.sentimentScore).average
    }
    
    /// Returns the total entry count
    func totalEntryCount() -> Int {
        let descriptor = FetchDescriptor<JournalEntry>()
        return (try? modelContext.fetchCount(descriptor)) ?? 0
    }
    
    /// Loads sample data for testing.
    func loadSampleDataIfNeeded() {
        let samples = SampleData.generateEntries()
        for sample in samples {
            let entry = JournalEntry(
                text: sample.text,
                date: sample.date,
                sentimentScore: sample.score,
                sentimentLabel: sample.label,
                confidence: 0.75,
                emotionalTones: sample.tones,
                tags: sample.tags
            )
            modelContext.insert(entry)
        }
        
        // Create mood records from sample data
        generateMoodRecordsFromEntries()
        
        try? modelContext.save()
    }
    
    /// Generates mood records from existing entries (used with sample data)
    private func generateMoodRecordsFromEntries() {
        let allEntries = fetchAllEntries()
        
        // Group entries by day
        var dailyEntries: [Date: [JournalEntry]] = [:]
        for entry in allEntries {
            let day = Calendar.current.startOfDay(for: entry.date)
            dailyEntries[day, default: []].append(entry)
        }
        
        // Create a mood record for each day
        for (day, entries) in dailyEntries {
            let avgScore = entries.map(\.sentimentScore).average
            let allTones = entries.flatMap(\.emotionalTones)
            let dominant = mostFrequent(in: allTones) ?? "neutral"
            
            let record = MoodRecord(
                date: day,
                averageScore: avgScore,
                entryCount: entries.count,
                dominantEmotion: dominant
            )
            modelContext.insert(record)
        }
    }
    
    // MARK: - Utility
    
    /// Returns the most frequently occurring element in an array
    private func mostFrequent(in array: [String]) -> String? {
        guard !array.isEmpty else { return nil }
        var counts: [String: Int] = [:]
        for item in array {
            counts[item, default: 0] += 1
        }
        return counts.max(by: { $0.value < $1.value })?.key
    }
}
