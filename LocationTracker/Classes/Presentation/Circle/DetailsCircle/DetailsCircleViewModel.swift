//
//  DetailsCircleViewModel.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 11.12.2023.
//

import RxSwift
import RxCocoa

final class DetailsCircleViewModel {
    enum Route {
        case dismiss, edit(Circle), delete, addMember(String)
    }
    
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    private lazy var activity = RxActivityIndicator()
    
    private let circle: Driver<Circle>
    
    private lazy var circleManager = CircleManager()
    private lazy var trackManager = TrackManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
    
    init(circle: Circle) {
        self.circle = BehaviorRelay(value: circle).asDriver()
    }
}

// MARK: Public
extension DetailsCircleViewModel {
    struct Input {
        let didTapClose: Signal<Void>
        let didSelect: Signal<DetailsCircleTableElement>
        let didDelete: Signal<Void>
    }
    
    struct Output {
        let name: Driver<String>
        let elements: Driver<[DetailsCircleTableElement]>
        let activity: Driver<Bool>
        let route: Driver<Route>
    }
    
    func configure(input: Input) -> Output {
        let trackInfo = makeTrackInfo()
        let geocoded = makeGeocode(trackInfo: trackInfo)
        
        return Output(
            name: circle.map { $0.name },
            elements: makeElements(geocoded: geocoded),
            activity: activity.asDriver(),
            route: makeRoute(
                didTapClose: input.didTapClose,
                didSelect: input.didSelect,
                didDelete: input.didDelete
            )
        )
    }
}

// MARK: Private
private extension DetailsCircleViewModel {
    func makeElements(geocoded: Driver<[(MemberTrackInfo, String?)]>) -> Driver<[DetailsCircleTableElement]> {
        Driver
            .combineLatest(circle, geocoded)
            .map { circle, trackInfo -> [DetailsCircleTableElement] in
                var result = [DetailsCircleTableElement]()
                
                result.append(.title)
                
                let userId = SessionManager().userId
                
                trackInfo.forEach { info, address in
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
    
    func makeGeocode(trackInfo: Driver<[MemberTrackInfo]>) -> Driver<[(MemberTrackInfo, String?)]> {
        trackInfo
            .flatMapLatest { [weak self] trackInfo -> Driver<[(MemberTrackInfo, String?)]> in
                guard let self else {
                    return .never()
                }
                
                return Single
                    .zip(trackInfo.map { self.trackManager.geocode(trackInfo: $0) })
                    .trackActivity(self.activity)
                    .asDriver(onErrorJustReturn: [])
            }
    }
    
    func makeTrackInfo() -> Driver<[MemberTrackInfo]> {
        circle
            .flatMapLatest { [weak self] circle -> Driver<[MemberTrackInfo]> in
                guard let self else {
                    return .never()
                }
                
                func source() -> Single<[MemberTrackInfo]> {
                    self.trackManager
                        .obtainTrackInfo(for: circle.members.map { $0.id })
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
    
    func makeRoute(
        didTapClose: Signal<Void>,
        didSelect: Signal<DetailsCircleTableElement>,
        didDelete: Signal<Void>
    ) -> Driver<Route> {
        let dismiss = didTapClose
            .asDriver(onErrorDriveWith: .never())
            .map { Route.dismiss }
        let action = didSelect
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(circle) { ($0, $1) }
            .compactMap { element, circle -> Route? in
                guard case let .action(action) = element else {
                    return nil
                }
                
                switch action {
                case .edit:
                    return .edit(circle)
                case .delete:
                    return .delete
                case .addMember:
                    return .addMember(circle.inviteCode)
                }
            }
        
        let delete = didDelete
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(circle)
            .flatMapLatest { [weak self] circle -> Driver<Route> in
                guard let self else {
                    return .never()
                }
                
                func source() -> Single<Route> {
                    self.circleManager
                        .delete(id: circle.id)
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
        
        return Driver
            .merge(dismiss, action, delete)
    }
}
