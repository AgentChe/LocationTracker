//
//  EditPlaceViewModel.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 11.01.2024.
//

import RxSwift
import RxCocoa

final class EditPlaceViewModel {
    enum Route {
        case dismiss
    }
    
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    private lazy var activity = RxActivityIndicator()
    
    private let place: Driver<Place>
    
    private lazy var trackManager = TrackManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
    
    init(place: Place) {
        self.place = BehaviorRelay(value: place).asDriver()
    }
}

// MARK: Public
extension EditPlaceViewModel {
    struct Input {
        let didDelete: Signal<Void>
    }
    
    struct Output {
        let activity: Driver<Bool>
        let address: Driver<String>
        let route: Driver<Route>
    }
    
    func configure(input: Input) -> Output {
        let geocode = makeGeocode()
        
        return Output(
            activity: activity.asDriver(),
            address: makeAddress(geocode: geocode),
            route: makeRoute(didDelete: input.didDelete)
        )
    }
}

// MARK: Private
private extension EditPlaceViewModel {
    func makeAddress(geocode: Driver<GeocodeResult>) -> Driver<String> {
        geocode
            .map { $0.address ?? "" }
    }
    
    func makeGeocode() -> Driver<GeocodeResult> {
        place
            .flatMapLatest { [weak self] place -> Driver<GeocodeResult> in
                guard let self else {
                    return .never()
                }
                
                func source() -> Single<GeocodeResult> {
                    self.trackManager
                        .geocode(place: place)
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
    
    func makeRoute(didDelete: Signal<Void>) -> Driver<Route> {
        didDelete
            .withLatestFrom(place)
            .flatMapLatest { [weak self] place -> Driver<Route> in
                guard let self else {
                    return .never()
                }
                
                func source() -> Single<Route> {
                    self.trackManager
                        .delete(placeId: place.id)
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
                    .asDriver(onErrorDriveWith: .never())
            }
    }
}
