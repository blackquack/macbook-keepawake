import Foundation
import IOKit.ps
import Shared

final class PowerSourceMonitor {
    typealias Provider = () -> PowerSource

    private let provider: Provider
    private var timer: Timer?

    private(set) var current: PowerSource
    var onChange: ((PowerSource) -> Void)?

    init(provider: @escaping Provider = SystemPowerSource.current) {
        self.provider = provider
        self.current = provider()
    }

    deinit {
        timer?.invalidate()
    }

    func start() {
        refresh()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func refresh() {
        let next = provider()
        guard next != current else { return }
        current = next
        onChange?(next)
    }
}

enum SystemPowerSource {
    static func current() -> PowerSource {
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sourceType = IOPSGetProvidingPowerSourceType(snapshot)
        guard let sourceType else {
            return .unknown
        }

        let type = sourceType.takeUnretainedValue() as String
        if type == kIOPMACPowerKey {
            return .ac
        }
        if type == kIOPMBatteryPowerKey {
            return .battery
        }
        return .unknown
    }
}
