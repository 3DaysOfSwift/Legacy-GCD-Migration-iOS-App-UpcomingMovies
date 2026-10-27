//
//  CustomListsViewModel.swift
//  UpcomingMovies
//
//  Created by Alonso on 4/19/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

import Foundation

@MainActor
final class CustomListsViewModel: CustomListsViewModelProtocol, SimpleViewStateProcessable {

    // MARK: - Dependencies

    private let customListsFeature: CustomListsFeature
    private var loadTask: Task<Void, Never>?

    // MARK: - Reactive properties

    let startLoading = BehaviorBindable(false).eraseToAnyBindable()
    let viewState = BehaviorBindable(CustomListsViewState.initial).eraseToAnyBindable()

    // MARK: - Computed properties

    var title: String? {
        LocalizedStrings.customListGroupOption()
    }

    private var lists: [ListProtocol] {
        viewState.value.currentEntities
    }

    var listCells: [CustomListCellViewModelProtocol] {
        lists.map { CustomListCellViewModel($0) }
    }

    // MARK: - Initializers

    init(customListsFeature: CustomListsFeature) {
        self.customListsFeature = customListsFeature
    }

    // MARK: - CustomListsViewModelProtocol

    func list(at index: Int) -> ListProtocol {
        lists[index]
    }

    func getCustomLists() {
        let showLoader = viewState.value.isInitialPage
        fetchCustomLists(currentPage: viewState.value.currentPage, showLoader: showLoader)
    }

    func refreshCustomLists() {
        fetchCustomLists(currentPage: 1, showLoader: false)
    }

    // MARK: - Private

    private func fetchCustomLists(currentPage: Int, showLoader: Bool) {
        guard loadTask == nil else { return }
        startLoading.value = showLoader
        loadTask = Task { [weak self] in
            guard let self else { return }
            defer { self.loadTask = nil }
            self.startLoading.value = false
            do {
                let lists = try await self.customListsFeature.loadLists(page: currentPage)
                self.viewState.value = self.processResult(lists,
                                                          currentPage: currentPage,
                                                          currentEntities: self.lists)
            } catch {
                self.viewState.value = .error(error)
            }
        }
    }

}
