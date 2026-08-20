import Shared

struct HelperConnectionTests {
    func testHelperIdentifiersAreStable() {
        expectEqual(AppConstants.helperLabel, "com.local.lidkeepawake.helper")
        expectEqual(AppConstants.helperMachServiceName, AppConstants.helperLabel)
        expectTrue(AppConstants.installedHelperPath.hasSuffix(AppConstants.helperLabel))
    }
}
