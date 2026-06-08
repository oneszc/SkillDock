import Foundation

public struct RemoteSkillImportFailure: Equatable, Sendable {
    public let candidateID: String
    public let message: String

    public init(candidateID: String, message: String) {
        self.candidateID = candidateID
        self.message = message
    }
}

public struct RemoteSkillImportResult: Equatable, Sendable {
    public let copied: [URL]
    public let skipped: [URL]
    public let failures: [RemoteSkillImportFailure]

    public init(
        copied: [URL],
        skipped: [URL],
        failures: [RemoteSkillImportFailure]
    ) {
        self.copied = copied
        self.skipped = skipped
        self.failures = failures
    }
}

public actor RemoteSkillImportService {
    private let fileOperator: SkillFileOperator
    private let sourceStore: RemoteSourceStore

    public init(
        fileOperator: SkillFileOperator = .init(),
        sourceStore: RemoteSourceStore = .init()
    ) {
        self.fileOperator = fileOperator
        self.sourceStore = sourceStore
    }

    public func importSelected(
        candidates: [RemoteSkillCandidate],
        repository: RemoteRepository,
        requestedMethod: RemoteAcquisitionPreference,
        libraryPath: URL
    ) async -> RemoteSkillImportResult {
        var copied: [URL] = []
        var skipped: [URL] = []
        var failures: [RemoteSkillImportFailure] = []

        for candidate in candidates where candidate.isSelected {
            do {
                let result = try await fileOperator.copySkill(
                    from: candidate.sourceURL,
                    to: libraryPath,
                    strategy: candidate.strategy
                )
                switch result {
                case let .copied(destination):
                    try await sourceStore.upsert(
                        sourceRecord(
                            candidate: candidate,
                            destination: destination,
                            repository: repository,
                            requestedMethod: requestedMethod
                        )
                    )
                    copied.append(destination)
                case let .skipped(destination):
                    skipped.append(destination)
                }
            } catch {
                failures.append(
                    RemoteSkillImportFailure(
                        candidateID: candidate.id,
                        message: error.localizedDescription
                    )
                )
            }
        }

        return RemoteSkillImportResult(copied: copied, skipped: skipped, failures: failures)
    }

    private func sourceRecord(
        candidate: RemoteSkillCandidate,
        destination: URL,
        repository: RemoteRepository,
        requestedMethod: RemoteAcquisitionPreference
    ) -> RemoteSkillSource {
        RemoteSkillSource(
            destination: destination,
            skillName: candidate.name,
            repositoryURL: repository.reference.repositoryURL,
            owner: repository.reference.owner,
            repository: repository.reference.repository,
            branch: repository.reference.branch ?? "HEAD",
            repositoryRelativePath: candidate.repositoryRelativePath,
            requestedMethod: requestedMethod,
            actualMethod: repository.method,
            commit: repository.commit,
            installedContentHash: candidate.contentHash
        )
    }
}
