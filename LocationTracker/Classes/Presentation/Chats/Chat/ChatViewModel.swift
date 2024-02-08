//
//  ChatViewModel.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 07.02.2024.
//

import RxSwift
import RxCocoa

final class ChatViewModel {
    typealias Partner = (name: String, photoURL: URL?)
    
    enum Route {
        case dismiss
    }
    
    let chatManager: ChatManager
    
    private let inputData: Driver<ChatInput>
    
    init(input: ChatInput) {
        self.chatManager = ChatManager(partnerId: input.partnerId)
        self.inputData = BehaviorRelay(value: input).asDriver()
    }
}

// MARK: Public
extension ChatViewModel {
    struct Input {
        let didTapClose: Signal<Void>
    }
    
    struct Output {
        let partner: Driver<Partner>
        let route: Driver<Route>
        let disposable: Disposable
    }
    
    func configure(input: Input) -> Output {
        Output(
            partner: makePartner(),
            route: makeRoute(didTapClose: input.didTapClose),
            disposable: makeDisposable(didTapClose: input.didTapClose)
        )
    }
}

// MARK: Private
private extension ChatViewModel {
    func makePartner() -> Driver<Partner> {
        inputData
            .map { ($0.partnerName, $0.partnerAvatarUrl) }
    }
    
    func makeRoute(didTapClose: Signal<Void>) -> Driver<Route> {
        didTapClose
            .map { Route.dismiss }
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeDisposable(didTapClose: Signal<Void>) -> Disposable {
        didTapClose
            .emit(to: Binder(self) { base, void in
                base.chatManager.disconnect()
            })
    }
}
