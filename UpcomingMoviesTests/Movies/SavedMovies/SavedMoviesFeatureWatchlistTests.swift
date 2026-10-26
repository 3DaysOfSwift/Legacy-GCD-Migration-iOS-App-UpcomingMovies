//
//  SavedMoviesFeatureWatchlistTests.swift
//  UpcomingMoviesTests
//
//  Created by Alonso on 27/08/22.
//  Copyright © 2022 Alonso. All rights reserved.
//

import XCTest
@testable import UpcomingMovies
@testable import UpcomingMoviesDomain

@MainActor
final class SavedMoviesFeatureWatchlistTests: XCTestCase {

    private var feature: SavedMoviesFeature!
    private var accountUseCase: AccountUseCaseProtocolMock! = AccountUseCaseProtocolMock()

    override func setUpWithError() throws {
        try super.setUpWithError()
        feature = SavedMoviesFeature(accountUseCase: accountUseCase)
    }

    override func tearDownWithError() throws {
        feature = nil
        accountUseCase = nil
        try super.tearDownWithError()
    }

    func testWatchlistLoadUsesTheWatchlist() async throws {
        // Arrange
        let moviesToTest = [Movie.with(id: 1)]
        accountUseCase.getWatchlistResult = .success(moviesToTest)

        let movies = try await feature.loadMovies(in: .watchlist, page: 1)
        XCTAssertEqual(movies.count, moviesToTest.count)
        XCTAssertEqual(accountUseCase.getWatchlistCallCount, 1)
    }

}
