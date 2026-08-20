import Foundation

public enum PowerSource: Equatable, Sendable {
    case ac
    case battery
    case unknown

    public var displayName: String {
        switch self {
        case .ac:
            return "Connected"
        case .battery:
            return "Battery"
        case .unknown:
            return "Unknown"
        }
    }

    public var isBattery: Bool {
        self == .battery
    }
}

public struct SleepStatus: Equatable, Sendable {
    public let sleepDisabled: Bool
    public let rawOutput: String

    public init(sleepDisabled: Bool, rawOutput: String = "") {
        self.sleepDisabled = sleepDisabled
        self.rawOutput = rawOutput
    }
}

public struct CommandOutput: Equatable, Sendable {
    public let stdout: String
    public let stderr: String
    public let terminationStatus: Int32

    public init(stdout: String, stderr: String, terminationStatus: Int32) {
        self.stdout = stdout
        self.stderr = stderr
        self.terminationStatus = terminationStatus
    }
}

public protocol CommandRunning {
    func run(executable: String, arguments: [String]) throws -> CommandOutput
}

public enum PMSetCommand {
    public static let executable = "/usr/bin/pmset"

    public static func setSleepOverrideArguments(enabled: Bool) -> [String] {
        ["-a", "disablesleep", enabled ? "1" : "0"]
    }

    public static let statusArguments = ["-g"]
}

public enum SleepStatusParser {
    public static func parse(_ output: String) throws -> SleepStatus {
        for line in output.split(whereSeparator: { $0 == "\n" || $0 == "\r" }) {
            let fields = line.split(whereSeparator: { $0 == " " || $0 == "\t" })
            guard fields.count >= 2, fields[0] == "SleepDisabled" else {
                continue
            }

            switch fields[1] {
            case "0":
                return SleepStatus(sleepDisabled: false, rawOutput: output)
            case "1":
                return SleepStatus(sleepDisabled: true, rawOutput: output)
            default:
                break
            }
        }

        throw SharedError.statusUnavailable(output.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}

public enum SharedError: LocalizedError, Equatable {
    case statusUnavailable(String)
    case commandFailed(String)
    case helperUnavailable(String)

    public var errorDescription: String? {
        switch self {
        case .statusUnavailable(let output):
            return output.isEmpty ? "Sleep status was not reported by pmset." : "Sleep status was not reported by pmset: \(output)"
        case .commandFailed(let message):
            return message
        case .helperUnavailable(let message):
            return message
        }
    }
}
