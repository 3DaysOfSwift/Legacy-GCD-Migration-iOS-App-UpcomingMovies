//
//  MovieReviewsFeature.swift
//  UpcomingMovies
//
//  Created by Alonso on 7/29/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import UpcomingMoviesDomain

/// Owns paged reviews and coalesces matching in-flight requests.
@MainActor
final class MovieReviewsFeature: MovieReviewsFeatureProviding {

    private let movieUseCase: MovieUseCaseProtocol
    private var loadTasks: [MovieReviewsRequest: Task<[ReviewProtocol], Error>] = [:]

    init(movieUseCase: MovieUseCaseProtocol) {
        self.movieUseCase = movieUseCase
    }

    func loadReviews(forMovieWithID movieID: Int, page: Int?) async throws -> [ReviewProtocol] {
        let request = MovieReviewsRequest(movieID: movieID, page: page)
        if let loadTask = loadTasks[request] {
            return try await loadTask.value
        }

        let loadTask = Task { [weak self] () throws -> [ReviewProtocol] in
            guard let self else { throw CancellationError() }
            defer { self.loadTasks[request] = nil }

            return try await withCheckedThrowingContinuation { continuation in
                self.movieUseCase.getMovieReviews(for: movieID, page: page) { result in
                    continuation.resume(with: result.map { $0.map(ReviewModel.init) })
                }
            }
        }
        loadTasks[request] = loadTask
        return try await loadTask.value

    }

}

private struct MovieReviewsRequest: Hashable {
    let movieID: Int
    let page: Int?
}
