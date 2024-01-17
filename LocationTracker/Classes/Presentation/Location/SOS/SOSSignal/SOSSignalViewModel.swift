//
//  SOSSignalViewModel.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 17.01.2024.
//

import RxSwift
import RxCocoa

final class SOSSignalViewModel {
    enum Route {
        case dismiss
        case startTimer
        case stopTimer
        case signalSended
        case incorrectCode
        case confirmCancel
    }
    
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    private let sos: Driver<SOS>
    private lazy var activity = RxActivityIndicator()
    
    private lazy var circleManager = CircleManager()
    private lazy var profileManager = ProfileManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
    
    init(sos: SOS) {
        self.sos = BehaviorRelay(value: sos).asDriver()
    }
}

// MARK: Public
extension SOSSignalViewModel {
    struct Input {
        let didTapClose: Signal<Void>
        let didTimerTick: Signal<Void>
        let didInputCode: Signal<String>
        let didCancelSignal: Signal<Void>
    }
    
    struct Output {
        let route: Driver<Route>
        let progress: Driver<Float>
        let secondsLeft: Driver<Int>
        let activity: Driver<Bool>
    }
    
    func configure(input: Input) -> Output {
        let pin = makePIN()
        let secondsLeft = makeSecondsLeft(didTimerTick: input.didTimerTick)
        let timerComplete = makeTimerComplete(didTimerTick: input.didTimerTick)
        
        return Output(
            route: makeRoute(
                didTapClose: input.didTapClose,
                timerComplete: timerComplete,
                didInputCode: input.didInputCode,
                pin: pin,
                didCancelSignal: input.didCancelSignal
            ),
            progress: makeProgress(secondsLeft: secondsLeft),
            secondsLeft: secondsLeft,
            activity: activity.asDriver()
        )
    }
}

// MARK: Private
private extension SOSSignalViewModel {
    func makeRoute(
        didTapClose: Signal<Void>,
        timerComplete: Driver<Bool>,
        didInputCode: Signal<String>,
        pin: Driver<String>,
        didCancelSignal: Signal<Void>
    ) -> Driver<Route> {
        let dismiss = didTapClose
                .map { Route.dismiss }
                .asDriver(onErrorDriveWith: .never())
        
        let startTimer = sos
            .compactMap { $0.signal ? nil : Route.startTimer }
        
        let stopTimer = timerComplete
            .compactMap { $0 ? Route.stopTimer : nil }
            .asDriver(onErrorDriveWith: .never())
        
        let sendSignal = timerComplete
            .filter { $0 }
            .withLatestFrom(sos)
            .flatMapLatest { [weak self] sos -> Driver<Route> in
                guard let self else {
                    return .never()
                }
                
                func source() -> Single<Route> {
                    self.circleManager
                        .sendSOS(circleId: sos.circleId)
                        .map { Route.signalSended }
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
        
        let signalSended = Driver
            .merge(
                sendSignal,
                sos.compactMap { $0.signal ? .signalSended : nil }
            )
        
        let pinCorrected = didInputCode
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(pin) { ($0, $1) }
            .map { input, pin -> Bool in
                input == pin
            }
        
        let incorrectPin = pinCorrected
            .compactMap { $0 ? nil : Route.incorrectCode }
        
        let confirmCancel = pinCorrected
            .compactMap { $0 ? Route.confirmCancel : nil }
        
        let cancel = didCancelSignal
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(timerComplete)
            .withLatestFrom(sos) { ($0, $1) }
            .flatMapLatest { [weak self] args -> Driver<Route> in
                guard let self else {
                    return .never()
                }
                
                let (timerComplete, sos) = args
                
                if !timerComplete {
                    return .just(.dismiss)
                }
                
                func source() -> Single<Route> {
                    self.circleManager
                        .cancelSOS(circleId: sos.circleId)
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
                    .trackActivity(self.activity)
                    .asDriver(onErrorDriveWith: .never())
            }
            
        return Driver
            .merge(dismiss, startTimer, stopTimer, signalSended, incorrectPin, confirmCancel, cancel)
    }
    
    func makeTimerComplete(didTimerTick: Signal<Void>) -> Driver<Bool> {
        didTimerTick
            .map { 1 }
            .scan(0) { seconds, tick -> Int in
                seconds + tick
            }
            .map { $0 == 10 }
            .startWith(false)
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeProgress(secondsLeft: Driver<Int>) -> Driver<Float> {
        secondsLeft
            .map { Float($0) / 10 }
    }
    
    func makeSecondsLeft(didTimerTick: Signal<Void>) -> Driver<Int> {
        sos
            .flatMapFirst { sos -> Driver<Int> in
                didTimerTick
                    .map { 1 }
                    .scan(10) { seconds, tick -> Int in
                        seconds - tick
                    }
                    .startWith(sos.signal ? 0 : 10)
                    .asDriver(onErrorDriveWith: .never())
            }
    }
    
    func makePIN() -> Driver<String> {
        profileManager
            .obtainProfile(forceUpdate: false)
            .map { $0?.pin ?? "" }
            .asDriver(onErrorDriveWith: .never())
    }
}
