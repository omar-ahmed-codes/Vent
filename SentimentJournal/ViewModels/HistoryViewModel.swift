import Foundation
import SwiftUI

/// ViewModel for the Entry History screen.
/// Handles fetching, filtering, searching, and deleting entries.
@Observable
@MainActor
final class HistoryViewModel {
    
    // MARK: - Published State
    
    /// All fetched entries
    var entries: [JournalEntry] = []
    
    /// Current search text
    var searchText: String = ""
    
    /// Filtered entries based on search and selected filter
    var filteredEntries: [JournalEntry] {
        var result = entries
        
        // Apply sentiment filter
        if selectedFilter != .all {
            result = result.filter { entry in
                switch selectedFilter {
                case .positive: return entry.sentimentLabel == "positive"
                case .neutral: return entry.sentimentLabel == "neutral"
                case .negative: return entry.sentimentLabel == "negative"
                case .all: return true
                }
            }
        }
        
        // Apply search
        if !searchText.isEmpty {
            result = result.filter { entry in
                entry.text.localizedCaseInsensitiveContains(searchText) ||
                entry.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) }) ||
                entry.emotionalTones.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }
        
        return result
    }
    
    /// Currently selected sentiment filter
    var selectedFilter: SentimentFilter = .all
    
    /// Group entries by date for section headers
    var groupedEntries: [(date: String, entries: [JournalEntry])] {
        let grouped = Dictionary(grouping: filteredEntries) { entry in
            Calendar.current.startOfDay(for: entry.date)
        }
        
        return grouped
            .sorted { $0.key > $1.key }
            .map { (date, entries) in
                let dateString = formatSectionDate(date)
                return (date: dateString, entries: entries.sorted { $0.date > $1.date })
            }
    }
    
    // MARK: - Filter Options
    
    enum SentimentFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case positive = "Positive"
        case neutral = "Neutral"
        case negative = "Negative"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .all: return "line.3.horizontal.decrease.circle"
            case .positive: return "face.smiling"
            case .neutral: return "face.dashed"
            case .negative: return "cloud.rain"
            }
        }
    }
    
    // MARK: - Dependencies
    
    private var persistenceService: PersistenceService?
    
    // MARK: - Initialization
    
    init() {}
    
    func configure(with persistenceService: PersistenceService) {
        self.persistenceService = persistenceService
    }
    
    // MARK: - Data Operations
    
    /// Fetches all entries from persistence
    func fetchEntries() {
        guard let persistenceService else { return }
        entries = persistenceService.fetchAllEntries()
    }
    
    /// Deletes an entry
    func deleteEntry(_ entry: JournalEntry) {
        persistenceService?.deleteEntry(entry)
        
        withAnimation(DesignSystem.Animations.defaultSpring) {
            entries.removeAll { $0.id == entry.id }
        }
        
        HapticManager.shared.light()
    }
    
    /// Deletes entries at the specified index set (for swipe-to-delete)
    func deleteEntries(at offsets: IndexSet, in sectionEntries: [JournalEntry]) {
        for index in offsets {
            let entry = sectionEntries[index]
            deleteEntry(entry)
        }
    }
    
    // MARK: - Private Helpers
    
    /// Formats a date for section headers with relative naming
    private func formatSectionDate(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return DateFormatters.mediumDate.string(from: date)
        }
    }
}
