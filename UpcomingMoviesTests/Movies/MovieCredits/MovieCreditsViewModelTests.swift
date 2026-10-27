//
//  MovieCreditsViewModelTests.swift
//  UpcomingMoviesTests
//
//  Created by Alonso on 7/5/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import XCTest
@testable import UpcomingMovies
@testable import UpcomingMoviesDomain

@MainActor
final class MovieCreditsViewModelTests: XCTestCase {

    private var mockMovieUseCase: MovieUseCaseProtocolMock!
    private var movieCreditsFeature: MovieCreditsFeature!
    private var mockSectionManager: MockMovieCreditsSectionManager!
    private var viewModelToTest: MovieCreditsViewModelProtocol!

    override func setUp() {
        super.setUp()
        mockMovieUseCase = MovieUseCaseProtocolMock()
        movieCreditsFeature = MovieCreditsFeature(movieUseCase: mockMovieUseCase)
        mockSectionManager = MockMovieCreditsSectionManager()

        viewModelToTest = MovieCreditsViewModel(movieId: 1, movieTitle: "Movie 1",
                                                movieCreditsFeature: movieCreditsFeature, factory: mockSectionManager)
    }

    override func tearDown() {
        mockMovieUseCase = nil
        movieCreditsFeature = nil
        mockSectionManager = nil
        viewModelToTest = nil
        super.tearDown()
    }

    func testMovieCreditsTitle() {
        // Act
        let title = viewModelToTest.movieTitle
        // Assert
        XCTAssertEqual(title, "Movie 1")
    }

    func testGetMovieCreditsEmpty() {
        // Arrange
        let expectation = XCTestExpectation(description: "Should get empty state")
        // Act
        viewModelToTest.viewState.bind { state in
            XCTAssertEqual(state, .empty)
            expectation.fulfill()
        }
        mockMovieUseCase.getMovieCreditsResult = .success(.withEmptyValues())
        viewModelToTest.getMovieCredits(showLoader: false)
        // Assert
        wait(for: [expectation], timeout: 1.0)
    }

    func testGetMovieCreditsPopulated() {
        // Arrange
        let expectation = XCTestExpectation(description: "Should get populated state")
        // Act
        viewModelToTest.viewState.bind { state in
            XCTAssertEqual(state, .populated([MockCastProtocol(id: 1)], [MockCrewProtocol(id: 1)]))
            expectation.fulfill()
        }
        mockMovieUseCase.getMovieCreditsResult = .success(.with(cast: [.with(id: 1)], crew: [.with(id: 1)]))
        viewModelToTest.getMovieCredits(showLoader: false)
        // Assert
        wait(for: [expectation], timeout: 1.0)
    }

    func testGetMovieCreditsError() {
        // Arrange
        let errorToTest = TestError()
        let expectation = XCTestExpectation(description: "Should get error state")
        // Act
        viewModelToTest.viewState.bind { state in
            XCTAssertEqual(state, .error(errorToTest))
            expectation.fulfill()
        }
        mockMovieUseCase.getMovieCreditsResult = Result.failure(errorToTest)
        viewModelToTest.getMovieCredits(showLoader: false)
        // Assert
        wait(for: [expectation], timeout: 1.0)
    }

    func testNumberOfSections() {
        // Arrange
        let sectionsToTest: [MovieCreditsCollapsibleSection] = [
            MovieCreditsCollapsibleSection(type: .cast, opened: true),
            MovieCreditsCollapsibleSection(type: .crew, opened: true)
        ]
        mockSectionManager.sections = sectionsToTest
        // Act
        let numberOfSections = viewModelToTest.numberOfSections()
        // Assert
        XCTAssertEqual(numberOfSections, sectionsToTest.count)
    }

    func testNumberOfItemsCastSection() {
        // Arrange
        let sectionsToTest: [MovieCreditsCollapsibleSection] = [
            MovieCreditsCollapsibleSection(type: .cast, opened: true),
            MovieCreditsCollapsibleSection(type: .crew, opened: true)
        ]
        mockSectionManager.sections = sectionsToTest

        let castToTest = [Cast.with()]
        let crewToTest = [Crew.with()]
        mockMovieUseCase.getMovieCreditsResult = .success(.with(cast: castToTest, crew: crewToTest))
        // Act
        viewModelToTest.getMovieCredits(showLoader: false)
        let numberOfItems = viewModelToTest.numberOfItems(for: 0)
        // Assert
        XCTAssertEqual(numberOfItems, castToTest.count)
    }

    func testNumberOfItemsCrewSection() {
        // Arrange
        let sectionsToTest: [MovieCreditsCollapsibleSection] = [
            MovieCreditsCollapsibleSection(type: .cast, opened: true),
            MovieCreditsCollapsibleSection(type: .crew, opened: true)
        ]
        mockSectionManager.sections = sectionsToTest

        let castToTest = [Cast.with()]
        let crewToTest = [Crew.with()]
        mockMovieUseCase.getMovieCreditsResult = .success(.with(cast: castToTest, crew: crewToTest))
        // Act
        viewModelToTest.getMovieCredits(showLoader: false)
        let numberOfItems = viewModelToTest.numberOfItems(for: 1)
        // Assert
        XCTAssertEqual(numberOfItems, crewToTest.count)
    }

    func testToggleClosedSection() {
        // Arrange
        let sectionsToTest: [MovieCreditsCollapsibleSection] = [
            MovieCreditsCollapsibleSection(type: .cast, opened: false),
            MovieCreditsCollapsibleSection(type: .crew, opened: false)
        ]
        mockSectionManager.sections = sectionsToTest
        let sectionIndexToTest = Int.random(in: 0...sectionsToTest.count - 1)
        let expectation = XCTestExpectation(description: "Should toggle section")
        // Act
        viewModelToTest.didToggleSection.bind { _ in
            expectation.fulfill()
        }
        viewModelToTest.toggleSection(sectionIndexToTest)
        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(mockSectionManager.toggleSectionCallCount, 1)
    }

    func testToggleOpenedSection() {
        // Arrange
        let sectionsToTest: [MovieCreditsCollapsibleSection] = [
            MovieCreditsCollapsibleSection(type: .cast, opened: true),
            MovieCreditsCollapsibleSection(type: .crew, opened: true)
        ]
        mockSectionManager.sections = sectionsToTest
        let sectionIndexToTest = Int.random(in: 0...sectionsToTest.count - 1)
        let expectation = XCTestExpectation(description: "Should toggle section")
        // Act
        viewModelToTest.didToggleSection.bind { _ in
            expectation.fulfill()
        }
        viewModelToTest.toggleSection(sectionIndexToTest)
        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(mockSectionManager.toggleSectionCallCount, 1)
    }

    func testEmptyCreditResultsTitle() {
        // Act
        let emptyCreditResultsTitle = viewModelToTest.emptyCreditResultsTitle
        // Assert
        XCTAssertEqual(emptyCreditResultsTitle, "No credits to show.")
    }

}
