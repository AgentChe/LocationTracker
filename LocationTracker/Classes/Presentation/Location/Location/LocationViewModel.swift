//
//  LocationViewModel.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 21.12.2023.
//

import RxSwift
import RxCocoa

// TODO:
// 2. обновление раз в n сек
// 3. маркер пользователя, если у него нет circle
final class LocationViewModel {
    enum Route {
        case trackInfo(MemberTrackInfo)
        case addMember(String)
        case edit(Circle)
        case delete(Circle)
        case select(Circle?)
        case createCircle
    }
    
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    private lazy var obtainCirclesActivity = RxActivityIndicator()
    private lazy var obtainTrackInfoActivity = RxActivityIndicator()
    private lazy var geocodeActivity = RxActivityIndicator()
    
    private lazy var profileManager = ProfileManager()
    private lazy var circleManager = CircleManager()
    private lazy var trackManager = TrackManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
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
        let circleActivity: Driver<Bool>
        let circleElements: Driver<[LocationCircleTableElement]>
        let membersAnnotations: Driver<[MemberAnnotation]>
        let route: Driver<Route>
        let disposable: Disposable
    }
    
    func configure(input: Input) -> Output {
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
            circleActivity: makeCircleActivity(),
            circleElements: circleElements,
            membersAnnotations: makeMembersAnnotations(trackInfo: trackInfo),
            route: makeRoute(
                didSelectElement: input.didSelectElement,
                selectedCircle: selectedCircle
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
    
    func makeMembersAnnotations(trackInfo: Driver<[MemberTrackInfo]?>) -> Driver<[MemberAnnotation]> {
        trackInfo
            .map { trackInfo -> [MemberAnnotation] in
                guard let trackInfo else {
                    return []
                }
                
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

                let isOwner = circle.owner.id == userId 
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
                    .trackActivity(self.geocodeActivity)
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
            .trackActivity(self.obtainCirclesActivity)
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeRoute(
        didSelectElement: Signal<LocationCircleTableElement>,
        selectedCircle: Driver<Circle?>
    ) -> Driver<Route> {
        didSelectElement
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
