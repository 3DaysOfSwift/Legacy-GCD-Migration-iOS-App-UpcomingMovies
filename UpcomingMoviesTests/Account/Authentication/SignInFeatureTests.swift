//
//  SignInFeatureTests.swift
//  UpcomingMoviesTests
//
//  Created by Alonso on 7/07/23.
//  Copyright © 2023 Alonso. All rights reserved.
//

import XCTest
@testable import UpcomingMovies
@testable import UpcomingMoviesDomain

@MainActor
final class SignInFeatureTests: XCTestCase {

    private var signInFeature: SignInFeature!
    private var mockUserUseCase: UserUseCaseProtocolMock!
    private var mockAuthUseCase: AuthUseCaseProtocolMock!

    override func setUp() {
        super.setUp()
        mockUserUseCase = UserUseCaseProtocolMock()
        mockAuthUseCase = AuthUseCaseProtocolMock()
        signInFeature = SignInFeature(authUseCase: mockAuthUseCase, userUseCase: mockUserUseCase)
    }

    override func tearDown() {
        signInFeature = nil
        mockUserUseCase = nil
        mockAuthUseCase = nil
        super.tearDown()
    }

    func testAuthorizationURLRequestsTheUseCase() async throws {
        let expectedURL = URL(string: "https://example.com")!
        mockAuthUseCase.getAuthURLResult = .success(expectedURL)

        let receivedURL = try await signInFeature.authorizationURL()

        XCTAssertEqual(receivedURL, expectedURL)
        XCTAssertEqual(mockAuthUseCase.getAuthURLCallCount, 1)
    }

    func testSignInSavesTheAuthenticatedUser() async throws {
        mockAuthUseCase.signInUserResult = .success(.with())

        _ = try await signInFeature.signIn()

        XCTAssertEqual(mockAuthUseCase.signInUserCallCount, 1)
        XCTAssertEqual(mockUserUseCase.saveUserCallCount, 1)
    }

    func testSignInDoesNotSaveAUserWhenAuthenticationFails() async {
        mockAuthUseCase.signInUserResult = .failure(TestError())

        do {
            _ = try await signInFeature.signIn()
            XCTFail("Expected sign-in to fail")
        } catch {
        }

        XCTAssertEqual(mockAuthUseCase.signInUserCallCount, 1)
        XCTAssertEqual(mockUserUseCase.saveUserCallCount, 0)
    }

}
