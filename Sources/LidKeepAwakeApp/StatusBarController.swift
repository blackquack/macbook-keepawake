import AppKit
import Shared

final class StatusBarController: NSObject {
    private let coordinator: ToggleCoordinator
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let menu = NSMenu()

    private let toggleItem = NSMenuItem(title: "Keep Mac Awake When Lid Closes", action: nil, keyEquivalent: "")
    private let powerItem = NSMenuItem(title: "Power: Unknown", action: nil, keyEquivalent: "")
    private let helperItem = NSMenuItem(title: "Helper: Not installed", action: nil, keyEquivalent: "")
    private let installItem = NSMenuItem(title: "Install Helper…", action: nil, keyEquivalent: "")
    private let errorItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")

    init(coordinator: ToggleCoordinator) {
        self.coordinator = coordinator
        super.init()
    }

    func start() {
        toggleItem.target = self
        toggleItem.action = #selector(toggleClicked)
        installItem.target = self
        installItem.action = #selector(installClicked)

        powerItem.isEnabled = false
        helperItem.isEnabled = false
        errorItem.isEnabled = false

        menu.addItem(toggleItem)
        menu.addItem(powerItem)
        menu.addItem(helperItem)
        menu.addItem(.separator())
        menu.addItem(installItem)
        menu.addItem(.separator())
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitClicked), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
        statusItem.button?.toolTip = "LidKeepAwake"

        coordinator.onStateChange = { [weak self] state in
            self?.update(state)
        }
        coordinator.onBatteryWarning = { [weak self] completion in
            self?.showBatteryWarning(completion: completion)
        }
    }

    private func update(_ state: ToggleState) {
        statusItem.button?.image = StatusIcon.image(
            enabled: state.enabled,
            hasError: state.errorMessage != nil
        )

        toggleItem.state = state.enabled ? .on : .off
        toggleItem.isEnabled = !state.busy
        powerItem.title = "Power: \(state.powerSource.displayName)"
        helperItem.title = "Helper: \(state.helperAvailability.displayName)"
        installItem.isHidden = state.helperAvailability == .ready || state.helperAvailability == .installing
        errorItem.isHidden = state.errorMessage == nil
        errorItem.title = state.errorMessage.map { "Error: \($0)" } ?? ""

        if state.powerSource == .battery && state.enabled {
            powerItem.title = "Power: Battery (sleep prevention active)"
        }
    }

    @objc private func toggleClicked() {
        coordinator.toggle()
    }

    @objc private func installClicked() {
        coordinator.installHelper()
    }

    @objc private func quitClicked() {
        NSApp.terminate(nil)
    }

    private func showBatteryWarning(completion: @escaping (Bool) -> Void) {
        let alert = NSAlert()
        alert.messageText = "Keep the Mac awake on battery?"
        alert.informativeText = "The Mac may drain its battery while the lid is closed. Do not place it in a bag or enclosed space while enabled."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Continue")
        alert.addButton(withTitle: "Cancel")
        completion(alert.runModal() == .alertFirstButtonReturn)
    }
}
