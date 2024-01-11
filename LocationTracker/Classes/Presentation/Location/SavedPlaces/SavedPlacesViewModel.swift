//
//  SavedPlacesViewModel.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 11.01.2024.
//

import RxSwift
import RxCocoa

final class SavedPlacesViewModel {
    enum Route {
        case edit(Place)
    }
    
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    private lazy var placesActivity = RxActivityIndicator()
    private lazy var geocodeActivity = RxActivityIndicator()
    
    private lazy var trackManager = TrackManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
}

// MARK: Public
extension SavedPlacesViewModel {
    struct Input {
        let didSelect: Signal<GeocodeResult>
    }
    
    struct Output {
        let elements: Driver<[GeocodeResult]>
        let activity: Driver<Bool>
        let isEmpty: Driver<Bool>
        let route: Driver<Route>
    }
    
    func configure(input: Input) -> Output {
        let places = makePlaces()
        let geocode = makeGeocode(places: places)
        let deleted = makeDeleted()
        let elements = makeElements(
            geocode: geocode,
            deleted: deleted
        )
        
        return Output(
            elements: elements,
            activity: makeActivity(),
            isEmpty: makeIsEmpty(elements: elements),
            route: makeRoute(didSelect: input.didSelect)
        )
    }
}

// MARK: Private
private extension SavedPlacesViewModel {
    func makeElements(geocode: Driver<[GeocodeResult]>, deleted: Driver<[Int]>) -> Driver<[GeocodeResult]> {
        Driver
            .combineLatest(geocode, deleted)
            .map { geocode, deleted -> [GeocodeResult] in
                geocode.filter { result -> Bool in
                    !deleted.contains(where: { $0 == result.place.id })
                }
            }
    }
    
    func makeIsEmpty(elements: Driver<[GeocodeResult]>) -> Driver<Bool> {
        elements
            .map { $0.isEmpty }
            .startWith(false)
    }
    
    func makeDeleted() -> Driver<[Int]> {
        TrackMediator.shared
            .didDeletePlace
            .scan([]) { $0 + [$1] }
            .asDriver(onErrorJustReturn: [])
            .startWith([])
    }
    
    func makeGeocode(places: Driver<[Place]>) -> Driver<[GeocodeResult]> {
        places
            .flatMapLatest { [weak self] places -> Driver<[GeocodeResult]> in
                guard let self else {
                    return .never()
                }
                
                let geocode = places
                    .map { self.trackManager.geocode(place: $0) }
                
                return Single
                    .zip(geocode)
                    .trackActivity(self.geocodeActivity)
                    .asDriver(onErrorJustReturn: [])
            }
    }
    
    func makePlaces() -> Driver<[Place]> {
        func source() -> Single<[Place]> {
            trackManager
                .savedPlaces()
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
            .trackActivity(placesActivity)
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeActivity() -> Driver<Bool> {
        Driver
            .combineLatest(placesActivity, geocodeActivity)
            .map { $0 || $1 }
    }
    
    func makeRoute(didSelect: Signal<GeocodeResult>) -> Driver<Route> {
        didSelect
            .map { Route.edit($0.place) }
            .asDriver(onErrorDriveWith: .never())
    }
}
