//
//  CustomListsFeatureTests.swift
//  UpcomingMoviesTests
//

import XCTest
@testable import UpcomingMovies
@testable import UpcomingMoviesDomain

@MainActor
final class CustomListsFeatureTests: XCTestCase {

    private var accountUseCase: AccountUseCaseProtocolMock!
    private var customListsFeature: CustomListsFeature!

    override func setUp() {
        super.setUp()
        accountUseCase = AccountUseCaseProtocolMock()
        customListsFeature = CustomListsFeature(accountUseCase: accountUseCase)
    }

    override func tearDown() {
        customListsFeature = nil
        accountUseCase = nil
        super.tearDown()
    }

    func testLoadListsMapsDomainListsForPresentation() async throws {
        accountUseCase.getCustomListsResult = .success([.with(id: "custom-list")])

        let lists = try await customListsFeature.loadLists(page: 1)

        XCTAssertEqual(lists.map(\.id), ["custom-list"])
        XCTAssertEqual(accountUseCase.getCustomListsCallCount, 1)
    }

    func testLoadListsPropagatesFailure() async {
        accountUseCase.getCustomListsResult = .failure(TestError())

        do {
            _ = try await customListsFeature.loadLists(page: 1)
            XCTFail("Expected the feature to propagate the account request failure")
        } catch {
            XCTAssertEqual(accountUseCase.getCustomListsCallCount, 1)
        }
    }
}
