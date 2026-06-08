import Foundation

public struct CommandOutput: Equatable, Sendable {
    public let standardOutput: String
    public let standardError: String

    public init(standardOutput: String, standardError: String) {
        self.standardOutput = standardOutput
        self.standardError = standardError
    }
}

public enum CommandRunnerError: Error, Sendable {
    case failed(executable: String, status: Int32, standardError: String)
}

public actor CommandRunner {
    public init() {}

    public func run(
        executable: URL,
        arguments: [String],
        currentDirectory: URL? = nil
    ) throws -> CommandOutput {
        let process = Process()
        let standardOutput = Pipe()
        let standardError = Pipe()
        process.executableURL = executable
        process.arguments = arguments
        process.currentDirectoryURL = currentDirectory
        process.standardOutput = standardOutput
        process.standardError = standardError

        try process.run()
        process.waitUntilExit()

        let output = String(
            data: standardOutput.fileHandleForReading.readDataToEndOfFile(),
            encoding: .utf8
        ) ?? ""
        let error = String(
            data: standardError.fileHandleForReading.readDataToEndOfFile(),
            encoding: .utf8
        ) ?? ""

        guard process.terminationStatus == 0 else {
            throw CommandRunnerError.failed(
                executable: executable.path,
                status: process.terminationStatus,
                standardError: error
            )
        }
        return CommandOutput(standardOutput: output, standardError: error)
    }
}
