//
//  SelectRoleViewModel.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 07.12.2023.
//

import RxSwift
import RxCocoa

final class SelectRoleViewModel {
    enum Route {
        case dismiss, createCode(CreateCircleCombineData)
    }
    
    private let data: Driver<CreateCircleCombineData>
    
    init(data: CreateCircleCombineData) {
        self.data = BehaviorRelay(value: data).asDriver()
    }
    
    private lazy var circleManager = CircleManager()
}

// MARK: Public
extension SelectRoleViewModel {
    struct Input {
        let didTapClose: Signal<Void>
        let didSelect: Signal<RolesTableElement>
        let didTapContinue: Signal<Void>
    }
    
    struct Output {
        let elements: Driver<[RolesTableElement]>
        let route: Driver<Route>
        let isContinueEnable: Driver<Bool>
    }
    
    func configure(input: Input) -> Output {
        let roles = makeRoles()
        let elements = makeElements(
            roles: roles,
            didSelect: input.didSelect
        )
        
        return Output(
            elements: elements,
            route: makeRoute(
                didTapClose: input.didTapClose,
                didTapContinue: input.didTapContinue,
                elements: elements
            ),
            isContinueEnable: makeIsContinueEnable(elements: elements)
        )
    }
}

// MARK: Private
private extension SelectRoleViewModel {
    func makeElements(
        roles: Driver<[Role]>,
        didSelect: Signal<RolesTableElement>
    ) -> Driver<[RolesTableElement]> {
        Driver
            .combineLatest(
                roles,
                didSelect
                    .asDriver(onErrorDriveWith: .never())
                    .map { $0.role.id }
                    .startWith(-1)
            ) { roles, selectionId -> [RolesTableElement] in
                roles.map { role -> RolesTableElement in
                    RolesTableElement(
                        role: role,
                        marked: role.id == selectionId
                    )
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
        didTapContinue: Signal<Void>,
        elements: Driver<[RolesTableElement]>
    ) -> Driver<Route> {
        let close = didTapClose
            .map { Route.dismiss }
            .asDriver(onErrorDriveWith: .never())
        
        let createCode = didTapContinue
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(data)
            .withLatestFrom(elements) { ($0, $1) }
            .map { data, elements -> Route in
                let roleId = elements.first(where: { $0.marked })?.role.id
                let copy = data.roleId(roleId)
                
                return .createCode(copy)
            }
        
        return Driver
            .merge(close, createCode)
    }
    
    func makeIsContinueEnable(elements: Driver<[RolesTableElement]>) -> Driver<Bool> {
        elements
            .map { elements -> Bool in
                elements.contains(where: { $0.marked })
            }
            .startWith(false)
    }
}
