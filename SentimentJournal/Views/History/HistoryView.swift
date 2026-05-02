import SwiftUI
import SwiftData

/// The entry history screen showing all past journal entries.
/// Features search, sentiment filtering, grouped by date,
/// swipe-to-delete, and navigation to entry details.
struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = HistoryViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.entries.isEmpty {
                    emptyState
                } else {
                    entryList
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
            .searchable(text: $viewModel.searchText, prompt: "Search entries, tags, emotions...")
            .onAppear {
                let service = PersistenceService(modelContext: modelContext)
                viewModel.configure(with: service)
                viewModel.fetchEntries()
            }
        }
    }
    
    // MARK: - Filter Bar
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(HistoryViewModel.SentimentFilter.allCases) { filter in
                    FilterChip(
                        label: filter.rawValue,
                        icon: filter.icon,
                        isSelected: viewModel.selectedFilter == filter
                    ) {
                        withAnimation(DesignSystem.Animations.snappySpring) {
                            viewModel.selectedFilter = filter
                        }
                        HapticManager.shared.selection()
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }
    
    // MARK: - Entry List
    
    private var entryList: some View {
        List {
            // Filter bar as first section
            Section {
                filterBar
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
            
            // Grouped entries
            ForEach(viewModel.groupedEntries, id: \.date) { group in
                Section {
                    ForEach(group.entries) { entry in
                        NavigationLink(destination: EntryDetailView(entry: entry)) {
                            EntryRowView(entry: entry)
                        }
                        .listRowBackground(Color(.secondarySystemGroupedBackground))
                    }
                    .onDelete { offsets in
                        viewModel.deleteEntries(at: offsets, in: group.entries)
                    }
                } header: {
                    Text(group.date)
                        .font(DesignSystem.Typography.captionMedium)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "book.closed")
                .font(.system(size: 56))
                .foregroundStyle(.tertiary)
            
            Text("No Entries Yet")
                .font(DesignSystem.Typography.screenTitle)
                .foregroundStyle(.primary)
            
            Text("Start writing in the Journal tab\nto see your entries here.")
                .font(DesignSystem.Typography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Entry Row

/// Compact row view for a journal entry in the list
struct EntryRowView: View {
    let entry: JournalEntry
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Sentiment emoji
            Text(entry.sentimentEmoji)
                .font(.system(size: 28))
            
            // Text preview and metadata
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(entry.preview)
                    .font(DesignSystem.Typography.body)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Text(DateFormatters.timeOnly.string(from: entry.date))
                        .font(DesignSystem.Typography.caption)
                        .foregroundStyle(.tertiary)
                    
                    // Sentiment badge
                    Text(entry.sentimentLabel.capitalized)
                        .font(DesignSystem.Typography.caption)
                        .foregroundStyle(DesignSystem.Colors.badgeColor(for: entry.sentimentLabel))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(DesignSystem.Colors.badgeColor(for: entry.sentimentLabel).opacity(0.12))
                        )
                    
                    if !entry.emotionalTones.isEmpty {
                        Text(entry.emotionalTones.first?.capitalized ?? "")
                            .font(DesignSystem.Typography.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, DesignSystem.Spacing.xs)
    }
}

// MARK: - Filter Chip

/// A selectable filter chip for the sentiment filter bar
struct FilterChip: View {
    let label: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                
                Text(label)
                    .font(DesignSystem.Typography.captionMedium)
            }
            .foregroundStyle(isSelected ? .white : .primary)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                Capsule()
                    .fill(isSelected ? DesignSystem.Colors.accent : Color(.tertiarySystemFill))
            )
        }
        .pressEffect()
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: [JournalEntry.self, MoodRecord.self], inMemory: true)
}
