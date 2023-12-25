//
//  LocationViewModel.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 21.12.2023.
//

import RxSwift
import RxCocoa

final class LocationViewModel {
    enum Route {
        case trackInfo(MemberTrackInfo)
        case addMember(String)
        case edit(Circle)
        case delete(Circle)
        case select(Circle?)
        case createCircle
    }
    
    deinit {
        GeoLocationManager.shared.remove(observer: self)
    }
    
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    private lazy var activity = RxActivityIndicator()
    
    private lazy var didUpdateLocationTrigger = PublishRelay<Location>()
    
    private lazy var profileManager = ProfileManager()
    private lazy var circleManager = CircleManager()
    private lazy var trackManager = TrackManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
    
    init() {
        GeoLocationManager.shared.add(observer: self)
    }
}

// MARK: Public
extension LocationViewModel {
    struct Input {
        let didMoveToMyCoordinate: Signal<Void>
        let didSelectCircle: Signal<Circle>
        let didSelectElement: Signal<LocationCircleTableElement>
        let didDeleteCircle: Signal<Circle>
    }
    
    struct Output {
        let moveToMyCoordinate: Driver<Location>
        let meAnnotation: Driver<MeAnnotation>
        let activity: Driver<Bool>
        let circleElements: Driver<[LocationCircleTableElement]>
        let route: Driver<Route>
        let disposable: Disposable
    }
    
