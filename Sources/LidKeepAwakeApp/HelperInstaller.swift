import AppKit
import Foundation
import Shared

enum HelperAvailability: Equatable {
    case ready
    case notInstalled
    case installing
    case failed(String)

    var displayName: String {
        switch self {
        case .ready:
            return "Ready"
        case .notInstalled:
            return "Not installed"
        case .installing:
            return "Installing…"
        case .failed(let message):
            return "Error: \(message)"
        }
    }
}

final class HelperInstaller {
    private let fileManager = FileManager.default

    private(set) var availability: HelperAvailability = .notInstalled

    func refresh() {
        let helperExists = fileManager.fileExists(atPath: AppConstants.installedHelperPath)
        let plistExists = fileManager.fileExists(atPath: AppConstants.installedLaunchDaemonPath)
        availability = helperExists && plistExists ? .ready : .notInstalled
    }

    func install(completion: @escaping (Result<Void, Error>) -> Void) {
        refresh()
        guard availability != .ready else {
            completion(.success(()))
            return
        }

        guard let scriptURL = Bundle.main.url(forResource: "install-helper", withExtension: "sh") else {
            let error = SharedError.helperUnavailable("The helper installer is missing from the app bundle.")
            availability = .failed(error.localizedDescription)
            completion(.failure(error))
            return
        }

        let helperURL = Bundle.main.bundleURL
            .appendingPathComponent("Contents/Library/HelperTools")
            .appendingPathComponent(AppConstants.helperExecutableName)
        let plistURL = Bundle.main.bundleURL
            .appendingPathComponent("Contents/Library/LaunchDaemons")
            .appendingPathComponent(AppConstants.helperLaunchDaemonPlistName)

        guard fileManager.fileExists(atPath: helperURL.path), fileManager.fileExists(atPath: plistURL.path) else {
            let error = SharedError.helperUnavailable("The bundled helper files are missing.")
            availability = .failed(error.localizedDescription)
            completion(.failure(error))
            return
        }

        availability = .installing

        let command = "/bin/sh \(shellQuote(scriptURL.path)) \(shellQuote(helperURL.path)) \(shellQuote(plistURL.path))"
        let appleScript = "do shell script \(appleScriptString(command)) with administrator privileges"

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", appleScript]

        let errorPipe = Pipe()
        process.standardError = errorPipe

        do {
            try process.run()
        } catch {
            availability = .failed(error.localizedDescription)
            completion(.failure(error))
            return
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            process.waitUntilExit()
            let errorOutput = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""

            DispatchQueue.main.async {
                guard let self else { return }
                self.refresh()

                if process.terminationStatus == 0 && self.availability == .ready {
                    completion(.success(()))
                } else {
                    let message = errorOutput.trimmingCharacters(in: .whitespacesAndNewlines)
                    let error = SharedError.helperUnavailable(message.isEmpty ? "The helper could not be installed." : message)
                    self.availability = .failed(error.localizedDescription)
                    completion(.failure(error))
                }
            }
        }
    }

    private func shellQuote(_ value: String) -> String {
        "'" + value.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }

    private func appleScriptString(_ value: String) -> String {
        let escaped = value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
        return "\"\(escaped)\""
    }
}
