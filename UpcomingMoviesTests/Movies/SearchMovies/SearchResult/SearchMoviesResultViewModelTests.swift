//
//  SearchMoviesResultViewModelTests.swift
//  UpcomingMoviesTests
//
//  Created by Alonso on 27/08/24.
//  Copyright © 2024 Alonso. All rights reserved.
//

import XCTest
@testable import UpcomingMovies
import UpcomingMoviesDomain

@MainActor
final class SearchMoviesResultViewModelTests: XCTestCase {

    private var featureDependencies: SearchMoviesFeatureTestDependencies!

    override func setUp() {
        super.setUp()
        featureDependencies = SearchMoviesFeatureTestDependencies()
    }

    override func tearDown() {
        featureDependencies = nil
        super.tearDown()
    }

    func testEmptySearchResultsTitle() {
        // Arrange
        let viewModelToTest = SearchMoviesResultViewModel(searchMoviesFeature: featureDependencies.makeFeature())
        // Act
        let emptySearchResultsTitle = viewModelToTest.emptySearchResultsTitle
        // Assert
        XCTAssertEqual(emptySearchResultsTitle, "No results to show.")
    }

    func testShareTitle() {
        // Arrange
        let viewModelToTest = SearchMoviesResultViewModel(searchMoviesFeature: featureDependencies.makeFeature())
        // Act
        let recentSearchesTitle = viewModelToTest.recentSearchesTitle
        // Assert
        XCTAssertEqual(recentSearchesTitle, "Recent searches")
    }

}
