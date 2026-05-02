import SwiftUI

/// Main tab bar navigation for the app.
/// Features 4 tabs: Journal, Insights, History, Settings.
/// Uses a clean, minimal tab bar with custom styling.
struct MainTabView: View {
    @State private var selectedTab: Tab = .journal
    
    enum Tab: String, CaseIterable {
        case journal = "Journal"
        case insights = "Insights"
        case history = "History"
        case settings = "Settings"
        
        var icon: String {
            switch self {
            case .journal: return "pencil.line"
            case .insights: return "chart.xyaxis.line"
            case .history: return "clock.arrow.circlepath"
            case .settings: return "gearshape"
            }
        }
        
        var selectedIcon: String {
            switch self {
            case .journal: return "pencil.line"
            case .insights: return "chart.xyaxis.line"
            case .history: return "clock.arrow.circlepath"
            case .settings: return "gearshape.fill"
            }
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            JournalView()
                .tabItem {
                    Label(Tab.journal.rawValue, systemImage: selectedTab == .journal ? Tab.journal.selectedIcon : Tab.journal.icon)
                }
                .tag(Tab.journal)
            
            InsightsView()
                .tabItem {
                    Label(Tab.insights.rawValue, systemImage: selectedTab == .insights ? Tab.insights.selectedIcon : Tab.insights.icon)
                }
                .tag(Tab.insights)
            
            HistoryView()
                .tabItem {
                    Label(Tab.history.rawValue, systemImage: selectedTab == .history ? Tab.history.selectedIcon : Tab.history.icon)
                }
                .tag(Tab.history)
            
            SettingsView()
                .tabItem {
                    Label(Tab.settings.rawValue, systemImage: selectedTab == .settings ? Tab.settings.selectedIcon : Tab.settings.icon)
                }
                .tag(Tab.settings)
        }
        .tint(DesignSystem.Colors.accent)
        .onChange(of: selectedTab) { _, _ in
            HapticManager.shared.selection()
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [JournalEntry.self, MoodRecord.self], inMemory: true)
}
