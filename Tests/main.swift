runTest("PMSetRunnerTests.testEnableArgumentsApplyToAllPowerSources") {
    PMSetRunnerTests().testEnableArgumentsApplyToAllPowerSources()
}
runTest("PMSetRunnerTests.testDisableArgumentsApplyToAllPowerSources") {
    PMSetRunnerTests().testDisableArgumentsApplyToAllPowerSources()
}
runTest("PMSetRunnerTests.testParserReadsEnabledState") {
    try PMSetRunnerTests().testParserReadsEnabledState()
}
runTest("PMSetRunnerTests.testParserReadsDisabledState") {
    try PMSetRunnerTests().testParserReadsDisabledState()
}
runTest("PMSetRunnerTests.testParserRejectsMissingState") {
    PMSetRunnerTests().testParserRejectsMissingState()
}
runTest("ToggleCoordinatorTests.testPowerSourceDoesNotChangeCommandScope") {
    ToggleCoordinatorTests().testPowerSourceDoesNotChangeCommandScope()
}
runTest("PowerSourceMonitorTests.testBatteryIsRecognizedAsBattery") {
    PowerSourceMonitorTests().testBatteryIsRecognizedAsBattery()
}
runTest("PowerSourceMonitorTests.testDisplayNames") {
    PowerSourceMonitorTests().testDisplayNames()
}
runTest("HelperConnectionTests.testHelperIdentifiersAreStable") {
    HelperConnectionTests().testHelperIdentifiersAreStable()
}

finishTests()
