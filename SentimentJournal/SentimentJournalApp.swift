import SwiftUI
import SwiftData

/// Sentiment Journal — App Entry Point
///
/// A minimalist, privacy-first journaling app with on-device sentiment analysis.
/// Built with SwiftUI, SwiftData, Natural Language framework, and Swift Charts.
///
/// All ML processing happens on-device. No external API calls. No data tracking.
@main
struct SentimentJournalApp: App {
    
    /// SwiftData model container configured with JournalEntry and MoodRecord models.
    /// Uses automatic schema migration and local storage only.
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            JournalEntry.self,
            MoodRecord.self,
            MoodCheckIn.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false // Persist to disk
        )
        
        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            // If we can't create the container, the app can't function.
            // In production, we'd handle this more gracefully.
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
