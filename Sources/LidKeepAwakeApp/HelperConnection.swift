import Foundation
import Shared

enum HelperConnectionError: LocalizedError {
    case unavailable(String)
    case rejected(String)

    var errorDescription: String? {
        switch self {
        case .unavailable(let message), .rejected(let message):
            return message
        }
    }
}

final class HelperConnection {
    private var connection: NSXPCConnection?
    var onDisconnected: (() -> Void)?

    deinit {
        connection?.invalidate()
    }

    func setSleepOverride(enabled: Bool, completion: @escaping (Result<SleepStatus, Error>) -> Void) {
        withProxy { proxy, failure in
            guard let proxy else {
                completion(.failure(failure ?? HelperConnectionError.unavailable("The helper is not available.")))
                return
            }

            proxy.setSleepOverride(enabled) { success, message in
                DispatchQueue.main.async {
                    guard success else {
                        completion(.failure(HelperConnectionError.rejected(message)))
                        return
                    }
                    self.getSleepStatus(completion: completion)
                }
            }
        }
    }

    func getSleepStatus(completion: @escaping (Result<SleepStatus, Error>) -> Void) {
        withProxy { proxy, failure in
            guard let proxy else {
                completion(.failure(failure ?? HelperConnectionError.unavailable("The helper is not available.")))
                return
            }

            proxy.getSleepStatus { enabled, message in
                DispatchQueue.main.async {
                    if enabled || message == "OK" {
                        completion(.success(SleepStatus(sleepDisabled: enabled)))
                    } else {
                        completion(.failure(HelperConnectionError.rejected(message)))
                    }
                }
            }
        }
    }

    func disconnect() {
        connection?.invalidate()
        connection = nil
    }

    private func withProxy(_ body: @escaping (PrivilegedHelperProtocol?, Error?) -> Void) {
        if let connection, let proxy = connection.remoteObjectProxyWithErrorHandler({ error in
            DispatchQueue.main.async {
                body(nil, error)
            }
        }) as? PrivilegedHelperProtocol {
            body(proxy, nil)
            return
        }

        let newConnection = NSXPCConnection(machServiceName: AppConstants.helperMachServiceName, options: .privileged)
        newConnection.remoteObjectInterface = NSXPCInterface(with: PrivilegedHelperProtocol.self)
        newConnection.interruptionHandler = { [weak self] in
            self?.onDisconnected?()
        }
        newConnection.invalidationHandler = { [weak self] in
            self?.connection = nil
            self?.onDisconnected?()
        }
        newConnection.resume()
        connection = newConnection

        guard let proxy = newConnection.remoteObjectProxyWithErrorHandler({ error in
            DispatchQueue.main.async {
                body(nil, error)
            }
        }) as? PrivilegedHelperProtocol else {
            body(nil, HelperConnectionError.unavailable("Could not create the helper proxy."))
            return
        }

        proxy.ping { [weak self] ok in
            DispatchQueue.main.async {
                guard ok else {
                    self?.disconnect()
                    body(nil, HelperConnectionError.unavailable("The helper did not respond."))
                    return
                }
                body(proxy, nil)
            }
        }
    }
}
