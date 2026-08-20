import AppKit
import Shared

final class StatusBarController: NSObject {
    private let coordinator: ToggleCoordinator
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let menu = NSMenu()

    private let toggleItem = NSMenuItem()
    private let toggleView = ToggleMenuItemView()
    private let powerItem = NSMenuItem()
    private let powerView = PowerStatusMenuItemView()
    private let errorItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")

    init(coordinator: ToggleCoordinator) {
        self.coordinator = coordinator
        super.init()
    }

    func start() {
        toggleView.onToggle = { [weak self] in
            self?.toggleClicked()
        }
        toggleItem.view = toggleView
        powerItem.view = powerView
        errorItem.isEnabled = false

        menu.addItem(toggleItem)
        menu.addItem(powerItem)
        menu.addItem(.separator())
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitClicked), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
        statusItem.button?.toolTip = "macbook-keepawake"

        coordinator.onStateChange = { [weak self] state in
            self?.update(state)
        }
    }

    private func update(_ state: ToggleState) {
        statusItem.button?.image = StatusIcon.image(
            enabled: state.enabled,
            hasError: state.errorMessage != nil
        )

        let acConnected = state.powerSource == .ac
        toggleView.update(
            isOn: state.enabled,
            isEnabled: acConnected && !state.busy
        )
        switch state.powerSource {
        case .ac:
            powerView.update(title: "Power: Connected", isWarning: false)
        case .battery:
            powerView.update(title: "Power: Battery - Plug in to enable", isWarning: true)
        case .unknown:
            powerView.update(title: "Power: Unknown", isWarning: false)
        }
        errorItem.isHidden = state.errorMessage == nil
        errorItem.title = state.errorMessage.map { "Error: \($0)" } ?? ""

    }

    @objc private func toggleClicked() {
        coordinator.toggle()
    }

    @objc private func quitClicked() {
        NSApp.terminate(nil)
    }
}
