//
//  SearchMoviesResultViewModel.swift
//  UpcomingMovies
//
//  Created by Alonso on 11/7/18.
//  Copyright © 2018 Alonso. All rights reserved.
//

import Foundation

@MainActor
final class SearchMoviesResultViewModel: SearchMoviesResultViewModelProtocol {

    // MARK: - Dependencies

    private let searchMoviesFeature: SearchMoviesFeature
    private var recentSearchesTask: Task<Void, Never>?
    private var searchMoviesTask: Task<Void, Never>?

    // MARK: - Reactive properties

    let viewState = BehaviorBindable(SearchMoviesResultViewState.recentSearches).eraseToAnyBindable()
    let needsRefresh = PublishBindable<Void>().eraseToAnyBindable()

    // MARK: - Computed properties

    private var movies: [MovieProtocol] {
        viewState.value.currentSearchedMovies
    }

    var recentSearchCells: [RecentSearchCellViewModelProtocol] {
        recentSearches.map { RecentSearchCellViewModel(searchText: $0.searchText) }
    }

    var movieCells: [MovieListCellViewModelProtocol] {
        movies.compactMap { MovieListCellViewModel($0)}
    }

    var emptySearchResultsTitle: String {
        LocalizedStrings.emptySearchResults()
    }

    var recentSearchesTitle: String {
        LocalizedStrings.recentSearches()
    }

    // MARK: - Stored properties

    private var recentSearches: [MovieSearchProtocol] = [] {
        didSet {
            if viewState.value == .recentSearches {
                needsRefresh.send()
            }
        }
    }

    // MARK: - Initilalizers

    init(searchMoviesFeature: SearchMoviesFeature) {
        self.searchMoviesFeature = searchMoviesFeature

        self.searchMoviesFeature.movieSearchesDidChange = { [weak self] in
            self?.loadRecentSearches()
        }
    }

    // MARK: - Movies handling

    func loadRecentSearches() -> Task<Void, Never> {
        if let recentSearchesTask {
            return recentSearchesTask
        }

        let loadTask = Task { [weak self] in
            guard let self else { return }
            defer { self.recentSearchesTask = nil }

            do {
                recentSearches = try await searchMoviesFeature.loadRecentSearches()
            } catch {
                // The existing screen keeps its current recent searches on a failed refresh.
            }
        }

        recentSearchesTask = loadTask
        return loadTask
    }

    func searchMovies(withSearchText searchText: String) -> Task<Void, Never> {
        if let searchMoviesTask {
            return searchMoviesTask
        }

        viewState.value = .searching
        searchMoviesFeature.recordSearchText(searchText)

        let searchTask = Task { [weak self] in
            guard let self else { return }
            defer { self.searchMoviesTask = nil }

            do {
                let movies = try await searchMoviesFeature.searchMovies(searchText: searchText)
                viewState.value = movies.isEmpty ? .empty : .populated(movies)
            } catch {
                viewState.value = .error(error)
            }
        }

        searchMoviesTask = searchTask
        return searchTask
    }

    func clearMovies() {
        viewState.value = .recentSearches
    }

    // MARK: - Movie detail builder

    func searchedMovie(at index: Int) -> MovieProtocol {
        movies[index]
    }
}
