//
//  MovieCreditsViewModel.swift
//  UpcomingMovies
//
//  Created by Alonso on 2/13/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

import Foundation

@MainActor
final class MovieCreditsViewModel: MovieCreditsViewModelProtocol {

    // MARK: - Dependencies

    private let movieId: Int
    private(set) var movieTitle: String

    private let movieCreditsFeature: MovieCreditsFeature
    private var factory: MovieCreditsSectionManagerProtocol
    private var loadTask: Task<Void, Never>?

    // MARK: - Reactive properties

    let viewState = BehaviorBindable(MovieCreditsViewState.initial).eraseToAnyBindable()
    let startLoading = BehaviorBindable(false).eraseToAnyBindable()
    let didToggleSection = PublishBindable<Int>().eraseToAnyBindable()

    // MARK: - Computed properties

    var emptyCreditResultsTitle: String {
        LocalizedStrings.emptyCreditResults()
    }

    // MARK: - Initializers

    init(movieId: Int,
         movieTitle: String,
         movieCreditsFeature: MovieCreditsFeature,
         factory: MovieCreditsSectionManagerProtocol) {
        self.movieId = movieId
        self.movieTitle = movieTitle

        self.movieCreditsFeature = movieCreditsFeature
        self.factory = factory
    }

    // MARK: - MovieCreditsViewModelProtocol

    func numberOfSections() -> Int {
        factory.sections.count
    }

    func numberOfItems(for section: Int) -> Int {
        let section = factory.sections[section]
        guard section.opened else { return 0 }
        switch section.type {
        case .cast:
            return viewState.value.currentCast.count
        case .crew:
            return viewState.value.currentCrew.count
        }
    }

    func creditModel(for section: Int, and index: Int) -> MovieCreditCellViewModelProtocol {
        switch factory.sections[section].type {
        case .cast:
            let cast = viewState.value.currentCast[index]
            return MovieCreditCellViewModel(cast: cast)
        case .crew:
            let crew = viewState.value.currentCrew[index]
            return MovieCreditCellViewModel(crew: crew)
        }
    }

    func headerModel(for index: Int) -> CollapsibleHeaderViewModel {
        let section = factory.sections[index]
        return CollapsibleHeaderViewModel(opened: section.opened,
                                          section: index,
                                          title: section.type.title)
    }

    func toggleSection(_ section: Int) {
        factory.toggleSection(at: section)
        didToggleSection.send(section)
    }

    func getMovieCredits(showLoader: Bool = false) {
        guard loadTask == nil else { return }
        startLoading.value = showLoader
        loadTask = Task { [weak self] in
            guard let self else { return }
            defer { self.loadTask = nil }
            self.startLoading.value = false
            do {
                let movieCredits = try await self.movieCreditsFeature.loadCredits(forMovieWithID: self.movieId)
                self.factory.updateSection(type: .cast, enabled: !movieCredits.cast.isEmpty)
                self.factory.updateSection(type: .crew, enabled: !movieCredits.crew.isEmpty)
                self.viewState.value = self.processResult(movieCredits)
            } catch {
                self.viewState.value = .error(error)
            }
        }
    }

    // MARK: - Private

    private func processResult(_ movieCredits: MovieCreditsProtocol) -> MovieCreditsViewState {
        let fetchedCast = movieCredits.cast
        let fetchedCrew = movieCredits.crew
        if fetchedCast.isEmpty && fetchedCrew.isEmpty {
            return .empty
        } else {
            return .populated(fetchedCast, fetchedCrew)
        }
    }

}
