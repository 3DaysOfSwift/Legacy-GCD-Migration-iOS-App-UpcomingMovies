//
//  SavedMoviesFeature.swift
//  UpcomingMovies
//
//  Created by Alonso on 7/23/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import UpcomingMoviesDomain

enum SavedMoviesCollection: Hashable {
    case favorites
    case watchlist
}

/// Owns the account collections while preserving their distinct server requests.
@MainActor
final class SavedMoviesFeature {

    private let accountUseCase: AccountUseCaseProtocol

    init(accountUseCase: AccountUseCaseProtocol) {
        self.accountUseCase = accountUseCase
    }

    private var loadTasks: [SavedMoviesRequest: Task<[MovieProtocol], Error>] = [:]

    func loadMovies(in collection: SavedMoviesCollection, page: Int?) async throws -> [MovieProtocol] {
        let request = SavedMoviesRequest(collection: collection, page: page)
        if let loadTask = loadTasks[request] { return try await loadTask.value }

        let loadTask = Task { [weak self] () throws -> [MovieProtocol] in
            guard let self else { throw CancellationError() }
            defer { self.loadTasks[request] = nil }
            return try await withCheckedThrowingContinuation { continuation in
                let completion: (Result<[Movie], Error>) -> Void = { result in
                    continuation.resume(with: result.map { $0.map(MovieModel.init) })
                }
                switch collection {
                case .favorites:
                    self.accountUseCase.getFavoriteList(page: page, sortBy: .createdAtDesc, completion: completion)
                case .watchlist:
                    self.accountUseCase.getWatchlist(page: page, sortBy: .createdAtDesc, completion: completion)
                }
            }
        }
        loadTasks[request] = loadTask
        return try await loadTask.value
    }

}

private struct SavedMoviesRequest: Hashable {
    let collection: SavedMoviesCollection
    let page: Int?
}
