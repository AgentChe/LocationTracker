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
    
    private lazy var historyPlacesActivity = RxActivityIndicator()
    private lazy var historyGeocodeActivity = RxActivityIndicator()
    
    private lazy var trackManager = TrackManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }()
    
    init(memberTrackInfo: MemberTrackInfo) {
        self.initialTrackInfo = BehaviorRelay(value: memberTrackInfo).asDriver()
    }
}

// MARK: Public
extension MemberViewModel {
    struct Input {
        let didRefresh: Signal<Void>
        let didBackDate: Signal<Date>
        let didNextDate: Signal<Date>
    }
    
    struct Output {
        let elements: Driver<[MemberTableElement]>
    }
    
    func configure(input: Input) -> Output {
        let trackInfo = makeTrackInfo(didRefresh: input.didRefresh)
        let geocodedLastPlace = makeGeocodedLastPlace(trackInfo: trackInfo)
        let historyDate = makeHistoryDate(
            didBackDate: input.didBackDate,
            didNextDate: input.didNextDate
        )
        let historyPlaces = makeHistoryPlaces(date: historyDate)
        let history = makeHistory(places: historyPlaces)
        let historyActivity = makeHistoryActivity()
        
        return Output(
            elements: makeElements(
                trackInfo: trackInfo,
                geocodedLastPlace: geocodedLastPlace,
                historyDate: historyDate,
                history: history,
                historyActivity: historyActivity
            )
        )
    }
}

// MARK: Private
private extension MemberViewModel {
    func makeElements(
        trackInfo: Driver<MemberTrackInfo>,
        geocodedLastPlace: Driver<GeocodeResult?>,
        historyDate: Driver<Date>,
        history: Driver<[GeocodeResult]>,
        historyActivity: Driver<Bool>
    ) -> Driver<[MemberTableElement]> {
        Driver
            .combineLatest(
                trackInfo,
                geocodedLastPlace,
                historyDate,
                history,
                historyActivity
            )
            .map { trackInfo, geocodedLastPlace, historyDate, history, historyActivity -> [MemberTableElement] in
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
                
                result.append(contentsOf: [
                    .buttons,
                    .title("Member.History".localized),
                    .date(historyDate)
                ])
                
                if historyActivity {
                    result.append(.preloader)
                } else {
                    history.forEach { geocode in
                        guard let address = geocode.address else {
                            return
                        }
                        
                        let element = MemberPlaceElement(
                            address: address,
                            updated: geocode.place.updated
                        )
                        result.append(.place(element))
                    }
                }
                
                return result
            }
    }
    
    func makeHistory(places: Driver<[Place]>) -> Driver<[GeocodeResult]> {
        places
            .flatMapLatest { [weak self] places -> Driver<[GeocodeResult]> in
                guard let self else {
                    return .never()
                }
                
                let geocode = places
                    .map { place -> Single<GeocodeResult> in
                        self.trackManager
                            .geocode(place: place)
                    }
                
                return Single
                    .zip(geocode)
                    .trackActivity(self.historyGeocodeActivity)
                    .asDriver(onErrorJustReturn: [])
            }
    }
    
    func makeHistoryPlaces(date: Driver<Date>) -> Driver<[Place]> {
        date
            .withLatestFrom(initialTrackInfo) { ($0, $1) }
            .flatMapLatest { [weak self] date, trackInfo -> Driver<[Place]> in
                guard let self else {
                    return .never()
                }
                
                let localizedDate = self.dateFormatter.string(from: date)
                
                return trackManager
                    .places(for: trackInfo.member.id, date: localizedDate)
                    .trackActivity(self.historyPlacesActivity)
                    .asDriver(onErrorJustReturn: [])
            }
            .startWith([])
    }
    
    func makeHistoryDate(
        didBackDate: Signal<Date>,
        didNextDate: Signal<Date>
    ) -> Driver<Date> {
        Signal
            .merge(
                didBackDate.map { ($0, -1) },
                didNextDate
                    .compactMap { date -> (Date, Int)? in
                        guard !Calendar.current.isDateInToday(date) else {
                            return nil
                        }
                        
                        return (date, 1)
                    }
            )
            .compactMap { date, value -> Date? in
                Calendar.current.date(byAdding: .day, value: value, to: date)
            }
            .startWith(Calendar.current.startOfDay(for: Date()))
            .asDriver(onErrorDriveWith: .never())
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
            .startWith(nil)
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
    
    func makeHistoryActivity() -> Driver<Bool> {
        Driver
            .combineLatest(historyPlacesActivity, historyGeocodeActivity)
            .map { places, geocode -> Bool in
                places || geocode
            }
    }
}
