import SwiftUI
import SwiftData

/// Full entry detail view for viewing and editing a journal entry.
/// Shows the full text, sentiment analysis details, emotional tones, and tags.
struct EntryDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let entry: JournalEntry
    @State private var editedText: String
    @State private var isEditing = false
    @State private var showDeleteAlert = false
    
    init(entry: JournalEntry) {
        self.entry = entry
        self._editedText = State(initialValue: entry.text)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                // Date header
                dateHeader
                
                // Sentiment overview
                sentimentOverview
                
                // Entry text
                entryContent
                
                // Emotional tones
                if !entry.emotionalTones.isEmpty {
                    emotionalTonesSection
                }
                
                // Tags
                if !entry.tags.isEmpty {
                    tagsSection
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }
        .background(
            LinearGradient(
                colors: [
                    DesignSystem.Colors.moodGradient(for: entry.sentimentScore).start.opacity(0.3),
                    Color(.systemBackground)
                ],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        isEditing.toggle()
                    } label: {
                        Label(isEditing ? "Done Editing" : "Edit", systemImage: isEditing ? "checkmark" : "pencil")
                    }
                    
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 18))
                }
            }
        }
        .alert("Delete Entry?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteEntry()
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
    
    // MARK: - Date Header
    
    private var dateHeader: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text(DateFormatters.fullDate.string(from: entry.date))
                .font(DesignSystem.Typography.sectionHeader)
                .foregroundStyle(.primary)
            
            Text(DateFormatters.timeOnly.string(from: entry.date))
                .font(DesignSystem.Typography.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Sentiment Overview
    
    private var sentimentOverview: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            // Emoji and label
            VStack(spacing: DesignSystem.Spacing.xs) {
                Text(entry.sentimentEmoji)
                    .font(.system(size: 40))
                
                Text(entry.sentimentLabel.capitalized)
                    .font(DesignSystem.Typography.captionMedium)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
                .frame(height: 50)
            
            // Score and confidence
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                HStack {
                    Text("Score")
                        .font(DesignSystem.Typography.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(String(format: "%+.2f", entry.sentimentScore))
                        .font(DesignSystem.Typography.smallNumber)
                        .foregroundStyle(.primary)
                }
                
                // Score bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        Capsule()
                            .fill(.secondary.opacity(0.15))
                            .frame(height: 6)
                        
                        // Fill
                        Capsule()
                            .fill(
                                DesignSystem.Colors.badgeColor(for: entry.sentimentLabel)
                            )
                            .frame(
                                width: geometry.size.width * entry.normalizedMoodScore,
                                height: 6
                            )
                    }
                }
                .frame(height: 6)
                
                HStack {
                    Text("Confidence")
                        .font(DesignSystem.Typography.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(Int(entry.confidence * 100))%")
                        .font(DesignSystem.Typography.smallNumber)
                        .foregroundStyle(.primary)
                }
            }
        }
        .cardStyle()
    }
    
    // MARK: - Entry Content
    
    private var entryContent: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            if isEditing {
                TextEditor(text: $editedText)
                    .font(DesignSystem.Typography.editorBody)
                    .frame(minHeight: 200)
                    .scrollContentBackground(.hidden)
                
                Button("Save Changes") {
                    saveChanges()
                }
                .font(DesignSystem.Typography.bodyMedium)
                .foregroundStyle(.white)
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(
                    Capsule()
                        .fill(DesignSystem.Colors.accent)
                )
                .pressEffect()
            } else {
                Text(entry.text)
                    .font(DesignSystem.Typography.editorBody)
                    .foregroundStyle(.primary)
                    .lineSpacing(6)
                    .textSelection(.enabled)
            }
            
            // Word count
            Text("\(entry.text.wordCount) words")
                .font(DesignSystem.Typography.caption)
                .foregroundStyle(.tertiary)
        }
    }
    
    // MARK: - Emotional Tones
    
    private var emotionalTonesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Emotional Tones")
                .font(DesignSystem.Typography.captionMedium)
                .foregroundStyle(.secondary)
            
            FlowLayout(spacing: DesignSystem.Spacing.sm) {
                ForEach(entry.emotionalTones, id: \.self) { tone in
                    Text(tone.capitalized)
                        .font(DesignSystem.Typography.captionMedium)
                        .foregroundStyle(DesignSystem.Colors.accent)
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .padding(.vertical, DesignSystem.Spacing.xs)
                        .background(
                            Capsule()
                                .fill(DesignSystem.Colors.accent.opacity(0.1))
                        )
                }
            }
        }
    }
    
    // MARK: - Tags
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Tags")
                .font(DesignSystem.Typography.captionMedium)
                .foregroundStyle(.secondary)
            
            FlowLayout(spacing: DesignSystem.Spacing.sm) {
                ForEach(entry.tags, id: \.self) { tag in
                    HStack(spacing: 4) {
                        Image(systemName: "tag.fill")
                            .font(.system(size: 10))
                        Text(tag.capitalized)
                            .font(DesignSystem.Typography.captionMedium)
                    }
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.vertical, DesignSystem.Spacing.xs)
                    .background(
                        Capsule()
                            .fill(.secondary.opacity(0.1))
                    )
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func saveChanges() {
        entry.text = editedText
        try? modelContext.save()
        isEditing = false
        HapticManager.shared.save()
    }
    
    private func deleteEntry() {
        modelContext.delete(entry)
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Flow Layout

/// A simple flow layout that wraps items to the next line when they don't fit.
struct FlowLayout: Layout {
    let spacing: CGFloat
    
    init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }
    
    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }
        
        return (positions, CGSize(width: maxX, height: y + rowHeight))
    }
}
