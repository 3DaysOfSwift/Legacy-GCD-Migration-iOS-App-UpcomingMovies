//
//  SearchMoviesMockFactory.swift
//  UpcomingMoviesTests
//
//  Created by Alonso on 7/10/22.
//  Copyright © 2022 Alonso. All rights reserved.
//

import Foundation
@testable import UpcomingMovies
import UpcomingMoviesDomain

final class SearchMoviesUseCaseMock: MovieSearchUseCaseProtocol {

    var didUpdateMovieSearch: (() -> Void)?

    var movieSearchesResult: Result<[MovieSearch], Error>?
    private(set) var getMovieSearchesCallCount = 0

    func getMovieSearches(completion: @escaping (Result<[MovieSearch], Error>) -> Void) {
        if let movieSearchesResult {
            completion(movieSearchesResult)
        }
        getMovieSearchesCallCount += 1
    }

    private(set) var saveSearchTextCallCount = 0

    func save(with searchText: String, completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
        saveSearchTextCallCount += 1
    }
}

final class SearchMovieVisitsUseCaseMock: MovieVisitUseCaseProtocol {

    var didUpdateMovieVisit: (() -> Void)?

    var movieVisitsResult: Result<[MovieVisit], Error>?
    private(set) var getMovieVisitsCallCount = 0

    func getMovieVisits(completion: @escaping (Result<[MovieVisit], Error>) -> Void) {
        if let movieVisitsResult {
            completion(movieVisitsResult)
        }
        getMovieVisitsCallCount += 1
    }

    func save(with id: Int, title: String, posterPath: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }
}

final class MockSearchMoviesResultControllerDelegate: MockViewController, SearchMoviesResultControllerDelegate {

    var didSelectRecentSearch = 0
    func searchMoviesResultController(_ searchMoviesResultController: SearchMoviesResultController, didSelectRecentSearch searchText: String) {
        didSelectRecentSearch += 1
    }

}

final class SearchMoviesFeatureTestDependencies {

    let movieUseCase = MovieUseCaseProtocolMock()
    let movieSearchUseCase = SearchMoviesUseCaseMock()
    let movieVisitUseCase = SearchMovieVisitsUseCaseMock()
    let genreUseCase = GenreUseCaseProtocolMock()

    func makeFeature() -> SearchMoviesFeature {
        SearchMoviesFeature(
            movieUseCase: movieUseCase,
            movieSearchUseCase: movieSearchUseCase,
            movieVisitUseCase: movieVisitUseCase,
            genreUseCase: genreUseCase,
            authenticationHandler: SearchAuthenticationHandlerMock()
        )
    }
}

final class SearchAuthenticationHandlerMock: AuthenticationHandlerProtocol {

    func currentUser() -> UserProtocol? {
        nil
    }

    func isUserSignedIn() -> Bool {
        false
    }

    func deleteCurrentUser() {
    }
}

final class MockSearchOptionsViewModel: SearchOptionsViewModelProtocol {

    var viewState: BehaviorBindable<SearchOptionsViewState> = .init(.emptyMovieVisits)

    var needsContentReload: PublishBindable<Void> = .init()

    var updateVisitedMovies: PublishBindable<Int> = .init()

    var selectedDefaultSearchOption: PublishBindable<DefaultSearchOption> = .init()

    var selectedMovieGenre: PublishBindable<(Int, String)> = .init()

    var selectedRecentlyVisitedMovie: PublishBindable<(Int, String)> = .init()

    var visitedMovieCells: [VisitedMovieCellViewModelProtocol] = .init()

    var genreCells: [GenreSearchOptionCellViewModelProtocol] = .init()

    var defaultSearchOptionsCells: [DefaultSearchOptionCellViewModelProtocol] = []

    private(set) var loadGenresCallCount = 0
    func loadGenres() -> Task<Void, Never> {
        loadGenresCallCount += 1
        return Task {}
    }

    private(set) var loadVisitedMoviesCallCount = 0
    func loadVisitedMovies() -> Task<Void, Never> {
        loadVisitedMoviesCallCount += 1
        return Task {}
    }

    var sectionAtIndexResult: SearchOptionsSection = .defaultSearches
    private(set) var sectionAtIndexCallCount = 0
    func section(at index: Int) -> SearchOptionsSection {
        sectionAtIndexCallCount += 1
        return sectionAtIndexResult
    }

    var sectionIndexResult: Int?
    private(set) var sectionIndexCallCount = 0
    func sectionIndex(for section: SearchOptionsSection) -> Int? {
        sectionIndexCallCount += 1
        return sectionIndexResult
    }

    var buildRecentlyVisitedMoviesCellResult: RecentlyVisitedMoviesCellViewModelProtocol = RecentlyVisitedMoviesCellViewModel(visitedMovieCells: [])
    private(set) var buildRecentlyVisitedMoviesCellCallCount = 0
    func buildRecentlyVisitedMoviesCell() -> RecentlyVisitedMoviesCellViewModelProtocol {
        buildRecentlyVisitedMoviesCellCallCount += 1
        return buildRecentlyVisitedMoviesCellResult
    }

    private(set) var getDefaultSearchSelectionCallCount = 0
    func getDefaultSearchSelection(by index: Int) {
        getDefaultSearchSelectionCallCount += 1
    }

    private(set) var getMovieGenreSelectionCallCount = 0
    func getMovieGenreSelection(by index: Int) {
        getMovieGenreSelectionCallCount += 1
    }

    // swiftlint:disable identifier_name
    private(set) var getRecentlyVisitedMovieSelectionCallCount = 0
    func getRecentlyVisitedMovieSelection(by index: Int) {
        getRecentlyVisitedMovieSelectionCallCount += 1
    }

}
