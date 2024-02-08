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
        case menu(Chat)
        case chat(Chat)
    }
    
    private lazy var didSocketErrorTrigger = PublishRelay<Error>()
    private lazy var didChatsEventTrigger = PublishRelay<ChatsEvent>()
    
    private lazy var chatsManager = ChatsManager()
}

// MARK: Public
extension ChatsViewModel {
    struct Input {
        let didConnect: Signal<Void>
        let didTapMenu: Signal<Chat>
        let didDeleteChat: Signal<Chat>
        let didSelectChat: Signal<Chat>
    }
    
    struct Output {
        let disposable: Disposable
        let action: Driver<Action>
        let route: Driver<Route>
    }
    
    func configure(input: Input) -> Output {
        Output(
            disposable: listenSocket(
                didConnect: input.didConnect,
                didDeleteChat: input.didDeleteChat
            ),
            action: makeAction(),
            route: makeRoute(
                didTapMenu: input.didTapMenu,
                didSelectChat: input.didSelectChat
            )
        )
    }
}

// MARK: Private
private extension ChatsViewModel {
    func listenSocket(didConnect: Signal<Void>, didDeleteChat: Signal<Chat>) -> Disposable {
        let connect = didConnect
            .startWith(())
            .emit(to: Binder(self) { base, void in
                base.chatsManager.connect()
            })
        
        let listen = chatsManager.event
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
        
        let delete = didDeleteChat
            .emit(to: Binder(self) { base, chat in
                base.chatsManager.action(action: .remove(chat.id))
            })
        
        return Disposables.create([connect, listen, delete])
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
    
    func makeRoute(
        didTapMenu: Signal<Chat>,
        didSelectChat: Signal<Chat>
    ) -> Driver<Route> {
        let menu = didTapMenu
            .map { Route.menu($0) }
            .asDriver(onErrorDriveWith: .never())
        
        let chat = didSelectChat
            .map { Route.chat($0) }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(menu, chat)
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
