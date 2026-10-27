//
//  MovieReviewsMockFactory.swift
//  UpcomingMoviesTests
//
//  Created by Alonso on 7/29/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

@testable import UpcomingMovies
import UpcomingMoviesDomain

final class MockMovieReviewsInteractor: MovieReviewsFeatureProviding {

    var getMovieReviewsResult: Result<[ReviewProtocol], Error>?
    func loadReviews(forMovieWithID movieID: Int, page: Int?) async throws -> [ReviewProtocol] {
        try getMovieReviewsResult?.get() ?? []
    }

}
