import Foundation

public protocol RemoteRepositoryProviding: Sendable {
    func acquire(_ reference: GitHubRepositoryReference) async throws -> RemoteRepository
}

public actor RemoteRepositoryService {
    private let cloneProvider: any RemoteRepositoryProviding
    private let zipProvider: any RemoteRepositoryProviding

    public init(
        cloneProvider: any RemoteRepositoryProviding,
        zipProvider: any RemoteRepositoryProviding
    ) {
        self.cloneProvider = cloneProvider
        self.zipProvider = zipProvider
    }

    public func acquire(
        _ reference: GitHubRepositoryReference,
        preference: RemoteAcquisitionPreference
    ) async throws -> RemoteRepository {
        switch preference {
        case .automatic:
            do {
                return try await cloneProvider.acquire(reference)
            } catch {
                return try await zipProvider.acquire(reference)
            }
        case .gitClone:
            return try await cloneProvider.acquire(reference)
        case .zip:
            return try await zipProvider.acquire(reference)
        }
    }
}
