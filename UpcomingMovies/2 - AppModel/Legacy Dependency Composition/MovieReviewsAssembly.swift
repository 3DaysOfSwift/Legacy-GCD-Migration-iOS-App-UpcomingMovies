//
//  MovieReviewsAssembly.swift
//  UpcomingMovies
//
//  Created by Alonso on 9/17/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import Swinject
import UpcomingMoviesDomain

final class MovieReviewsAssembly: Assembly {

    func assemble(container: Container) {
        container.register(MovieReviewsFeature.self) { resolver in
            guard let useCaseProvider = resolver.resolve(UseCaseProviderProtocol.self) else {
                fatalError("UseCaseProviderProtocol dependency could not be resolved")
            }
            return MovieReviewsFeature(movieUseCase: useCaseProvider.movieUseCase())
        }

        container.register(MovieReviewsViewModelProtocol.self) { (resolver, movieId: Int, movieTitle: String) in
            guard let movieReviewsFeature = resolver.resolve(MovieReviewsFeature.self) else {
                fatalError("MovieReviewsFeature dependency could not be resolved")
            }
            return MovieReviewsViewModel(movieId: movieId,
                                         movieTitle: movieTitle,
                                         movieReviewsFeature: movieReviewsFeature)
        }
    }

}