    func configure(input: Input) -> Output {
        let myPhotoUrl = makeMyPhotoUrl()
        let circles = makeCircles()
        let selectedCircle = makeSelectedCircle(
            didSelectCircle: input.didSelectCircle,
            circles: circles
        )
        let trackInfo = makeTrackInfo(for: selectedCircle)
        let geocoded = makeGeocode(trackInfo: trackInfo)
        let circleElements = makeCircleElements(
            selectedCircle: selectedCircle,
            geocoded: geocoded
        )
        
        return Output(
            moveToMyCoordinate: makeMoveToMyCoordinate(didMoveToMyCoordinate: input.didMoveToMyCoordinate),
            meAnnotation: makeMeAnnotation(myPhotoUrl: myPhotoUrl),
            activity: activity.asDriver(),
            circleElements: circleElements,
            route: makeRoute(
                didSelectElement: input.didSelectElement,
                selectedCircle: selectedCircle
            ),
            disposable: makeDisposable(didDeleteCircle: input.didDeleteCircle)
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
    enum CircleAction {
        case created(Circle)
        case joined(Circle)
        case edited(Circle)
        case deleted(Int)
        case excluded(CircleMediator.Excluded)
    }
    
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
    
    func makeCircleElements(
        selectedCircle: Driver<Circle?>,
        geocoded: Driver<[(MemberTrackInfo, String?)]?>
    ) -> Driver<[LocationCircleTableElement]> {
        Driver
            .combineLatest(selectedCircle, geocoded)
            .compactMap { circle, geocoded -> [LocationCircleTableElement]? in
                guard let circle, let geocoded else {
                    return [.create]
                }
                
                var result = [LocationCircleTableElement]()

                result.append(.circleName(circle.name))
                result.append(.title)

                let userId = SessionManager().userId

                geocoded.forEach { info, address in
                    let element = DetailsCircleTableMember(
                        trackInfo: info,
                        me: info.member.id == userId,
                        address: address
                    )
                    result.append(.member(element))
                }

                let isOwner = circle.owner.id != userId // TODO: != -> ==
                let actions: [DetailsCircleTableAction] = isOwner ? [.edit, .delete] : [.addMember]
                actions.forEach { result.append(.action($0)) }

                return result
            }
    }
    
    func makeGeocode(trackInfo: Driver<[MemberTrackInfo]?>) -> Driver<[(MemberTrackInfo, String?)]?> {
        trackInfo
            .flatMapLatest { [weak self] trackInfo -> Driver<[(MemberTrackInfo, String?)]?> in
                guard let self, let trackInfo else {
                    return .just(nil)
                }
                
                return Single
                    .zip(trackInfo.map { self.trackManager.geocode(trackInfo: $0) })
                    .map { result -> [(MemberTrackInfo, String?)]? in result }
                    .trackActivity(self.activity)
                    .asDriver(onErrorJustReturn: [])
            }
    }
    
    func makeTrackInfo(for circle: Driver<Circle?>) -> Driver<[MemberTrackInfo]?> {
        circle
            .flatMapLatest { [weak self] circle -> Driver<[MemberTrackInfo]?> in
                guard let self, let circle else {
                    return .just(nil)
                }
                
                func source() -> Single<[MemberTrackInfo]?> {
                    self.trackManager
                        .obtainTrackInfo(for: circle.members.map { $0.id })
                        .map { result -> [MemberTrackInfo]? in result }
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
                    .asDriver(onErrorJustReturn: [])
            }
    }
    
    func makeSelectedCircle(
        didSelectCircle: Signal<Circle>,
        circles: Driver<[Circle]>
    ) -> Driver<Circle?> {
        let initial = circles
            .map { $0.first }
        
        let selected = didSelectCircle
            .map { circle -> Circle? in circle }
            .asDriver(onErrorDriveWith: .never())
        
        let circle = Driver
            .merge(initial, selected)
        
        return Driver
            .combineLatest(circle, circles)
            .flatMapLatest { args -> Driver<Circle?> in
                let (circle, circles) = args
                
                let action = Signal<CircleAction>
                    .merge(
                        CircleMediator.shared.didCreatedCircle.map { CircleAction.created($0) },
                        CircleMediator.shared.didJoinedToCircle.map { CircleAction.joined($0) },
                        CircleMediator.shared.didEditedCircle.map { CircleAction.edited($0) },
                        CircleMediator.shared.didDeletedCircle.map { CircleAction.deleted($0) },
                        CircleMediator.shared.didExcludedFromCircle.map { CircleAction.excluded($0) }
                    )
                
                return action
                    .scan(circle) { circle, action -> Circle? in
                        switch action {
                        case .created(let object):
                            return circle ?? object
                        case .joined(let object):
                            return circle ?? object
                        case .edited(let object):
                            return circle?.id == object.id ? object : circle
                        case .deleted(let id):
                            guard circle?.id == id else {
                                return circle
                            }
                            
                            return circles.first
                        case .excluded(let object):
                            guard let circle, circle.id == object.circleId else {
                                return nil
                            }
                            
                            return circle.replace(excluded: object.membersIds)
                        }
                    }
                    .startWith(circle)
                    .distinctUntilChanged()
                    .asDriver(onErrorJustReturn: nil)
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
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeRoute(
        didSelectElement: Signal<LocationCircleTableElement>,
        selectedCircle: Driver<Circle?>
    ) -> Driver<Route> {
        Driver
            .combineLatest(
                didSelectElement.asDriver(onErrorDriveWith: .never()),
                selectedCircle
            )
            .compactMap { element, circle -> Route? in
                switch element {
                case .circleName:
                    return .select(circle)
                case .member(let memberElement):
                    return .trackInfo(memberElement.trackInfo)
                case .action(let action):
                    guard let circle else {
                        return nil
                    }
                    
                    switch action {
                    case .addMember:
                        return .addMember(circle.inviteCode)
                    case .delete:
                        return .delete(circle)
                    case .edit:
                        return .edit(circle)
                    }
                case .create:
                    return .createCircle
                default:
                    return nil
                }
            }
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeDisposable(didDeleteCircle: Signal<Circle>) -> Disposable {
        didDeleteCircle
            .asDriver(onErrorDriveWith: .never())
            .flatMapLatest { [weak self] circle -> Driver<Void> in
                guard let self else {
                    return .never()
                }
                
                func source() -> Single<Void> {
                    self.circleManager
                        .delete(id: circle.id)
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
            .drive()
    }
}

// MARK: Additional
private extension LocationViewModel.CircleAction {
    var id: Int {
        switch self {
        case .created(let circle):
            return circle.id
        case .joined(let circle):
            return circle.id
        case .edited(let circle):
            return circle.id
        case .deleted(let id):
            return id
        case .excluded(let excluded):
            return excluded.circleId
        }
    }
}

// MARK: Additional
private extension Circle {
    func replace(excluded: [String]) -> Circle {
        Circle(
            id: id,
            name: name,
            imageUrl: imageUrl,
            inviteCode: inviteCode,
            owner: owner,
            members: members.filter { member -> Bool in
                !excluded.contains(where: { member.id == $0 })
            }
        )
    }
}
