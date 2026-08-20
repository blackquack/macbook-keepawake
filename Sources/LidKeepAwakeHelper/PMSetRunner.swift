import Foundation
import Shared

final class PMSetRunner {
    private let commandRunner: CommandRunning

    init(commandRunner: CommandRunning = SystemCommandRunner()) {
        self.commandRunner = commandRunner
    }

    func setSleepOverride(enabled: Bool) throws -> SleepStatus {
        let result = try commandRunner.run(
            executable: PMSetCommand.executable,
            arguments: PMSetCommand.setSleepOverrideArguments(enabled: enabled)
        )

        guard result.terminationStatus == 0 else {
            let detail = result.stderr.trimmingCharacters(in: .whitespacesAndNewlines)
            throw SharedError.commandFailed(detail.isEmpty ? "pmset failed with status \(result.terminationStatus)." : detail)
        }

        let status = try readStatus()
        guard status.sleepDisabled == enabled else {
            throw SharedError.commandFailed("pmset did not produce the requested SleepDisabled state.")
        }
        return status
    }

    func readStatus() throws -> SleepStatus {
        let result = try commandRunner.run(
            executable: PMSetCommand.executable,
            arguments: PMSetCommand.statusArguments
        )

        guard result.terminationStatus == 0 else {
            let detail = result.stderr.trimmingCharacters(in: .whitespacesAndNewlines)
            throw SharedError.commandFailed(detail.isEmpty ? "pmset status failed with status \(result.terminationStatus)." : detail)
        }

        return try SleepStatusParser.parse(result.stdout)
    }
}

private struct SystemCommandRunner: CommandRunning {
    func run(executable: String, arguments: [String]) throws -> CommandOutput {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        try process.run()
        process.waitUntilExit()

        let stdout = String(data: stdoutPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        let stderr = String(data: stderrPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""

        return CommandOutput(
            stdout: stdout,
            stderr: stderr,
            terminationStatus: process.terminationStatus
        )
    }
}
