//
//  UpcomingMoviesViewModel.swift
//  UpcomingMovies
//
//  Created by Alonso on 11/5/18.
//  Copyright © 2018 Alonso. All rights reserved.
//

import Foundation

@MainActor
final class UpcomingMoviesViewModel: UpcomingMoviesViewModelProtocol, SimpleViewStateProcessable {

    // MARK: - Dependencies

    private let upcomingMoviesFeature: UpcomingMoviesFeature
    private let factory: UpcomingMoviesFactoryProtocol
    private let userPreferencesHandler: UserPreferencesHandlerProtocol
    private var loadTasks: [Int: Task<Void, Never>] = [:]

    // MARK: - Reactive properties

    let viewState = BehaviorBindable(UpcomingMoviesViewState.initial).eraseToAnyBindable()
    let startLoading = BehaviorBindable(false).eraseToAnyBindable()
    let didUpdatePresentationMode = PublishBindable<UpcomingMoviesPresentationMode>().eraseToAnyBindable()

    // MARK: - Computed properties

    private var movies: [MovieProtocol] {
        viewState.value.currentEntities
    }

    var movieCells: [UpcomingMovieCellViewModelProtocol] {
        movies.compactMap { UpcomingMovieCellViewModel($0) }
    }

    var needsPrefetch: Bool {
        viewState.value.needsPrefetch
    }

    var currentPresentationMode: UpcomingMoviesPresentationMode {
        userPreferencesHandler.upcomingMoviesPresentationMode
    }

    // MARK: - Initializers

    init(upcomingMoviesFeature: UpcomingMoviesFeature,
         factory: UpcomingMoviesFactoryProtocol,
         userPreferencesHandler: UserPreferencesHandlerProtocol) {
        self.upcomingMoviesFeature = upcomingMoviesFeature
        self.factory = factory
        self.userPreferencesHandler = userPreferencesHandler
    }

    // MARK: - UpcomingMoviesViewModelProtocol

    @discardableResult
    func getMovies() -> Task<Void, Never> {
        let showLoader = viewState.value.isInitialPage
        return loadMovies(page: viewState.value.currentPage, showLoader: showLoader)
    }

    @discardableResult
    func refreshMovies() -> Task<Void, Never> {
        loadMovies(page: 1, showLoader: false)
    }

    func movie(for index: Int) -> MovieProtocol {
        movies[index]
    }

    func getToggleBarButtonItemModel() -> ToggleBarButtonItemViewModelProtocol {
        let contents = factory.makeGridBarButtonItemContents(for: currentPresentationMode)
        return ToggleBarButtonItemViewModel(contents: contents)
    }

    func updatePresentationMode() {
        switch currentPresentationMode {
        case .preview:
            userPreferencesHandler.upcomingMoviesPresentationMode = .detail
            didUpdatePresentationMode.send(.detail)
        case .detail:
            userPreferencesHandler.upcomingMoviesPresentationMode = .preview
            didUpdatePresentationMode.send(.preview)
        }
    }

    // MARK: - Private

    private func loadMovies(page: Int, showLoader: Bool) -> Task<Void, Never> {
        if let loadTask = loadTasks[page] {
            return loadTask
        }

        startLoading.value = showLoader
        let upcomingMoviesFeature = self.upcomingMoviesFeature
        let loadTask = Task { [weak self] in
            defer { self?.loadTasks[page] = nil }
            do {
                let movies = try await upcomingMoviesFeature.loadMovies(page: page)
                guard let self else { return }
                self.viewState.value = self.processResult(movies,
                                                          currentPage: page,
                                                          currentEntities: self.movies)
            } catch is CancellationError {
                // A newer load is already responsible for publishing the screen state.
            } catch {
                self?.viewState.value = .error(error)
            }
            self?.startLoading.value = false
        }

        loadTasks[page] = loadTask
        return loadTask
    }

}
