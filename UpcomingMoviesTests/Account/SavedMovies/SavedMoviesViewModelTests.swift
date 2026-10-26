//
//  SavedMoviesViewModelTests.swift
//  UpcomingMoviesTests
//
//  Created by Alonso on 7/24/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import XCTest
@testable import UpcomingMovies
@testable import UpcomingMoviesDomain

@MainActor
final class SavedMoviesViewModelTests: XCTestCase {

    private var savedMoviesFeature: SavedMoviesFeature!
    private var accountUseCase: AccountUseCaseProtocolMock!
    private var viewModelToTest: SavedMoviesViewModelProtocol!

    override func setUp() {
        super.setUp()
        accountUseCase = AccountUseCaseProtocolMock()
        savedMoviesFeature = SavedMoviesFeature(accountUseCase: accountUseCase)
        viewModelToTest = SavedMoviesViewModel(savedMoviesFeature: savedMoviesFeature, collection: .favorites)
    }

    override func tearDown() {
        savedMoviesFeature = nil
        accountUseCase = nil
        viewModelToTest = nil
        super.tearDown()
    }

    func testSavedMoviesTitle() {
        // Arrange
        viewModelToTest.displayTitle = "Test title"
        // Act
        let title = viewModelToTest.displayTitle
        // Assert
        XCTAssertEqual(title, "Test title")
    }

    func testEmptyMovieResultsTitle() {
        // Act
        let title = viewModelToTest.emptyMovieResultsTitle
        // Assert
        XCTAssertEqual(title, "There are no movies to show right now.")
    }

    func testGetCollectionListPopulated() {
        // Arrange
        let moviestoTest = [MockMovieProtocol(id: 1), MockMovieProtocol(id: 2)]
        var statesToReceive: [SimpleViewState<MovieProtocol>] = [.paging(moviestoTest, next: 2), .populated(moviestoTest)]

        let expectation = XCTestExpectation(description: "Should get populated state after a paging state")
        // Act
        viewModelToTest.viewState.bind { state in
            XCTAssertEqual(state, statesToReceive.removeFirst())
            expectation.fulfill()
        }
        accountUseCase.getFavoriteListResult = Result.success(moviestoTest.map(Movie.init))
        viewModelToTest.getCollectionList()
        accountUseCase.getFavoriteListResult = Result.success([])
        viewModelToTest.getCollectionList()
        // Assert
        wait(for: [expectation], timeout: 1.0)
    }

    func testGetCollectionListPaging() {
        // Arrange
        let moviesToTest = [MockMovieProtocol(id: 1), MockMovieProtocol(id: 2)]
        let expectation = XCTestExpectation(description: "Should get paging state")
        // Act
        viewModelToTest.viewState.bind { state in
            XCTAssertEqual(state, .paging(moviesToTest, next: 2))
            expectation.fulfill()
        }
        accountUseCase.getFavoriteListResult = Result.success(moviesToTest.map(Movie.init))
        viewModelToTest.getCollectionList()
        // Assert
        wait(for: [expectation], timeout: 1.0)
    }

    func testGetCollectionListEmpty() {
        // Arrange
        let moviesToTest: [MovieProtocol] = []
        let expectation = XCTestExpectation(description: "Should get empty state")
        // Act
        viewModelToTest.viewState.bind { state in
            XCTAssertEqual(state, .empty)
            expectation.fulfill()
        }
        accountUseCase.getFavoriteListResult = Result.success([])
        viewModelToTest.getCollectionList()
        // Assert
        wait(for: [expectation], timeout: 1.0)
    }

    func testGetCollectionListError() {
        // Arrange
        let errorToTest = TestError()
        let expectation = XCTestExpectation(description: "Should get error state")
        // Act
        viewModelToTest.viewState.bind { state in
            XCTAssertEqual(state, .error(errorToTest))
            expectation.fulfill()
        }
        accountUseCase.getFavoriteListResult = Result.failure(errorToTest)
        viewModelToTest.getCollectionList()
        // Assert
        wait(for: [expectation], timeout: 1.0)
    }

    func testMovieCellsCount() {
        // Arrange
        let moviesToTest = [MockMovieProtocol(id: 1), MockMovieProtocol(id: 2)]
        // Act
        accountUseCase.getFavoriteListResult = Result.success(moviesToTest.map(Movie.init))
        viewModelToTest.getCollectionList()
        let cellsCount = viewModelToTest.movieCells.count
        // Assert
        XCTAssertEqual(cellsCount, moviesToTest.count)
    }

    func testMovieCellsZeroCount() {
        // Arrange
        let moviesToTest: [MovieProtocol] = []
        // Act
        accountUseCase.getFavoriteListResult = Result.success([])
        viewModelToTest.getCollectionList()
        let cellsCount = viewModelToTest.movieCells.count
        // Assert
        XCTAssertEqual(cellsCount, .zero)
    }

    func testMovieIndex() {
        // Arrange
        let moviesToTest = [MockMovieProtocol(id: 1), MockMovieProtocol(id: 2)]
        let indexToTest = Int.random(in: 0...moviesToTest.count - 1)
        // Act
        accountUseCase.getFavoriteListResult = Result.success(moviesToTest.map(Movie.init))
        viewModelToTest.getCollectionList()
        let movie = viewModelToTest.movie(at: indexToTest)
        // Assert
        XCTAssertEqual(movie.id, moviesToTest[indexToTest].id)
    }

}
