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
        case proposeAddMember(String)
        case proposeCreateCircle
        case sos(Circle)
        case cancelSOS(SOS)
        case moveToMyCoordinate(Location)
        case paygate
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
        let didTapSOS: Signal<Void>
        let didTouchMap: Signal<Void>
    }
    
    struct Output {
        let circleActivity: Driver<Bool>
        let circleElements: Driver<[LocationCircleTableElement]>
        let membersAnnotations: Driver<[MemberAnnotation]>
        let route: Driver<Route>
        let disposable: Disposable
        let sos: Driver<Bool>
        let paidCircle: Driver<Bool>
    }
    
    func configure(input: Input) -> Output {
        let myPhoto = makeMyPhoto()
        let circles = makeCircles()
        let selectedCircle = makeSelectedCircle(
            didSelectCircle: input.didSelectCircle,
            circles: circles
        )
        let circleTrackInfo = makeTrackInfo(for: selectedCircle)
        let myTrackInfo = makeMyTrackInfo(myPhoto: myPhoto)
        let geocode = makeGeocode(trackInfo: circleTrackInfo)
        let circleElements = makeCircleElements(
            selectedCircle: selectedCircle,
            geocode: geocode
        )
        let sos = makeSos(circleTrackInfo: circleTrackInfo)
        
        return Output(
            circleActivity: makeCircleActivity(),
            circleElements: circleElements,
            membersAnnotations: makeMembersAnnotations(
                circleTrackInfo: circleTrackInfo,
                myTrackInfo: myTrackInfo
            ),
            route: makeRoute(
                didSelectElement: input.didSelectElement,
                selectedCircle: selectedCircle,
                didSelectAnnotation: input.didSelectAnnotation,
                didTapSOS: input.didTapSOS,
                sos: sos,
                didMoveToMyCoordinate: input.didMoveToMyCoordinate,
                didTouchMap: input.didTouchMap
            ),
            disposable: makeDisposable(didDeleteCircle: input.didDeleteCircle),
            sos: sos,
            paidCircle: makeCheckPaidCircle(circle: selectedCircle)
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
        case sos(SOS)
    }
    
    func makeCheckPaidCircle(circle: Driver<Circle?>) -> Driver<Bool> {
        circle
            .map { circle -> Bool in
                guard let circle else {
                    return false
                }
                
                let sessionManager = SessionManager()
                
                let isOwner = sessionManager.userId == circle.owner.id
                
                return isOwner ? !sessionManager.hasActiveSubscriptions() : false
            }
            .startWith(false)
    }
    
    func makeSos(circleTrackInfo: Driver<[MemberTrackInfo]?>) -> Driver<Bool> {
        circleTrackInfo
            .map { circleTrackInfo -> Bool in
                let userId = SessionManager().userId
                
                guard let me = circleTrackInfo?.first(where: { $0.member.id == userId })?.member else {
                    return false
                }
                
                return me.sos
            }
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
    
    func makeMyTrackInfo(myPhoto: Driver<Image?>) -> Driver<MemberTrackInfo> {
        Driver
            .combineLatest(didUpdateLocation, myPhoto)
            .map { didUpdateLocation, myPhotoUrl -> MemberTrackInfo in
                let member = Member(
                    id: SessionManager().userId,
                    name: "Location.Me".localized,
                    photo: nil,
                    roleId: nil,
                    chatId: ProfileManager().chatId,
                    sos: false
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
                    batteryLevel: Int(UIDevice.current.batteryLevel * 100)
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
                        CircleMediator.shared.didExcludedFromCircle.map { CircleAction.excluded($0) },
                        CircleMediator.shared.didSendSOS
                            .map { SOS(signal: true, circleId: $0) }
                            .map { CircleAction.sos($0) },
                        CircleMediator.shared.didCancelSOS
                            .map { SOS(signal: false, circleId: $0) }
                            .map { CircleAction.sos($0) }
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
                        case .sos(let sos):
                            return circle?.replace(sos: sos)
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
        didSelectAnnotation: Signal<MemberAnnotation>,
        didTapSOS: Signal<Void>,
        sos: Driver<Bool>,
        didMoveToMyCoordinate: Signal<Void>,
        didTouchMap: Signal<Void>
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
        
        let sos = didTapSOS
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(sos)
            .withLatestFrom(selectedCircle) { ($0, $1) }
            .map { sos, circle -> Route in
                guard let circle else {
                    return .proposeCreateCircle
                }

                if circle.members.count <= 1 {
                    return .proposeAddMember(circle.inviteCode)
                }

                if sos {
                    return .cancelSOS(SOS(
                        signal: sos,
                        circleId: circle.id
                    ))
                }

                return .sos(circle)
            }
        
        let moveToMyCoordinate = didMoveToMyCoordinate
            .map { GeoLocationManager.shared.location }
            .startWith(GeoLocationManager.shared.location)
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .never())
            .map { Route.moveToMyCoordinate($0) }
        
        let route = Driver
            .merge(selectElement, selectAnnotation, sos, moveToMyCoordinate)
        
        let result = route
            .withLatestFrom(selectedCircle) { ($0, $1) }
            .map { route, circle -> Route in
                guard let circle, !route.ignorePaygate else {
                    return route
                }
                
                let sessionManager = SessionManager()
                
                let isOwner = sessionManager.userId == circle.owner.id
                
                if isOwner {
                    let needPayment = !sessionManager.hasActiveSubscriptions()
                    return needPayment ? .paygate : route
                }
                
                return route
            }
        
        let touchMap = didTouchMap
            .withLatestFrom(selectedCircle)
            .compactMap { circle -> Route? in
                guard let circle else {
                    return nil
                }
                
                let sessionManager = SessionManager()
                
                let isOwner = sessionManager.userId == circle.owner.id
                
                if isOwner {
                    let needPayment = !sessionManager.hasActiveSubscriptions()
                    return needPayment ? .paygate : nil
                }
                
                return nil
            }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver.merge(result, touchMap)
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
    
    func makeMyPhoto() -> Driver<Image?> {
        let initial = profileManager
            .obtainProfile(forceUpdate: false)
            .map { $0?.photo }
            .asDriver(onErrorJustReturn: nil)
        
        let updated = ProfileMediator.shared
            .didChangePhoto
            .map { image -> Image? in image }
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
private extension Circle {
    func replace(excluded: [String]) -> Circle {
        Circle(
            id: id,
            name: name,
            image: image,
            inviteCode: inviteCode,
            owner: owner,
            members: members.filter { member -> Bool in
                !excluded.contains(where: { member.id == $0 })
            }
        )
    }
    
    func replace(sos: SOS) -> Circle {
        let myId = SessionManager().userId
        
        func member(_ member: Member) -> Member {
            Member(
                id: member.id,
                name: member.name,
                photo: member.photo,
                roleId: member.roleId,
                chatId: member.chatId,
                sos: member.id == myId ? sos.signal : member.sos
            )
        }
        
        return Circle(
            id: id,
            name: name,
            image: image,
            inviteCode: inviteCode,
            owner: member(owner),
            members: members.map { member($0) }
        )
    }
}

// MARK: Additional
private extension LocationViewModel.Route {
    var ignorePaygate: Bool {
        switch self {
        case .select:
            return true
        default:
            return false
        }
    }
}
