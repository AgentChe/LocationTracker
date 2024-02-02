//
//  ChatsViewModel.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 02.02.2024.
//

import RxSwift
import RxCocoa

final class ChatsViewModel {
    enum Action {
        case elements([ChatsTableElement])
        case removed(String)
        case created(ChatsTableElement)
        case changed(ChatsTableElement)
        case error(Error)
    }
    
    enum Route {
        case menu
    }
    
    private lazy var didSocketErrorTrigger = PublishRelay<Error>()
    private lazy var didChatsEventTrigger = PublishRelay<ChatsEvent>()
    
    private lazy var chatsManager = ChatsManager()
}

// MARK: Public
extension ChatsViewModel {
    struct Input {
        let didTapMenu: Signal<Void>
    }
    
    struct Output {
        let disposable: Disposable
        let action: Driver<Action>
        let route: Driver<Route>
    }
    
    func configure(input: Input) -> Output {
        chatsManager.connect()
        
        return Output(
            disposable: listenSocket(),
            action: makeAction(),
            route: makeRoute(didTapMenu: input.didTapMenu)
        )
    }
}

// MARK: Private
private extension ChatsViewModel {
    func listenSocket() -> Disposable {
        chatsManager.event
            .bind(to: Binder(self) { base, socketEvent in
                switch socketEvent {
                case .connected:
                    base.chatsManager.action(action: .getList)
                case .error(let error):
                    base.didSocketErrorTrigger.accept(error)
                case .peerClosed:
                    let error = NSError(domain: "Chats.PeerClosed".localized, code: 500)
                    base.didSocketErrorTrigger.accept(error)
                case .event(let event):
                    base.didChatsEventTrigger.accept(event)
                }
            })
    }
    
    func makeAction() -> Driver<Action> {
        let error = didSocketErrorTrigger
            .asDriver(onErrorDriveWith: .never())
            .map { Action.error($0) }
        
        let elements = didChatsEventTrigger
            .asDriver(onErrorDriveWith: .never())
            .compactMap { event -> Action? in
                let userId = SessionManager().userId
                
                switch event {
                case .list(let chats):
                    let elements = chats.compactMap { chat -> ChatsTableElement? in
                        ChatsTableElement(
                            chat: chat,
                            userId: userId
                        )
                    }
                    
                    return .elements(elements)
                case .changed(let chat):
                    guard let element = ChatsTableElement(chat: chat, userId: userId) else {
                        return nil
                    }
                    
                    return .changed(element)
                case .removed(let chatId):
                    return .removed(chatId)
                case .created(let chat):
                    guard let element = ChatsTableElement(chat: chat, userId: userId) else {
                        return nil
                    }
                    
                    return .created(element)
                }
            }
        
        return Driver
            .merge(error, elements)
    }
    
    func makeRoute(didTapMenu: Signal<Void>) -> Driver<Route> {
        didTapMenu
            .map { Route.menu }
            .asDriver(onErrorDriveWith: .never())
    }
}

// MARK: Additional
private extension ChatsEvent {
    var chats: [Chat]? {
        switch self {
        case .list(let chats):
            return chats
        default:
            return nil
        }
    }
}
