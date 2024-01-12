//
//  ResetPINViewModel.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 12.01.2024.
//

import RxSwift
import RxCocoa

final class ResetPINViewModel {
    enum Route {
        case dismiss
    }
    
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    private lazy var activity = RxActivityIndicator()
    
    private lazy var profileManager = ProfileManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
}

// MARK: Public
extension ResetPINViewModel {
    struct Input {
        let didInputPIN: Signal<String>
    }
    
    struct Output {
        let activity: Driver<Bool>
        let route: Driver<Route>
    }
    
    func configure(input: Input) -> Output {
        Output(
            activity: activity.asDriver(),
            route: makeRoute(didInputPIN: input.didInputPIN)
        )
    }
}

// MARK: Private
private extension ResetPINViewModel {
    func makeRoute(didInputPIN: Signal<String>) -> Driver<Route> {
        didInputPIN
            .flatMapLatest { [weak self] pin -> Driver<Route> in
                guard let self else {
                    return .never()
                }
                
                func source() -> Single<Route> {
                    self.profileManager
                        .set(pin: pin)
                        .map { Route.dismiss }
                }
                
                func trigger(error: Error) -> Observable<Void> {
                    guard let tryAgain = self.tryAgain?(error) else {
                        return .empty()
                    }
                    
                    return tryAgain
                }
                
                return self.observableRetrySingle
                    .retry(source: { source() },
                           trigger: { trigger(error: $0) })
                    .trackActivity(self.activity)
                    .asDriver(onErrorDriveWith: .never())
            }
    }
}
