//
//  CircleManager.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 05.12.2023.
//

import RxSwift

protocol CircleManagerProtocol: AnyObject {
    func obtainRoles(forceUpdate: Bool) -> Single<[Role]>
    func create(
        name: String,
        photo: String?,
        roleId: Int
    ) -> Single<Circle?>
    func join(inviteCode: String) -> Single<Circle?>
    func edit(
        id: Int,
        name: String,
        photo: String?,
        roleId: Int
    ) -> Single<Circle?>
    func obtainCircles() -> Single<[Circle]>
    func delete(id: Int) -> Single<Void>
    func exclude(membersIds: [String], circleId: Int) -> Single<Void>
}

final class CircleManager {
    enum Constants {
        static let roles = "circle_manager_roles_key"
    }
    
    private lazy var restApiTransport = RestAPITransport()
    
    private lazy var sessionManager = SessionManager()
}

// MARK: CircleManagerProtocol
extension CircleManager: CircleManagerProtocol {
    func obtainRoles(forceUpdate: Bool) -> Single<[Role]> {
        forceUpdate ? loadRoles() : cachedRoles()
    }
    
    func create(
        name: String,
        photo: String?,
        roleId: Int
    ) -> Single<Circle?> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = CreateCircleRequest(
            userToken: userToken,
            photoPath: photo,
            name: name,
            roleId: roleId
        )
        
        return restApiTransport
            .callServerApi(requestBody: request)
            .map { CreateCircleResponse.map(from: $0) }
            .do(onSuccess: { circle in
                guard let circle else {
                    return
                }

                CircleMediator.shared.created(circle: circle)
            })
    }
    
    func join(inviteCode: String) -> Single<Circle?> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = JoinToCircleRequest(
            userToken: userToken,
            inviteCode: inviteCode
        )

        return restApiTransport
            .callServerApi(requestBody: request)
            .map { CreateCircleResponse.map(from: $0) }
            .do(onSuccess: { circle in
                guard let circle else {
                    return
                }
                
                CircleMediator.shared.joinedTo(circle: circle)
            })
    }
    
    func edit(
        id: Int,
        name: String,
        photo: String?,
        roleId: Int
    ) -> Single<Circle?> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = EditCircleRequest(
            userToken: userToken,
            id: id,
            photoPath: photo,
            name: name,
            roleId: roleId
        )
        
        return restApiTransport
            .callServerApi(requestBody: request)
            .map { CreateCircleResponse.map(from: $0) }
            .do(onSuccess: { circle in
                guard let circle else {
                    return
                }
                
                CircleMediator.shared.edited(circle: circle)
            })
    }
    
    func obtainCircles() -> Single<[Circle]> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = GetCirclesRequest(userToken: userToken)

        return restApiTransport
            .callServerApi(requestBody: request)
            .map { GetCirclesResponse.map(from: $0) }
    }
    
    func delete(id: Int) -> Single<Void> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = DeleteCircleRequest(userToken: userToken, id: id)
        
        return restApiTransport
            .callServerApi(requestBody: request)
            .mapToVoid()
            .do(onSuccess: {
                CircleMediator.shared.deleted(id: id)
            })
    }
    
    func exclude(membersIds: [String], circleId: Int) -> Single<Void> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = ExcludeMemberRequest(
            userToken: userToken,
            membersIds: membersIds,
            circleId: circleId
        )
        
        return restApiTransport
            .callServerApi(requestBody: request)
            .mapToVoid()
            .do(onSuccess: {
                CircleMediator.shared.excluded((membersIds, circleId))
            })
    }
}

// MARK: Private
private extension CircleManager {
    func loadRoles() -> Single<[Role]> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = GetRolesRequest(userToken: userToken)
        
        return restApiTransport
            .callServerApi(requestBody: request)
            .map { GetRolesResponse.map(from: $0) }
            .do(onSuccess: { [weak self] roles in
                self?.store(roles: roles)
            })
    }
    
    func store(roles: [Role]) {
        guard let data = try? JSONEncoder().encode(roles) else {
            return
        }
        
        UserDefaults.standard.set(data, forKey: Constants.roles)
    }
    
    func cachedRoles() -> Single<[Role]> {
        Single<[Role]>.create { single in
            var roles: [Role] {
                guard let data = UserDefaults.standard.data(forKey: Constants.roles) else {
                    return []
                }
                
                let result = try? JSONDecoder().decode([Role].self, from: data)
                return result ?? []
            }
            
            single(.success(roles))
            
            return Disposables.create()
        }
    }
}
