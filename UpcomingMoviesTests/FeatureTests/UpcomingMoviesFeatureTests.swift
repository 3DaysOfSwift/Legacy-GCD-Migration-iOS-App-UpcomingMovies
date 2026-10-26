//
//  UpcomingMoviesFeatureTests.swift
//  UpcomingMoviesTests
//

import XCTest
@testable import UpcomingMovies
import UpcomingMoviesDomain

@MainActor
final class UpcomingMoviesFeatureTests: XCTestCase {

    func testEquivalentPageLoadsShareOneExecution() async throws {
        var loadCallCount = 0
        let expectedMovie = makeMovie(id: 1)
        let upcomingMoviesFeature = UpcomingMoviesFeature(
            loadUpcomingMovies: { _, completion in
                loadCallCount += 1
                completion(.success([expectedMovie]))
            },
            makeMoviePresentationModel: { movie in
                MockMovieProtocol(id: movie.id)
            }
        )

        let firstLoadTask = Task { try await upcomingMoviesFeature.loadMovies(page: 1) }
        let secondLoadTask = Task { try await upcomingMoviesFeature.loadMovies(page: 1) }

        _ = try await firstLoadTask.value
        _ = try await secondLoadTask.value

        XCTAssertEqual(loadCallCount, 1)
    }

    private func makeMovie(id: Int) -> Movie {
        Movie(id: id,
              title: "Movie \(id)",
              genreIds: nil,
              overview: "Overview",
              posterPath: nil,
              backdropPath: nil,
              releaseDate: nil,
              voteAverage: nil)
    }

}
