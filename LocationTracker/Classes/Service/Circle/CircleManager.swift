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
        id: String,
        name: String,
        photo: String?,
        roleId: String
    ) -> Single<Circle?>
    func obtainCircles() -> Single<[Circle]>
    func delete(id: Int) -> Single<Void>
    func exclude(memberId: String, circleId: String) -> Single<Void>
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
    }
    
    func edit(
        id: String,
        name: String,
        photo: String?,
        roleId: String
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
    }
    
    // TODO
    func obtainCircles() -> Single<[Circle]> {
        Single<[Circle]>.create { single in
            func circle() -> Circle {
                let id = Int.random(in: 1...10000000)
                
                let images = [
                    URL(string: "https://www.freeiconspng.com/thumbs/family-icon/family-icon-6.png"),
                    URL(string: "https://static.vecteezy.com/system/resources/thumbnails/019/038/988/small/happy-family-family-with-children-together-png.png"),
                    URL(string: "https://png.pngtree.com/png-vector/20220319/ourmid/pngtree-big-family-with-three-generation-png-image_4503557.png"),
                    nil
                ]
                
                func member(me: Bool = false) -> Member {
                    let mId = Int.random(in: 1...123123123)
                    
                    return Member(
                        id: me ? SessionManager().userId : "\(mId)",
                        name: "Member \(mId)",
                        photoUrl: nil,
                        roleId: Int.random(in: 1...5)
                    )
                }
                
                return Circle(
                    id: id,
                    name: "Circle \(id)",
                    imageUrl: images.randomElement()!,
                    inviteCode: "AAASAS",
                    owner: member(me: true),
                    members: [member(), member(), member(), member()]
                )
            }
            
            let circles = [
                circle(),
                circle(),
                circle(),
                circle(),
                circle(),
                circle(),
                circle(),
                circle(),
            ]
            single(.success(circles))
            
            return Disposables.create()
        }
        
        
//        guard let userToken = sessionManager.getSession()?.userToken else {
//            return .error(SignError.tokenNotFound)
//        }
//
//        let request = GetCirclesRequest(userToken: userToken)
//
//        return restApiTransport
//            .callServerApi(requestBody: request)
//            .map { GetCirclesResponse.map(from: $0) }
    }
    
    func delete(id: Int) -> Single<Void> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = DeleteCircleRequest(userToken: userToken, id: id)
        
        return restApiTransport
            .callServerApi(requestBody: request)
            .mapToVoid()
    }
    
    func exclude(memberId: String, circleId: String) -> Single<Void> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = ExcludeMemberRequest(
            userToken: userToken,
            memberId: memberId,
            circleId: circleId
        )
        
        return restApiTransport
            .callServerApi(requestBody: request)
            .mapToVoid()
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
