//
//  CustomListDetailFeatureTests.swift
//  UpcomingMoviesTests
//

import XCTest
@testable import UpcomingMovies
@testable import UpcomingMoviesDomain

@MainActor
final class CustomListDetailFeatureTests: XCTestCase {

    private var accountUseCase: AccountUseCaseProtocolMock!
    private var customListDetailFeature: CustomListDetailFeature!

    override func setUp() {
        super.setUp()
        accountUseCase = AccountUseCaseProtocolMock()
        customListDetailFeature = CustomListDetailFeature(accountUseCase: accountUseCase)
    }

    override func tearDown() {
        customListDetailFeature = nil
        accountUseCase = nil
        super.tearDown()
    }

    func testLoadMoviesMapsDomainMoviesForPresentation() async throws {
        accountUseCase.getCustomListMoviesResult = .success([.with(id: 44)])

        let movies = try await customListDetailFeature.loadMovies(forListWithID: "list")

        XCTAssertEqual(movies.map(\.id), [44])
        XCTAssertEqual(accountUseCase.getCustomListMoviesCallCount, 1)
    }
}
