//
//  CustomListsViewModelTests.swift
//  UpcomingMoviesTests
//
//  Created by Alonso on 7/27/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import XCTest
@testable import UpcomingMovies
@testable import UpcomingMoviesDomain

@MainActor
final class CustomListsViewModelTests: XCTestCase {

    typealias CustomListsState = SimpleViewState<ListProtocol>

    private var customListsFeature: CustomListsFeature!
    private var accountUseCase: AccountUseCaseProtocolMock!
    private var viewModelToTest: CustomListsViewModelProtocol!

    override func setUp() {
        super.setUp()
        accountUseCase = AccountUseCaseProtocolMock()
        customListsFeature = CustomListsFeature(accountUseCase: accountUseCase)
        viewModelToTest = CustomListsViewModel(customListsFeature: customListsFeature)
    }

    override func tearDown() {
        customListsFeature = nil
        accountUseCase = nil
        viewModelToTest = nil
        super.tearDown()
    }

    func testGetCustomListsEmpty() {
        // Arrange
        let customListsToTest: [List] = []
        let expectation = XCTestExpectation(description: "Should get empty state")
        // Act
        viewModelToTest.viewState.bind { state in
            XCTAssertEqual(state, .empty)
            expectation.fulfill()
        }
        accountUseCase.getCustomListsResult = Result.success(customListsToTest)
        viewModelToTest.getCustomLists()
        // Assert
        wait(for: [expectation], timeout: 1.0)
    }

    func testGetCustomListsPopulated() {
        // Arrange
        let customListsToTest = [List.with(id: "1"), List.with(id: "2")]
        let expectedLists = customListsToTest.map(ListModel.init)
        var statesToReceive: [CustomListsState] = [.paging(expectedLists, next: 2)]

        let expectation = XCTestExpectation(description: "Should get populated state after a paging state")
        // Act
        viewModelToTest.viewState.bind { state in
            XCTAssertEqual(state, statesToReceive.removeFirst())
            expectation.fulfill()
        }
        accountUseCase.getCustomListsResult = Result.success(customListsToTest)
        viewModelToTest.getCustomLists()
        // Assert
        wait(for: [expectation], timeout: 1.0)
    }

    func testGetCustomListsPaging() {
        // Arrange
        let customListsToTest = [List.with(id: "1"), List.with(id: "2")]
        let expectedLists = customListsToTest.map(ListModel.init)
        let expectation = XCTestExpectation(description: "Should get paging state")
        // Act
        viewModelToTest.viewState.bind { state in
            XCTAssertEqual(state, .paging(expectedLists, next: 2))
            expectation.fulfill()
        }
        accountUseCase.getCustomListsResult = Result.success(customListsToTest)
        viewModelToTest.getCustomLists()
        // Assert
        wait(for: [expectation], timeout: 1.0)
    }

    func testGetCustomListsError() {
        // Arrange
        let errorToTest = TestError()
        let expectation = XCTestExpectation(description: "Should get error state")
        // Act
        viewModelToTest.viewState.bind { state in
            XCTAssertEqual(state, .error(errorToTest))
            expectation.fulfill()
        }
        accountUseCase.getCustomListsResult = Result.failure(errorToTest)
        viewModelToTest.getCustomLists()
        // Assert
        wait(for: [expectation], timeout: 1.0)
    }

    func testTitle() {
        // Act
        let title = viewModelToTest.title
        // Assert
        XCTAssertEqual(title, "Created Lists")
    }

}
