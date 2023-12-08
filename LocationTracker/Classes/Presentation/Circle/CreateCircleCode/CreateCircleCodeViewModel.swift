//
//  CreateCircleCodeViewModel.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 07.12.2023.
//

import RxSwift
import RxCocoa

final class CreateCircleCodeViewModel {
    enum Route {
        case dismiss, share(String)
    }
    
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    private lazy var activity = RxActivityIndicator()
    
    private lazy var circleManager = CircleManager()
    private lazy var profileManager = ProfileManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
    
    private let data: Driver<CreateCircleCombineData>
    
    init(data: CreateCircleCombineData) {
        self.data = BehaviorRelay(value: data).asDriver()
    }
}

// MARK: Public
extension CreateCircleCodeViewModel {
    struct Input {
        let didTapDone: Signal<Void>
        let didTapShare: Signal<Void>
    }
    
    struct Output {
        let activity: Driver<Bool>
        let route: Driver<Route>
        let inviteCode: Driver<String>
    }
    
    func configure(input: Input) -> Output {
        let inviteCode = makeInviteCode()
        
        return Output(
            activity: activity.asDriver(),
            route: makeRoute(
                didTapDone: input.didTapDone,
                didTapShare: input.didTapShare,
                code: inviteCode
            ),
            inviteCode: inviteCode
        )
    }
}

// MARK: Private
private extension CreateCircleCodeViewModel {
    func makeRoute(
        didTapDone: Signal<Void>,
        didTapShare: Signal<Void>,
        code: Driver<String>
    ) -> Driver<Route> {
        let done = didTapDone
            .map { Route.dismiss }
            .asDriver(onErrorDriveWith: .never())
        
        let share = didTapShare
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(code)
            .map { Route.share($0) }
        
        return Driver
            .merge(done, share)
    }
    
    func makeInviteCode() -> Driver<String> {
        data
            .flatMapLatest { [weak self] data -> Driver<String> in
                guard let self else {
                    return .never()
                }
                
                func photoUrl() -> Single<URL?> {
                    guard let photo = data.image?.jpegData(compressionQuality: 0.5) else {
                        return .deferred { .just(nil) }
                    }
                    
                    return self.profileManager
                        .upload(photo: photo)
                }
                
                func source() -> Single<String> {
                    photoUrl()
                        .flatMap { url -> Single<Circle?> in
                            self.circleManager
                                .create(
                                    name: data.name,
                                    photo: url?.absoluteString,
                                    roleId: data.roleId ?? ""
                                )
                        }
                        .flatMap { circle -> Single<String> in
                            guard let circle else {
                                return .error(ContentError(.notContent))
                            }
                            
                            return .just(circle.inviteCode)
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
                    .trackActivity(self.activity)
                    .asDriver(onErrorDriveWith: .never())
            }
    }
}
