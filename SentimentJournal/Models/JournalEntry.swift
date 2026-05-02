import Foundation
import SwiftData

/// Core journal entry model persisted via SwiftData.
/// Each entry stores the raw text along with computed sentiment analysis results.
@Model
final class JournalEntry {
    // MARK: - Properties
    
    /// Unique identifier for the entry
    var id: UUID
    
    /// The raw journal text written by the user
    var text: String
    
    /// Timestamp when the entry was created
    var date: Date
    
    /// Sentiment score from NLTagger, ranging from -1.0 (very negative) to +1.0 (very positive)
    var sentimentScore: Double
    
    /// Human-readable sentiment label: "positive", "neutral", or "negative"
    var sentimentLabel: String
    
    /// Confidence of the sentiment analysis (0.0 to 1.0)
    var confidence: Double
    
    /// Detected emotional tones (e.g., "happy", "anxious", "calm", "stressed")
    var emotionalTones: [String]
    
    /// Extracted tags/keywords from the entry text
    var tags: [String]
    
    // MARK: - Initialization
    
    init(
        text: String,
        date: Date = .now,
        sentimentScore: Double = 0.0,
        sentimentLabel: String = "neutral",
        confidence: Double = 0.0,
        emotionalTones: [String] = [],
        tags: [String] = []
    ) {
        self.id = UUID()
        self.text = text
        self.date = date
        self.sentimentScore = sentimentScore
        self.sentimentLabel = sentimentLabel
        self.confidence = confidence
        self.emotionalTones = emotionalTones
        self.tags = tags
    }
}

// MARK: - Computed Properties

extension JournalEntry {
    /// Returns a short preview of the entry text (first 80 characters)
    var preview: String {
        if text.count <= 80 {
            return text
        }
        return String(text.prefix(80)) + "…"
    }
    
    /// Returns an emoji representing the sentiment
    var sentimentEmoji: String {
        switch sentimentScore {
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
    
    /// Returns a normalized mood score (0.0 to 1.0) for chart display
    var normalizedMoodScore: Double {
        (sentimentScore + 1.0) / 2.0
    }
}
