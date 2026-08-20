import Foundation

public enum AppConstants {
    public static let appBundleIdentifier = "com.local.lidkeepawake"
    public static let helperLabel = "com.local.lidkeepawake.helper"
    public static let helperMachServiceName = "com.local.lidkeepawake.helper"
    public static let helperExecutableName = "LidKeepAwakeHelper"
    public static let helperLaunchDaemonPlistName = "com.local.lidkeepawake.helper.plist"

    public static let installedHelperPath = "/Library/PrivilegedHelperTools/\(helperLabel)"
    public static let installedLaunchDaemonPath = "/Library/LaunchDaemons/\(helperLaunchDaemonPlistName)"
}
