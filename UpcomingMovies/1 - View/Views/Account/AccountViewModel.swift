//
//  AccountViewModel.swift
//  UpcomingMovies
//
//  Created by Alonso on 3/20/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

import Foundation

final class AccountViewModel: AccountViewModelProtocol {

    private let accountFeature: AccountFeature

    let showAuthPermission = PublishBindable<URL>().eraseToAnyBindable()
    let didUpdateAuthenticationState = BehaviorBindable<AuthenticationState?>(nil).eraseToAnyBindable()
    let didReceiveError = PublishBindable<Void>().eraseToAnyBindable()

    var title: String? { LocalizedStrings.accountTabBarTitle() }

    var navigationItemTitle: String? { LocalizedStrings.accountTitle() }

    // MARK: - Initializers

    init(accountFeature: AccountFeature) {
        self.accountFeature = accountFeature

        didUpdateAuthenticationState.value = isUserSignedIn() ? .currentlySignedIn : .currentlySignedOut
    }

    // MARK: - AccountViewModelProtocol

    func isUserSignedIn() -> Bool {
        currentUser() != nil
    }

    func currentUser() -> UserProtocol? {
        accountFeature.currentUser()
    }

}
