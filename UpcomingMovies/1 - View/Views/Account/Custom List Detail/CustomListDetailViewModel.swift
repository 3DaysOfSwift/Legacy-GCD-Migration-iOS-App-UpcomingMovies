//
//  CustomListDetailViewModel.swift
//  UpcomingMovies
//
//  Created by Alonso on 4/19/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

import Foundation

@MainActor
final class CustomListDetailViewModel: CustomListDetailViewModelProtocol {

    // MARK: - Dependencies

    private let list: ListProtocol
    private let customListDetailFeature: CustomListDetailFeature
    private var loadTask: Task<Void, Never>?

    // MARK: - Reactive properties

    let viewState = BehaviorBindable(CustomListDetailViewState.loading).eraseToAnyBindable()

    // MARK: - Computed properties

    var emptyMovieResultsTitle: String {
        LocalizedStrings.emptyMovieResults()
    }

    private var movies: [MovieProtocol] {
        viewState.value.currentMovies
    }

    var movieCells: [MovieListCellViewModel] {
        movies.map { MovieListCellViewModel($0) }
    }

    var listName: String? {
        list.name
    }

    // MARK: - Initializers

    init(_ list: ListProtocol, customListDetailFeature: CustomListDetailFeature) {
        self.list = list
        self.customListDetailFeature = customListDetailFeature
    }

    // MARK: - CustomListDetailViewModelProtocol

    func buildHeaderViewModel() -> CustomListDetailHeaderViewModelProtocol {
        CustomListDetailHeaderViewModel(list: list)
    }

    func buildSectionViewModel() -> CustomListDetailSectionViewModel {
        CustomListDetailSectionViewModel(list: list)
    }

    func movie(at index: Int) -> MovieProtocol {
        movies[index]
    }

    func getListMovies() {
        guard loadTask == nil else { return }
        loadTask = Task { [weak self] in
            guard let self else { return }
            defer { self.loadTask = nil }
            do {
                let movies = try await self.customListDetailFeature.loadMovies(forListWithID: self.list.id)
                self.viewState.value = self.processResult(movies)
            } catch {
                self.viewState.value = .error(error)
            }
        }
    }

    // MARK: - Private

    private func processResult(_ movies: [MovieProtocol]) -> CustomListDetailViewState {
        guard !movies.isEmpty else { return .empty }

        return .populated(movies)
    }

}
