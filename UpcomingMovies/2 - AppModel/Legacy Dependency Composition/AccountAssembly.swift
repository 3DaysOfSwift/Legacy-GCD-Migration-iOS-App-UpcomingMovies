//
//  AccountAssembly.swift
//  UpcomingMovies
//
//  Created by Alonso on 9/13/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import Swinject
import UpcomingMoviesDomain

final class AccountAssembly: Assembly {

    func assemble(container: Container) {
        container.register(AccountFeature.self) { resolver in
            guard let authHandler = resolver.resolve(AuthenticationHandlerProtocol.self) else {
                fatalError("AuthenticationHandlerProtocol dependency could not be resolved")
            }
            return AccountFeature(authHandler: authHandler)
        }

        container.register(AccountViewModelProtocol.self) { resolver in
            guard let accountFeature = resolver.resolve(AccountFeature.self) else {
                fatalError("AccountFeature dependency could not be resolved")
            }
            return AccountViewModel(accountFeature: accountFeature)
        }
    }

}
