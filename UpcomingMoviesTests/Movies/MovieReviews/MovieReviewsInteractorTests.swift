//
//  MovieReviewsInteractorTests.swift
//  UpcomingMoviesTests
//
//  Created by Alonso on 4/06/22.
//  Copyright © 2022 Alonso. All rights reserved.
//

import XCTest
@testable import UpcomingMovies
@testable import UpcomingMoviesDomain

@MainActor
final class MovieReviewsFeatureTests: XCTestCase {

    private var movieReviewsFeature: MovieReviewsFeature!
    private var mockMovieUseCase: UpcomingMoviesDomain.MovieUseCaseProtocolMock!

    override func setUp() {
        super.setUp()
        mockMovieUseCase = MovieUseCaseProtocolMock()
        movieReviewsFeature = MovieReviewsFeature(movieUseCase: mockMovieUseCase)
    }

    override func tearDown() {
        movieReviewsFeature = nil
        mockMovieUseCase = nil
        super.tearDown()
    }

    func testLoadReviewsRequestsTheMovieUseCase() async throws {
        // Arrange
        let reviewToTest = [Review.with()]
        mockMovieUseCase.getMovieReviewsResult = .success(reviewToTest)

        let reviews = try await movieReviewsFeature.loadReviews(forMovieWithID: 1, page: 1)
        // Assert
        XCTAssertEqual(reviews.map(\.id), reviewToTest.map(\.id))
        XCTAssertEqual(mockMovieUseCase.getMovieReviewsCallCount, 1)
    }

}
