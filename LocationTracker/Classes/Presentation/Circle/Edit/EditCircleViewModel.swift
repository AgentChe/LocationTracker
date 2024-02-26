//
//  EditCircleViewModel.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 12.12.2023.
//

import RxSwift
import RxCocoa
import UIKit

final class EditCircleViewModel {
    enum Route {
        case dismiss, editInfo(Info), editRole(Role?), addMember(String), saved
    }
    
    typealias Info = (String, EditCircleName.Photo)
    typealias Data = (
        id: Int,
        excludeMembers: [Member],
        name: String,
        image: EditCircleName.Photo,
        roleId: Int?
    )
    
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    private lazy var activity = RxActivityIndicator()
    
    private let circle: Driver<Circle>
    
    private lazy var circleManager = CircleManager()
    private lazy var profileManager = ProfileManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
    
    init(circle: Circle) {
        self.circle = BehaviorRelay(value: circle).asDriver()
    }
}

// MARK: Public
extension EditCircleViewModel {
    struct Input {
        let didTapClose: Signal<Void>
        let didEditName: Signal<Void>
        let didEditRole: Signal<Void>
        let didDeleteMember: Signal<Member>
        let didAddMember: Signal<Void>
        let didSave: Signal<Void>
        let updatedInfo: Signal<Info>
        let updatedRole: Signal<Role>
    }
    
    struct Output {
        let elements: Driver<[EditCircleTableElement]>
        let route: Driver<Route>
        let activity: Driver<Bool>
    }
    
    func configure(input: Input) -> Output {
        let info = makeInfo(updatedInfo: input.updatedInfo)
        let roles = makeRoles()
        let role = makeRole(
            roles: roles,
            updatedRole: input.updatedRole
        )
        let excludeMembers = makeExcludedMembers(didDeleteMember: input.didDeleteMember)
        let members = makeMembers(excludeMembers: excludeMembers)
        
        return Output(
            elements: makeElements(
                info: info,
                role: role,
                members: members
            ),
            route: makeRoute(
                didTapClose: input.didTapClose,
                didEditName: input.didEditName,
                didEditRole: input.didEditRole,
                didAddMember: input.didAddMember,
                didSave: input.didSave,
                info: info,
                role: role,
                excludeMembers: excludeMembers
            ),
            activity: activity.asDriver()
        )
    }
}

// MARK: Private
private extension EditCircleViewModel {
    func makeElements(
        info: Driver<Info>,
        role: Driver<Role?>,
        members: Driver<[Member]>
    ) -> Driver<[EditCircleTableElement]> {
        Driver
            .combineLatest(info, role, members)
            .map { info, role, members -> [EditCircleTableElement] in
                var result = [EditCircleTableElement]()
                
                let name = EditCircleName(photo: info.1, name: info.0)
                result.append(.name(name))
                
                if let role = role {
                    result.append(.role(role))
                }
                
                result.append(.membersTitle)
                
                members.forEach { member in
                    let element = EditCircleMember(member: member)
                    result.append(.member(element))
                }
                
                result.append(.addMember)
                
                return result
            }
    }
    
    func makeInfo(updatedInfo: Signal<Info>) -> Driver<Info> {
        Driver
            .merge(
                updatedInfo
                    .asDriver(onErrorDriveWith: .never()),
                circle
                    .map { circle in
                        (circle.name, .url(circle.image))
                    }
            )
    }
    
    func makeRole(roles: Driver<[Role]>, updatedRole: Signal<Role>) -> Driver<Role?> {
        let initialRole = Driver
            .combineLatest(roles, circle)
            .map { roles, circle -> Role? in
                let userId = SessionManager().userId

                guard let me = circle.members.first(where: { $0.id == userId }) else {
                    return nil
                }

                return roles.first(where: { me.roleId == $0.id })
            }
        
        return Driver
            .merge(
                updatedRole
                    .map { role -> Role? in role }
                    .asDriver(onErrorDriveWith: .never()),
                initialRole
            )
    }
    
