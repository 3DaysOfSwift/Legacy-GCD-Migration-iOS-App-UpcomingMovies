//
//  MovieCreditsFeature.swift
//  UpcomingMovies
//
//  Created by Alonso on 7/28/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import Foundation
import UpcomingMoviesDomain

/// Owns credits requests for a movie and shares equivalent in-flight loads.
@MainActor
final class MovieCreditsFeature {

    private let movieUseCase: MovieUseCaseProtocol
    private var loadTasks: [Int: Task<MovieCreditsProtocol, Error>] = [:]

    init(movieUseCase: MovieUseCaseProtocol) {
        self.movieUseCase = movieUseCase
    }

    func loadCredits(forMovieWithID movieID: Int) async throws -> MovieCreditsProtocol {
        if let loadTask = loadTasks[movieID] {
            return try await loadTask.value
        }

        let loadTask = Task { [weak self] () throws -> MovieCreditsProtocol in
            guard let self else { throw CancellationError() }
            defer { self.loadTasks[movieID] = nil }

            return try await withCheckedThrowingContinuation { continuation in
                self.movieUseCase.getMovieCredits(for: movieID, page: nil) { result in
                    continuation.resume(with: result.map(MovieCreditsModel.init))
                }
            }
        }
        loadTasks[movieID] = loadTask
        return try await loadTask.value
    }

}
