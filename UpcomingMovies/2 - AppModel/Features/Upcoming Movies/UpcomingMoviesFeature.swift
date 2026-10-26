//
//  UpcomingMoviesFeature.swift
//  UpcomingMovies
//
//  Created by Alonso on 6/13/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import Foundation
import UpcomingMoviesDomain

@MainActor
final class UpcomingMoviesFeature {

    typealias UpcomingMoviesLoader = (Int, @escaping (Result<[Movie], Error>) -> Void) -> Void
    typealias MoviePresentationModel = (Movie) -> MovieProtocol

    private let loadUpcomingMovies: UpcomingMoviesLoader
    private let makeMoviePresentationModel: MoviePresentationModel
    private var inFlightLoadTasks: [Int: Task<[MovieProtocol], Error>] = [:]
    private var latestRequestIdentifier = 0

    init(movieUseCase: MovieUseCaseProtocol, genreHandler: GenreHandlerProtocol) {
        self.loadUpcomingMovies = { page, completion in
            movieUseCase.getUpcomingMovies(page: page, completion: completion)
        }
        self.makeMoviePresentationModel = { movie in
            MovieModel(movie, genreHandler: genreHandler)
        }
    }

    init(loadUpcomingMovies: @escaping UpcomingMoviesLoader,
         makeMoviePresentationModel: @escaping MoviePresentationModel) {
        self.loadUpcomingMovies = loadUpcomingMovies
        self.makeMoviePresentationModel = makeMoviePresentationModel
    }

    func loadMovies(page: Int) async throws -> [MovieProtocol] {
        // A pull-to-refresh is more relevant than an earlier prefetch. The network
        // requests may finish in either order, but only the newest request is
        // allowed to publish a result to the screen.
        latestRequestIdentifier += 1
        let requestIdentifier = latestRequestIdentifier

        let loadTask: Task<[MovieProtocol], Error>
        if let inFlightLoadTask = inFlightLoadTasks[page] {
            loadTask = inFlightLoadTask
        } else {
            let loadUpcomingMovies = self.loadUpcomingMovies
            let makeMoviePresentationModel = self.makeMoviePresentationModel
            loadTask = Task {
                let domainMovies: [Movie] = try await withCheckedThrowingContinuation { continuation in
                    loadUpcomingMovies(page) { result in
                        continuation.resume(with: result)
                    }
                }
                return domainMovies.map(makeMoviePresentationModel)
            }
            inFlightLoadTasks[page] = loadTask
        }

        defer {
            inFlightLoadTasks[page] = nil
        }

        let movies = try await loadTask.value
        guard requestIdentifier == latestRequestIdentifier else {
            throw CancellationError()
        }
        return movies
    }

}
