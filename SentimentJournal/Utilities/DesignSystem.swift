import SwiftUI

/// Centralized design system providing consistent visual tokens across the app.
/// All colors, typography, spacing, and animation curves are defined here
/// to ensure a cohesive, premium feel throughout.
struct DesignSystem {
    
    // MARK: - Colors
    
    struct Colors {
        // Primary palette
        static let primaryText = Color(.label)
        static let secondaryText = Color(.secondaryLabel)
        static let tertiaryText = Color(.tertiaryLabel)
        
        // Mood gradient colors — high saturation for visible background shifts
        static let positiveStart = Color(hue: 0.35, saturation: 0.45, brightness: 0.92)  // Vivid mint green
        static let positiveEnd = Color(hue: 0.50, saturation: 0.40, brightness: 0.88)    // Vivid sky blue
        
        static let neutralStart = Color(hue: 0.08, saturation: 0.12, brightness: 0.94)   // Warm beige
        static let neutralEnd = Color(hue: 0.65, saturation: 0.08, brightness: 0.92)     // Cool gray
        
        static let negativeStart = Color(hue: 0.98, saturation: 0.40, brightness: 0.92)  // Vivid coral
        static let negativeEnd = Color(hue: 0.06, saturation: 0.45, brightness: 0.88)    // Vivid orange
        
        // UI elements
        static let cardBackground = Color(.systemBackground).opacity(0.8)
        static let cardBackgroundSolid = Color(.secondarySystemBackground)
        static let divider = Color(.separator)
        
        // Chart colors
        static let chartLine = Color(hue: 0.6, saturation: 0.5, brightness: 0.8)
        static let chartGradientTop = Color(hue: 0.6, saturation: 0.4, brightness: 0.85).opacity(0.4)
        static let chartGradientBottom = Color(hue: 0.6, saturation: 0.4, brightness: 0.85).opacity(0.0)
        
        // Sentiment badge colors
        static let positiveBadge = Color(hue: 0.38, saturation: 0.45, brightness: 0.75)
        static let neutralBadge = Color(hue: 0.08, saturation: 0.15, brightness: 0.70)
        static let negativeBadge = Color(hue: 0.02, saturation: 0.45, brightness: 0.75)
        
        // Accent
        static let accent = Color(hue: 0.6, saturation: 0.55, brightness: 0.75)
        
        /// Returns gradient colors based on sentiment score.
        /// Uses interpolation for smooth transitions between mood zones.
        static func moodGradient(for score: Double) -> (start: Color, end: Color) {
            switch score {
            case 0.15...:
                return (positiveStart, positiveEnd)
            case -0.15..<0.15:
                return (neutralStart, neutralEnd)
            default:
                return (negativeStart, negativeEnd)
            }
        }
        
        /// Returns a badge color for the sentiment label
        static func badgeColor(for label: String) -> Color {
            switch label.lowercased() {
            case "positive":
                return positiveBadge
            case "negative":
                return negativeBadge
            default:
                return neutralBadge
            }
        }
    }
    
    // MARK: - Typography
    
    struct Typography {
        // Journal editor
        static let editorTitle = Font.system(.largeTitle, design: .serif, weight: .medium)
        static let editorBody = Font.system(.title3, design: .serif, weight: .regular)
        static let editorPlaceholder = Font.system(.title3, design: .serif, weight: .regular)
        
        // Navigation & headers
        static let screenTitle = Font.system(.title, design: .rounded, weight: .bold)
        static let sectionHeader = Font.system(.headline, design: .rounded, weight: .semibold)
        
        // Body text
        static let body = Font.system(.body, design: .default, weight: .regular)
        static let bodyMedium = Font.system(.body, design: .default, weight: .medium)
        static let caption = Font.system(.caption, design: .default, weight: .regular)
        static let captionMedium = Font.system(.caption, design: .default, weight: .medium)
        
        // Numbers & data
        static let largeNumber = Font.system(.title, design: .rounded, weight: .bold)
        static let smallNumber = Font.system(.callout, design: .rounded, weight: .semibold)
        
        // Insight text
        static let insightText = Font.system(.subheadline, design: .rounded, weight: .medium)
    }
    
    // MARK: - Spacing
    
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    
    struct Radius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let pill: CGFloat = 100
    }
    
    // MARK: - Animations
    
    struct Animations {
        /// Standard spring animation for most interactions
        static let defaultSpring = Animation.spring(response: 0.5, dampingFraction: 0.8)
        
        /// Snappy spring for button presses and small UI changes
        static let snappySpring = Animation.spring(response: 0.3, dampingFraction: 0.7)
        
        /// Slow, smooth transition for background color changes
        static let moodTransition = Animation.easeInOut(duration: 1.5)
        
        /// Medium transition for view state changes
        static let stateTransition = Animation.easeInOut(duration: 0.4)
        
        /// Quick fade for text/opacity changes
        static let quickFade = Animation.easeOut(duration: 0.2)
        
        /// Chart animation
        static let chartAppear = Animation.spring(response: 0.8, dampingFraction: 0.75)
    }
    
    // MARK: - Shadows
    
    struct Shadows {
        static let cardShadowColor = Color.black.opacity(0.06)
        static let cardShadowRadius: CGFloat = 12
        static let cardShadowY: CGFloat = 4
    }
}
