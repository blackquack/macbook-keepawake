import Shared

struct PowerAssertionTests {
    func testStartsDisabled() {
        let controller = PowerAssertionController()
        expectFalse(controller.isEnabled)
    }

    func testDisablingBeforeEnablingIsSafe() throws {
        let controller = PowerAssertionController()
        try controller.setEnabled(false)
        expectFalse(controller.isEnabled)
    }
}
