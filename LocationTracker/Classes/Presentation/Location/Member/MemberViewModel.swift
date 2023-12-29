//
//  MemberViewModel.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 27.12.2023.
//

import RxSwift
import RxCocoa

final class MemberViewModel {
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    private let initialTrackInfo: Driver<MemberTrackInfo>
    
    private lazy var trackManager = TrackManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
    
    init(memberTrackInfo: MemberTrackInfo) {
        self.initialTrackInfo = BehaviorRelay(value: memberTrackInfo).asDriver()
    }
}

// MARK: Public
extension MemberViewModel {
    struct Input {
        let didRefresh: Signal<Void>
    }
    
    struct Output {
        let elements: Driver<[MemberTableElement]>
    }
    
    func configure(input: Input) -> Output {
        let trackInfo = makeTrackInfo(didRefresh: input.didRefresh)
        let geocodedLastPlace = makeGeocodedLastPlace(trackInfo: trackInfo)
        
        return Output(
            elements: makeElements(
                trackInfo: trackInfo,
                geocodedLastPlace: geocodedLastPlace
            )
        )
    }
}

// MARK: Private
private extension MemberViewModel {
    func makeElements(
        trackInfo: Driver<MemberTrackInfo>,
        geocodedLastPlace: Driver<GeocodeResult?>
    ) -> Driver<[MemberTableElement]> {
        Driver
            .combineLatest(
                trackInfo,
                geocodedLastPlace
            )
            .map { trackInfo, geocodedLastPlace -> [MemberTableElement] in
                var result = [MemberTableElement]()
                
                let info = MemberInfoElement(trackInfo: trackInfo)
                result.append(.info(info))
                
                if let lastPlace = geocodedLastPlace, let address = lastPlace.address {
                    let element = MemberPlaceElement(
                        address: address,
                        updated: lastPlace.place.updated,
                        withRefresh: true
                    )
                    result.append(contentsOf: [
                        .title("Member.CurrentPosition".localized),
                        .place(element)
                    ])
                }
                
                result.append(.buttons)
                
                result.append(.title("Member.History".localized))
                
                return result
            }
    }
    
    func makeGeocodedLastPlace(trackInfo: Driver<MemberTrackInfo>) -> Driver<GeocodeResult?> {
        trackInfo
            .flatMapLatest { [weak self] trackInfo -> Driver<GeocodeResult?> in
                guard let self, let place = trackInfo.lastPlace else {
                    return .just(nil)
                }
                
                return self.trackManager
                    .geocode(place: place)
                    .map { result -> GeocodeResult? in result }
                    .asDriver(onErrorJustReturn: nil)
            }
    }
    
    func makeTrackInfo(didRefresh: Signal<Void>) -> Driver<MemberTrackInfo> {
        let refresh = didRefresh
            .withLatestFrom(initialTrackInfo)
            .map { $0.member.id }
            .flatMapLatest { [weak self] memberId -> Driver<MemberTrackInfo> in
                guard let self else {
                    return .never()
                }
                
                func source() -> Single<MemberTrackInfo> {
                    self.trackManager
                        .obtainTrackInfo(for: [memberId])
                        .map { result -> MemberTrackInfo in
                            guard let trackInfo = result.first else {
                                throw ContentError(.notContent)
                            }
                            
                            return trackInfo
                        }
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
            .merge(initialTrackInfo, refresh)
    }
}
