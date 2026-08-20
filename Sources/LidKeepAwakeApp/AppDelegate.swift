import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let powerSourceMonitor = PowerSourceMonitor()
    private let helperInstaller = HelperInstaller()
    private lazy var helperConnection = HelperConnection()
    private lazy var stateStore = AppStateStore()
    private lazy var coordinator = ToggleCoordinator(
        helperInstaller: helperInstaller,
        helperConnection: helperConnection,
        powerSourceMonitor: powerSourceMonitor,
        stateStore: stateStore
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
