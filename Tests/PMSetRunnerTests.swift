import Shared

struct PMSetRunnerTests {
    func testEnableArgumentsApplyToAllPowerSources() {
        expectEqual(PMSetCommand.setSleepOverrideArguments(enabled: true), ["-a", "disablesleep", "1"])
    }

    func testDisableArgumentsApplyToAllPowerSources() {
        expectEqual(PMSetCommand.setSleepOverrideArguments(enabled: false), ["-a", "disablesleep", "0"])
    }

    func testParserReadsEnabledState() throws {
        let status = try SleepStatusParser.parse("System-wide power settings:\nSleepDisabled 1\n")
        expectTrue(status.sleepDisabled)
    }

    func testParserReadsDisabledState() throws {
        let status = try SleepStatusParser.parse("System-wide power settings:\nSleepDisabled 0\n")
        expectFalse(status.sleepDisabled)
    }

    func testParserRejectsMissingState() {
        expectThrows { _ = try SleepStatusParser.parse("System-wide power settings:\n") }
    }
}
