import Foundation

/// Represents a single generated insight about the user's journaling patterns.
struct Insight: Identifiable {
    let id = UUID()
    let text: String
    let icon: String       // SF Symbol name
    let category: InsightCategory
    
    enum InsightCategory {
        case pattern      // Behavioral pattern
        case trend        // Mood trend
        case suggestion   // Actionable suggestion
        case milestone    // Achievement/milestone
    }
}

/// Analyzes journal entries to generate actionable, human-readable insights.
/// Uses basic pattern detection — no ML or complex algorithms needed.
///
/// Example insights:
/// - "You feel better on weekends"
/// - "Entries tagged 'work' tend to be more negative"
/// - "You've been on a positive streak for 5 days"
struct InsightsService {
    
    /// Generates all available insights from the provided entries.
    /// - Parameter entries: All journal entries to analyze
    /// - Returns: Array of insights, sorted by relevance
    func generateInsights(from entries: [JournalEntry]) -> [Insight] {
        guard entries.count >= 3 else {
            return [Insight(
                text: "Keep journaling! We need a few more entries to generate insights.",
                icon: "pencil.and.outline",
                category: .suggestion
            )]
        }
        
        var insights: [Insight] = []
        
        // Run all insight generators
        insights.append(contentsOf: weekendVsWeekdayInsight(entries))
        insights.append(contentsOf: tagSentimentInsights(entries))
        insights.append(contentsOf: streakInsight(entries))
        insights.append(contentsOf: timeOfDayInsight(entries))
        insights.append(contentsOf: trendInsight(entries))
        insights.append(contentsOf: volumeInsight(entries))
        insights.append(contentsOf: emotionInsight(entries))
        insights.append(contentsOf: consistencyInsight(entries))
        
        return insights
    }
    
    // MARK: - Insight Generators
    
    /// Compares mood scores between weekdays and weekends
    private func weekendVsWeekdayInsight(_ entries: [JournalEntry]) -> [Insight] {
        let weekendEntries = entries.filter { $0.date.isWeekend }
        let weekdayEntries = entries.filter { !$0.date.isWeekend }
        
        guard weekendEntries.count >= 2, weekdayEntries.count >= 2 else { return [] }
        
        let weekendAvg = weekendEntries.map(\.sentimentScore).average
        let weekdayAvg = weekdayEntries.map(\.sentimentScore).average
        let diff = weekendAvg - weekdayAvg
        
        if diff > 0.2 {
            return [Insight(
                text: "You tend to feel better on weekends. Your weekend mood averages \(String(format: "%.0f", diff * 100))% higher.",
                icon: "sun.max.fill",
                category: .pattern
            )]
        } else if diff < -0.2 {
            return [Insight(
                text: "Interestingly, your weekday entries are more positive than weekends.",
                icon: "briefcase.fill",
                category: .pattern
            )]
        }
        
        return []
    }
    
    /// Analyzes sentiment by tag to find patterns
    private func tagSentimentInsights(_ entries: [JournalEntry]) -> [Insight] {
        var tagScores: [String: [Double]] = [:]
        
        for entry in entries {
            for tag in entry.tags {
                tagScores[tag, default: []].append(entry.sentimentScore)
            }
        }
        
        var insights: [Insight] = []
        
        for (tag, scores) in tagScores {
            guard scores.count >= 2 else { continue }
            let avg = scores.average
            
            if avg < -0.3 {
                insights.append(Insight(
                    text: "Entries about '\(tag)' tend to be more negative. Consider what's causing stress here.",
                    icon: "exclamationmark.triangle.fill",
                    category: .pattern
                ))
            } else if avg > 0.5 {
                insights.append(Insight(
                    text: "'\(tag.capitalized)' entries are consistently positive! This seems to bring you joy.",
                    icon: "heart.fill",
                    category: .pattern
                ))
            }
        }
        
        // Limit to top 3 tag insights
        return Array(insights.prefix(3))
    }
    
    /// Detects positive or negative streaks
    private func streakInsight(_ entries: [JournalEntry]) -> [Insight] {
        let sorted = entries.sorted { $0.date > $1.date }
        
        // Count consecutive positive days
        var positiveStreak = 0
        for entry in sorted {
            if entry.sentimentScore > 0.1 {
                positiveStreak += 1
            } else {
                break
            }
        }
        
        if positiveStreak >= 3 {
            return [Insight(
                text: "You're on a \(positiveStreak)-entry positive streak! Keep it up! 🎉",
                icon: "flame.fill",
                category: .milestone
            )]
        }
        
        // Count consecutive negative days
        var negativeStreak = 0
        for entry in sorted {
            if entry.sentimentScore < -0.1 {
                negativeStreak += 1
            } else {
                break
            }
        }
        
        if negativeStreak >= 3 {
            return [Insight(
                text: "The last \(negativeStreak) entries have been tough. Remember, difficult periods pass. Consider talking to someone you trust.",
                icon: "heart.circle.fill",
                category: .suggestion
            )]
        }
        
        return []
    }
    
