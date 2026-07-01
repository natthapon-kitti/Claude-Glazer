import SwiftUI
import ServiceManagement

struct MenuView: View {
    @ObservedObject var monitor: UsageMonitor
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("CLAUDE USAGE")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .tracking(1.5)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 14) {
                LimitRow(icon: "clock.fill", label: "5-hour window", percent: monitor.usage.fiveHourPercent, resetsAt: monitor.usage.fiveHourResetsAt, resetStyle: .time)
                LimitRow(icon: "calendar", label: "7-day window", percent: monitor.usage.weekPercent, resetsAt: monitor.usage.weekResetsAt, resetStyle: .date)
            }

            Divider()

            Toggle("Open at Login", isOn: $launchAtLogin)
                .toggleStyle(.checkbox)
                .font(.system(size: 11, weight: .medium))
                .onChange(of: launchAtLogin) { _, enabled in
                    try? enabled ? SMAppService.mainApp.register() : SMAppService.mainApp.unregister()
                }

            Divider()

            HStack(spacing: 16) {
                FooterButton(icon: "arrow.clockwise", title: "Refresh") { monitor.refresh() }
                Spacer()
                FooterButton(icon: "power", title: "Quit") { NSApplication.shared.terminate(nil) }
            }
        }
        .padding(14)
        .frame(width: 320)
    }
}

private enum ResetStyle {
    case time
    case date
}

private struct LimitRow: View {
    let icon: String
    let label: String
    let percent: Double
    let resetsAt: Date?
    let resetStyle: ResetStyle

    private var fraction: Double {
        min(percent / 100, 1)
    }

    private var tint: Color {
        switch fraction {
        case ..<0.7: .claudeAccent
        case ..<0.9: .yellow
        default: .red
        }
    }

    private var resetText: String? {
        guard let resetsAt else { return nil }
        switch resetStyle {
        case .time: return "Resets \(resetsAt.formatted(.dateTime.hour().minute()))"
        case .date: return "Resets \(resetsAt.formatted(.dateTime.month(.abbreviated).day()))"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Label {
                    Text(label)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                } icon: {
                    Image(systemName: icon)
                        .font(.system(size: 9))
                        .foregroundStyle(.tertiary)
                }
                Spacer()
                if let resetText {
                    Text(resetText)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(.tertiary)
                }
                Text("\(Int(fraction * 100))%")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(fraction >= 0.9 ? .red : .primary)
                    .frame(width: 44, alignment: .trailing)
            }

            GaugeBar(fraction: fraction, tint: tint)
        }
    }
}

private struct GaugeBar: View {
    let fraction: Double
    let tint: Color

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.secondary.opacity(0.15))
                Capsule()
                    .fill(tint.gradient)
                    .frame(width: max(geo.size.width * fraction, 3))
            }
        }
        .frame(height: 6)
        .animation(.easeOut(duration: 0.4), value: fraction)
    }
}

private struct FooterButton: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.system(size: 11, weight: .medium))
        }
        .buttonStyle(.plain)
        .foregroundStyle(.secondary)
    }
}

private extension Color {
    static let claudeAccent = Color(red: 0.85, green: 0.47, blue: 0.34)
}

#Preview {
    let monitor = UsageMonitor()
    monitor.usage = Usage(
        fiveHourPercent: 32,
        fiveHourResetsAt: Date().addingTimeInterval(3600),
        weekPercent: 68,
        weekResetsAt: Date().addingTimeInterval(3 * 24 * 3600)
    )
   return  MenuView(monitor: monitor)
}

