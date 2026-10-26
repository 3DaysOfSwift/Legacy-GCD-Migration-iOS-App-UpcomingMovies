//
//  SignInAssembly.swift
//  UpcomingMovies
//
//  Created by Alonso on 3/07/23.
//  Copyright © 2023 Alonso. All rights reserved.
//

import Swinject
import UpcomingMoviesDomain

final class SignInAssembly: Assembly {

    func assemble(container: Container) {
        container.register(SignInFeature.self) { resolver in
            guard let useCaseProvider = resolver.resolve(UseCaseProviderProtocol.self) else {
                fatalError("UseCaseProviderProtocol dependency could not be resolved")
            }
            return SignInFeature(authUseCase: useCaseProvider.authUseCase(), userUseCase: useCaseProvider.userUseCase())
        }

        container.register(SignInViewModelProtocol.self) { resolver in
            guard let signInFeature = resolver.resolve(SignInFeature.self) else {
                fatalError("SignInFeature dependency could not be resolved")
            }
            return SignInViewModel(signInFeature: signInFeature)
        }
    }

}
