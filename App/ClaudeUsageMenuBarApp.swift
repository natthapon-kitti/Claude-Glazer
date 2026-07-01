import SwiftUI

@main
struct ClaudeUsageMenuBarApp: App {
    @StateObject private var monitor = UsageMonitor()

    var body: some Scene {
        MenuBarExtra {
            MenuView(monitor: monitor)
                .task { monitor.start() }
        } label: {
            Text(monitor.menuTitle)
        }
        .menuBarExtraStyle(.window)
    }
}
