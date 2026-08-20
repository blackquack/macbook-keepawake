import Foundation
import Darwin

private var testFailures = 0

func expectTrue(_ value: Bool, _ message: String = "Expected true") {
    if !value {
        testFailures += 1
        print("FAIL: \(message)")
    }
}

func expectFalse(_ value: Bool, _ message: String = "Expected false") {
    expectTrue(!value, message)
}

func expectEqual<T: Equatable>(_ actual: T, _ expected: T, _ message: String = "Values differ") {
    if actual != expected {
        testFailures += 1
        print("FAIL: \(message). Actual: \(actual), expected: \(expected)")
    }
}

func expectThrows(_ body: () throws -> Void, _ message: String = "Expected an error") {
    do {
        try body()
        testFailures += 1
        print("FAIL: \(message)")
    } catch {
        // Expected.
    }
}

func runTest(_ name: String, _ body: () throws -> Void) {
    do {
        try body()
        print("PASS: \(name)")
    } catch {
        testFailures += 1
        print("FAIL: \(name): \(error.localizedDescription)")
    }
}

func finishTests() -> Never {
    if testFailures == 0 {
        print("All tests passed.")
        exit(0)
    }
    print("\(testFailures) test failure(s).")
    exit(1)
}
