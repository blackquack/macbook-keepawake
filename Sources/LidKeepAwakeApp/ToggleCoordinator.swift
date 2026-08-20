import Foundation
import Shared

struct ToggleState: Equatable {
    var enabled = false
    var powerSource: PowerSource = .unknown
    var helperAvailability: HelperAvailability = .notInstalled
    var busy = false
    var errorMessage: String?
}

final class ToggleCoordinator {
    private let helperInstaller: HelperInstaller
    private let helperConnection: HelperConnection
    private let powerSourceMonitor: PowerSourceMonitor
    private let stateStore: AppStateStore

    private(set) var state = ToggleState()
    var onStateChange: ((ToggleState) -> Void)?
    var onBatteryWarning: ((@escaping (Bool) -> Void) -> Void)?

    init(
        helperInstaller: HelperInstaller,
        helperConnection: HelperConnection,
        powerSourceMonitor: PowerSourceMonitor,
        stateStore: AppStateStore
    ) {
        self.helperInstaller = helperInstaller
        self.helperConnection = helperConnection
        self.powerSourceMonitor = powerSourceMonitor
        self.stateStore = stateStore
    }

    func start() {
        helperConnection.onDisconnected = { [weak self] in
            guard let self else { return }
            self.state.enabled = false
            self.state.errorMessage = "The helper connection ended. Sleep prevention was cleared."
            self.publish()
        }

        powerSourceMonitor.onChange = { [weak self] source in
            self?.state.powerSource = source
            self?.publish()
        }

        powerSourceMonitor.start()
        helperInstaller.refresh()
        state.helperAvailability = helperInstaller.availability
        state.powerSource = powerSourceMonitor.current
        publish()

        refreshSleepStatus()
    }

    func toggle() {
        guard !state.busy else { return }
        let nextValue = !state.enabled

        if helperInstaller.availability != .ready {
            installAndThen { [weak self] success in
                guard success else { return }
                self?.continueToggle(to: nextValue)
            }
            return
        }

        continueToggle(to: nextValue)
    }

    private func continueToggle(to nextValue: Bool) {
        if nextValue && state.powerSource == .battery && !stateStore.hasShownBatteryWarning {
            stateStore.markBatteryWarningShown()
            onBatteryWarning? { [weak self] accepted in
                guard accepted else { return }
                self?.performSet(enabled: true)
            }
            return
        }

        performSet(enabled: nextValue)
    }

    func installHelper(completion: ((Bool) -> Void)? = nil) {
        guard !state.busy else {
            completion?(false)
            return
        }

        state.busy = true
        state.errorMessage = nil
        publish()

        helperInstaller.install { [weak self] result in
            guard let self else { return }
            self.state.busy = false
            self.helperInstaller.refresh()
            self.state.helperAvailability = self.helperInstaller.availability

            switch result {
            case .success:
                self.state.errorMessage = nil
                self.publish()
                completion?(true)
            case .failure(let error):
                self.state.errorMessage = error.localizedDescription
                self.publish()
                completion?(false)
            }
        }
    }

    func shutdown() {
        powerSourceMonitor.stop()
        helperConnection.setSleepOverride(enabled: false) { [weak self] _ in
            self?.helperConnection.disconnect()
        }
    }

    private func installAndThen(completion: @escaping (Bool) -> Void) {
        installHelper(completion: completion)
    }

    private func performSet(enabled: Bool) {
        guard !state.busy else { return }
        guard helperInstaller.availability == .ready else {
            state.errorMessage = "Install the helper before enabling sleep prevention."
            publish()
            return
        }

        state.busy = true
        state.errorMessage = nil
        publish()

        helperConnection.setSleepOverride(enabled: enabled) { [weak self] result in
            guard let self else { return }
            self.state.busy = false

            switch result {
            case .success(let status):
                self.state.enabled = status.sleepDisabled
                self.state.errorMessage = nil
            case .failure(let error):
                self.state.errorMessage = error.localizedDescription
            }

            self.publish()
        }
    }

    private func refreshSleepStatus() {
        guard helperInstaller.availability == .ready else { return }

        helperConnection.getSleepStatus { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let status):
                self.state.enabled = status.sleepDisabled
                self.state.errorMessage = nil
            case .failure(let error):
                self.state.errorMessage = error.localizedDescription
            }
            self.publish()
        }
    }

    private func publish() {
        state.helperAvailability = helperInstaller.availability
        onStateChange?(state)
    }
}
