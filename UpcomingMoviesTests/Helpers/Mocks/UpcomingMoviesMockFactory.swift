//
//  UpcomingMoviesMockFactory.swift
//  UpcomingMoviesTests
//
//  Created by Alonso on 7/7/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

@testable import UpcomingMovies
import UpcomingMoviesDomain
import UIKit

final class MockUpcomingMoviesLoader {

    var upcomingMovies: Result<[Movie], Error>?
    private(set) var loadCallCount = 0

    func loadMovies(page: Int, completion: @escaping (Result<[Movie], Error>) -> Void) {
        loadCallCount += 1
        if let upcomingMovies {
            completion(upcomingMovies)
        }
    }

}

final class MockUpcomingMoviesFactory: UpcomingMoviesFactoryProtocol {

    var makeGridBarButtonItemContentsResult: [ToggleBarButtonItemContent] = []
    func makeGridBarButtonItemContents(for presentationMode: UpcomingMoviesPresentationMode) -> [ToggleBarButtonItemContent] {
        makeGridBarButtonItemContentsResult
    }

}

final class MockUpcomingMoviesNavigationDelegate: NSObject, UpcomingMoviesNavigationDelegate {

    var parentCoordinator: Coordinator?

    private(set) var configureCallCount = 0
    func configure(selectedFrame: CGRect?, with imageToTransition: UIImage?) {
        configureCallCount += 1
    }

    private(set) var updateOffsetCallCount = 0
    func updateOffset(_ verticalSafeAreaOffset: CGFloat) {
        updateOffsetCallCount += 1
    }

}
