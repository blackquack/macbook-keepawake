import Foundation

@objc public protocol PrivilegedHelperProtocol {
    func setSleepOverride(_ enabled: Bool, withReply reply: @escaping (Bool, String) -> Void)
    func getSleepStatus(withReply reply: @escaping (Bool, String) -> Void)
    func ping(withReply reply: @escaping (Bool) -> Void)
}
