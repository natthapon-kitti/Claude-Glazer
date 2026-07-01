import SwiftUI

@main
struct ClaudeUsageMenuBarApp: App {
    @StateObject private var monitor = UsageMonitor()

    var body: some Scene {
        MenuBarExtra {
            MenuView(monitor: monitor)
                .task { monitor.start() }
        } label: {
            Image(systemName: "gauge.with.needle", variableValue: max(monitor.usage.fiveHourPercent, monitor.usage.weekPercent) / 100)
        }
        .menuBarExtraStyle(.window)
    }
}
