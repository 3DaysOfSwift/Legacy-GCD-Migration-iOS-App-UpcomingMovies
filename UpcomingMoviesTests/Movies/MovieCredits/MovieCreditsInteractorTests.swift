//
//  MovieCreditsInteractorTests.swift
//  UpcomingMoviesTests
//
//  Created by Alonso on 3/06/22.
//  Copyright © 2022 Alonso. All rights reserved.
//

import XCTest
@testable import UpcomingMovies
@testable import UpcomingMoviesDomain

@MainActor
final class MovieCreditsFeatureTests: XCTestCase {

    private var movieCreditsFeature: MovieCreditsFeature!
    private var mockMovieUseCase: MovieUseCaseProtocolMock!

    override func setUp() {
        super.setUp()
        mockMovieUseCase = MovieUseCaseProtocolMock()
        movieCreditsFeature = MovieCreditsFeature(movieUseCase: mockMovieUseCase)
    }

    override func tearDown() {
        movieCreditsFeature = nil
        mockMovieUseCase = nil
        super.tearDown()
    }

    func testLoadCreditsRequestsTheMovieUseCase() async throws {
        // Act
        mockMovieUseCase.getMovieCreditsResult = .success(.withEmptyValues())
        _ = try await movieCreditsFeature.loadCredits(forMovieWithID: 1)
        // Assert
        XCTAssertEqual(mockMovieUseCase.getMovieCreditsCallCount, 1)
    }

}
