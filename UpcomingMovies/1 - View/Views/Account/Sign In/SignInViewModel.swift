//
//  SignInViewModel.swift
//  UpcomingMovies
//
//  Created by Alonso on 3/07/23.
//  Copyright © 2023 Alonso. All rights reserved.
//

import Foundation

@MainActor
final class SignInViewModel: SignInViewModelProtocol {

    private let signInFeature: SignInFeature
    private var authorizationTask: Task<Void, Never>?
    private var userSignInTask: Task<Void, Never>?

    let startLoading = BehaviorBindable(false).eraseToAnyBindable()
    let showAuthPermission = PublishBindable<URL>().eraseToAnyBindable()
    let didUpdateAuthenticationState = BehaviorBindable<AuthenticationState?>(nil).eraseToAnyBindable()
    let didReceiveError = PublishBindable<Void>().eraseToAnyBindable()

    var signInButtonTitle: String? {
        LocalizedStrings.signIn()
    }

    init(signInFeature: SignInFeature) {
        self.signInFeature = signInFeature
    }

    // MARK: - SignInViewModelProtocol

    func startAuthorizationProcess() {
        guard authorizationTask == nil else {
            return
        }

        startLoading.value = true
        authorizationTask = Task { [weak self] in
            guard let self else {
                return
            }

            defer {
                self.authorizationTask = nil
            }

            do {
                let url = try await self.signInFeature.authorizationURL()
                self.showAuthPermission.send(url)
            } catch {
                self.didReceiveError.send()
            }
        }
    }

    func signInUser() {
        guard userSignInTask == nil else {
            return
        }

        userSignInTask = Task { [weak self] in
            guard let self else {
                return
            }

            defer {
                self.userSignInTask = nil
            }

            do {
                _ = try await self.signInFeature.signIn()
                self.didUpdateAuthenticationState.value = .justSignedIn
            } catch {
                self.didReceiveError.send()
            }
        }
    }

}
