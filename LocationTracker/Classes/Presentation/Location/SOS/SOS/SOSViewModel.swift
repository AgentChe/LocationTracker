//
//  SOSViewModel.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 16.01.2024.
//

import RxSwift
import RxCocoa

final class SOSViewModel {
    enum Route {
        case dismiss
        case instruction
        case signal(SOS)
    }
    
    private let circle: Driver<Circle>
    
    private lazy var profileManager = ProfileManager()
    
    init(circle: Circle) {
        self.circle = BehaviorRelay(value: circle).asDriver()
    }
}

// MARK: Public
extension SOSViewModel {
    struct Input {
        let didTapClose: Signal<Void>
        let didTapInstruction: Signal<Void>
        let didTapSOS: Signal<Void>
    }
    
    struct Output {
        let route: Driver<Route>
        let pin: Driver<String>
    }
    
    func configure(input: Input) -> Output {
        Output(
            route: makeRoute(
                didTapClose: input.didTapClose,
                didTapInstruction: input.didTapInstruction,
                didTapSOS: input.didTapSOS
            ),
            pin: makePIN()
        )
    }
}

// MARK: Private
private extension SOSViewModel {
    func makeRoute(
        didTapClose: Signal<Void>,
        didTapInstruction: Signal<Void>,
        didTapSOS: Signal<Void>
    ) -> Driver<Route> {
        let dismiss = didTapClose
            .map { Route.dismiss }
            .asDriver(onErrorDriveWith: .never())
        
        let instruction = didTapInstruction
            .map { Route.instruction }
            .asDriver(onErrorDriveWith: .never())
        
        let signal = didTapSOS
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(circle)
            .map { circle -> Route in
                let sos = SOS(signal: false, circleId: circle.id)
                return Route.signal(sos)
            }
        
        return Driver
            .merge(dismiss, instruction, signal)
    }
    
    func makePIN() -> Driver<String> {
        profileManager
            .obtainProfile(forceUpdate: false)
            .map { $0?.pin ?? "" }
            .asDriver(onErrorJustReturn: "")
    }
}
