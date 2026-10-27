//
//  CustomListsProtocols.swift
//  UpcomingMovies
//
//  Created by Alonso on 6/27/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import Foundation

protocol CustomListsViewModelProtocol {

    var startLoading: AnyBehaviorBindable<Bool> { get }
    var viewState: AnyBehaviorBindable<CustomListsViewState> { get }
    var listCells: [CustomListCellViewModelProtocol] { get }

    var title: String? { get }

    func list(at index: Int) -> ListProtocol

    func getCustomLists()
    func refreshCustomLists()

}

protocol CustomListsCoordinatorProtocol: Coordinator {

    func showListDetail(for customList: ListProtocol)

}
