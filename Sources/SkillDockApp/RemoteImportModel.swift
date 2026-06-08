import Foundation
import Observation
import SkillDockCore

@MainActor
@Observable
final class RemoteImportModel {
    enum Step {
        case link
        case skills
        case result
    }

    var step: Step = .link
    var link = ""
    var preference: RemoteAcquisitionPreference = .automatic
    var repository: RemoteRepository?
    var candidates: [RemoteSkillCandidate] = []
    var result: RemoteSkillImportResult?
    var isWorking = false
    var errorMessage: String?

    private let parser: GitHubURLParser
    private let repositoryService: RemoteRepositoryService
    private let scanner: RemoteSkillScanner
    private let importService: RemoteSkillImportService

    init(
        parser: GitHubURLParser = .init(),
        repositoryService: RemoteRepositoryService = .init(
            cloneProvider: GitCloneRepositoryProvider(),
            zipProvider: GitHubZipRepositoryProvider()
        ),
        scanner: RemoteSkillScanner = .init(),
        importService: RemoteSkillImportService = .init()
    ) {
        self.parser = parser
        self.repositoryService = repositoryService
        self.scanner = scanner
        self.importService = importService
    }

    var selectedCount: Int {
        candidates.filter(\.isSelected).count
    }

    func inspect(libraryPath: URL) async {
        isWorking = true
        errorMessage = nil
        defer { isWorking = false }
        do {
            let reference = try parser.parse(link)
            let repository = try await repositoryService.acquire(reference, preference: preference)
            let candidates = try await scanner.scan(repository: repository, libraryPath: libraryPath)
            guard !candidates.isEmpty else {
                cleanup(repository)
                errorMessage = "No Skills were found in this repository."
                return
            }
            self.repository = repository
            self.candidates = candidates
            step = .skills
        } catch {
            errorMessage = "SkillDock could not read this public GitHub repository."
        }
    }

    func importSelected(libraryPath: URL) async -> RemoteSkillImportResult? {
        guard let repository, selectedCount > 0 else { return nil }
        isWorking = true
        errorMessage = nil
        let result = await importService.importSelected(
            candidates: candidates,
            repository: repository,
            requestedMethod: preference,
            libraryPath: libraryPath
        )
        self.result = result
        step = .result
        isWorking = false
        cleanup(repository)
        self.repository = nil
        return result
    }

    func reset() {
        if let repository {
            cleanup(repository)
        }
        step = .link
        link = ""
        preference = .automatic
        repository = nil
        candidates = []
        result = nil
        isWorking = false
        errorMessage = nil
    }

    private func cleanup(_ repository: RemoteRepository) {
        guard repository.requiresCleanup else { return }
        let operationDirectory = repository.localRoot
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        try? FileManager.default.removeItem(at: operationDirectory)
    }
}
