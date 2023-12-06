//
//  CircleMediator.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 05.12.2023.
//

import RxSwift
import RxCocoa

final class CircleMediator {
    typealias Excluded = (memberId: String, circleId: String)
    
    static let shared = CircleMediator()
    
    private lazy var didCreatedCircleTrigger = PublishRelay<Circle>()
    private lazy var didJoinedToCircleTrigger = PublishRelay<Circle>()
    private lazy var didEditedCircleTrigger = PublishRelay<Circle>()
    private lazy var didDeletedCircleTrigger = PublishRelay<String>()
    private lazy var didExcludedFromCircleTrigger = PublishRelay<Excluded>()
    
    private init() {}
}

// MARK: Public
extension CircleMediator {
    func created(circle: Circle) {
        didCreatedCircleTrigger.accept(circle)
    }
    
    func joinedTo(circle: Circle) {
        didJoinedToCircleTrigger.accept(circle)
    }
    
    func edited(circle: Circle) {
        didEditedCircleTrigger.accept(circle)
    }
    
    func deleted(id: String) {
        didDeletedCircleTrigger.accept(id)
    }
    
    func excluded(_ excluded: Excluded) {
        didExcludedFromCircleTrigger.accept(excluded)
    }
    
    var didCreatedCircle: Signal<Circle> {
        didCreatedCircleTrigger.asSignal()
    }
    
    var didJoinedToCircle: Signal<Circle> {
        didJoinedToCircleTrigger.asSignal()
    }
    
    var didEditedCircle: Signal<Circle> {
        didEditedCircleTrigger.asSignal()
    }
    
    var didDeletedCircle: Signal<String> {
        didDeletedCircleTrigger.asSignal()
    }
    
    var didExcludedFromCircle: Signal<Excluded> {
        didExcludedFromCircleTrigger.asSignal()
    }
}
