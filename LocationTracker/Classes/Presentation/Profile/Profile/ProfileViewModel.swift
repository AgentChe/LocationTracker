//
//  ProfileViewModel.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 21.12.2023.
//

import RxSwift
import RxCocoa

final class ProfileViewModel {
    enum Route {
        case edit, savePlaces, changePIN, settings
    }
    
    private lazy var profileManager = ProfileManager()
}

// MARK: Public
extension ProfileViewModel {
    struct Input {
        let didTapEdit: Signal<Void>
        let didTapMenu: Signal<ProfileMenuButton.MenuItem>
    }
    
    struct Output {
        let elements: Driver<[ProfileTableElement]>
        let route: Driver<Route>
    }
    
    func configure(input: Input) -> Output {
        let profile = makeProfile()
        
        return Output(
            elements: makeElements(profile: profile),
            route: makeRoute(
                didTapEdit: input.didTapEdit,
                didTapMenu: input.didTapMenu
            )
        )
    }
}

// MARK: Private
private extension ProfileViewModel {
    enum ProfileChange {
        case name(String)
        case photoUrl(URL)
    }
    
    func makeElements(profile: Driver<Profile>) -> Driver<[ProfileTableElement]> {
        profile
            .map { profile -> [ProfileTableElement] in
                [
                    .title,
                    .edit(ProfileEditElement(
                        photoUrl: profile.photoUrl,
                        name: profile.name
                    )),
                    .menu
                ]
            }
    }
    
    func makeProfile() -> Driver<Profile> {
        let initial = profileManager
            .obtainProfile(forceUpdate: false)
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .never())
        
        return initial
            .flatMap { profile -> Driver<Profile> in
                let name = ProfileMediator.shared.didChangeName
                    .asDriver(onErrorDriveWith: .never())
                    .map { ProfileChange.name($0) }
                let photoUrl = ProfileMediator.shared.didChangePhotoURL
                    .asDriver(onErrorDriveWith: .never())
                    .map { ProfileChange.photoUrl($0) }
                let change = Driver
                    .merge(name, photoUrl)
                
                return change
                    .scan(profile) { profile, change -> Profile in
                        switch change {
                        case .name(let name):
                            return Profile(
                                name: name,
                                photoUrl: profile.photoUrl,
                                pin: profile.pin
                            )
                        case .photoUrl(let photoUrl):
                            return Profile(
                                name: profile.name,
                                photoUrl: photoUrl,
                                pin: profile.pin
                            )
                        }
                    }
                    .startWith(profile)
            }
    }
    
    func makeRoute(
        didTapEdit: Signal<Void>,
        didTapMenu: Signal<ProfileMenuButton.MenuItem>
    ) -> Driver<Route> {
        let edit = didTapEdit
            .map { Route.edit }
            .asDriver(onErrorDriveWith: .never())
        
        let menu = didTapMenu
            .map { menuItem -> Route in
                switch menuItem {
                case .savedPlaces:
                    return .savePlaces
                case .pin:
                    return .changePIN
                case .settings:
                    return .settings
                }
            }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(edit, menu)
    }
}
