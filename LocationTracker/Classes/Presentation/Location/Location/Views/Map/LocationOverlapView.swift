//
//  LocationOverlapView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 28.03.2024.
//

import UIKit
import RxSwift
import RxCocoa

final class LocationOverlapView: UIView {
    private lazy var didTouchTrigger = PublishRelay<Void>()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        didTouchTrigger.accept(Void())
    }
}

// MARK: Public
extension LocationOverlapView {
    var didTouch: Signal<Void> {
        didTouchTrigger.asSignal()
    }
}
