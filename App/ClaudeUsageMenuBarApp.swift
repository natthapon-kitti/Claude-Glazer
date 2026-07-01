import SwiftUI

@main
struct ClaudeUsageMenuBarApp: App {
    @StateObject private var monitor = UsageMonitor()

    var body: some Scene {
        MenuBarExtra {
            MenuView(monitor: monitor)
                .task { monitor.start() }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "gauge.with.needle")
                Text("5h \(Int(monitor.usage.fiveHourPercent))% · 7d \(Int(monitor.usage.weekPercent))%")
            }
        }
        .menuBarExtraStyle(.window)
    }
}
