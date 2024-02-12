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
    
    enum Action {
        case error(Error)
        case page(ChatPage)
        case chatRemoved
        case newMessage(ChatMessage)
    }
    
    enum Route {
        case dismiss
    }
    
    private lazy var didSocketErrorTrigger = PublishRelay<Error>()
    private lazy var didChatEventTrigger = PublishRelay<ChatEvent>()
    
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
        let didSendMessage: Signal<String>
        let didLoadPage: Signal<Int>
    }
    
    struct Output {
        let partner: Driver<Partner>
        let action: Driver<Action>
        let route: Driver<Route>
        let disposable: Disposable
    }
    
    func configure(input: Input) -> Output {
        chatManager.connect()
        
        return Output(
            partner: makePartner(),
            action: makeAction(),
            route: makeRoute(didTapClose: input.didTapClose),
            disposable: makeDisposable(
                didTapClose: input.didTapClose,
                didSendMessage: input.didSendMessage,
                didLoadPage: input.didLoadPage
            )
        )
    }
}

// MARK: Private
private extension ChatViewModel {
    func makePartner() -> Driver<Partner> {
        inputData
            .map { ($0.partnerName, $0.partnerAvatarUrl) }
    }
    
    func makeAction() -> Driver<Action> {
        let error = didSocketErrorTrigger
            .asDriver(onErrorDriveWith: .never())
            .map { Action.error($0) }
        
        let elements = didChatEventTrigger
            .asDriver(onErrorDriveWith: .never())
            .compactMap { event -> Action? in
                switch event {
                case .list(let page):
                    return .page(page)
                case .chatRemoved:
                    return .chatRemoved
                case .newMessage(let message):
                    return .newMessage(message)
                }
            }
        
        return Driver
            .merge(error, elements)
    }
    
    func makeRoute(didTapClose: Signal<Void>) -> Driver<Route> {
        didTapClose
            .map { Route.dismiss }
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeDisposable(
        didTapClose: Signal<Void>,
        didSendMessage: Signal<String>,
        didLoadPage: Signal<Int>
    ) -> Disposable {
        let disconnect = didTapClose
            .emit(to: Binder(self) { base, void in
                base.chatManager.disconnect()
            })
        
        let listen = chatManager.event
            .bind(to: Binder(self) { base, socketEvent in
                switch socketEvent {
                case .connected:
                    base.chatManager.action(action: .getList(1))
                case .error(let error):
                    base.didSocketErrorTrigger.accept(error)
                case .peerClosed:
                    let error = NSError(domain: "Chats.PeerClosed".localized, code: 500)
                    base.didSocketErrorTrigger.accept(error)
                case .event(let event):
                    base.didChatEventTrigger.accept(event)
                }
            })
        
        let sendMessage = didSendMessage
            .emit(to: Binder(self) { base, message in
                base.chatManager.action(action: .sendMessage(message))
            })
        
        let loadPage = didLoadPage
            .emit(to: Binder(self) { base, page in
                base.chatManager.action(action: .getList(page))
            })
        
        return Disposables.create(disconnect, listen, sendMessage, loadPage)
    }
}
