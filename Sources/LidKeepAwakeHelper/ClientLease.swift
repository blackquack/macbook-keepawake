import Foundation

final class ClientLease {
    var onExpired: (() -> Void)?
    private(set) var isActive = false
    private var generation = 0

    func attach(to connection: NSXPCConnection) {
        generation += 1
        let connectionGeneration = generation
        isActive = true
        connection.invalidationHandler = { [weak self] in
            self?.expire(connectionGeneration)
        }
        connection.interruptionHandler = { [weak self] in
            self?.expire(connectionGeneration)
        }
    }

    func expire() {
        expire(generation)
    }

    private func expire(_ connectionGeneration: Int) {
        guard connectionGeneration == generation else { return }
        guard isActive else { return }
        isActive = false
        onExpired?()
    }
}
