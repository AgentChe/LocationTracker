//
//  CirclesViewModel.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 06.12.2023.
//

import RxSwift
import RxCocoa

final class CirclesViewModel {
    enum Route {
        case create, join, dismiss, details(Circle), selected(Circle)
    }
    
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    private lazy var activity = RxActivityIndicator()
    private let mode: Driver<CirclesViewController.Mode>
    
    private lazy var circleManager = CircleManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
    
    init(mode: CirclesViewController.Mode) {
        self.mode = BehaviorRelay(value: mode).asDriver()
    }
}

// MARK: Public
extension CirclesViewModel {
    struct Input {
        let didTapCreate: Signal<Void>
        let didTapJoin: Signal<Void>
        let didTapClose: Signal<Void>
        let didSelectElement: Signal<CirclesTableElement>
    }
    
    struct Output {
        let activity: Driver<Bool>
        let elements: Driver<[CirclesTableElement]>
        let route: Driver<Route>
    }
    
    func configure(input: Input) -> Output {
        let elements = makeCircles()
            .map { circles -> [CirclesTableElement] in
                circles.map { CirclesTableElement(circle: $0) }
            }
        
        return Output(
            activity: activity.asDriver(),
            elements: elements,
            route: makeRoute(
                didTapCreate: input.didTapCreate,
                didTapJoin: input.didTapJoin,
                didTapClose: input.didTapClose,
                didSelectElement: input.didSelectElement
            )
        )
    }
}

// MARK: Private
private extension CirclesViewModel {
    func makeElements(circles: Driver<[Circle]>) -> Driver<[CirclesTableElement]> {
        Driver
            .combineLatest(circles, mode)
            .map { circles, mode -> [CirclesTableElement] in
                var selectedCircle: Circle? = {
                    switch mode {
                    case .list:
                        return nil
                    case .select(let object):
                        return object
                    }
                }()
                
                return circles.map { circle -> CirclesTableElement in
                    CirclesTableElement(
                        circle: circle,
                        selected: circle.id == selectedCircle?.id
                    )
                }
            }
    }
    
    func makeCircles() -> Driver<[Circle]> {
        func source() -> Single<[Circle]> {
            circleManager
                .obtainCircles()
        }
        
        func trigger(error: Error) -> Observable<Void> {
            guard let tryAgain = self.tryAgain?(error) else {
                return .empty()
            }
            
            return tryAgain
        }
        
        return observableRetrySingle
            .retry(source: { source() },
                   trigger: { trigger(error: $0) })
            .trackActivity(activity)
            .asDriver(onErrorJustReturn: [])
    }
    
    func makeRoute(
        didTapCreate: Signal<Void>,
        didTapJoin: Signal<Void>,
        didTapClose: Signal<Void>,
        didSelectElement: Signal<CirclesTableElement>
    ) -> Driver<Route> {
        let create = didTapCreate
            .map { Route.create }
            .asDriver(onErrorDriveWith: .never())
        let join = didTapJoin
            .map { Route.join }
            .asDriver(onErrorDriveWith: .never())
        let dismiss = didTapClose
            .map { Route.dismiss }
            .asDriver(onErrorDriveWith: .never())
        let select = didSelectElement
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(mode) { ($0, $1) }
            .map { element, mode -> Route in
                switch mode {
                case .list:
                    return Route.details(element.circle)
                case .select:
                    return Route.selected(element.circle)
                }
            }
        
        return Driver
            .merge(create, join, dismiss, select)
    }
}
