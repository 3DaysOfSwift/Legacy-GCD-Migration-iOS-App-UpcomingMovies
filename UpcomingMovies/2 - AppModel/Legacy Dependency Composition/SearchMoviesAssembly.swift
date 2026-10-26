//
//  SearchMoviesAssembly.swift
//  UpcomingMovies
//
//  Created by Alonso on 9/16/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import Foundation
import Swinject
import UpcomingMoviesDomain

final class SearchMoviesAssembly: Assembly {

    func assemble(container: Container) {
        container.register(SearchMoviesFeature.self) { resolver in
            guard let useCaseProvider = resolver.resolve(UseCaseProviderProtocol.self) else {
                fatalError("UseCaseProviderProtocol dependency could not be resolved")
            }
            guard let authenticationHandler = resolver.resolve(AuthenticationHandlerProtocol.self) else {
                fatalError("AuthenticationHandlerProtocol dependency could not be resolved")
            }

            return SearchMoviesFeature(
                movieUseCase: useCaseProvider.movieUseCase(),
                movieSearchUseCase: useCaseProvider.movieSearchUseCase(),
                movieVisitUseCase: useCaseProvider.movieVisitUseCase(),
                genreUseCase: useCaseProvider.genreUseCase(),
                authenticationHandler: authenticationHandler
            )
        }
        container.register(SearchOptionsViewModelProtocol.self) { resolver in
            guard let searchMoviesFeature = resolver.resolve(SearchMoviesFeature.self) else {
                fatalError("SearchMoviesFeature dependency could not be resolved")
            }
            return SearchOptionsViewModel(searchMoviesFeature: searchMoviesFeature)
        }
        container.register(SearchMoviesResultViewModelProtocol.self) { resolver in
            guard let searchMoviesFeature = resolver.resolve(SearchMoviesFeature.self) else {
                fatalError("SearchMoviesFeature dependency could not be resolved")
            }
            return SearchMoviesResultViewModel(searchMoviesFeature: searchMoviesFeature)
        }
    }

}
