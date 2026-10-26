//
//  SignInFeature.swift
//  UpcomingMovies
//
//  Created by Alonso on 3/07/23.
//  Copyright © 2023 Alonso. All rights reserved.
//

import Foundation
import UpcomingMoviesDomain

/// Owns sign-in domain work and shares duplicate in-flight requests.
@MainActor
final class SignInFeature {

    private let authUseCase: AuthUseCaseProtocol
    private let userUseCase: UserUseCaseProtocol

    private var authorizationURLTask: Task<URL, Error>?
    private var signInTask: Task<User, Error>?

    init(authUseCase: AuthUseCaseProtocol,
         userUseCase: UserUseCaseProtocol) {
        self.authUseCase = authUseCase
        self.userUseCase = userUseCase
    }

    func authorizationURL() async throws -> URL {
        if let authorizationURLTask {
            return try await authorizationURLTask.value
        }

        let task = Task { [weak self] () throws -> URL in
            guard let self else {
                throw CancellationError()
            }

            defer {
                self.authorizationURLTask = nil
            }

            return try await withCheckedThrowingContinuation { continuation in
                self.authUseCase.getAuthURL { result in
                    continuation.resume(with: result)
                }
            }
        }

        authorizationURLTask = task
        return try await task.value
    }

    func signIn() async throws -> User {
        if let signInTask {
            return try await signInTask.value
        }

        let task = Task { [weak self] () throws -> User in
            guard let self else {
                throw CancellationError()
            }

            defer {
                self.signInTask = nil
            }

            let user = try await withCheckedThrowingContinuation { continuation in
                self.authUseCase.signInUser { result in
                    continuation.resume(with: result)
                }
            }
            self.userUseCase.saveUser(user)
            return user
        }

        signInTask = task
        return try await task.value
    }

}
