import Foundation
import Shared

struct ToggleState: Equatable {
    var enabled = false
    var powerSource: PowerSource = .unknown
    var busy = false
    var errorMessage: String?
}

final class ToggleCoordinator {
    private let powerAssertionController: PowerAssertionController
    private let powerSourceMonitor: PowerSourceMonitor

    private(set) var state = ToggleState()
    var onStateChange: ((ToggleState) -> Void)?

    init(
        powerAssertionController: PowerAssertionController,
        powerSourceMonitor: PowerSourceMonitor
    ) {
        self.powerAssertionController = powerAssertionController
        self.powerSourceMonitor = powerSourceMonitor
    }

    func start() {
        powerSourceMonitor.onChange = { [weak self] source in
            guard let self else { return }

            self.state.powerSource = source
            if source != .ac, self.powerAssertionController.isEnabled {
                try? self.powerAssertionController.setEnabled(false)
                self.state.enabled = self.powerAssertionController.isEnabled
            }
            self.publish()
        }

        powerSourceMonitor.start()
        state.powerSource = powerSourceMonitor.current
        state.enabled = powerAssertionController.isEnabled
        if state.powerSource != .ac, state.enabled {
            try? powerAssertionController.setEnabled(false)
            state.enabled = powerAssertionController.isEnabled
        }
        publish()
    }

    func toggle() {
        guard !state.busy, state.powerSource == .ac else { return }
        performSet(enabled: !state.enabled)
    }

    func shutdown() {
        powerSourceMonitor.stop()
        try? powerAssertionController.setEnabled(false)
    }

    private func performSet(enabled: Bool) {
        guard !state.busy else { return }

        state.busy = true
        state.errorMessage = nil
        publish()

        do {
            try powerAssertionController.setEnabled(enabled)
            state.enabled = powerAssertionController.isEnabled
            state.errorMessage = nil
        } catch {
            state.enabled = powerAssertionController.isEnabled
            state.errorMessage = error.localizedDescription
        }

        state.busy = false
        publish()
    }

    private func publish() {
        onStateChange?(state)
    }
}
