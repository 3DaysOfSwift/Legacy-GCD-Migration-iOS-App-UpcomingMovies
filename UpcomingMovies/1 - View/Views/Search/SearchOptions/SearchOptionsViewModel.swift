//
//  SearchOptionsViewModel.swift
//  UpcomingMovies
//
//  Created by Alonso on 1/15/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

import UpcomingMoviesDomain

@MainActor
final class SearchOptionsViewModel: SearchOptionsViewModelProtocol {

    // MARK: - Dependencies

    private let searchMoviesFeature: SearchMoviesFeature
    private var genresTask: Task<Void, Never>?
    private var movieVisitsTask: Task<Void, Never>?

    // MARK: - Reactive properties

    let viewState: BehaviorBindable<SearchOptionsViewState> = BehaviorBindable(.emptyMovieVisits)

    let needsContentReload: PublishBindable<Void> = PublishBindable()
    let updateVisitedMovies: PublishBindable<Int> = PublishBindable()

    let selectedDefaultSearchOption: PublishBindable<DefaultSearchOption> = PublishBindable()
    let selectedMovieGenre: PublishBindable<(Int, String)> = PublishBindable()
    let selectedRecentlyVisitedMovie: PublishBindable<(Int, String)> = PublishBindable()

    // MARK: - Computed properties

    var visitedMovieCells: [VisitedMovieCellViewModelProtocol] {
        movieVisits.map { VisitedMovieCellViewModel(movieVisit: $0) }
    }

    var genreCells: [GenreSearchOptionCellViewModelProtocol] {
        genres.map { GenreSearchOptionCellViewModel(genre: $0) }
    }

    var defaultSearchOptionsCells: [DefaultSearchOptionCellViewModelProtocol] {
        defaultSearchOptions.map { DefaultSearchOptionCellViewModel(defaultSearchOption: $0) }
    }

    // MARK: - Stored properties

    private var movieVisits: [MovieVisitProtocol] = []
    private var genres: [GenreProtocol] = []
    private let defaultSearchOptions: [DefaultSearchOption] = [.popular, .topRated]

    // MARK: - Initializers

    init(searchMoviesFeature: SearchMoviesFeature) {
        self.searchMoviesFeature = searchMoviesFeature

        self.searchMoviesFeature.movieVisitsDidChange = { [weak self] in
            self?.loadVisitedMovies()
        }
    }

    // MARK: - SearchOptionsViewModelProtocol

    func loadGenres() -> Task<Void, Never> {
        if let genresTask {
            return genresTask
        }

        let loadTask = Task { [weak self] in
            guard let self else { return }
            defer { self.genresTask = nil }

            do {
                genres = try await searchMoviesFeature.loadGenres()
                needsContentReload.send()
            } catch {
                // The existing screen remains usable when genres cannot refresh.
            }
        }

        genresTask = loadTask
        return loadTask
    }

    func loadVisitedMovies() -> Task<Void, Never> {
        if let movieVisitsTask {
            return movieVisitsTask
        }

        let loadTask = Task { [weak self] in
            guard let self else { return }
            defer { self.movieVisitsTask = nil }

            do {
                movieVisits = try await searchMoviesFeature.loadMovieVisits()
                let viewStateChanged = configureViewState(movieVisits: movieVisits)
                if viewStateChanged {
                    needsContentReload.send()
                } else if let index = sectionIndex(for: .recentlyVisited) {
                    updateVisitedMovies.send(index)
                }
            } catch {
                // The existing screen keeps its current visit history on failure.
            }
        }

        movieVisitsTask = loadTask
        return loadTask
    }

    func section(at index: Int) -> SearchOptionsSection {
        viewState.value.sections[index]
    }

    func sectionIndex(for section: SearchOptionsSection) -> Int? {
        let sections = viewState.value.sections
        return sections.firstIndex(of: section)
    }

    func buildRecentlyVisitedMoviesCell() -> RecentlyVisitedMoviesCellViewModelProtocol {
        RecentlyVisitedMoviesCellViewModel(visitedMovieCells: visitedMovieCells)
    }

    func getDefaultSearchSelection(by index: Int) {
        let defaultSearchOption = defaultSearchOptions[index]
        selectedDefaultSearchOption.send(defaultSearchOption)
    }

    func getMovieGenreSelection(by index: Int) {
        let selectedGenre = genres[index]
        selectedMovieGenre.send((selectedGenre.id, selectedGenre.name))
    }

    func getRecentlyVisitedMovieSelection(by index: Int) {
        let selectedVisitedMovie = movieVisits[index]
        selectedRecentlyVisitedMovie.send((selectedVisitedMovie.id, selectedVisitedMovie.title))
    }

    // MARK: - Private

    /**
     * Configures the state of the view according to the saved movie visits
     * quantity. Returns true if the state changed and false if not.
     */
    private func configureViewState(movieVisits: [MovieVisitProtocol]) -> Bool {
        let oldViewState = viewState.value
        viewState.value = movieVisits.isEmpty ? .emptyMovieVisits : .populatedMovieVisits

        return oldViewState != viewState.value
    }

}
