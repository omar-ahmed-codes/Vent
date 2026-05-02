import Foundation
import SwiftUI
import SwiftData

/// ViewModel for the journal entry screen.
/// Handles text input, debounced sentiment analysis, auto-save,
/// and dynamic mood color computation.
@Observable
@MainActor
final class JournalViewModel {
    
    // MARK: - Published State
    
    /// The current text being edited
    var currentText: String = "" {
        didSet {
            onTextChanged()
        }
    }
    
    /// Current sentiment analysis result
    var sentimentResult: SentimentResult = .neutral
    
    /// Whether sentiment analysis is currently running
    var isAnalyzing: Bool = false
    
    /// Whether the editor is in focused/typing mode (hides chrome)
    var isEditorFocused: Bool = false
    
    /// Whether the entry has been saved
    var isSaved: Bool = false
    
    /// The entry being edited (nil for new entries)
    var currentEntry: JournalEntry?
    
    /// Dynamic background gradient based on current sentiment
    var moodGradientColors: (start: Color, end: Color) {
        DesignSystem.Colors.moodGradient(for: sentimentResult.score)
    }
    
    /// Whether there's meaningful text to analyze
    var hasContent: Bool {
        currentText.trimmingCharacters(in: .whitespacesAndNewlines).count >= 5
    }
    
    /// Word count of current text
    var wordCount: Int {
        currentText.wordCount
    }
    
    // MARK: - Dependencies
    
    private let sentimentService = SentimentService()
    private var persistenceService: PersistenceService?
    
    // MARK: - Private State
    
    /// Task for debounced sentiment analysis
    private var analysisTask: Task<Void, Never>?
    
    /// Task for debounced auto-save
    private var saveTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    init() {}
    
    /// Sets the persistence service (called from view with environment)
    func configure(with persistenceService: PersistenceService) {
        self.persistenceService = persistenceService
    }
    
    // MARK: - Text Change Handling
    
    /// Called every time the text changes.
    /// Triggers debounced analysis and auto-save.
    private func onTextChanged() {
        isSaved = false
        scheduleAnalysis()
        scheduleAutoSave()
    }
    
    /// Schedules sentiment analysis after a 500ms debounce.
    /// Cancels any pending analysis to avoid wasted work.
    private func scheduleAnalysis() {
        analysisTask?.cancel()
        
        guard hasContent else {
            sentimentResult = .neutral
            return
        }
        
        analysisTask = Task { [weak self] in
            // 500ms debounce
            try? await Task.sleep(for: .milliseconds(500))
            
            guard !Task.isCancelled else { return }
            
            await self?.performAnalysis()
        }
    }
    
    /// Performs the actual sentiment analysis on a background thread.
    private func performAnalysis() async {
        let textToAnalyze = currentText
        isAnalyzing = true
        
        // Run analysis on background thread via the actor
        let result = await sentimentService.analyze(text: textToAnalyze)
        
        guard !Task.isCancelled else { return }
        
        // Update UI on main thread (we're @MainActor)
        withAnimation(DesignSystem.Animations.moodTransition) {
            self.sentimentResult = result
        }
        isAnalyzing = false
    }
    
    /// Schedules auto-save after 2 seconds of inactivity.
    private func scheduleAutoSave() {
        saveTask?.cancel()
        
        guard hasContent else { return }
        
        saveTask = Task { [weak self] in
            // 2 second debounce for auto-save
            try? await Task.sleep(for: .seconds(2))
            
            guard !Task.isCancelled else { return }
            
            await self?.saveEntry()
        }
    }
    
    // MARK: - Public Methods
    
    /// Manually triggers a save (e.g., when user navigates away)
    func saveEntry() async {
        guard hasContent else { return }
        
        // Ensure we have the latest analysis
        let result = await sentimentService.analyze(text: currentText)
        self.sentimentResult = result
        
        if let entry = currentEntry {
            // Update existing entry
            entry.text = currentText
            entry.sentimentScore = result.score
            entry.sentimentLabel = result.label
            entry.confidence = result.confidence
            entry.emotionalTones = result.emotionalTones
            entry.tags = result.tags
            persistenceService?.updateEntry()
        } else {
            // Create new entry
            let entry = JournalEntry(
                text: currentText,
                sentimentScore: result.score,
                sentimentLabel: result.label,
                confidence: result.confidence,
                emotionalTones: result.emotionalTones,
                tags: result.tags
            )
            persistenceService?.saveEntry(entry)
            currentEntry = entry
        }
        
        // Update daily mood record
        persistenceService?.updateDailyMoodRecord()
        
        isSaved = true
        HapticManager.shared.save()
        
        // Reset saved indicator after 2 seconds
        Task {
            try? await Task.sleep(for: .seconds(2))
            if !Task.isCancelled {
                isSaved = false
            }
        }
    }
    
    /// Starts a new entry (clears current state)
    func newEntry() {
        withAnimation(DesignSystem.Animations.stateTransition) {
            currentText = ""
            sentimentResult = .neutral
            currentEntry = nil
            isEditorFocused = false
            isSaved = false
        }
    }
    
    /// Loads an existing entry for editing
    func loadEntry(_ entry: JournalEntry) {
        currentEntry = entry
        currentText = entry.text
        sentimentResult = SentimentResult(
            score: entry.sentimentScore,
            label: entry.sentimentLabel,
            confidence: entry.confidence,
            emotionalTones: entry.emotionalTones,
            tags: entry.tags
        )
    }
}
