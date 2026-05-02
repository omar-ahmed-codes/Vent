import Foundation

/// Provides 30 days of realistic sample journal entries for testing and previews.
/// Entries have varied sentiments, emotional tones, and writing styles.
struct SampleData {
    
    /// Generates sample journal entries spanning the last 30 days
    static func generateEntries() -> [(text: String, date: Date, score: Double, label: String, tones: [String], tags: [String])] {
        let entries: [(text: String, daysAgo: Int, score: Double, label: String, tones: [String], tags: [String])] = [
            // Recent entries
            (
                "Had an amazing morning workout today. Feeling energized and ready to take on the world. The weather was perfect for a run outside.",
                0, 0.85, "positive", ["happy", "energized"], ["workout", "morning"]
            ),
            (
                "Work was incredibly stressful today. Back-to-back meetings with no break. I need to set better boundaries with my time.",
                1, -0.65, "negative", ["stressed", "frustrated"], ["work", "meetings"]
            ),
            (
                "Spent the afternoon reading in the park. There's something so calming about being surrounded by nature. Finished two chapters of my book.",
                2, 0.70, "positive", ["calm", "peaceful"], ["reading", "nature"]
            ),
            (
                "Just a regular day. Nothing special happened. Made dinner, watched some TV. Sometimes ordinary days are perfectly fine.",
                3, 0.05, "neutral", ["calm"], ["routine"]
            ),
            (
                "Feeling anxious about the presentation tomorrow. I've prepared well, but the nervousness is still there. Deep breaths.",
                4, -0.45, "negative", ["anxious", "nervous"], ["work", "presentation"]
            ),
            (
                "The presentation went great! Got positive feedback from the team. All that worry for nothing. Celebrated with coffee and cake.",
                5, 0.90, "positive", ["happy", "relieved", "grateful"], ["work", "success"]
            ),
            (
                "Had a wonderful dinner with old friends. We laughed so much my cheeks hurt. These connections are so important to nurture.",
                6, 0.88, "positive", ["happy", "grateful", "loved"], ["friends", "social"]
            ),
            (
                "Couldn't sleep well last night. Mind was racing with random thoughts. Feeling tired and a bit foggy today.",
                7, -0.35, "negative", ["tired", "anxious"], ["sleep", "health"]
            ),
            (
                "Started learning a new recipe — homemade pasta from scratch. It was messy but so satisfying. The result was delicious!",
                8, 0.75, "positive", ["happy", "creative"], ["cooking", "learning"]
            ),
            (
                "Rainy day. Stayed in and organized my closet. There's something therapeutic about decluttering. Found some old photos too.",
                9, 0.30, "positive", ["calm", "nostalgic"], ["home", "organizing"]
            ),
            // Older entries
            (
                "Had a disagreement with a colleague about the project direction. It was uncomfortable but I think we resolved it maturely.",
                10, -0.20, "neutral", ["stressed", "thoughtful"], ["work", "conflict"]
            ),
            (
                "Sunday morning yoga session was exactly what I needed. Feeling centered and grateful for this practice.",
                11, 0.80, "positive", ["calm", "grateful", "peaceful"], ["yoga", "weekend"]
            ),
            (
                "Feeling overwhelmed with all the deadlines piling up. Need to prioritize better. Made a to-do list which helped a bit.",
                12, -0.55, "negative", ["stressed", "overwhelmed"], ["work", "deadlines"]
            ),
            (
                "Beautiful sunset walk along the waterfront. Sometimes you just need to slow down and appreciate the simple things.",
                13, 0.72, "positive", ["peaceful", "grateful"], ["nature", "walking"]
            ),
            (
                "Doctor's appointment today. Everything looks good. Grateful for good health. Should schedule the dentist too.",
                14, 0.25, "neutral", ["relieved"], ["health", "routine"]
            ),
            (
                "Binge-watched a new series. It was entertaining but I feel guilty about wasting the whole day. Tomorrow I'll be more productive.",
                15, -0.15, "neutral", ["guilty"], ["entertainment", "rest"]
            ),
            (
                "Got a surprise care package from mom. Homemade cookies and a sweet note. Feeling so loved and missing home.",
                16, 0.82, "positive", ["loved", "grateful", "nostalgic"], ["family"]
            ),
            (
                "Traffic was terrible today. Spent two hours commuting. Seriously considering working from home more often.",
                17, -0.40, "negative", ["frustrated", "tired"], ["commute", "work"]
            ),
            (
                "Volunteered at the local food bank this morning. Puts everything in perspective. Want to do this more regularly.",
                18, 0.78, "positive", ["grateful", "fulfilled"], ["volunteering", "community"]
            ),
            (
                "Tried meditation for the first time using an app. It was hard to quiet my mind but I'll keep at it.",
                19, 0.20, "neutral", ["curious", "calm"], ["meditation", "wellness"]
            ),
            (
                "Feeling really down today. No particular reason, just one of those days. Going to bed early and hoping tomorrow is better.",
                20, -0.70, "negative", ["sad", "tired"], ["mental health"]
            ),
            (
                "Weekend brunch with the family was lovely. Kids were being hilarious. These moments are what life is about.",
                21, 0.92, "positive", ["happy", "loved", "grateful"], ["family", "weekend"]
            ),
            (
                "Finally completed the online course I started months ago. Proud of myself for following through despite being busy.",
                22, 0.65, "positive", ["proud", "accomplished"], ["learning", "achievement"]
            ),
            (
                "Argument with my partner about finances. We both said things we didn't mean. Need to revisit this calmly tomorrow.",
                23, -0.60, "negative", ["angry", "stressed", "sad"], ["relationship", "conflict"]
            ),
            (
                "Went for a long hike in the mountains. The views were breathtaking. Nature has a way of making problems feel smaller.",
                24, 0.85, "positive", ["peaceful", "energized", "happy"], ["nature", "hiking", "weekend"]
            ),
            (
                "Meeting with the new client went well. Exciting project ahead. Feeling motivated and optimistic about Q2.",
                25, 0.60, "positive", ["excited", "motivated"], ["work", "career"]
            ),
            (
                "Headache all day. Couldn't focus on anything. Took some medicine and rested. Hope it's not a migraine coming.",
                26, -0.50, "negative", ["tired", "worried"], ["health"]
            ),
            (
                "Planted some herbs on the balcony — basil, rosemary, and mint. Looking forward to using them in cooking.",
                27, 0.55, "positive", ["happy", "creative", "calm"], ["gardening", "home"]
            ),
            (
                "Average Monday. Work was fine, nothing exciting. Made a decent lunch. Started reading a new novel before bed.",
                28, 0.10, "neutral", ["calm"], ["work", "routine", "reading"]
            ),
            (
                "Grateful for a peaceful weekend. Recharged and ready for the week ahead. Setting intentions for the month.",
                29, 0.68, "positive", ["grateful", "calm", "motivated"], ["weekend", "planning"]
            ),
        ]
        
        return entries.map { entry in
            let date = Calendar.current.date(byAdding: .day, value: -entry.daysAgo, to: .now) ?? .now
            // Add a random hour to make timestamps feel realistic
            let hour = Int.random(in: 7...22)
            let minute = Int.random(in: 0...59)
            var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
            components.hour = hour
            components.minute = minute
            let finalDate = Calendar.current.date(from: components) ?? date
            
            return (
                text: entry.text,
                date: finalDate,
                score: entry.score,
                label: entry.label,
                tones: entry.tones,
                tags: entry.tags
            )
        }
    }
}
