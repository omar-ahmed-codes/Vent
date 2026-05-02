import UIKit

/// Centralized haptic feedback manager.
/// Wraps UIKit's haptic generators with a clean API
/// and respects the user's preference setting.
final class HapticManager {
    static let shared = HapticManager()
    
    /// Whether haptic feedback is enabled (stored in UserDefaults)
    var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "hapticFeedbackEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "hapticFeedbackEnabled") }
    }
    
    private init() {
        // Default to enabled if not yet set
        if UserDefaults.standard.object(forKey: "hapticFeedbackEnabled") == nil {
            UserDefaults.standard.set(true, forKey: "hapticFeedbackEnabled")
        }
    }
    
    // MARK: - Impact Feedback
    
    /// Light impact — for subtle UI interactions
    func light() {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Medium impact — for standard interactions
    func medium() {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Soft impact — for background changes
    func soft() {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // MARK: - Notification Feedback
    
    /// Success notification — used when saving an entry
    func success() {
        guard isEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    /// Warning notification
    func warning() {
        guard isEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }
    
    // MARK: - Selection Feedback
    
    /// Selection changed — for pickers and toggles
    func selection() {
        guard isEnabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    // MARK: - Composite Patterns
    
    /// Custom save pattern: soft impact followed by success
    func save() {
        guard isEnabled else { return }
        success()
    }
}
