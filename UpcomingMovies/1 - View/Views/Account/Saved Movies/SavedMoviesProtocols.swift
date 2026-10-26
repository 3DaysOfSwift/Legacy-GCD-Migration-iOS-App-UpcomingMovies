//
//  SavedMoviesProtocols.swift
//  UpcomingMovies
//
//  Created by Alonso on 6/27/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import Foundation

protocol SavedMoviesViewModelProtocol {

    var displayTitle: String? { get set }

    var movieCells: [SavedMovieCellViewModelProtocol] { get }
    var needsPrefetch: Bool { get }

    var startLoading: AnyBehaviorBindable<Bool> { get }
    var viewState: AnyBehaviorBindable<SavedMoviesViewState> { get }

    var emptyMovieResultsTitle: String? { get }

    func getCollectionList()
    func refreshCollectionList()

    func movie(at index: Int) -> MovieProtocol

}

protocol SavedMoviesCoordinatorProtocol: AnyObject, MovieDetailCoordinable {}
