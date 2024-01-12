//
//  ProfileManager.swift
//  Soccer
//
//  Created by Андрей Чернышев on 05.07.2022.
//

import RxSwift

protocol ProfileManagerProtocol {
    func upload(photo: Data) -> Single<URL?>
    func set(
        name: String?,
        photoUrl: URL?,
        pin: String?,
        pushToken: String?
    ) -> Single<Void>
    func obtainProfile(forceUpdate: Bool) -> Single<Profile?>
    func syncTokens(oldToken: String, newToken: String) -> Single<Void>
    func login(userToken: String) -> Single<Void>
}

final class ProfileManager {
    enum Constants {
        static let nameKey = "profile_manager_name_key"
        static let photoUrlKey = "profile_manager_photo_url_key"
        static let pinKey = "profile_manager_pin_key"
    }
    
    private lazy var defaultRequestWrapper = DefaultRequestWrapper()
    private lazy var restAPITransport = RestAPITransport()
    
    private lazy var sessionManager = SessionManager()
}

// MARK: ProfileManagerProtocol
extension ProfileManager: ProfileManagerProtocol {
    func upload(photo: Data) -> Single<URL?> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = UploadPhotoRequest(userToken: userToken)
        
        return restAPITransport
            .formBody(data: photo, request: request)
            .map { UploadPhotoResponse.map(from: $0) }
    }
    
    func set(
        name: String? = nil,
        photoUrl: URL? = nil,
        pin: String? = nil,
        pushToken: String? = nil
    ) -> Single<Void> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = SetRequest(
            userToken: userToken,
            name: name,
            photoPath: photoUrl?.absoluteString,
            pin: pin,
            pushToken: pushToken
        )
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .mapToVoid()
            .do(onSuccess: { [weak self] in
                self?.store(name: name)
                self?.store(photoUrl: photoUrl)
                self?.store(pin: pin)
            })
    }
    
    func obtainProfile(forceUpdate: Bool) -> Single<Profile?> {
        forceUpdate ? loadProfile() : cachedProfile()
    }
    
    func syncTokens(oldToken: String, newToken: String) -> Single<Void> {
        let request = SyncTokensRequest(oldToken: oldToken,
                                        newToken: newToken)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .mapToVoid()
    }
    
    func login(userToken: String) -> Single<Void> {
        let request = LoginRequest(userToken: userToken)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .mapToVoid()
    }
}

// MARK: Private
private extension ProfileManager {
    func loadProfile() -> Single<Profile?> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = GetProfileRequest(userToken: userToken)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetProfileResponse.map(from: $0) }
    }
    
    func cachedProfile() -> Single<Profile?> {
        Single<Profile?>.create { single in
            let name = UserDefaults.standard.string(forKey: Constants.nameKey)
            let photoUrl = UserDefaults.standard.url(forKey: Constants.photoUrlKey)
            let pin = UserDefaults.standard.string(forKey: Constants.pinKey)
            
            var profile: Profile? {
                guard let name else {
                    return nil
                }
                
                return Profile(
                    name: name,
                    photoUrl: photoUrl,
                    pin: pin
                )
            }
            
            single(.success(profile))
            
            return Disposables.create()
        }
    }
    
    func store(name: String?) {
        guard let name else {
            return
        }
        
        UserDefaults.standard.set(name, forKey: Constants.nameKey)
        
        ProfileMediator.shared.notify(name: name)
    }
    
    func store(photoUrl: URL?) {
        guard let photoUrl else {
            return
        }
        
        UserDefaults.standard.set(photoUrl, forKey: Constants.photoUrlKey)
        
        ProfileMediator.shared.notify(photoURL: photoUrl)
    }
    
    func store(pin: String?) {
        guard let pin else {
            return
        }
        
        UserDefaults.standard.set(pin, forKey: Constants.pinKey)
        
        ProfileMediator.shared.notify(pin: pin)
    }
}
