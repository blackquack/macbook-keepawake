import Foundation

final class AppStateStore {
    private let defaults: UserDefaults
    private let batteryWarningKey = "batteryWarningShown"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var hasShownBatteryWarning: Bool {
        defaults.bool(forKey: batteryWarningKey)
    }

    func markBatteryWarningShown() {
        defaults.set(true, forKey: batteryWarningKey)
    }
}
