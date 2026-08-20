import Shared

struct ToggleCoordinatorTests {
    func testPowerSourceDoesNotChangeCommandScope() {
        expectEqual(PMSetCommand.setSleepOverrideArguments(enabled: true).first, "-a")
        expectEqual(PMSetCommand.setSleepOverrideArguments(enabled: false).first, "-a")
    }
}
