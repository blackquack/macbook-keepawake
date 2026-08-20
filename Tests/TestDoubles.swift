import Shared

final class RecordingCommandRunner: CommandRunning {
    struct Call: Equatable {
        let executable: String
        let arguments: [String]
    }

    var calls: [Call] = []
    var nextOutput = CommandOutput(stdout: "SleepDisabled 0\n", stderr: "", terminationStatus: 0)

    func run(executable: String, arguments: [String]) throws -> CommandOutput {
        calls.append(Call(executable: executable, arguments: arguments))
        return nextOutput
    }
}
