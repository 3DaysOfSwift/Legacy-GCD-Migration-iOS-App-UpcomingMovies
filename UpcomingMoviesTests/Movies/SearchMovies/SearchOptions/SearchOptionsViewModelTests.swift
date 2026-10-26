//
//  SearchOptionsViewModelTests.swift
//  UpcomingMoviesTests
//
//  Created by Alonso on 7/10/22.
//  Copyright © 2022 Alonso. All rights reserved.
//

import XCTest
@testable import UpcomingMovies

@MainActor
final class SearchOptionsViewModelTests: XCTestCase {

    private var viewModel: SearchOptionsViewModel!
    private var featureDependencies: SearchMoviesFeatureTestDependencies!

    override func setUpWithError() throws {
        try super.setUpWithError()
        featureDependencies = SearchMoviesFeatureTestDependencies()
        viewModel = SearchOptionsViewModel(searchMoviesFeature: featureDependencies.makeFeature())
    }

    override func tearDownWithError() throws {
        viewModel = nil
        featureDependencies = nil
        try super.tearDownWithError()
    }

    func testLoadGenres() {
        // Arrange
        let genresToTest = [Genre(id: 12345, name: "Genre 1")]
        let expectation = XCTestExpectation(description: "Content reload should be called")
        // Act
        viewModel.needsContentReload.bind({ _ in
            expectation.fulfill()
        }, on: nil)
        featureDependencies.genreUseCase.fetchAllResult = .success(genresToTest)
        viewModel.loadGenres()
        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(featureDependencies.genreUseCase.fetchAllCallCount, 1)
    }

    func testLoadVisitedMoviesFirstLoad() {
        // Arrange
        let movieVisitsToTest = [MovieVisit.with()]
        let expectation = XCTestExpectation(description: "Content reload should be called")
        // Act
        viewModel.needsContentReload.bind({ _ in
            expectation.fulfill()
        }, on: nil)
        featureDependencies.movieVisitUseCase.movieVisitsResult = .success(movieVisitsToTest)
        viewModel.loadVisitedMovies()
        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(featureDependencies.movieVisitUseCase.getMovieVisitsCallCount, 1)
    }

    func testLoadVisitedMoviesUpdate() {
        // Arrange
        let movieVisitsToTest = [MovieVisit.with()]
        let expectation = XCTestExpectation(description: "Movie visit update should be called")
        // Act
        viewModel.updateVisitedMovies.bind({ _ in
            expectation.fulfill()
        }, on: nil)

        featureDependencies.movieVisitUseCase.movieVisitsResult = .success(movieVisitsToTest)
        viewModel.loadVisitedMovies()

        featureDependencies.movieVisitUseCase.didUpdateMovieVisit?()
        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(featureDependencies.movieVisitUseCase.getMovieVisitsCallCount, 2)
    }

}
