//
//  CustomListsAssembly.swift
//  UpcomingMovies
//
//  Created by Alonso on 9/15/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import Swinject
import UpcomingMoviesDomain

final class CustomListsAssembly: Assembly {

    func assemble(container: Container) {
        container.register(CustomListsFeature.self) { resolver in
            guard let useCaseProvider = resolver.resolve(UseCaseProviderProtocol.self) else {
                fatalError("UseCaseProviderProtocol dependency could not be resolved")
            }
            return CustomListsFeature(accountUseCase: useCaseProvider.accountUseCase())
        }

        container.register(CustomListsViewModelProtocol.self) { resolver in
            guard let customListsFeature = resolver.resolve(CustomListsFeature.self) else {
                fatalError("CustomListsFeature dependency could not be resolved")
            }
            return CustomListsViewModel(customListsFeature: customListsFeature)
        }
    }

}
