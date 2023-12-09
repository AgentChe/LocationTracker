//
//  JoinToCircleViewModel.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 08.12.2023.
//

import RxSwift
import RxCocoa

final class JoinToCircleViewModel {
    enum Route {
        case dismiss, toCircle(Circle)
    }
    
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    private lazy var activity = RxActivityIndicator()
    
    private lazy var circleManager = CircleManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
}

// MARK: Public
extension JoinToCircleViewModel {
    struct Input {
        let didTapClose: Signal<Void>
        let didTapSubmit: Signal<String>
    }
    
    struct Output {
        let route: Driver<Route>
        let activity: Driver<Bool>
    }
    
    func configure(input: Input) -> Output {
        Output(
            route: makeRoute(
                didTapClose: input.didTapClose,
                didTapSubmit: input.didTapSubmit
            ),
            activity: activity.asDriver()
        )
    }
}

// MARK: Private
private extension JoinToCircleViewModel {
    func makeRoute(
        didTapClose: Signal<Void>,
        didTapSubmit: Signal<String>
    ) -> Driver<Route> {
        let close = didTapClose
            .map { Route.dismiss }
            .asDriver(onErrorDriveWith: .never())
        
        let joined = didTapSubmit
            .flatMapLatest { [weak self] code -> Driver<Route> in
                guard let self else {
                    return .never()
                }
                
                func source() -> Single<Route> {
                    self.circleManager
                        .join(inviteCode: code)
                        .flatMap { circle -> Single<Circle> in
                            guard let circle else {
                                return .error(ContentError(.notContent))
                            }
                            
                            return .just(circle)
                        }
                        .map { Route.toCircle($0) }
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
        
        return Driver
            .merge(close, joined)
    }
}
