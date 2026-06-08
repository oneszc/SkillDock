import Foundation
import XCTest
@testable import SkillDockCore

final class RemoteRepositoryServiceTests: XCTestCase {
    func testAutomaticUsesCloneWhenCloneSucceeds() async throws {
        let clone = StubRepositoryProvider(result: .success(repository(method: .gitClone)))
        let zip = StubRepositoryProvider(result: .success(repository(method: .zip)))
        let service = RemoteRepositoryService(cloneProvider: clone, zipProvider: zip)

        let result = try await service.acquire(reference(), preference: .automatic)

        XCTAssertEqual(result.method, .gitClone)
        let cloneCount = await clone.acquisitionCount()
        let zipCount = await zip.acquisitionCount()
        XCTAssertEqual(cloneCount, 1)
        XCTAssertEqual(zipCount, 0)
    }

    func testAutomaticFallsBackToZipWhenCloneFails() async throws {
        let clone = StubRepositoryProvider(result: .failure(StubError.failed))
        let zip = StubRepositoryProvider(result: .success(repository(method: .zip)))
        let service = RemoteRepositoryService(cloneProvider: clone, zipProvider: zip)

        let result = try await service.acquire(reference(), preference: .automatic)

        XCTAssertEqual(result.method, .zip)
        let cloneCount = await clone.acquisitionCount()
        let zipCount = await zip.acquisitionCount()
        XCTAssertEqual(cloneCount, 1)
        XCTAssertEqual(zipCount, 1)
    }

    func testExplicitCloneDoesNotInvokeZip() async {
        let clone = StubRepositoryProvider(result: .failure(StubError.failed))
        let zip = StubRepositoryProvider(result: .success(repository(method: .zip)))
        let service = RemoteRepositoryService(cloneProvider: clone, zipProvider: zip)

        do {
            _ = try await service.acquire(reference(), preference: .gitClone)
            XCTFail("Expected explicit Clone failure")
        } catch {
            let cloneCount = await clone.acquisitionCount()
            let zipCount = await zip.acquisitionCount()
            XCTAssertEqual(cloneCount, 1)
            XCTAssertEqual(zipCount, 0)
        }
    }

    func testExplicitZipDoesNotInvokeClone() async throws {
        let clone = StubRepositoryProvider(result: .success(repository(method: .gitClone)))
        let zip = StubRepositoryProvider(result: .success(repository(method: .zip)))
        let service = RemoteRepositoryService(cloneProvider: clone, zipProvider: zip)

        let result = try await service.acquire(reference(), preference: .zip)

        XCTAssertEqual(result.method, .zip)
        let cloneCount = await clone.acquisitionCount()
        let zipCount = await zip.acquisitionCount()
        XCTAssertEqual(cloneCount, 0)
        XCTAssertEqual(zipCount, 1)
    }
}

private enum StubError: Error {
    case failed
}

private actor StubRepositoryProvider: RemoteRepositoryProviding {
    private let result: Result<RemoteRepository, Error>
    private var count = 0

    init(result: Result<RemoteRepository, Error>) {
        self.result = result
    }

    func acquire(_ reference: GitHubRepositoryReference) async throws -> RemoteRepository {
        count += 1
        return try result.get()
    }

    func acquisitionCount() -> Int {
        count
    }
}

private func reference() -> GitHubRepositoryReference {
    GitHubRepositoryReference(owner: "owner", repository: "repository")
}

private func repository(method: RemoteAcquisitionMethod) -> RemoteRepository {
    RemoteRepository(
        reference: reference(),
        localRoot: URL(fileURLWithPath: "/tmp/repository"),
        method: method,
        commit: "abc123",
        requiresCleanup: method == .zip
    )
}
