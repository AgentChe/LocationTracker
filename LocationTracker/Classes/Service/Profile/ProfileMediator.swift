//
//  ProfileMediator.swift
//  Soccer
//
//  Created by Андрей Чернышев on 03.02.2023.
//

import RxSwift
import RxCocoa

final class ProfileMediator {
    static let shared = ProfileMediator()
    
    private lazy var didChangeNameTrigger = PublishRelay<String>()
    private lazy var didChangePhotoURLTrigger = PublishRelay<URL>()
    private lazy var didChangePINTrigger = PublishRelay<String>()
    
    private init() {}
}

// MARK: Public
extension ProfileMediator {
    func notify(name: String) {
        didChangeNameTrigger.accept(name)
    }
    
    func notify(photoURL: URL) {
        didChangePhotoURLTrigger.accept(photoURL)
    }
    
    func notify(pin: String) {
        didChangePINTrigger.accept(pin)
    }
}

// MARK: Public (Rx)
extension ProfileMediator {
    var didChangeName: Signal<String> {
        didChangeNameTrigger.asSignal()
    }
    
    var didChangePhotoURL: Signal<URL> {
        didChangePhotoURLTrigger.asSignal()
    }
    
    var didChangePIN: Signal<String> {
        didChangePINTrigger.asSignal()
    }
}
