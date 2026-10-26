//
//  ProfileFeature.swift
//  UpcomingMovies
//
//  Created by Alonso on 7/17/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import Foundation
import UpcomingMoviesDomain

@MainActor
final class ProfileFeature {

    private let userUseCase: UserUseCaseProtocol
    private let authUseCase: AuthUseCaseProtocol
    private let accountUseCase: AccountUseCaseProtocol
    private var accountDetailTask: Task<UserProtocol, Error>?
    private var signOutTask: Task<Bool, Error>?

    init(userUseCase: UserUseCaseProtocol,
         authUseCase: AuthUseCaseProtocol,
         accountUseCase: AccountUseCaseProtocol) {
        self.userUseCase = userUseCase
        self.authUseCase = authUseCase
        self.accountUseCase = accountUseCase
    }

    func loadAccountDetail() async throws -> UserProtocol {
        if let accountDetailTask { return try await accountDetailTask.value }
        let task = Task { [weak self] () throws -> UserProtocol in
            guard let self else { throw CancellationError() }
            defer { self.accountDetailTask = nil }
            let user = try await withCheckedThrowingContinuation { continuation in
                self.accountUseCase.getAccountDetail { result in
                    continuation.resume(with: result)
                }
            }
            self.userUseCase.saveUser(user)
            return UserModel(user)
        }
        accountDetailTask = task
        return try await task.value
    }

    func signOut() async throws -> Bool {
        if let signOutTask { return try await signOutTask.value }
        let task = Task { [weak self] () throws -> Bool in
            guard let self else { throw CancellationError() }
            defer { self.signOutTask = nil }
            return try await withCheckedThrowingContinuation { continuation in
                self.authUseCase.signOutUser { result in
                    continuation.resume(with: result)
                }
            }
        }
        signOutTask = task
        return try await task.value
    }

}
