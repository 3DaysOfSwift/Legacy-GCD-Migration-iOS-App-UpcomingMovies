//
//  CustomListsInteractor.swift
//  UpcomingMovies
//
//  Created by Alonso on 7/26/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import Foundation
import UpcomingMoviesDomain

/// Owns Custom Lists requests and coalesces matching page loads.
@MainActor
final class CustomListsFeature {

    private let accountUseCase: AccountUseCaseProtocol
    private var loadTasks: [CustomListsRequest: Task<[ListProtocol], Error>] = [:]

    init(accountUseCase: AccountUseCaseProtocol) {
        self.accountUseCase = accountUseCase
    }

    func loadLists(page: Int?) async throws -> [ListProtocol] {
        let request = CustomListsRequest(page: page)
        if let loadTask = loadTasks[request] {
            return try await loadTask.value
        }

        let loadTask = Task { [weak self] () throws -> [ListProtocol] in
            guard let self else { throw CancellationError() }
            defer { self.loadTasks[request] = nil }

            return try await withCheckedThrowingContinuation { continuation in
                self.accountUseCase.getCustomLists(page: page) { result in
                    continuation.resume(with: result.map { $0.map(ListModel.init) })
                }
            }
        }
        loadTasks[request] = loadTask
        return try await loadTask.value
    }

}

private struct CustomListsRequest: Hashable {
    let page: Int?
}
