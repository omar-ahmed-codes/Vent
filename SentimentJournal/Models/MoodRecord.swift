import Foundation
import SwiftData

/// Aggregated daily mood record for efficient chart queries.
/// Instead of recomputing averages from all entries every time,
/// we maintain daily summaries.
@Model
final class MoodRecord {
    // MARK: - Properties
    
    /// Unique identifier
    var id: UUID
    
    /// The date this record represents (normalized to start of day)
    var date: Date
    
    /// Average sentiment score across all entries for this day
    var averageScore: Double
    
    /// Number of journal entries made on this day
    var entryCount: Int
    
    /// The most frequently detected emotion for the day
    var dominantEmotion: String
    
    // MARK: - Initialization
    
    init(
        date: Date,
        averageScore: Double,
        entryCount: Int = 1,
        dominantEmotion: String = "neutral"
    ) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.averageScore = averageScore
        self.entryCount = entryCount
        self.dominantEmotion = dominantEmotion
    }
}

// MARK: - Computed Properties

extension MoodRecord {
    /// Human-readable label for the average mood
    var moodLabel: String {
        switch averageScore {
        case 0.3...:
            return "Good"
        case -0.3..<0.3:
            return "Okay"
        default:
            return "Tough"
        }
    }
    
    /// Emoji for the daily mood
    var moodEmoji: String {
        switch averageScore {
        case 0.5...:
            return "😊"
        case 0.1..<0.5:
            return "🙂"
        case -0.1..<0.1:
            return "😐"
        case -0.5..<(-0.1):
            return "😔"
        default:
            return "😢"
        }
    }
}
