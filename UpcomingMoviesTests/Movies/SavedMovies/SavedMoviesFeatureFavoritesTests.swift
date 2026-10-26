//
//  SavedMoviesFeatureFavoritesTests.swift
//  UpcomingMoviesTests
//
//  Created by Alonso on 24/08/22.
//  Copyright © 2022 Alonso. All rights reserved.
//

import XCTest
@testable import UpcomingMovies
@testable import UpcomingMoviesDomain

@MainActor
final class SavedMoviesFeatureFavoritesTests: XCTestCase {

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

    func testFavoritesLoadUsesTheFavoriteList() async throws {
        // Arrange
        let moviesToTest = [Movie.with(id: 1)]
        accountUseCase.getFavoriteListResult = .success(moviesToTest)

        let movies = try await feature.loadMovies(in: .favorites, page: 1)
        XCTAssertEqual(movies.count, moviesToTest.count)
        XCTAssertEqual(accountUseCase.getFavoriteListCallCount, 1)
    }

}
