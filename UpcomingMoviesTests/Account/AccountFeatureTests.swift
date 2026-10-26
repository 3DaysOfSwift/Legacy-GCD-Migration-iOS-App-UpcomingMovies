//
//  AccountFeatureTests.swift
//  UpcomingMoviesTests
//
//  Created by Alonso on 11/06/23.
//  Copyright © 2023 Alonso. All rights reserved.
//

import XCTest
@testable import UpcomingMovies
final class AccountFeatureTests: XCTestCase {
    private var authenticationHandler: MockAccountAuthenticationHandler!
    private var accountFeature: AccountFeature!

    override func setUp() {
        super.setUp()
        authenticationHandler = MockAccountAuthenticationHandler()
        accountFeature = AccountFeature(authHandler: authenticationHandler)
    }

    override func tearDown() {
        accountFeature = nil
        authenticationHandler = nil
        super.tearDown()
    }

    func testCurrentUserReturnsAuthenticationHandlerUser() {
        let expectedUser = MockUserProtocol()
        authenticationHandler.currentUserResult = expectedUser

        XCTAssertTrue(accountFeature.currentUser() === expectedUser)
    }

    func testCurrentUserReturnsNilWhenNoUserIsSignedIn() {
        authenticationHandler.currentUserResult = nil

        XCTAssertNil(accountFeature.currentUser())
    }
}
