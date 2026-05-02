<p align="center">
  <img src="Screenshots/app_icon.png" width="120" alt="Vent App Icon" />
</p>

<h1 align="center">Vent</h1>

<p align="center">
  <em>Your unfiltered journal. Write like you're texting a friend.</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/iOS-17%2B-blue?style=flat-square&logo=apple" />
  <img src="https://img.shields.io/badge/Swift-5.9-orange?style=flat-square&logo=swift" />
  <img src="https://img.shields.io/badge/SwiftUI-Native-purple?style=flat-square" />
  <img src="https://img.shields.io/badge/ML-On--Device-green?style=flat-square&logo=apple" />
  <img src="https://img.shields.io/badge/Privacy-100%25%20Local-brightgreen?style=flat-square&logo=lock" />
</p>

---

## ✨ What is Vent?

**Vent** is a privacy-first iOS journaling app that understands how you *actually* talk. No formal writing needed — use slang, abbreviations, modern lingo — Vent gets it.

It uses **on-device AI** to analyze your emotions in real-time as you type, changes the background color to match your mood, and tracks your emotional patterns over time with beautiful charts and insights.

**Zero data leaves your device. Ever.**

---

## 📱 Screenshots

<p align="center">
  <img src="Screenshots/screenshot_2.png" width="200" alt="App Screenshot 2" />
  &nbsp;
  <img src="Screenshots/screenshot_3.png" width="200" alt="App Screenshot 3" />
  &nbsp;
  <img src="Screenshots/screenshot_4.png" width="200" alt="App Screenshot 4" />
  &nbsp;
  <img src="Screenshots/screenshot_5.png" width="200" alt="App Screenshot 5" />
</p>

<p align="center">
  <img src="Screenshots/screenshot_6.png" width="200" alt="App Screenshot 6" />
  &nbsp;
  <img src="Screenshots/screenshot_7.png" width="200" alt="App Screenshot 7" />
</p>

---

## 🔥 Top Features

### 🎨 Dynamic Mood Background
The entire screen changes color based on what you write — **in real-time**.
- **Positive** vibes → Green/Teal gradient
- **Neutral** vibes → Warm Beige
- **Negative** vibes → Coral/Orange gradient

The transition is smooth and animated, giving you instant visual feedback on your emotional state.

### 🧠 AI That Gets You
Unlike generic sentiment tools, Vent's engine understands **real language**:
- **100+ slang/abbreviations** expanded automatically: `rn`, `ngl`, `tbh`, `fr fr`, `bussin`, `goated`, `lowkey`, etc.
- **Context-aware scoring**: "bored... wanna watch a movie rn" = **neutral** (not negative). It understands you're just idle, not sad.
- **16 emotional tones** detected: Happy, Calm, Excited, Playful, Grateful, Proud, Nostalgic, Romantic, Hopeful, Bored, Anxious, Stressed, Sad, Angry, Tired, Confused
- Powered by Apple's **Natural Language framework** — all processing happens on your iPhone

### 💜 Interactive Mood Check-In
Beautiful full-screen check-in flow (morning, afternoon, and evening):
1. **Rate your day** with a slider — the emoji face changes as you slide
2. **Pick your emotion** from 9 interactive icons
3. **Add a note** (optional)

Inspired by premium wellness apps — smooth animations, lavender gradient, buttery transitions.

### 📊 Mood Insights Dashboard
- **Swift Charts** line graph showing mood trends over weeks/months
- **Weekly summaries** with mini sparkline charts
- **AI-generated insights**: "Your weekends are 23% happier than weekdays"
- **Streak tracking**: see how many days in a row you've journaled

### 📝 Distraction-Free Writing
- Full-screen minimal editor — no clutter
- **No autocorrect** — write naturally, like texting
- Auto-save after 2 seconds of inactivity
- Real-time word count and emotional tone pills
- Time-based greeting (Good Morning / Afternoon / Evening / Night)

### 🔒 100% Private
- All data stored **locally** using SwiftData
- All ML runs **on-device** — no API calls, no servers, no cloud
- No third-party dependencies — pure Apple frameworks
- No tracking, no analytics, no accounts

---

## 🛠 Tech Stack

| Layer | Technology |
|-------|-----------|
| **UI** | SwiftUI |
| **Storage** | SwiftData |
| **ML/NLP** | Apple Natural Language Framework |
| **Charts** | Swift Charts |
| **Architecture** | MVVM with `@Observable` |
| **Concurrency** | Swift Actors + async/await |
| **Target** | iOS 17+ |

---

## 📁 Project Structure

```
SentimentJournal/
├── Models/
│   ├── JournalEntry.swift       # Core journal entry model
│   ├── MoodRecord.swift         # Aggregated daily mood data
│   └── MoodCheckIn.swift        # Check-in responses
├── Services/
│   ├── SentimentService.swift   # NLP engine + slang expansion
│   ├── PersistenceService.swift # SwiftData CRUD
│   └── InsightsService.swift    # Pattern detection & insights
├── ViewModels/
│   ├── JournalViewModel.swift   # Debounced analysis + auto-save
│   ├── InsightsViewModel.swift  # Chart data + summaries
│   └── HistoryViewModel.swift   # Search + filter
├── Views/
│   ├── Journal/                 # Editor, mood background, indicators
│   ├── CheckIn/                 # Interactive mood check-in flow
│   ├── Insights/                # Charts, summaries, insight cards
│   ├── History/                 # Entry list, detail view
│   ├── Settings/                # Preferences, data management
│   └── Navigation/              # Tab bar
├── Utilities/
│   ├── DesignSystem.swift       # Colors, typography, animations
│   ├── HapticManager.swift      # Haptic feedback
│   ├── DateFormatters.swift     # Shared formatters
│   ├── Extensions.swift         # Helpers & modifiers
│   └── SampleData.swift         # 30-day test dataset
└── SentimentJournalApp.swift    # App entry point
```

---

## 🚀 Getting Started

### Prerequisites
- **Xcode 15+**
- **iOS 17+ Simulator** (download in Xcode → Settings → Platforms)
- macOS Sonoma or later

### Run the App
1. Clone this repo
2. Open `Vent.xcodeproj` in Xcode
3. Select an iPhone simulator (e.g., iPhone 15 Pro)
4. Press `Cmd + R` to build and run
5. Go to **Settings → Load Sample Data** to populate test entries

---

## 👨‍💻 Designed & Created by Omar

---

<p align="center">
  <sub>Built with SwiftUI · No data leaves your device · Ever.</sub>
</p>
