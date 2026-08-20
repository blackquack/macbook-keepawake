import Foundation
import IOKit.pwr_mgt

public enum PowerAssertionError: LocalizedError, Equatable {
    case creationFailed(String)
    case releaseFailed(String)

    public var errorDescription: String? {
        switch self {
        case .creationFailed(let status):
            return "macOS could not keep the system awake (status: \(status))."
        case .releaseFailed(let status):
            return "macOS could not release the sleep-prevention request (status: \(status))."
        }
    }
}

public final class PowerAssertionController {
    private var assertionID: IOPMAssertionID?

    public private(set) var isEnabled = false

    public init() {}

    deinit {
        try? releaseAssertion()
    }

    public func setEnabled(_ enabled: Bool) throws {
        if enabled {
            try createAssertion()
        } else {
            try releaseAssertion()
        }
    }

    private func createAssertion() throws {
        guard assertionID == nil else { return }

        var newAssertionID: IOPMAssertionID = 0
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventSystemSleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "macbook-keepawake" as CFString,
            &newAssertionID
        )

        guard result == kIOReturnSuccess else {
            throw PowerAssertionError.creationFailed(String(describing: result))
        }

        assertionID = newAssertionID
        isEnabled = true
    }

    private func releaseAssertion() throws {
        guard let assertionID else {
            isEnabled = false
            return
        }

        let result = IOPMAssertionRelease(assertionID)
        guard result == kIOReturnSuccess else {
            throw PowerAssertionError.releaseFailed(String(describing: result))
        }

        self.assertionID = nil
        isEnabled = false
    }
}
