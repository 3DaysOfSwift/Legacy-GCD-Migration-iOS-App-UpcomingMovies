//
//  AccountMockFactory.swift
//  UpcomingMoviesTests
//
//  Created by Alonso on 7/14/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import Foundation
@testable import UpcomingMovies

final class MockAccountAuthenticationHandler: AuthenticationHandlerProtocol {

    var currentUserResult: UserProtocol?
    func currentUser() -> UserProtocol? {
        currentUserResult
    }

    func isUserSignedIn() -> Bool {
        currentUserResult != nil
    }

    func deleteCurrentUser() {
        currentUserResult = nil
    }

}
