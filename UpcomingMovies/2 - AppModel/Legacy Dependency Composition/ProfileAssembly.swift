//
//  ProfileAssembly.swift
//  UpcomingMovies
//
//  Created by Alonso on 9/15/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import Swinject
import UpcomingMoviesDomain

final class ProfileAssembly: Assembly {

    func assemble(container: Container) {
        container.register(ProfileFactoryProtocol.self) { _ in
            ProfileFactory()
        }

        container.register(ProfileFeature.self) { resolver in
            guard let useCaseProvider = resolver.resolve(UseCaseProviderProtocol.self) else {
                fatalError("UseCaseProviderProtocol dependency could not be resolved")
            }
            return ProfileFeature(userUseCase: useCaseProvider.userUseCase(),
                                     authUseCase: useCaseProvider.authUseCase(),
                                     accountUseCase: useCaseProvider.accountUseCase())
        }

        container.register(ProfileViewModelProtocol.self) { (resolver, user: UserProtocol) in
            guard let profileFeature = resolver.resolve(ProfileFeature.self) else {
                fatalError("ProfileFeature dependency could not be resolved")
            }
            guard let factory = resolver.resolve(ProfileFactoryProtocol.self) else {
                fatalError("ProfileFactoryProtocol dependency could not be resolved")
            }
            return ProfileViewModel(userAccount: user,
                                    profileFeature: profileFeature,
                                    factory: factory)
        }
    }

}
