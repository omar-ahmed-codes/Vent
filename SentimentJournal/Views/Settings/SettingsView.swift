import SwiftUI
import SwiftData

/// Minimal settings screen with appearance, haptic feedback,
/// data management, and privacy information.
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hapticFeedbackEnabled") private var hapticEnabled = true
    @AppStorage("colorSchemePreference") private var colorSchemePreference = 0 // 0=auto, 1=light, 2=dark
    
    @State private var showResetAlert = false
    @State private var showLoadSampleDataAlert = false
    @State private var entryCount: Int = 0
    
    var body: some View {
        NavigationStack {
            List {
                // Preferences
                preferencesSection
                
                // Data
                dataSection
                
                // About
                aboutSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                updateEntryCount()
            }
        }
    }
    

    
    // MARK: - Preferences Section
    
    private var preferencesSection: some View {
        Section {
            Toggle(isOn: $hapticEnabled) {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Haptic Feedback")
                        Text("Subtle vibrations on save and interactions")
                            .font(DesignSystem.Typography.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "hand.tap")
                }
            }
            .tint(DesignSystem.Colors.accent)
            .onChange(of: hapticEnabled) { _, newValue in
                HapticManager.shared.isEnabled = newValue
                if newValue {
                    HapticManager.shared.selection()
                }
            }
        } header: {
            Label("Preferences", systemImage: "gearshape")
        }
    }
    
    // MARK: - Data Section
    
    private var dataSection: some View {
        Section {
            // Entry count
            HStack {
                Label("Journal Entries", systemImage: "doc.text")
                Spacer()
                Text("\(entryCount)")
                    .foregroundStyle(.secondary)
            }
            
            // Load sample data
            Button {
                showLoadSampleDataAlert = true
            } label: {
                Label("Load Sample Data", systemImage: "tray.and.arrow.down")
            }
            .alert("Load Sample Data?", isPresented: $showLoadSampleDataAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Load") {
                    loadSampleData()
                }
            } message: {
                Text("This will add 30 days of sample entries for testing. Existing entries won't be affected.")
            }
            
            // Reset data
            Button(role: .destructive) {
                showResetAlert = true
            } label: {
                Label("Delete All Data", systemImage: "trash")
                    .foregroundStyle(.red)
            }
            .alert("Delete All Data?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete Everything", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("This will permanently delete all journal entries and mood data. This cannot be undone.")
            }
        } header: {
            Label("Data", systemImage: "externaldrive")
        }
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        Section {
            // Privacy
            HStack {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Privacy")
                        Text("All data stays on your device. No external servers, no tracking.")
                            .font(DesignSystem.Typography.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "lock.shield.fill")
                        .foregroundStyle(.green)
                }
            }
            
            // ML processing
            HStack {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("On-Device ML")
                        Text("Sentiment analysis runs entirely on your device using Apple's Natural Language framework.")
                            .font(DesignSystem.Typography.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "brain")
                        .foregroundStyle(DesignSystem.Colors.accent)
                }
            }
            
            // Version
            HStack {
                Label("Version", systemImage: "info.circle")
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Label("About", systemImage: "info.circle")
        } footer: {
            Text("Designed & Created by Omar")
                .font(DesignSystem.Typography.caption)
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity)
                .padding(.top, DesignSystem.Spacing.lg)
        }
    }
    
    // MARK: - Actions
    
    private func updateEntryCount() {
        let service = PersistenceService(modelContext: modelContext)
        entryCount = service.totalEntryCount()
    }
    
    private func loadSampleData() {
        let service = PersistenceService(modelContext: modelContext)
        service.loadSampleDataIfNeeded()
        updateEntryCount()
        HapticManager.shared.success()
    }
    
    private func resetAllData() {
        do {
            try modelContext.delete(model: JournalEntry.self)
            try modelContext.delete(model: MoodRecord.self)
            try modelContext.save()
            updateEntryCount()
            HapticManager.shared.warning()
        } catch {
            print("Failed to reset data: \(error)")
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [JournalEntry.self, MoodRecord.self], inMemory: true)
}
