//
//  ProfileMockFactory.swift
//  UpcomingMoviesTests
//
//  Created by Alonso on 7/18/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

@testable import UpcomingMovies
@testable import UpcomingMoviesDomain

final class MockProfileViewModel: ProfileViewModelProtocol {

    var userInfoCell: ProfileAccountInfoCellViewModelProtocol?

    var reloadAccountInfo = PublishBindable<Void>().eraseToAnyBindable()
    var didUpdateAuthenticationState = BehaviorBindable<AuthenticationState?>(nil).eraseToAnyBindable()
    var didReceiveError = PublishBindable<Void>().eraseToAnyBindable()

    var signOutTitle: String? = "Sign out"
    var signOutConfirmationTitle: String? = "Sign Out Confirmation"

    var sectionAtIndexResult: ProfileSection = .accountInfo
    private(set) var sectionAtIndexCallCount = 0
    func section(at index: Int) -> ProfileSection {
        sectionAtIndexCallCount += 1
        return sectionAtIndexResult
    }

    var numberOfSectionsResult: Int = 0
    private(set) var numberOfSectionsCallCount = 0
    func numberOfSections() -> Int {
        numberOfSectionsCallCount += 1
        return numberOfSectionsResult
    }

    var numberOfRowsResult: Int = 0
    private(set) var numberOfRowsCallCount = 0
    func numberOfRows(for section: Int) -> Int {
        numberOfRowsCallCount += 1
        return numberOfRowsResult
    }

    var profileOptionResult = ProfileOption.customLists
    private(set) var profileOptionCallCount = 0
    func profileOption(for section: Int, at index: Int) -> ProfileOptionProtocol {
        profileOptionCallCount += 1
        return profileOptionResult
    }

    var buildProfileOptionCellViewModelResult = MockProfileSelectableOptionCellViewModel()
    private(set) var buildProfileOptionCellViewModelCallCount = 0
    func buildProfileOptionCellViewModel(for section: Int, at index: Int) -> ProfileSelectableOptionCellViewModelProtocol {
        buildProfileOptionCellViewModelCallCount += 1
        return buildProfileOptionCellViewModelResult
    }

    var buildSignOutCellViewModelResult = MockProfileSignOutCellViewModel()
    private(set) var buildSignOutCellViewModelCallCount = 0
    func buildSignOutCellViewModel() -> ProfileSignOutCellViewModelProtocol {
        buildSignOutCellViewModelCallCount += 1
        return buildSignOutCellViewModelResult
    }

    private(set) var getAccountDetailsCallCount = 0
    func getAccountDetails() {
        getAccountDetailsCallCount += 1
    }

    private(set) var signOutCurrentUserCallCount = 0
    func signOutCurrentUser() {
        signOutCurrentUserCallCount += 1
    }

}

final class MockProfileSelectableOptionCellViewModel: ProfileSelectableOptionCellViewModelProtocol {

    var title: String?

}

final class MockProfileSignOutCellViewModel: ProfileSignOutCellViewModelProtocol {

    var title: String = ""

}

final class MockProfileViewFactory: ProfileFactoryProtocol {

    var collectionSectionOptions: [ProfileOptionProtocol] = []
    var recommendedSectionOptions: [ProfileOptionProtocol] = []
    var customListsSectionOptions: [ProfileOptionProtocol] = []

    // MARK: - ProfileFactoryProtocol

    func profileOptions(for section: ProfileSection) -> [ProfileOptionProtocol] {
        switch section {
        case .accountInfo, .signOut:
            return []
        case .collections:
            return collectionSectionOptions
        case .recommended:
            return recommendedSectionOptions
        case .customLists:
            return customListsSectionOptions
        }
    }

    var sections: [ProfileSection] = []

}

final class MockProfileViewControllerDelegate: MockViewController, ProfileViewControllerDelegate {

    private(set) var didTapProfileOptionCallCount = 0
    func profileViewController(didTapProfileOption option: ProfileOptionProtocol) {
        didTapProfileOptionCallCount += 1
    }

    private(set) var didUpdateAuthenticationStateCallCount = 0
    func didUpdateAuthenticationState(_ state: AuthenticationState) {
        didUpdateAuthenticationStateCallCount += 1
    }

}

final class MockProfileCoordinator: ProfileCoordinatorProtocol {}
