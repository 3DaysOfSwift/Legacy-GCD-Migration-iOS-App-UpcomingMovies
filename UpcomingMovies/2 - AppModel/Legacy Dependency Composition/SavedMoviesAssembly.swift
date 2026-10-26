//
//  SavedMoviesAssembly.swift
//  UpcomingMovies
//
//  Created by Alonso on 9/13/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import Swinject
import UpcomingMoviesDomain

final class SavedMoviesAssembly: Assembly {

    func assemble(container: Container) {
        container.register(SavedMoviesFeature.self) { resolver in
            guard let useCaseProvider = resolver.resolve(UseCaseProviderProtocol.self) else {
                fatalError("UseCaseProviderProtocol dependency could not be resolved")
            }
            return SavedMoviesFeature(accountUseCase: useCaseProvider.accountUseCase())
        }

        container.register(SavedMoviesViewModelProtocol.self) { (resolver, displayTitle: String?) in
            guard let savedMoviesFeature = resolver.resolve(SavedMoviesFeature.self) else {
                fatalError("SavedMoviesFeature dependency could not be resolved")
            }
            let collection: SavedMoviesCollection = displayTitle == ProfileOption.watchlist.title ? .watchlist : .favorites
            let viewModel = SavedMoviesViewModel(savedMoviesFeature: savedMoviesFeature, collection: collection)
            viewModel.displayTitle = displayTitle

            return viewModel
        }
    }

}
