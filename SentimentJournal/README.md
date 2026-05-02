# Sentiment Journal

A minimalist, privacy-first journaling app with on-device sentiment analysis, built entirely with SwiftUI.

![iOS 17+](https://img.shields.io/badge/iOS-17%2B-blue)
![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-green)

---

## Features

- **📝 Distraction-Free Journaling** — Full-screen minimal text editor with auto-save
- **🧠 On-Device Sentiment Analysis** — Real-time mood scoring using Apple's Natural Language framework
- **📊 Mood Visualization** — Beautiful line charts showing mood trends over time (Swift Charts)
- **🎨 Dynamic UI** — Background color smoothly transitions based on your mood
- **💡 Smart Insights** — Pattern detection like "You feel better on weekends"
- **🔒 Privacy-First** — All processing on-device. No servers, no tracking, no data collection.
- **✨ Microinteractions** — Spring animations and haptic feedback for a premium feel

---

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Language | Swift 5.9 |
| UI Framework | SwiftUI |
| Persistence | SwiftData |
| ML/NLP | Natural Language framework |
| Charts | Swift Charts |
| Architecture | MVVM with `@Observable` |
| Target | iOS 17+ |

---

## How to Run

### Prerequisites
- **Xcode 15** or later
- **iOS 17+** Simulator or device
- macOS Sonoma or later (recommended)

### Steps

1. **Open Xcode** and create a new project:
   - File → New → Project
   - Choose "App" under iOS
   - Product Name: `SentimentJournal`
   - Organization Identifier: `com.sentimentjournal`
   - Interface: **SwiftUI**
   - Storage: **SwiftData** ← Important!
   - Language: **Swift**

2. **Replace the auto-generated files** with the source files from this project:
   - Delete the auto-generated `ContentView.swift` and `Item.swift` files
   - Drag all folders (`Models/`, `Views/`, `ViewModels/`, `Services/`, `Utilities/`) into the Xcode project navigator
   - Replace the auto-generated `SentimentJournalApp.swift` with the one from this project

3. **Build and Run**:
   - Select an iOS 17+ simulator (iPhone 15 Pro recommended)
   - Press `Cmd + R` to build and run

4. **Load Sample Data** (optional):
   - Go to Settings tab → "Load Sample Data"
   - This adds 30 days of realistic test entries

---

## Architecture

```
MVVM Architecture
┌────────────────────┐
│      Views         │  SwiftUI views (presentation only)
├────────────────────┤
│    ViewModels      │  @Observable classes (business logic, state)
├────────────────────┤
│     Services       │  SentimentService, PersistenceService, InsightsService
├────────────────────┤
│      Models        │  SwiftData @Model classes
└────────────────────┘
```

### Key Design Decisions

- **SwiftData** over Core Data — Modern, less boilerplate, native SwiftUI integration
- **`@Observable`** over `ObservableObject` — More efficient observation, fewer unnecessary re-renders
- **`NLTagger`** over custom Core ML — Built-in sentiment scoring, no model file needed, fully on-device
- **Actor-based `SentimentService`** — Thread-safe ML processing without manual lock management
- **Debounced analysis** (500ms) — Prevents excessive ML calls during typing

---

## Screens

1. **Journal** — Full-screen editor with dynamic mood background
2. **Insights** — Mood charts, weekly summaries, and AI-generated insights
3. **History** — Searchable, filterable list of all past entries
4. **Settings** — Appearance, haptics, data management, privacy info

---

## Sentiment Analysis

The app uses Apple's `NLTagger` with the `.sentimentScore` scheme:

- **Score Range**: -1.0 (very negative) to +1.0 (very positive)
- **Labels**: positive (>0.1), neutral (-0.1 to 0.1), negative (<-0.1)
- **Emotional Tones**: Keyword-based detection for 12 emotions (happy, calm, anxious, stressed, etc.)
- **Tags**: Automatic category detection (work, family, health, nature, etc.)

All processing runs on a background thread via Swift's actor system.

---

## Privacy

- ✅ All data stored locally via SwiftData
- ✅ All ML processing on-device via Natural Language framework
- ✅ No network requests
- ✅ No analytics or tracking
- ✅ No third-party SDKs

---

## Project Structure

```
SentimentJournal/
├── SentimentJournalApp.swift          # App entry point
├── Models/
│   ├── JournalEntry.swift             # Journal entry data model
│   └── MoodRecord.swift               # Daily mood aggregate
├── Views/
│   ├── Navigation/
│   │   └── MainTabView.swift          # Tab bar navigation
│   ├── Journal/
│   │   ├── JournalView.swift          # Main editor screen
│   │   ├── SentimentIndicator.swift   # Mood pill badge
│   │   └── MoodBackground.swift       # Dynamic gradient modifier
│   ├── Insights/
│   │   ├── InsightsView.swift         # Analytics dashboard
│   │   ├── MoodChartView.swift        # Mood line chart
│   │   ├── WeeklySummaryView.swift    # Weekly overview cards
│   │   └── InsightCardView.swift      # Individual insight card
│   ├── History/
│   │   ├── HistoryView.swift          # Entry list with search
│   │   └── EntryDetailView.swift      # Full entry view
│   └── Settings/
│       └── SettingsView.swift         # App settings
├── ViewModels/
│   ├── JournalViewModel.swift         # Journal editor logic
│   ├── InsightsViewModel.swift        # Chart & insight data
│   └── HistoryViewModel.swift         # Entry history logic
├── Services/
│   ├── SentimentService.swift         # NLP analysis engine
│   ├── PersistenceService.swift       # SwiftData operations
│   └── InsightsService.swift          # Pattern detection
└── Utilities/
    ├── DesignSystem.swift             # Design tokens
    ├── HapticManager.swift            # Haptic feedback
    ├── DateFormatters.swift           # Shared formatters
    ├── Extensions.swift               # Utility extensions
    └── SampleData.swift               # Test data generator
```

---

## License

This project is for educational and personal use.
