//
//  ProfileViewModel.swift
//  UpcomingMovies
//
//  Created by Alonso on 3/24/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

import Foundation

@MainActor
final class ProfileViewModel: ProfileViewModelProtocol {

    // MARK: - Stored properties

    private var userAccount: UserProtocol
    private let profileFeature: ProfileFeature
    private let factory: ProfileFactoryProtocol
    private var accountDetailsTask: Task<Void, Never>?
    private var signOutTask: Task<Void, Never>?

    let reloadAccountInfo = PublishBindable<Void>().eraseToAnyBindable()
    let didUpdateAuthenticationState = BehaviorBindable<AuthenticationState?>(nil).eraseToAnyBindable()
    let didReceiveError = PublishBindable<Void>().eraseToAnyBindable()

    // MARK: - Computed properties

    var userInfoCell: ProfileAccountInfoCellViewModelProtocol? {
        ProfileAccountInfoCellViewModel(userAccount: userAccount)
    }

    var signOutTitle: String? {
        LocalizedStrings.signOut()
    }

    var signOutConfirmationTitle: String? {
        LocalizedStrings.signOutConfirmationTitle()
    }

    // MARK: - Initializers

    init(userAccount: UserProtocol,
         profileFeature: ProfileFeature,
         factory: ProfileFactoryProtocol) {
        self.userAccount = userAccount
        self.profileFeature = profileFeature
        self.factory = factory
    }

    // MARK: - ProfileViewModelProtocol

    func section(at index: Int) -> ProfileSection {
        factory.sections[index]
    }

    func numberOfSections() -> Int {
        factory.sections.count
    }

    func numberOfRows(for section: Int) -> Int {
        let section = self.section(at: section)
        let profileOptions = factory.profileOptions(for: section)

        return profileOptions.count
    }

    func profileOption(for section: Int, at index: Int) -> ProfileOptionProtocol {
        let section = self.section(at: section)
        let profileOptions = factory.profileOptions(for: section)

        return profileOptions[index]
    }

    func buildProfileOptionCellViewModel(for section: Int,
                                         at index: Int) -> ProfileSelectableOptionCellViewModelProtocol {
        let profileOption = self.profileOption(for: section, at: index)
        return ProfileSelectableOptionCellViewModel(profileOption)
    }

    func buildSignOutCellViewModel() -> ProfileSignOutCellViewModelProtocol {
        ProfileSignOutCellViewModel()
    }

    // MARK: - Networking

    func getAccountDetails() {
        guard accountDetailsTask == nil else { return }
        accountDetailsTask = Task { [weak self] in
            guard let self else { return }
            defer { self.accountDetailsTask = nil }
            guard let user = try? await self.profileFeature.loadAccountDetail() else { return }

            // If there is no update to display we don't reload user account info
            if self.userAccount.hasUpdatedInfo(user) {
                self.userAccount = user
                self.reloadAccountInfo.send(())
            }
        }
    }

    func signOutCurrentUser() {
        guard signOutTask == nil else { return }
        signOutTask = Task { [weak self] in
            guard let self else { return }
            defer { self.signOutTask = nil }
            do {
                _ = try await self.profileFeature.signOut()
                self.didUpdateAuthenticationState.value = .justSignedOut
            } catch {
                self.didReceiveError.send()
            }
        }
    }

}
