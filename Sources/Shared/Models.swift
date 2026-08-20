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
