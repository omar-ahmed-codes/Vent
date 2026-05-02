import SwiftUI

// MARK: - Color Extensions

extension Color {
    /// Creates a color from a mood score (-1.0 to +1.0)
    /// Interpolates between negative (coral), neutral (gray), and positive (green-blue)
    static func fromMoodScore(_ score: Double) -> Color {
        let clampedScore = max(-1.0, min(1.0, score))
        
        if clampedScore >= 0 {
            // Interpolate from neutral to positive
            let t = clampedScore
            let hue = 0.08 + t * 0.30    // beige → green
            let saturation = 0.08 + t * 0.17
            let brightness = 0.94 - t * 0.02
            return Color(hue: hue, saturation: saturation, brightness: brightness)
        } else {
            // Interpolate from neutral to negative
            let t = abs(clampedScore)
            let hue = 0.08 - t * 0.06    // beige → coral
            let saturation = 0.08 + t * 0.17
            let brightness = 0.94 + t * 0.01
            return Color(hue: hue, saturation: saturation, brightness: brightness)
        }
    }
}

// MARK: - Date Extensions

extension Date {
    /// Returns the start of the day for this date
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    /// Returns the start of the week (Sunday) for this date
    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }
    
    /// Returns the start of the month for this date
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
    
    /// Returns true if this date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    /// Returns true if this date falls on a weekend
    var isWeekend: Bool {
        Calendar.current.isDateInWeekend(self)
    }
    
    /// Returns the day of the week as a string (e.g., "Monday")
    var dayOfWeekString: String {
        DateFormatters.fullDayOfWeek.string(from: self)
    }
    
    /// Returns the hour of the day (0-23)
    var hourOfDay: Int {
        Calendar.current.component(.hour, from: self)
    }
    
    /// Number of days between this date and another date
    func daysBetween(_ other: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self.startOfDay, to: other.startOfDay)
        return abs(components.day ?? 0)
    }
    
    /// Returns a date offset by the specified number of days
    func addingDays(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    /// Returns a date offset by the specified number of weeks
    func addingWeeks(_ weeks: Int) -> Date {
        Calendar.current.date(byAdding: .weekOfYear, value: weeks, to: self) ?? self
    }
}

// MARK: - String Extensions

extension String {
    /// Returns the word count of the string
    var wordCount: Int {
        let words = self.split { $0.isWhitespace || $0.isNewline }
        return words.count
    }
    
    /// Returns a truncated version of the string
    func truncated(to length: Int, trailing: String = "…") -> String {
        if self.count <= length {
            return self
        }
        return String(self.prefix(length)) + trailing
    }
}

// MARK: - Array Extensions

extension Array where Element == Double {
    /// Returns the average of all elements
    var average: Double {
        guard !isEmpty else { return 0 }
        return reduce(0, +) / Double(count)
    }
}

// MARK: - View Extensions

extension View {
    /// Applies the card style used throughout the app
    func cardStyle() -> some View {
        self
            .padding(DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.large)
                    .fill(.ultraThinMaterial)
            )
            .shadow(
                color: DesignSystem.Shadows.cardShadowColor,
                radius: DesignSystem.Shadows.cardShadowRadius,
                y: DesignSystem.Shadows.cardShadowY
            )
    }
    
    /// Applies a subtle press effect on tap
    func pressEffect() -> some View {
        self.buttonStyle(PressEffectButtonStyle())
    }
}

// MARK: - Custom Button Style

/// A button style that scales down slightly on press for a tactile feel
struct PressEffectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(DesignSystem.Animations.snappySpring, value: configuration.isPressed)
    }
}
