//
//  CustomListDetailAssembly.swift
//  UpcomingMovies
//
//  Created by Alonso on 9/15/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import Swinject
import UpcomingMoviesDomain

final class CustomListDetailAssembly: Assembly {

    func assemble(container: Container) {
        container.register(CustomListDetailFeature.self) { resolver in
            guard let useCaseProvider = resolver.resolve(UseCaseProviderProtocol.self) else {
                fatalError("UseCaseProviderProtocol dependency could not be resolved")
            }
            return CustomListDetailFeature(accountUseCase: useCaseProvider.accountUseCase())
        }

        container.register(CustomListDetailViewModelProtocol.self) { (resolver, list: ListProtocol) in
            guard let customListDetailFeature = resolver.resolve(CustomListDetailFeature.self) else {
                fatalError("CustomListDetailFeature dependency could not be resolved")
            }
            return CustomListDetailViewModel(list, customListDetailFeature: customListDetailFeature)
        }
    }

}
