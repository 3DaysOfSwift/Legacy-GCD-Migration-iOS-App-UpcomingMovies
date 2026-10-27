//
//  CustomListDetailFeature.swift
//  UpcomingMovies
//
//  Created by Alonso on 7/27/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import Foundation
import UpcomingMoviesDomain

/// Owns the selected custom list's movie request.
@MainActor
final class CustomListDetailFeature {

    private let accountUseCase: AccountUseCaseProtocol
    private var loadTasks: [String: Task<[MovieProtocol], Error>] = [:]

    init(accountUseCase: AccountUseCaseProtocol) {
        self.accountUseCase = accountUseCase
    }

    func loadMovies(forListWithID listID: String) async throws -> [MovieProtocol] {
        if let loadTask = loadTasks[listID] {
            return try await loadTask.value
        }

        let loadTask = Task { [weak self] () throws -> [MovieProtocol] in
            guard let self else { throw CancellationError() }
            defer { self.loadTasks[listID] = nil }

            return try await withCheckedThrowingContinuation { continuation in
                self.accountUseCase.getCustomListMovies(listId: listID) { result in
                    continuation.resume(with: result.map { $0.map(MovieModel.init) })
                }
            }
        }
        loadTasks[listID] = loadTask
        return try await loadTask.value
    }

}
