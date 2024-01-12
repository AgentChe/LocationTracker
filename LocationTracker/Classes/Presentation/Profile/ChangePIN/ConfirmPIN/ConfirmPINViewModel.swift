//
//  ConfirmPINViewModel.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 12.01.2024.
//

import RxSwift
import RxCocoa

final class ConfirmPINViewModel {
    enum Route {
        case incorrectPIN
        case correctPIN
    }
    
    private lazy var profileManager = ProfileManager()
}

// MARK: Public
extension ConfirmPINViewModel {
    struct Input {
        let didInputPIN: Signal<String>
    }
    
    struct Output {
        let route: Driver<Route>
    }
    
    func configure(input: Input) -> Output {
        let pin = makePIN()
        
        return Output(
            route: makeRoute(
                didInputPIN: input.didInputPIN,
                pin: pin
            )
        )
    }
}

// MARK: Private
private extension ConfirmPINViewModel {
    func makeRoute(
        didInputPIN: Signal<String>,
        pin: Driver<String>
    ) -> Driver<Route> {
        didInputPIN
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(pin) { ($0, $1) }
            .map { inputPIN, pin -> Route in
                inputPIN == pin ? .correctPIN : .incorrectPIN
            }
    }
    
    func makePIN() -> Driver<String> {
        profileManager
            .obtainProfile(forceUpdate: false)
            .map { $0?.pin ?? "" }
            .asDriver(onErrorDriveWith: .never())
    }
}