    func makeExcludedMembers(didDeleteMember: Signal<Member>) -> Driver<[Member]> {
        didDeleteMember
            .scan([]) { result, exclude -> [Member] in
                result + [exclude]
            }
            .startWith([])
            .asDriver(onErrorJustReturn: [])
    }
    
    func makeMembers(excludeMembers: Driver<[Member]>) -> Driver<[Member]> {
        Driver
            .combineLatest(circle, excludeMembers)
            .map { circle, excludeMembers -> [Member] in
                circle.members
                    .filter { member -> Bool in
                        !excludeMembers.contains(where: { $0.id == member.id })
                    }
            }
    }
    
    func makeRoles() -> Driver<[Role]> {
        circleManager
            .obtainRoles(forceUpdate: false)
            .asDriver(onErrorJustReturn: [])
    }
    
    func makeRoute(
        didTapClose: Signal<Void>,
        didEditName: Signal<Void>,
        didEditRole: Signal<Void>,
        didAddMember: Signal<Void>,
        didSave: Signal<Void>,
        info: Driver<Info>,
        role: Driver<Role?>,
        excludeMembers: Driver<[Member]>
    ) -> Driver<Route> {
        let dismiss = didTapClose
            .asDriver(onErrorDriveWith: .never())
            .map { Route.dismiss }
        let editInfo = didEditName
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(info)
            .map { Route.editInfo($0) }
        let editRole = didEditRole
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(role)
            .map { Route.editRole($0) }
        let addMember = didAddMember
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(circle)
            .map { Route.addMember($0.inviteCode) }
        let save = makeSave(
            didSave: didSave,
            excludeMembers: excludeMembers,
            info: info,
            role: role
        )
        
        return Driver
            .merge(dismiss, editInfo, editRole, addMember, save)
    }
    
    func makeSave(
        didSave: Signal<Void>,
        excludeMembers: Driver<[Member]>,
        info: Driver<Info>,
        role: Driver<Role?>
    ) -> Driver<Route> {
        func photoUrl(source: EditCircleName.Photo) -> Single<Image?> {
            switch source {
            case .url(let image):
                return .just(image)
            case .image(let image):
                guard let photo = image.jpegData(compressionQuality: 0.5) else {
                    return .deferred { .just(nil) }
                }

                return self.profileManager
                    .upload(photo: photo)
            }
        }
        
        func exclude(circleId: Int, members: [Member]) -> Single<Void> {
            guard !members.isEmpty else {
                return .just(Void())
            }
            
            return circleManager
                .exclude(membersIds: members.map { $0.id }, circleId: circleId)
        }
        
        let action = didSave
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(circle.map { $0.id })
            .withLatestFrom(excludeMembers) { ($0, $1) }
            .withLatestFrom(info) { ($0.0, $0.1, $1) }
            .withLatestFrom(role) { ($0.0, $0.1, $0.2, $1) }
        
        let route = action
            .flatMapLatest { [weak self] id, excludeMembers, info, role -> Driver<Route> in
                guard let self else {
                    return .never()
                }
                
                func source() -> Single<Route> {
                    photoUrl(source: info.1)
                        .flatMap { image -> Single<Route> in
                            exclude(circleId: id, members: excludeMembers)
                                .flatMap {
                                    self.circleManager
                                        .edit(
                                            id: id,
                                            name: info.0,
                                            photoId: image?.id,
                                            roleId: role?.id ?? -1
                                        )
                                }
                                .map { circle -> Route in
                                    guard circle != nil else {
                                        throw ContentError(.notContent)
                                    }
                                    
                                    return .saved
                                }
                        }
                }
                
                func trigger(error: Error) -> Observable<Void> {
                    guard let tryAgain = self.tryAgain?(error) else {
                        return .empty()
                    }
                    
                    return tryAgain
                }
                
                return self.observableRetrySingle
                    .retry(source: { source() },
                           trigger: { trigger(error: $0) })
                    .trackActivity(self.activity)
                    .asDriver(onErrorDriveWith: .never())
            }
        
        return route
    }
}
