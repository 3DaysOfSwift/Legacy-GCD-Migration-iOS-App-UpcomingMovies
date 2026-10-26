//
//  SavedMoviesViewModel.swift
//  UpcomingMovies
//
//  Created by Alonso on 3/3/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

import Foundation

@MainActor
final class SavedMoviesViewModel: SavedMoviesViewModelProtocol, SimpleViewStateProcessable {

    // MARK: - Dependencies

    private let savedMoviesFeature: SavedMoviesFeature
    private let collection: SavedMoviesCollection
    private var loadTask: Task<Void, Never>?

    // MARK: - Reactive properties

    let startLoading = BehaviorBindable(false).eraseToAnyBindable()
    let viewState = BehaviorBindable(SavedMoviesViewState.initial).eraseToAnyBindable()

    // MARK: - Computed properties

    private var movies: [MovieProtocol] {
        viewState.value.currentEntities
    }

    var movieCells: [SavedMovieCellViewModelProtocol] {
        movies.compactMap { SavedMovieCellViewModel($0) }
    }

    var needsPrefetch: Bool {
        viewState.value.needsPrefetch
    }

    var emptyMovieResultsTitle: String? {
        LocalizedStrings.emptyMovieResults()
    }

    var displayTitle: String?

    // MARK: - Initializers

    init(savedMoviesFeature: SavedMoviesFeature, collection: SavedMoviesCollection) {
        self.savedMoviesFeature = savedMoviesFeature
        self.collection = collection
    }

    // MARK: - SavedMoviesViewModelProtocol

    func movie(at index: Int) -> MovieProtocol {
        movies[index]
    }

    func getCollectionList() {
        let showLoader = viewState.value.isInitialPage
        fetchCollectionList(page: viewState.value.currentPage, showLoader: showLoader)
    }

    func refreshCollectionList() {
        fetchCollectionList(page: 1, showLoader: false)
    }

    // MARK: - Private

    private func fetchCollectionList(page: Int, showLoader: Bool) {
        guard loadTask == nil else { return }
        startLoading.value = showLoader
        loadTask = Task { [weak self] in
            guard let self else { return }
            defer { self.loadTask = nil }
            self.startLoading.value = false
            do {
                let movies = try await self.savedMoviesFeature.loadMovies(in: self.collection, page: page)
                self.viewState.value = self.processResult(movies,
                                                          currentPage: page,
                                                          currentEntities: self.movies)
            } catch {
                self.viewState.value = .error(error)
            }
        }
    }

}
