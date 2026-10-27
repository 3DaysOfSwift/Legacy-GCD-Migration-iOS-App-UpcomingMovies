//
//  MovieReviewsViewModel.swift
//  UpcomingMovies
//
//  Created by Alonso on 2/11/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

@MainActor
final class MovieReviewsViewModel: MovieReviewsViewModelProtocol, SimpleViewStateProcessable {

    // MARK: - Dependencies

    private let movieId: Int
    private let movieReviewsFeature: MovieReviewsFeatureProviding
    private var loadTask: Task<Void, Never>?

    // MARK: - Reactive properties

    let viewState = BehaviorBindable(MovieReviewsViewState.initial).eraseToAnyBindable()
    let startLoading = BehaviorBindable(false).eraseToAnyBindable()

    // MARK: - Computed properties

    private var reviews: [ReviewProtocol] {
        viewState.value.currentEntities
    }

    var reviewCells: [MovieReviewCellViewModelProtocol] {
        let reviews = viewState.value.currentEntities
        return reviews.map { MovieReviewCellViewModel($0) }
    }

    var needsPrefetch: Bool {
        viewState.value.needsPrefetch
    }

    var emptyReviewResultsTitle: String {
        LocalizedStrings.emptyReviewResults()
    }

    // MARK: - Stored properties

    let movieTitle: String

    // MARK: - Initializers

    init(movieId: Int, movieTitle: String,
         movieReviewsFeature: MovieReviewsFeatureProviding) {
        self.movieId = movieId
        self.movieTitle = movieTitle

        self.movieReviewsFeature = movieReviewsFeature
    }

    // MARK: - MovieReviewsViewModelProtocol

    func selectedReview(at index: Int) -> ReviewProtocol {
        reviews[index]
    }

    func getMovieReviews() {
        let showLoader = viewState.value.isInitialPage
        fetchMovieReviews(currentPage: viewState.value.currentPage, showLoader: showLoader)
    }

    func refreshMovieReviews() {
        fetchMovieReviews(currentPage: 1, showLoader: false)
    }

    // MARK: - Private

    private func fetchMovieReviews(currentPage: Int, showLoader: Bool = false) {
        guard loadTask == nil else { return }
        startLoading.value = showLoader
        loadTask = Task { [weak self] in
            guard let self else { return }
            defer { self.loadTask = nil }
            self.startLoading.value = false
            do {
                let reviews = try await self.movieReviewsFeature.loadReviews(forMovieWithID: self.movieId, page: currentPage)
                self.viewState.value = self.processResult(reviews,
                                                          currentPage: currentPage,
                                                          currentEntities: self.reviews)
            } catch {
                self.viewState.value = .error(error)
            }
        }
    }

}
