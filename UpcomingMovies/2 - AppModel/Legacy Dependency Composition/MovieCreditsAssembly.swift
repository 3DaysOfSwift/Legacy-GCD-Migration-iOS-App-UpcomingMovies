//
//  MovieCreditsAssembly.swift
//  UpcomingMovies
//
//  Created by Alonso on 9/17/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import Foundation
import Swinject
import UpcomingMoviesDomain

final class MovieCreditsAssembly: Assembly {

    func assemble(container: Container) {
        container.register(MovieCreditsSectionManagerProtocol.self) { _ in
            MovieCreditsSectionManager()
        }

        container.register(MovieCreditsFeature.self) { resolver in
            guard let useCaseProvider = resolver.resolve(UseCaseProviderProtocol.self) else {
                fatalError("UseCaseProviderProtocol dependency could not be resolved")
            }
            return MovieCreditsFeature(movieUseCase: useCaseProvider.movieUseCase())
        }

        container.register(MovieCreditsViewModelProtocol.self) { (resolver, movieId: Int, movieTitle: String) in
            guard let factory = resolver.resolve(MovieCreditsSectionManagerProtocol.self) else {
                fatalError("MovieCreditsFactoryProtocol dependency could not be resolved")
            }
            guard let movieCreditsFeature = resolver.resolve(MovieCreditsFeature.self) else {
                fatalError("MovieCreditsFeature dependency could not be resolved")
            }
            return MovieCreditsViewModel(movieId: movieId, movieTitle: movieTitle,
                                         movieCreditsFeature: movieCreditsFeature, factory: factory)
        }
    }

}
