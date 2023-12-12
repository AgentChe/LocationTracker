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
        case dismiss, editInfo(Info), editRole(Role?), addMember(String)
    }
    
    typealias Info = (String, EditCircleName.Photo)
    
    private let circle: Driver<Circle>
    
    private lazy var circleManager = CircleManager()
    
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
                info: info,
                role: role
            )
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
                        (circle.name, .url(circle.imageUrl))
                    }
            )
    }
    
    func makeRole(roles: Driver<[Role]>, updatedRole: Signal<Role>) -> Driver<Role?> {
        let initialRole = Driver
            .combineLatest(roles, circle)
            .map { roles, circle -> Role? in
                // TODO
                roles.first
                
//                let userId = SessionManager().userId
//
//                guard let me = circle.members.first(where: { $0.id == userId }) else {
//                    return nil
//                }
//
//                return roles.first(where: { me.roleId == $0.id })
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
        info: Driver<Info>,
        role: Driver<Role?>
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
        
        return Driver
            .merge(dismiss, editInfo, editRole, addMember)
    }
}
