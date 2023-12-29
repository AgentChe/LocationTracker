//
//  LocationViewModel.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 21.12.2023.
//

import RxSwift
import RxCocoa

final class LocationViewModel {
    typealias TrackInfoGeocode = (trackInfo: MemberTrackInfo, result: GeocodeResult)
    
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
    
    private lazy var obtainCirclesActivity = RxActivityIndicator()
    private lazy var obtainTrackInfoActivity = RxActivityIndicator()
    private lazy var geocodeActivity = RxActivityIndicator()
    
    private lazy var didUpdateLocationTrigger = BehaviorRelay(value: GeoLocationManager.shared.location)
    private lazy var didUpdateLocation = didUpdateLocationTrigger.asDriver()
    
    private lazy var profileManager = ProfileManager()
    private lazy var circleManager = CircleManager()
    private lazy var trackManager = TrackManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
    
    init() {
        GeoLocationManager.shared.add(observer: self)
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

// MARK: Public
extension LocationViewModel {
    struct Input {
        let didMoveToMyCoordinate: Signal<Void>
        let didSelectCircle: Signal<Circle>
        let didSelectElement: Signal<LocationCircleTableElement>
        let didDeleteCircle: Signal<Circle>
        let didSelectAnnotation: Signal<MemberAnnotation>
    }
    
    struct Output {
        let moveToMyCoordinate: Driver<Location>
        let circleActivity: Driver<Bool>
        let circleElements: Driver<[LocationCircleTableElement]>
        let membersAnnotations: Driver<[MemberAnnotation]>
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
        let circleTrackInfo = makeTrackInfo(for: selectedCircle)
        let myTrackInfo = makeMyTrackInfo(myPhotoUrl: myPhotoUrl)
        let geocode = makeGeocode(trackInfo: circleTrackInfo)
        let circleElements = makeCircleElements(
            selectedCircle: selectedCircle,
            geocode: geocode
        )
        
        return Output(
            moveToMyCoordinate: makeMoveToMyCoordinate(didMoveToMyCoordinate: input.didMoveToMyCoordinate),
            circleActivity: makeCircleActivity(),
            circleElements: circleElements,
            membersAnnotations: makeMembersAnnotations(
                circleTrackInfo: circleTrackInfo,
                myTrackInfo: myTrackInfo
            ),
            route: makeRoute(
                didSelectElement: input.didSelectElement,
                selectedCircle: selectedCircle,
                didSelectAnnotation: input.didSelectAnnotation
            ),
            disposable: makeDisposable(didDeleteCircle: input.didDeleteCircle)
        )
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
    
    func makeMembersAnnotations(
        circleTrackInfo: Driver<[MemberTrackInfo]?>,
        myTrackInfo: Driver<MemberTrackInfo>
    ) -> Driver<[MemberAnnotation]> {
        Driver
            .combineLatest(circleTrackInfo, myTrackInfo)
            .map { circleTrackInfo, myTrackInfo -> [MemberTrackInfo] in
                circleTrackInfo ?? [myTrackInfo]
            }
            .map { trackInfo -> [MemberAnnotation] in
                let userId = SessionManager().userId
                
                return trackInfo.compactMap { info -> MemberAnnotation? in
                    MemberAnnotation(
                        trackInfo: info,
                        me: info.member.id == userId
                    )
                }
            }
    }
    
    func makeCircleElements(
        selectedCircle: Driver<Circle?>,
        geocode: Driver<[TrackInfoGeocode]?>
    ) -> Driver<[LocationCircleTableElement]> {
        Driver
            .combineLatest(selectedCircle, geocode)
            .compactMap { circle, geocode -> [LocationCircleTableElement]? in
                guard let circle, let geocode else {
                    return [.create]
                }
                
                var result = [LocationCircleTableElement]()

                result.append(.circleName(circle.name))
                result.append(.title)

                let userId = SessionManager().userId

                geocode.forEach { geocode in
                    let element = DetailsCircleTableMember(
                        trackInfo: geocode.trackInfo,
                        me: geocode.trackInfo.member.id == userId,
                        address: geocode.result.address
                    )
                    result.append(.member(element))
                }

                let isOwner = circle.owner.id == userId 
                let actions: [DetailsCircleTableAction] = isOwner ? [.edit, .delete] : [.addMember]
                actions.forEach { result.append(.action($0)) }

                return result
            }
    }
    
    func makeGeocode(trackInfo: Driver<[MemberTrackInfo]?>) -> Driver<[TrackInfoGeocode]?> {
        trackInfo
            .flatMapLatest { [weak self] trackInfo -> Driver<[TrackInfoGeocode]?> in
                guard let self, let trackInfo else {
                    return .just(nil)
                }
                
                let geocode = trackInfo
                    .compactMap { trackInfo -> Single<TrackInfoGeocode>? in
                        guard let place = trackInfo.lastPlace else {
                            return nil
                        }
                        
                        return self.trackManager
                            .geocode(place: place)
                            .map { (trackInfo, $0) }
                    }
                
                return Single
                    .zip(geocode)
                    .map { result -> [TrackInfoGeocode]? in result }
                    .trackActivity(self.geocodeActivity)
                    .asDriver(onErrorJustReturn: [])
            }
    }
    
    func makeMyTrackInfo(myPhotoUrl: Driver<URL?>) -> Driver<MemberTrackInfo> {
        Driver
            .combineLatest(didUpdateLocation, myPhotoUrl)
            .map { didUpdateLocation, myPhotoUrl -> MemberTrackInfo in
                let member = Member(
                    id: SessionManager().userId,
                    name: "Location.Me".localized,
                    photoUrl: nil,
                    roleId: nil
                )
                
                var place: Place? {
                    guard let location = didUpdateLocation else {
                        return nil
                    }
                    
                    return Place(
                        id: Int.random(in: Int.min...0),
                        location: location,
                        updated: Date()
                    )
                }
                
                return MemberTrackInfo(
                    member: member,
                    lastPlace: place,
                    batteryLevel: UIDevice.current.batteryLevel
                )
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
                    .trackActivity(self.obtainTrackInfoActivity)
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
            .trackActivity(obtainCirclesActivity)
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeRoute(
        didSelectElement: Signal<LocationCircleTableElement>,
        selectedCircle: Driver<Circle?>,
        didSelectAnnotation: Signal<MemberAnnotation>
    ) -> Driver<Route> {
        let selectElement = didSelectElement
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(selectedCircle) { ($0, $1) }
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
        
        let selectAnnotation = didSelectAnnotation
            .map { Route.trackInfo($0.trackInfo) }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(selectElement, selectAnnotation)
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
    
    func makeCircleActivity() -> Driver<Bool> {
        Driver
            .combineLatest(
                obtainCirclesActivity,
                obtainTrackInfoActivity,
                geocodeActivity
            )
            .map { circles, trackInfo, geocode -> Bool in
                circles || trackInfo || geocode
            }
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
