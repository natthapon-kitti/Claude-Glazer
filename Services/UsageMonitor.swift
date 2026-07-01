import Foundation
import SwiftUI
import Combine

@MainActor
final class UsageMonitor: ObservableObject {
    @Published var usage = Usage()

    private var timer: Timer?
    private let cacheURL = FileManager.default
        .homeDirectoryForCurrentUser
        .appendingPathComponent(".claude/usage_status_cache.json")

    func start() {
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refresh()
            }
        }
    }

    func refresh() {
        Task.detached { [cacheURL] in
            let result = Self.readUsage(from: cacheURL)
            await MainActor.run { [weak self] in
                self?.usage = result
            }
        }
    }

    nonisolated private static func readUsage(from cacheURL: URL) -> Usage {
        var usage = Usage()

        guard let data = try? Data(contentsOf: cacheURL),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let rateLimits = obj["rate_limits"] as? [String: Any]
        else {
            return usage
        }

        if let fiveHour = rateLimits["five_hour"] as? [String: Any] {
            usage.fiveHourPercent = fiveHour["used_percentage"] as? Double ?? 0
            if let resetsAt = fiveHour["resets_at"] as? Double {
                usage.fiveHourResetsAt = Date(timeIntervalSince1970: resetsAt)
            }
        }

        if let sevenDay = rateLimits["seven_day"] as? [String: Any] {
            usage.weekPercent = sevenDay["used_percentage"] as? Double ?? 0
            if let resetsAt = sevenDay["resets_at"] as? Double {
                usage.weekResetsAt = Date(timeIntervalSince1970: resetsAt)
            }
        }

        return usage
    }
}