    /// Analyzes if time of day affects mood
    private func timeOfDayInsight(_ entries: [JournalEntry]) -> [Insight] {
        let morningEntries = entries.filter { (5...11).contains($0.date.hourOfDay) }
        let eveningEntries = entries.filter { (17...23).contains($0.date.hourOfDay) }
        
        guard morningEntries.count >= 2, eveningEntries.count >= 2 else { return [] }
        
        let morningAvg = morningEntries.map(\.sentimentScore).average
        let eveningAvg = eveningEntries.map(\.sentimentScore).average
        
        if morningAvg - eveningAvg > 0.25 {
            return [Insight(
                text: "Your morning entries tend to be more positive. You might be a morning person!",
                icon: "sunrise.fill",
                category: .pattern
            )]
        } else if eveningAvg - morningAvg > 0.25 {
            return [Insight(
                text: "You tend to feel better in the evenings. Your best reflections come later in the day.",
                icon: "moon.stars.fill",
                category: .pattern
            )]
        }
        
        return []
    }
    
    /// Detects overall mood trend (improving or declining)
    private func trendInsight(_ entries: [JournalEntry]) -> [Insight] {
        let sorted = entries.sorted { $0.date < $1.date }
        guard sorted.count >= 5 else { return [] }
        
        let halfPoint = sorted.count / 2
        let firstHalf = Array(sorted.prefix(halfPoint))
        let secondHalf = Array(sorted.suffix(halfPoint))
        
        let firstAvg = firstHalf.map(\.sentimentScore).average
        let secondAvg = secondHalf.map(\.sentimentScore).average
        let diff = secondAvg - firstAvg
        
        if diff > 0.2 {
            return [Insight(
                text: "Your mood has been trending upward recently. You're making progress! 📈",
                icon: "arrow.up.right",
                category: .trend
            )]
        } else if diff < -0.2 {
            return [Insight(
                text: "Your mood has dipped recently compared to earlier entries. Be gentle with yourself.",
                icon: "arrow.down.right",
                category: .trend
            )]
        }
        
        return []
    }
    
    /// Insights based on journaling volume
    private func volumeInsight(_ entries: [JournalEntry]) -> [Insight] {
        var insights: [Insight] = []
        
        if entries.count >= 30 {
            insights.append(Insight(
                text: "You've written \(entries.count) journal entries! Consistency is the key to self-awareness.",
                icon: "star.fill",
                category: .milestone
            ))
        } else if entries.count >= 7 {
            insights.append(Insight(
                text: "You've completed your first week of journaling. Great start!",
                icon: "checkmark.seal.fill",
                category: .milestone
            ))
        }
        
        // Average word count
        let totalWords = entries.map { $0.text.wordCount }.reduce(0, +)
        let avgWords = entries.isEmpty ? 0 : totalWords / entries.count
        
        if avgWords > 50 {
            insights.append(Insight(
                text: "Your entries average \(avgWords) words. Detailed reflection leads to deeper insights.",
                icon: "text.alignleft",
                category: .pattern
            ))
        }
        
        return insights
    }
    
    /// Most common emotional tone insights
    private func emotionInsight(_ entries: [JournalEntry]) -> [Insight] {
        var toneCounts: [String: Int] = [:]
        for entry in entries {
            for tone in entry.emotionalTones {
                toneCounts[tone, default: 0] += 1
            }
        }
        
        guard let topEmotion = toneCounts.max(by: { $0.value < $1.value }) else { return [] }
        
        let percentage = Int(Double(topEmotion.value) / Double(entries.count) * 100)
        
        if percentage >= 30 {
            return [Insight(
                text: "'\(topEmotion.key.capitalized)' is your most common emotional tone, appearing in \(percentage)% of your entries.",
                icon: "face.smiling",
                category: .pattern
            )]
        }
        
        return []
    }
    
    /// Checks journaling consistency
    private func consistencyInsight(_ entries: [JournalEntry]) -> [Insight] {
        guard entries.count >= 7 else { return [] }
        
        // Count unique days with entries in the last 14 days
        let twoWeeksAgo = Date.now.addingDays(-14)
        let recentEntries = entries.filter { $0.date >= twoWeeksAgo }
        let uniqueDays = Set(recentEntries.map { Calendar.current.startOfDay(for: $0.date) })
        
        if uniqueDays.count >= 12 {
            return [Insight(
                text: "You've journaled \(uniqueDays.count) out of the last 14 days. Impressive consistency!",
                icon: "calendar.badge.checkmark",
                category: .milestone
            )]
        } else if uniqueDays.count <= 3 {
            return [Insight(
                text: "Try to journal more regularly. Even a few sentences daily can boost self-awareness.",
                icon: "calendar",
                category: .suggestion
            )]
        }
        
        return []
    }
}
