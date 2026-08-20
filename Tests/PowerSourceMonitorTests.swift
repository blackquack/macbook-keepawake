import Shared

struct PowerSourceMonitorTests {
    func testBatteryIsRecognizedAsBattery() {
        expectTrue(PowerSource.battery.isBattery)
        expectFalse(PowerSource.ac.isBattery)
    }

    func testDisplayNames() {
        expectEqual(PowerSource.ac.displayName, "Connected")
        expectEqual(PowerSource.battery.displayName, "Battery")
    }
}
