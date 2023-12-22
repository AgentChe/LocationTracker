//
//  LocationViewModel.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 21.12.2023.
//

import RxSwift
import RxCocoa

final class LocationViewModel {
    deinit {
        GeoLocationManager.shared.remove(observer: self)
    }
    
    private lazy var didUpdateLocationTrigger = PublishRelay<Location>()
    
    private lazy var profileManager = ProfileManager()
    
    init() {
        GeoLocationManager.shared.add(observer: self)
    }
}

// MARK: Public
extension LocationViewModel {
    struct Input {
        let didMoveToMyCoordinate: Signal<Void>
    }
    
    struct Output {
        let moveToMyCoordinate: Driver<Location>
        let meAnnotation: Driver<MeAnnotation>
    }
    
    func configure(input: Input) -> Output {
        let myPhotoUrl = makeMyPhotoUrl()
        
        return Output(
            moveToMyCoordinate: makeMoveToMyCoordinate(didMoveToMyCoordinate: input.didMoveToMyCoordinate),
            meAnnotation: makeMeAnnotation(myPhotoUrl: myPhotoUrl)
        )
    }
}

// MARK: GeoLocationManagerDelegate
extension LocationViewModel: GeoLocationManagerDelegate {
    func geoLocationDidChange(permissionStatus: GeoLocationPermissionStatus) {}
    
    func geoLocationDidUpdate(locations: [Location]) {
        guard let location = locations.first else {
            return
        }
        
        didUpdateLocationTrigger.accept(location)
    }
}

// MARK: Private
private extension LocationViewModel {
    func makeMoveToMyCoordinate(didMoveToMyCoordinate: Signal<Void>) -> Driver<Location> {
        didMoveToMyCoordinate
            .map { GeoLocationManager.shared.location }
            .startWith(GeoLocationManager.shared.location)
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeMeAnnotation(myPhotoUrl: Driver<URL?>) -> Driver<MeAnnotation> {
        let meAnnotation = Driver
            .zip(
                myPhotoUrl
                    .asObservable()
                    .take(1)
                    .asDriver(onErrorDriveWith: .never()),
                didUpdateLocationTrigger
                    .take(1)
                    .asDriver(onErrorDriveWith: .never())
            )
            .map { url, location -> MeAnnotation in
                MeAnnotation(
                    coordinate: location.asCLLocation.coordinate,
                    photoUrl: url
                )
            }
        
        return meAnnotation
            .flatMapLatest { [weak self] meAnnotation -> Driver<MeAnnotation> in
                guard let self else {
                    return .never()
                }
                
                return Driver
                    .combineLatest(
                        myPhotoUrl
                            .startWith(meAnnotation.photoUrl),
                        self.didUpdateLocationTrigger
                            .asDriver(onErrorDriveWith: .never())
                    )
                    .scan(meAnnotation) { annotation, args -> MeAnnotation in
                        let (url, location) = args
                        
                        annotation.coordinate = location.asCLLocation.coordinate
                        annotation.photoUrl = url
                        
                        return annotation
                    }
                    .startWith(meAnnotation)
            }
    }
    
    func makeMyPhotoUrl() -> Driver<URL?> {
        let initial = profileManager
            .obtainProfile(forceUpdate: false)
            .map { $0?.photoUrl }
            .asDriver(onErrorJustReturn: nil)
        
        let updated = ProfileMediator.shared
            .didChangePhotoURL
            .map { url -> URL? in url }
            .asDriver(onErrorJustReturn: nil)
        
        return Driver
            .merge(initial, updated)
    }
}
