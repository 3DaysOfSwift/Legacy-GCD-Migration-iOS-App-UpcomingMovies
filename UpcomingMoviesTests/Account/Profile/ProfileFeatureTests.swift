//
//  ProfileFeatureTests.swift
//  UpcomingMoviesTests
//
//  Created by Alonso on 12/07/23.
//  Copyright © 2023 Alonso. All rights reserved.
//

import XCTest
@testable import UpcomingMovies
@testable import UpcomingMoviesDomain

@MainActor
final class ProfileFeatureTests: XCTestCase {

    private var profileFeature: ProfileFeature!
    private var mockUserUseCase: UserUseCaseProtocolMock!
    private var mockAuthUseCase: AuthUseCaseProtocolMock!
    private var mockAccountUseCase: AccountUseCaseProtocolMock!

    override func setUp() {
        super.setUp()
        mockUserUseCase = UserUseCaseProtocolMock()
        mockAuthUseCase = AuthUseCaseProtocolMock()
        mockAccountUseCase = AccountUseCaseProtocolMock()
        profileFeature = ProfileFeature(userUseCase: mockUserUseCase,
                                       authUseCase: mockAuthUseCase,
                                       accountUseCase: mockAccountUseCase)
    }

    override func tearDown() {
        profileFeature = nil
        mockUserUseCase = nil
        mockAuthUseCase = nil
        mockAccountUseCase = nil
        super.tearDown()
    }

    func testLoadAccountDetailSavesTheUser() async throws {
        // Arrange
        mockAccountUseCase.getAccountDetailResult = .success(.with())
        _ = try await profileFeature.loadAccountDetail()
        XCTAssertEqual(mockUserUseCase.saveUserCallCount, 1)
    }

    func testLoadAccountDetailDoesNotSaveOnFailure() async {
        // Arrange
        mockAccountUseCase.getAccountDetailResult = .failure(TestError())
        _ = try? await profileFeature.loadAccountDetail()
        XCTAssertEqual(mockUserUseCase.saveUserCallCount, 0)
    }

    func testSignOutRequestsTheUseCase() async {
        _ = try? await profileFeature.signOut()
        XCTAssertEqual(mockAuthUseCase.signOutUserCallCount, 1)
    }

}
