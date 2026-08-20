import Foundation
import Shared

final class HelperService: NSObject, NSXPCListenerDelegate, PrivilegedHelperProtocol {
    private let runner: PMSetRunner
    private let lease = ClientLease()
    private var activeConnection: NSXPCConnection?

    init(runner: PMSetRunner) {
        self.runner = runner
        super.init()

        lease.onExpired = { [weak self] in
            _ = try? self?.runner.setSleepOverride(enabled: false)
            self?.activeConnection = nil
        }
    }

    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        activeConnection?.invalidate()
        activeConnection = newConnection
        newConnection.exportedInterface = NSXPCInterface(with: PrivilegedHelperProtocol.self)
        newConnection.exportedObject = self
        lease.attach(to: newConnection)
        newConnection.resume()
        return true
    }

    func setSleepOverride(_ enabled: Bool, withReply reply: @escaping (Bool, String) -> Void) {
        do {
            let status = try runner.setSleepOverride(enabled: enabled)
            reply(true, status.sleepDisabled ? "Enabled" : "Disabled")
        } catch {
            reply(false, error.localizedDescription)
        }
    }

    func getSleepStatus(withReply reply: @escaping (Bool, String) -> Void) {
        do {
            let status = try runner.readStatus()
            reply(status.sleepDisabled, "OK")
        } catch {
            reply(false, error.localizedDescription)
        }
    }

    func ping(withReply reply: @escaping (Bool) -> Void) {
        reply(true)
    }
}
