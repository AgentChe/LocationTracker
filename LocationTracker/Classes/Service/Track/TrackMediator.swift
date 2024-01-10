//
//  TrackMediator.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 10.01.2024.
//

import RxSwift
import RxCocoa

final class TrackMediator {
    static let shared = TrackMediator()
    
    private lazy var didSavePlaceTrigger = PublishRelay<Int>()
    private lazy var didDeletePlaceTrigger = PublishRelay<Int>()
    
    private init() {}
}

// MARK: Public
extension TrackMediator {
    func save(placeId: Int) {
        didSavePlaceTrigger.accept(placeId)
    }
    
    func delete(placeId: Int) {
        didDeletePlaceTrigger.accept(placeId)
    }
    
    var didSavePlace: Signal<Int> {
        didSavePlaceTrigger.asSignal()
    }
    
    var didDeletePlace: Signal<Int> {
        didDeletePlaceTrigger.asSignal()
    }
}
