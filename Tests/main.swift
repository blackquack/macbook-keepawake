runTest("PowerAssertionTests.testStartsDisabled") {
    PowerAssertionTests().testStartsDisabled()
}
runTest("PowerAssertionTests.testDisablingBeforeEnablingIsSafe") {
    try PowerAssertionTests().testDisablingBeforeEnablingIsSafe()
}
runTest("PowerSourceMonitorTests.testBatteryIsRecognizedAsBattery") {
    PowerSourceMonitorTests().testBatteryIsRecognizedAsBattery()
}
runTest("PowerSourceMonitorTests.testDisplayNames") {
    PowerSourceMonitorTests().testDisplayNames()
}

finishTests()
