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
        case photo(Image)
    }
    
    func makeElements(profile: Driver<Profile>) -> Driver<[ProfileTableElement]> {
        profile
            .map { profile -> [ProfileTableElement] in
                [
                    .title,
                    .edit(ProfileEditElement(
                        photoUrl: profile.photo?.url,
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
                let photo = ProfileMediator.shared.didChangePhoto
                    .asDriver(onErrorDriveWith: .never())
                    .map { ProfileChange.photo($0) }
                let change = Driver
                    .merge(name, photo)
                
                return change
                    .scan(profile) { profile, change -> Profile in
                        switch change {
                        case .name(let name):
                            return Profile(
                                name: name,
                                photo: profile.photo,
                                pin: profile.pin
                            )
                        case .photo(let photo):
                            return Profile(
                                name: profile.name,
                                photo: photo,
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
