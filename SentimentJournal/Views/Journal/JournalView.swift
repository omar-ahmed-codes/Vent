import SwiftUI
import SwiftData

/// The main journal entry screen — a full-screen, minimal text editor
/// with dynamic mood-based background, floating sentiment indicator,
/// and distraction-free typing experience.
struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = JournalViewModel()
    @FocusState private var isTextFieldFocused: Bool
    @State private var showCheckIn = false
    
    var body: some View {
        ZStack {
            // Dynamic mood background
            backgroundLayer
            
            VStack(spacing: 0) {
                // Top bar (fades when typing)
                topBar
                
                // Check-in prompt (fades when typing)
                if !viewModel.isEditorFocused {
                    checkInBanner
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
                
                // Text editor
                editorArea
                
                // Bottom bar with sentiment info
                bottomBar
            }
        }
        .onAppear {
            let service = PersistenceService(modelContext: modelContext)
            viewModel.configure(with: service)
        }
        .onChange(of: isTextFieldFocused) { _, newValue in
            withAnimation(DesignSystem.Animations.stateTransition) {
                viewModel.isEditorFocused = newValue
            }
        }
        .fullScreenCover(isPresented: $showCheckIn) {
            MoodCheckInView()
        }
    }
    
    // MARK: - Background
    
    private var backgroundLayer: some View {
        LinearGradient(
            colors: [
                viewModel.moodGradientColors.start,
                viewModel.moodGradientColors.end
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .animation(DesignSystem.Animations.moodTransition, value: viewModel.sentimentResult.score)
    }
    
    // MARK: - Top Bar
    
    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting)
                    .font(DesignSystem.Typography.screenTitle)
                    .foregroundStyle(.primary)
                
                Text(DateFormatters.fullDate.string(from: .now))
                    .font(DesignSystem.Typography.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // New entry button
            if viewModel.currentEntry != nil {
                Button {
                    viewModel.newEntry()
                    isTextFieldFocused = true
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                        )
                }
                .pressEffect()
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.top, DesignSystem.Spacing.sm)
        .padding(.bottom, DesignSystem.Spacing.sm)
        .opacity(viewModel.isEditorFocused ? 0.3 : 1.0)
        .animation(DesignSystem.Animations.stateTransition, value: viewModel.isEditorFocused)
    }
    
    // MARK: - Check-In Banner
    
    private var checkInBanner: some View {
        Button {
            showCheckIn = true
            HapticManager.shared.light()
        } label: {
            HStack(spacing: DesignSystem.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hue: 0.72, saturation: 0.35, brightness: 0.85),
                                    Color(hue: 0.75, saturation: 0.30, brightness: 0.78)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Text(checkInEmoji)
                        .font(.system(size: 18))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(checkInTitle)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Text("Tap to check in")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm + 2)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.large)
                    .fill(.ultraThinMaterial)
            )
        }
        .pressEffect()
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.bottom, DesignSystem.Spacing.sm)
    }
    
    private var checkInTitle: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12: return "Morning Check-In"
        case 12..<17: return "Afternoon Check-In"
        default: return "Evening Check-In"
        }
    }
    
    private var checkInEmoji: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12: return "🌅"
        case 12..<17: return "☀️"
        default: return "🌙"
        }
    }
    
    // MARK: - Editor Area
    
    private var editorArea: some View {
        ScrollView {
            TextEditor(text: $viewModel.currentText)
                .font(DesignSystem.Typography.editorBody)
                .foregroundStyle(.primary)
                .scrollContentBackground(.hidden)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.sentences)
                .focused($isTextFieldFocused)
                .frame(minHeight: 300)
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .overlay(alignment: .topLeading) {
                    if viewModel.currentText.isEmpty {
                        Text("How are you feeling today?")
                            .font(DesignSystem.Typography.editorPlaceholder)
                            .foregroundStyle(.tertiary)
                            .padding(.horizontal, DesignSystem.Spacing.lg)
                            .padding(.top, 8)
                            .allowsHitTesting(false)
                    }
                }
        }
        .scrollDismissesKeyboard(.interactively)
    }
    
    // MARK: - Bottom Bar
    
    private var bottomBar: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            // Emotional tones
            if !viewModel.sentimentResult.emotionalTones.isEmpty && viewModel.hasContent {
                EmotionalTonePills(tones: viewModel.sentimentResult.emotionalTones)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
            
            HStack {
                // Word count
                if viewModel.hasContent {
                    Text("\(viewModel.wordCount) words")
                        .font(DesignSystem.Typography.caption)
                        .foregroundStyle(.tertiary)
                }
                
                Spacer()
                
                // Sentiment indicator
                if viewModel.hasContent {
                    SentimentIndicator(
                        result: viewModel.sentimentResult,
                        isAnalyzing: viewModel.isAnalyzing,
                        isSaved: viewModel.isSaved
                    )
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.bottom, DesignSystem.Spacing.md)
        .opacity(viewModel.isEditorFocused ? 0.6 : 1.0)
        .animation(DesignSystem.Animations.stateTransition, value: viewModel.isEditorFocused)
        .animation(DesignSystem.Animations.defaultSpring, value: viewModel.hasContent)
    }
    
    // MARK: - Helpers
    
    /// Returns a time-appropriate greeting
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<21: return "Good Evening"
        default: return "Good Night"
        }
    }
}

#Preview {
    JournalView()
        .modelContainer(for: [JournalEntry.self, MoodRecord.self, MoodCheckIn.self], inMemory: true)
}
