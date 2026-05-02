import Foundation
import SwiftData

/// Stores a mood check-in response from the interactive quiz.
/// Users get prompted 3 times daily: morning, afternoon, night.
@Model
final class MoodCheckIn {
    var id: UUID
    var date: Date
    var timeOfDay: String        // "morning", "afternoon", "night"
    var dayRating: Double         // 0.0 to 1.0 from slider
    var selectedEmotion: String   // e.g. "good", "stressed", "happy", "sad", "calm", "angry"
    var note: String              // optional short note
    
    init(
        date: Date = .now,
        timeOfDay: String,
        dayRating: Double,
        selectedEmotion: String,
        note: String = ""
    ) {
        self.id = UUID()
        self.date = date
        self.timeOfDay = timeOfDay
        self.dayRating = dayRating
        self.selectedEmotion = selectedEmotion
        self.note = note
    }
}
