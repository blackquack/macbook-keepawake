import AppKit
import Shared

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let powerSourceMonitor = PowerSourceMonitor()
    private let powerAssertionController = PowerAssertionController()
    private lazy var coordinator = ToggleCoordinator(
        powerAssertionController: powerAssertionController,
        powerSourceMonitor: powerSourceMonitor
    )
    private var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        statusBarController = StatusBarController(coordinator: coordinator)
        statusBarController?.start()
        coordinator.start()
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        coordinator.shutdown()
        return .terminateNow
    }
}
