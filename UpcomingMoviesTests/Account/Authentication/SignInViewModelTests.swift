//
//  SignInViewModelTests.swift
//  UpcomingMoviesTests
//
//  Created by Alonso on 3/07/23.
//  Copyright © 2023 Alonso. All rights reserved.
//

import XCTest
@testable import UpcomingMovies
import UpcomingMoviesDomain

@MainActor
final class SignInViewModelTests: XCTestCase {

    private var signInFeature: SignInFeature!
    private var mockUserUseCase: UserUseCaseProtocolMock!
    private var mockAuthUseCase: AuthUseCaseProtocolMock!
    private var viewModelToTest: SignInViewModelProtocol!

    override func setUp() {
        super.setUp()
        mockUserUseCase = UserUseCaseProtocolMock()
        mockAuthUseCase = AuthUseCaseProtocolMock()
        signInFeature = SignInFeature(authUseCase: mockAuthUseCase, userUseCase: mockUserUseCase)
        viewModelToTest = SignInViewModel(signInFeature: signInFeature)
    }

    override func tearDown() {
        viewModelToTest = nil
        signInFeature = nil
        mockUserUseCase = nil
        mockAuthUseCase = nil
        super.tearDown()
    }

    func testAuthorizationProcessSuccess() {
        // Arrange
        let permissionURLToTest = URL(string: "http://www.google.com")!
        let expectation = XCTestExpectation(description: "Get permission URL")
        // Act
        viewModelToTest.showAuthPermission.bind { url in
            XCTAssertNotNil(url)
            expectation.fulfill()
        }
        mockAuthUseCase.getAuthURLResult = Result.success(permissionURLToTest)
        viewModelToTest.startAuthorizationProcess()
        // Assert
        wait(for: [expectation], timeout: 1.0)
    }

    func testAuthorizationProcessError() {
        // Arrange
        let errorToTest = TestError()
        let expectation = XCTestExpectation(description: "Get permission URL error")
        // Act
        viewModelToTest.didReceiveError.bind {
            expectation.fulfill()
        }
        mockAuthUseCase.getAuthURLResult = Result.failure(errorToTest)
        viewModelToTest.startAuthorizationProcess()
        // Assert
        wait(for: [expectation], timeout: 1.0)
    }

    func testSignInUserSuccess() {
        // Arrange
        let userToTest = User.with()
        let expectation = XCTestExpectation(description: "Sign in user")
        // Act
        viewModelToTest.didUpdateAuthenticationState.bind { state in
            XCTAssertEqual(state, .justSignedIn)
            expectation.fulfill()
        }
        mockAuthUseCase.signInUserResult = Result.success(userToTest)
        viewModelToTest.signInUser()
        // Assert
        wait(for: [expectation], timeout: 1.0)
    }

    func testSignInUserError() {
        // Arrange
        let errorToTest = TestError()
        let expectation = XCTestExpectation(description: "Sign in user error")
        // Act
        viewModelToTest.didReceiveError.bind {
            expectation.fulfill()
        }
        mockAuthUseCase.signInUserResult = Result.failure(errorToTest)
        viewModelToTest.signInUser()
        // Assert
        wait(for: [expectation], timeout: 1.0)
    }

    func testSignInButtonTitle() {
        // Act
        let buttonTitle = viewModelToTest.signInButtonTitle
        // Assert
        XCTAssertEqual(buttonTitle, "Sign in with TheMovieDB")
    }

}
